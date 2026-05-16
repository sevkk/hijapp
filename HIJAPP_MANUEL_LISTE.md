# HIJAPP — Şevk'in Manuel Yapacakları

> Bu işler AI'ya yaptırılamaz. Çoğu hesap açma, doğrulama ve karar verme.
> Sıralı listelendi — yukarıdan aşağı git, üsttekiler altakileri açar.

---

## A. Hemen — Bu Hafta

### A.1 Git temizliği (1 saat)
2 ayın işi commit'lenmemiş halde duruyor. Claude Code'a "git temizliği yap"
de ama önce sen kendin `git status` ile bak, içinde olmaması gereken bir
şey (`.env`, gerçek API key, kişisel test fotoğrafı) varsa elle çıkar.
**Yedek al** ondan sonra commit'le.

### A.2 Replicate API kredi bakiyesi
- replicate.com → hesabına gir → Billing
- En az **$10** yükle (test için $20 daha rahat)
- API token'ı `.env` ya da Firebase Remote Config'e koy, koda **kesinlikle** hardcode etme
- Mevcut token kullanılmış mı kontrol et — Mart'tan beri kullanılmamış olabilir, expired mi diye dene

### A.3 Firebase Console kontrolü
- console.firebase.google.com → `hijapp-prod` (ya da var olan adıyla) projesine gir
- Doğrula:
  - [ ] Authentication enable mi (Email/Password)
  - [ ] Firestore enable mi (production mode)
  - [ ] Storage enable mi
  - [ ] Billing plan **Blaze (pay-as-you-go)** mı — Cloud Functions için şart
  - [ ] Cloud Functions enable mi
- Firestore'da şu indeksleri elle oluşturman gerekecek (Console → Firestore → Indexes):
  - `try_on_events`: `boutiqueId ASC + timestamp DESC`
  - `try_on_events`: `productId ASC + timestamp DESC`
  - `try_on_events`: `referralCodeId ASC + timestamp DESC`
  - `boutiques/{id}/products`: `category ASC + sortOrder ASC`
  - `boutiques/{id}/codes`: `isActive ASC + createdAt DESC`

### A.4 Stitch / AI Studio export temizliği
`ai_studio_export/` ve `STITCH_PROMPTS.md` artık spec'le güncelliğini yitirdi.
Karar: ya bunları arşivle (`docs/archive/`), ya da sil. Yeni paletle uyumsuzlar.

---

## B. Kısa Vade — 1-2 Hafta

### B.1 Apple Developer hesabı ($99/yıl)
- developer.apple.com → enroll
- iOS yayını için zorunlu. In-app purchase için de zorunlu.
- Verification gelene kadar 24-48 saat sürebilir
- Şirket olarak vs şahıs olarak: butik B2B modelinde **şirket hesabı** öneriyorum
  (Şahıs Şirketi DUNS numarası şartı çıkabilir, hazırlıklı ol)

### B.2 Google Play Console ($25 tek seferlik)
- play.google.com/console → register
- Banka hesabı ekle (B2C kredi satışı için)

### B.3 iyzico Merchant hesabı (TR butikleri için)
- iyzico.com → "İş ortağı ol"
- Şirket bilgileri + vergi levhası gerekecek
- Onboarding sırasında "marketplace değiliz, kendi ürünümüzü satıyoruz" de
  (yoksa marketplace anlaşması istiyorlar)
- API key + secret'ı Firebase Functions config'e koy

### B.4 Stripe hesabı (opsiyonel — uluslararası butikler için)
- stripe.com → register
- TR yerleşik şirket Stripe Atlas / Türkiye Stripe ile kurulabilir
- Şimdilik şart değil, ilk uluslararası butik geldiğinde aç

### B.5 İlk butik ortağı
Bu projeyi öldüren ya da yaşatan an. Spec yazılır, kod yazılır ama gerçek butikle
test edilmeyen sistem işe yaramaz.

