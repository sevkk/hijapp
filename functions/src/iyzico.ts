/**
 * iyzico Checkout Form entegrasyonu — Spec v2 Bolum 7/8.
 *
 * Iki HTTPS endpoint sunar:
 *   - createIyzicoCheckout (callable) — butik admin "X paketi al" diyince
 *     iyzico checkoutFormInitialize cagrilir, dönen `paymentPageUrl` admin
 *     paneline donulur. Token (`conversationId`) DB'ye pending olarak yazilir.
 *   - iyzicoCallback (HTTP) — iyzico kullanici odemeyi tamamlayinca buraya
 *     POST atar. retrieveCheckoutForm ile dogrula, basariliysa butik
 *     creditBalance'i arttir + transaction yaz.
 *
 * Konfigurasyon: Firebase Functions env vars (Spec v2: hardcode etme!)
 *   firebase functions:secrets:set IYZICO_API_KEY
 *   firebase functions:secrets:set IYZICO_SECRET
 *   firebase functions:config:set iyzico.base_url="https://sandbox-api.iyzipay.com"
 *
 * Test mode'da (IYZICO_API_KEY yoksa veya 'test' ile basliyorsa) sahte
 * checkout URL'i dondurur — UI akisi dev'de calisir.
 */

import { onCall, onRequest, HttpsError } from 'firebase-functions/v2/https';
import { defineSecret, defineString } from 'firebase-functions/params';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import Iyzipay from 'iyzipay';

const iyzicoApiKey = defineSecret('IYZICO_API_KEY');
const iyzicoSecret = defineSecret('IYZICO_SECRET');
const iyzicoBaseUrl = defineString('IYZICO_BASE_URL', {
  default: 'https://sandbox-api.iyzipay.com',
});
const callbackUrl = defineString('IYZICO_CALLBACK_URL', {
  default: '',
});

interface CreateCheckoutInput {
  packageId: string;
  credits: number;
  priceTry: number;
  buyer: {
    name: string;
    surname: string;
    email: string;
    gsmNumber?: string;
    identityNumber?: string;
    city?: string;
    country?: string;
    address?: string;
  };
}

export const createIyzicoCheckout = onCall(
  { secrets: [iyzicoApiKey, iyzicoSecret] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Giris yapmalisin');
    }
    const data = request.data as CreateCheckoutInput;
    if (!data?.packageId || !data?.credits || !data?.priceTry || !data?.buyer?.email) {
      throw new HttpsError('invalid-argument', 'Eksik paket bilgisi');
    }

    const db = getFirestore();
    const conversationId = db.collection('_').doc().id; // unique id

    // DB'ye pending checkout kaydi
    await db.collection('iyzico_checkouts').doc(conversationId).set({
      conversationId,
      uid: request.auth.uid,
      packageId: data.packageId,
      credits: data.credits,
      priceTry: data.priceTry,
      buyerEmail: data.buyer.email,
      status: 'pending',
      createdAt: FieldValue.serverTimestamp(),
    });

    // Test mode escape hatch
    const apiKey = iyzicoApiKey.value();
    if (!apiKey || apiKey.startsWith('test-stub')) {
      logger.warn('iyzico: test stub mode — gercek odeme yapilmayacak');
      return {
        conversationId,
        paymentPageUrl: `https://example.invalid/iyzico-stub?cid=${conversationId}`,
        token: 'stub-token',
        testMode: true,
      };
    }

    const client = new Iyzipay({
      apiKey,
      secretKey: iyzicoSecret.value(),
      uri: iyzicoBaseUrl.value(),
    });

    const totalStr = data.priceTry.toFixed(2);
    return await new Promise((resolve, reject) => {
      client.checkoutFormInitialize.create(
        {
          locale: 'tr',
          conversationId,
          price: totalStr,
          paidPrice: totalStr,
          currency: 'TRY',
          basketId: data.packageId,
          paymentGroup: 'PRODUCT',
          callbackUrl: callbackUrl.value(),
          enabledInstallments: [1, 2, 3, 6],
          buyer: {
            id: request.auth!.uid,
            name: data.buyer.name,
            surname: data.buyer.surname,
            gsmNumber: data.buyer.gsmNumber ?? '+905300000000',
            email: data.buyer.email,
            identityNumber: data.buyer.identityNumber ?? '11111111111',
            registrationAddress: data.buyer.address ?? 'Belirsiz',
            ip: request.rawRequest.ip ?? '127.0.0.1',
            city: data.buyer.city ?? 'Istanbul',
            country: data.buyer.country ?? 'Turkey',
          },
          shippingAddress: {
            contactName: `${data.buyer.name} ${data.buyer.surname}`,
            city: data.buyer.city ?? 'Istanbul',
            country: data.buyer.country ?? 'Turkey',
            address: data.buyer.address ?? 'Belirsiz',
          },
          billingAddress: {
            contactName: `${data.buyer.name} ${data.buyer.surname}`,
            city: data.buyer.city ?? 'Istanbul',
            country: data.buyer.country ?? 'Turkey',
            address: data.buyer.address ?? 'Belirsiz',
          },
          basketItems: [
            {
              id: data.packageId,
              name: `${data.credits} HIJAPP Kredi`,
              category1: 'Dijital Urun',
              itemType: 'VIRTUAL',
              price: totalStr,
            },
          ],
        },
        (err: unknown, raw: unknown) => {
          const result = raw as { status?: string; paymentPageUrl?: string; token?: string };
          if (err) {
            logger.error('iyzico initialize error', err);
            reject(new HttpsError('internal', 'iyzico hatasi'));
            return;
          }
          if (result.status !== 'success' || !result.paymentPageUrl) {
            logger.error('iyzico non-success', result);
            reject(new HttpsError('internal', 'iyzico basarisiz'));
            return;
          }
          resolve({
            conversationId,
            paymentPageUrl: result.paymentPageUrl,
            token: result.token,
            testMode: false,
          });
        },
      );
    });
  },
);

