/**
 * HIJAPP Cloud Functions — Spec v2 Bolum 7.
 *
 * - onTryOnComplete   : try_on_events koleksiyonuna yeni dokuman gelince
 *                       last30DaysCount rolling counter'larini gunceller
 *                       (event-time bucketing yerine sade increment + nightly cron'da reset)
 * - onCodeRedeem      : transactions/{txId} 'referral_redeem' tipinde olunca
 *                       butik bakiyesini dusur, user'a kredi yukle, telemetri kaydet
 *                       (mobil tarafi bunu zaten transaction icinde yapiyor; bu function
 *                        idempotency / yeniden sayim ve butik bakiyesi rezervasyonu icin
 *                        ek bir guvenlik agi)
 * - weeklyBoutiqueReport : Cloud Scheduler ile pazartesi 09:00 TR — son 7 gunluk
 *                          butik ozet email'i (haftalik rapor aboneliklerine gore)
 */

import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue, Timestamp } from 'firebase-admin/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { logger } from 'firebase-functions/v2';

initializeApp();
const db = getFirestore();

// Spec v2 Adim 8 — iyzico checkout entegrasyonu
export { createIyzicoCheckout, iyzicoCallback } from './iyzico.js';

/**
 * Spec 3.3 / 7: Yeni try_on_event uretildiginde butik & urun counter'larini
 * gunceller. Mobile zaten basarili event'lerde sayaclari arttiriyor; bu function
 * ek olarak `last30DaysCount` yaklasik degerini guncel tutar.
 *
 * Strateji: increment et, sonra nightly cron `recalcLast30Days` ile gercek deger
 * uzerine yaz (drift'i sifirla).
 */
export const onTryOnComplete = onDocumentCreated(
  'try_on_events/{eventId}',
  async (event) => {
    const data = event.data?.data();
    if (!data) return;
    const succeeded = data.succeeded === true;
    if (!succeeded) return;

    const productId = data.productId as string | undefined;
    const boutiqueId = data.boutiqueId as string | undefined;
    if (!productId && !boutiqueId) return;

    const batch = db.batch();
    if (productId) {
      batch.set(
        db.collection('boutique_products').doc(productId),
        {
          last30DaysCount: FieldValue.increment(1),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }
    if (boutiqueId) {
      batch.set(
        db.collection('boutiques').doc(boutiqueId),
        {
          last30DaysTryOns: FieldValue.increment(1),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }
    await batch.commit();
    logger.info('onTryOnComplete: counters incremented', {
      eventId: event.params.eventId,
      productId,
      boutiqueId,
    });
  },
);

/**
 * Spec 7: Kod kullanildigi anda transactions/{txId} 'referral_redeem'
 * yaziliyor. Mobil tarafi user'a krediyi zaten yukluyor; biz burada
 *   1. butik creditBalance dususunu garanti altina aliriz (idempotent)
 *   2. referral_codes/{id}.totalCreditsGranted ve redeemedByUsers'i tutariz
 */
export const onCodeRedeem = onDocumentCreated(
  'transactions/{txId}',
  async (event) => {
    const data = event.data?.data();
    if (!data || data.type !== 'referral_redeem') return;

    const boutiqueId = data.boutiqueId as string | undefined;
    const userId = data.userId as string | undefined;
    const referralCode = data.referralCode as string | undefined;
    const amount = (data.amount as number | undefined) ?? 0;
    if (!boutiqueId || !userId || !referralCode || amount <= 0) return;

    // Bu function tek seferlik run garantisi vermez (en az bir kere). Bu yuzden
    // butik bakiyesini dusurmek icin ayri bir 'reservation' belgesi kullan.
    const reservationRef = db
      .collection('boutiques')
      .doc(boutiqueId)
      .collection('credit_reservations')
      .doc(event.params.txId);

    await db.runTransaction(async (tx) => {
      const existing = await tx.get(reservationRef);
      if (existing.exists) {
        logger.info('onCodeRedeem: already processed', { txId: event.params.txId });
        return;
      }

      tx.set(reservationRef, {
        amount,
        userId,
        referralCode,
        createdAt: FieldValue.serverTimestamp(),
      });

      tx.update(db.collection('boutiques').doc(boutiqueId), {
        creditBalance: FieldValue.increment(-amount),
        totalCreditsDistributed: FieldValue.increment(amount),
        updatedAt: FieldValue.serverTimestamp(),
      });

      // Code-level analytics
      const codeQuery = await db
        .collection('referral_codes')
        .where('code', '==', referralCode)
        .limit(1)
        .get();
      if (!codeQuery.empty) {
        tx.update(codeQuery.docs[0].ref, {
          totalCreditsGranted: FieldValue.increment(amount),
          redeemedByUsers: FieldValue.arrayUnion(userId),
          updatedAt: FieldValue.serverTimestamp(),
        });
      }
    });

    logger.info('onCodeRedeem: reservation recorded', {
      txId: event.params.txId,
      boutiqueId,
      amount,
    });
  },
);

/**
 * Spec 7: Pazartesi 09:00 TR (06:00 UTC) — haftalik butik ozet email'i.
 *
 * Email gonderimi placeholder; gercek SMTP/SendGrid entegrasyonu Adim 8/9'da
 * eklenir. Bu function su an ozet bilgileri 'boutique_weekly_reports' koleksiyonuna
 * yaziyor — email worker'i bu koleksiyondan tuketmeli.
 */
export const weeklyBoutiqueReport = onSchedule(
  {
    schedule: '0 6 * * 1', // every Monday 06:00 UTC (~09:00 Europe/Istanbul)
    timeZone: 'Europe/Istanbul',
  },
  async () => {
    const boutiques = await db
      .collection('boutiques')
      .where('isActive', '==', true)
      .where('weeklyReportEnabled', '==', true)
      .get();

    const since = Timestamp.fromMillis(Date.now() - 7 * 24 * 60 * 60 * 1000);

    for (const b of boutiques.docs) {
      const events = await db
        .collection('try_on_events')
        .where('boutiqueId', '==', b.id)
        .where('timestamp', '>=', since)
        .get();

      const total = events.size;
      const success = events.docs.filter((d) => d.data().succeeded === true).length;
      const failed = total - success;

      const perProduct: Record<string, number> = {};
      for (const doc of events.docs) {
        const pid = (doc.data().productId as string) || '';
        if (!pid) continue;
        perProduct[pid] = (perProduct[pid] ?? 0) + 1;
      }
      const top = Object.entries(perProduct)
        .sort((a, b2) => b2[1] - a[1])
        .slice(0, 5);

      await db.collection('boutique_weekly_reports').add({
        boutiqueId: b.id,
        email: b.data().email,
        weekStart: since,
        weekEnd: FieldValue.serverTimestamp(),
        totalTryOns: total,
        successCount: success,
        failedCount: failed,
        topProducts: top.map(([pid, count]) => ({ productId: pid, count })),
        sent: false,
        createdAt: FieldValue.serverTimestamp(),
      });
    }

    logger.info('weeklyBoutiqueReport: queued', { count: boutiques.size });
  },
);