Senin yapman gerekenler:
- 3-5 hedef butik belirle (büyüklük: orta segment, sosyal medya aktif olanlar
  — Modanisa fazla büyük, Etsy'deki tek kişilik butikler fazla küçük; arada bir yer)
- Birine doğrudan ulaş — Instagram DM yerine **mağazaya gidip yüz yüze** sun
  (B2B SaaS satışında soğuk DM dönüşümü %0.5)
- Pilot teklif: **3 ay ücretsiz** + 1000 ücretsiz kredi karşılığında feedback
- "MVP'yi test edeceğim, geri bildirimine ihtiyacım var" çerçevesi >
  "ürünümü satıyorum"
- Geri bildirim toplama yöntemi: haftalık 30 dk Zoom + 1 sayfa anket

### B.6 KVKK Aydınlatma Metni + Açık Rıza
- TR'de mecburi. Avukat yardımı (300-800 TL) ya da hazır template:
  - Verbis kaydı (eğer butikler hesap açıp veri girecekse)
  - Aydınlatma metni
  - Çerez politikası (web admin paneli için)
- Mevcut `privacy_policy.html` muhtemelen yetersiz — gözden geçir

### B.7 Marka tescili (opsiyonel ama yapsan iyi olur)
- "HIJAPP" ismi için TPMK'da tescil sorgula (4-5 hafta + ~1000 TL)
- Daha sonra bir başkası benzer isimle tescil ederse rebrand çile olur

---

## C. Orta Vade — 1 Ay+

### C.1 Mağaza listeleri (App Store + Play Store)
- 3-5 uygulama içi screenshot (yeni paletle, 6.7" iPhone + Android dimensions)
- 30 saniyelik tanıtım videosu (opsiyonel ama dönüşümü 2x artırır)
- Açıklama metni (TR + EN)
- Kategori: Lifestyle veya Beauty
- Yaş sınırı: 4+

### C.2 İçerik hazırlığı — Demo butik
İlk gerçek butik bağlanana kadar uygulamada **demo butik** durmalı:
- "HIJAPP Demo" adında dummy butik oluştur
- 12-15 ücretsiz stok görseli (Unsplash'tan modest fashion hijab) yükle
- Anonim kullanıcılar bunu görüp deneyebilsin
- İlk gerçek butik geldiğinde demo'yu gizle

### C.3 Domain ve email
- hijapp.com (ya da hijapp.app) al
- Google Workspace ya da Zoho kur (info@, butik@, destek@)
- Admin paneli Firebase Hosting'e deploy: `admin.hijapp.com` subdomain'i ile

### C.4 Onboarding email akışı
Butik admin paneline ilk girişte:
- Hoş geldin email'i
- Vitrin yükleme rehberi (PDF)
- Kod oluşturma örnek senaryosu
- Haftalık otomatik rapor (Cloud Function ile gönder)

---

## D. Sürekli — Operasyonel

### D.1 Replicate maliyet takibi
Her try-on $0.01 maliyet. Aylık fatura nedir gözünden kaçırma. Eğer butikler
toplu pakette aldıkları krediyi hızla tüketiyorsa **fiyatlandırmayı revize et**.

### D.2 Butik feedback toplama
İlk butik ortağı geldikten sonra her hafta:
- Hangi feature'ı kullandılar / kullanmadılar
- Hangi kullanıcılar gerçekten try-on yaptı vs sadece açtı kapadı
- Butiğin müşterileri kod kullandıktan sonra mağazaya geldi mi (dış metrik —
  butiğe sor)

### D.3 Replicate model takibi
`prunaai/p-image-edit` an itibarıyla kullandığın model. Yeni başörtüsü-spesifik
modeller çıktıkça test et. Mock mode'da A/B testi yap, kalite artışı varsa
geç. Maliyet/kalite oranı önemli.

---

## E. Karar Bekleyen Şeyler — ✅ ÇÖZÜLDÜ (16 Mayıs 2026)

- ✅ **Outbound link:** Var ama göze batmaz (küçük link)
- ✅ **Onboarding:** Onaylı — Şevk elle onaylar
- ✅ **Tüketici paket:** 10 deneme = ₺49, 50 deneme = ₺169
- ✅ **Butik kredi birim:** Hedef ₺1.00/kredi, hacim indirimleri spec'in 6.6'sında

Karar dışı kalan: **white-label**. Şimdilik mimari `boutiqueId`-merkezli yapıldığı için
ileride SDK çıkarmak kolay olacak, ayrı bir kararla erteliyoruz.

---

## Özet — Bu Hafta İçin 3 Şey

1. **Replicate'e kredi yükle + token kontrolü** (15 dakika)
2. **Firebase Console'da indeksleri ve Blaze plan'ı doğrula** (30 dakika)
3. **3 hedef butik listesi çıkar + birine ulaş** (2-3 saat — yaptığın anda projenin gerçek olmasına başlar)