/**
 * iyzico callback (POST x-www-form-urlencoded with `token`).
 * retrieveCheckoutForm ile validate eder, basariliysa butik bakiyesini arttirir.
 */
export const iyzicoCallback = onRequest(
  { secrets: [iyzicoApiKey, iyzicoSecret] },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).send('method not allowed');
      return;
    }
    const token = (req.body?.token as string | undefined) ?? '';
    if (!token) {
      res.status(400).send('token required');
      return;
    }

    const apiKey = iyzicoApiKey.value();
    if (!apiKey || apiKey.startsWith('test-stub')) {
      logger.warn('iyzicoCallback: test stub — bakiye guncellenmedi');
      res.status(200).send('test-stub ok');
      return;
    }

    const client = new Iyzipay({
      apiKey,
      secretKey: iyzicoSecret.value(),
      uri: iyzicoBaseUrl.value(),
    });

    const result = await new Promise<{
      status?: string;
      paymentStatus?: string;
      conversationId?: string;
      paidPrice?: string;
    }>((resolve, reject) => {
      client.checkoutForm.retrieve({ token, locale: 'tr' }, (err: unknown, r: unknown) => {
        if (err) reject(err);
        else resolve(r as { status?: string; paymentStatus?: string; conversationId?: string; paidPrice?: string });
      });
    });

    if (result.status !== 'success' || result.paymentStatus !== 'SUCCESS') {
      logger.warn('iyzicoCallback: payment failed', result);
      res.redirect(302, '/billing?status=failed');
      return;
    }

    const db = getFirestore();
    const conv = result.conversationId!;
    const docRef = db.collection('iyzico_checkouts').doc(conv);
    await db.runTransaction(async (tx) => {
      const doc = await tx.get(docRef);
      if (!doc.exists) throw new Error('checkout not found');
      const d = doc.data()!;
      if (d.status === 'completed') return; // idempotent

      tx.update(docRef, {
        status: 'completed',
        paidPrice: result.paidPrice,
        completedAt: FieldValue.serverTimestamp(),
      });

      // Butik dokumanini bulup creditBalance + totalCreditsPurchased arttir.
      const boutiqueQ = await db
        .collection('boutiques')
        .where('email', '==', d.buyerEmail)
        .limit(1)
        .get();
      if (!boutiqueQ.empty) {
        tx.update(boutiqueQ.docs[0].ref, {
          creditBalance: FieldValue.increment(d.credits),
          totalCreditsPurchased: FieldValue.increment(d.credits),
          updatedAt: FieldValue.serverTimestamp(),
        });
      }

      // Transaction log
      const txRef = db.collection('transactions').doc();
      tx.set(txRef, {
        type: 'boutique_purchase',
        boutiqueEmail: d.buyerEmail,
        packageId: d.packageId,
        amount: d.credits,
        priceTry: d.priceTry,
        paymentProvider: 'iyzico',
        providerTxId: token,
        status: 'completed',
        createdAt: FieldValue.serverTimestamp(),
      });
    });

    res.redirect(302, '/billing?status=ok');
  },
);
