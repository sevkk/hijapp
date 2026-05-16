# HIJAPP — Spec v2 (B2B-Öncelikli)

> Bu döküman, Claude Code'a verilebilecek formatta yazıldı. Mevcut kod tabanında devam ederken
> bu spec'i referans al, eksik bölümleri implement et.

---

## 0. Karar Özeti (16 Mayıs 2026 — Şevk onayladı)

| Karar | Sonuç |
|-------|-------|
| Outbound link | **Var ama göze batmaz** — ürün detayında küçük "Butik sitesini ziyaret et ↗" linki, ana CTA değil |
| Butik onboarding | **Onaylı** — Şevk manuel onaylar, self-serve değil. UI'da sadece "Butik ortağı olmak için iletişim" linki |
| Tüketici paket | **10 deneme = ₺49** (başlangıç). 50 deneme = ₺169 (en popüler) |
| Butik fiyatlandırması (revize edildi) | **Starter 50 kr ₺599, Growth 100 kr ₺1.000, Pro 500 kr ₺4.490, Premium 2000 kr ₺16.990, Enterprise 10000 kr ₺79.990.** Detay Bölüm 6.6'da |
| Tüketici-butik fiyat çelişkisi | **Bilinçli kabul edildi** — butik müşteriye kodu bedava verir, çelişki müşteri gözünde sorun değil. Butik kanalı pazarlama, fiyat duyarlılığı tüketiciden farklı |
| Hedef butik segmenti | **Karma** — küçük (Starter)/orta (Growth)/büyük (Pro+) butikler hepsi kapsamda |

---

## 1. Stratejik Bağlam

**Birincil müşteri:** Başörtüsü butikleri (B2B).
**İkincil müşteri:** Tüketici son kullanıcı (B2C — küçük gelir kalemi).

Butik şunları yapar:
- Aylık/yıllık olarak kredi paketi satın alır
- Bu kredilerden bir kısmını referans kodu olarak müşterilerine dağıtır
- Kendi ürünlerinin (eşarp, şal, hijap modeli) görsellerini uygulamanın "vitrin"ine yükler
- Hangi ürününün ne kadar denendiğini analitik panelinden takip eder

Butik şunları YAPMAZ:
- Uygulama üzerinden ürün satışı (e-ticaret yok)
- Sipariş yönetimi, kargo, ödeme tahsilatı

Tüketici şunları yapar:
- Anonim ya da hesaplı kullanır
- Günlük ücretsiz limit (5/gün) veya kredi bazlı kullanır
- Butik kodu girerek ekstra kredi kazanır
- İsterse kendi kendine kredi paketi satın alır
- Butik vitrinindeki ürünleri kendi fotoğrafında dener
- Sonucu kaydeder/paylaşır (uygulama dışında butiğe ulaşmak istemesi olası — outbound link bırakılabilir ama ödeme uygulama içinde olmaz)

---

## 2. Marka Sistemi — "Saray"

### 2.1 Renk Paleti

| Token | Hex | Kullanım |
|-------|-----|----------|
| `primary` | `#4B1528` | Birincil aksiyon, marka rengi, koyu yüzeyler |
| `primaryLight` | `#72243E` | Hover, secondary primary, vurgular |
| `cream` | `#F8F2E8` | Ana arka plan |
| `creamSoft` | `#FBF6EE` | Kart arka plan, soft accent yüzeyler |
| `gold` | `#B8895E` | Premium vurgu, üst seviye CTA, ayraç çizgi |
| `goldLight` | `#FAC775` | Bordo üzerinde altın metin (kontrast için) |
| `sage` | `#8FA68A` | Başarı, soft secondary action |
| `inkBlack` | `#2A1F25` | Birincil metin (saf siyah yerine) |
| `inkMuted` | `#6B5A60` | İkincil metin, hint, label |
| `border` | `#E8DDD0` | Kart kenarı, ayraç (0.5px) |

### 2.2 Tipografi

- **Başlık:** Playfair Display (Google Fonts) — `font-weight: 500`
  - H1 24sp, H2 20sp, H3 17sp
- **Gövde:** Inter (Google Fonts) — `font-weight: 400/500`
  - Body 14sp, Caption 12sp, Label 11sp (caps, letter-spacing: 0.3)
- **Sayı/Mono:** rakam tablolarında SF Mono / JetBrains Mono — yalnız analitikte

Flutter için: `google_fonts` paketi ekle. `pubspec.yaml`'da
`google_fonts: ^6.x` ve `lib/app/theme.dart`'ta `TextTheme`'i bunlarla kur.

### 2.3 Tasarım Dili

- **Köşeler:** 8px (input, küçük kartlar) / 12px (büyük kart) / 14-18px (telefonun
  içindeki büyük yüzeyler). Pill ve rozetler hariç çok büyük radius kullanma.
- **Gölge:** Yok. Yüzey ayrımı için 0.5px `border` ve yumuşak iç dolgu kullan.
- **Vurgu:** Premium hissi için `gold` border-top ya da 1-2px gold ince çizgi.
  Glow, shadow, neon yasak.
- **Boşluk:** 16-24px iç padding standardı, kartlar arası 12px.
- **Görseller:** Modest fashion görsel ağırlıklı. Placeholder kullanırken bordo /
  altın / krem ile tutarlı blok renkler kullan.

---

## 3. Veri Modeli Düzeltmeleri

### 3.1 BoutiqueProductModel — Sadeleştirme

`lib/core/models/boutique_product_model.dart` içinde:

**Çıkar:**
- `price` (String?) — uygulamada satış yok, kafa karıştırıcı
- `purchaseUrl` (String?) — opsiyonel: butiğin kendi sitesine outbound link
  olarak tutulabilir ama ismi `boutiqueWebsiteUrl` olarak değiştirilmeli ve
  zorunlu değil bir "Mağazaya git" linki olarak konumlandırılmalı

**Ekle:**
```dart
final int tryOnCount;     // toplam deneme sayısı, Firestore counter
final int last30DaysCount; // batch cron ile güncellenir, dashboard'da gösterilir
final String category;    // 'sal', 'esarp', 'hijap', 'tunik' vb. — filtre için
```

`fromFirestore` ve `toFirestore` metodlarını da güncelle.

### 3.2 Yeni Koleksiyon: `try_on_events`

Her başarılı try-on bir event olarak loglanır. Analitiğin esnek versiyonu.

```
try_on_events/{eventId}
  - boutiqueId: String
  - productId: String
  - userId: String? (anonim olabilir)
  - userType: 'free' | 'paid' | 'referral'
  - referralCodeId: String? (kod ile gelmişse)
  - timestamp: Timestamp
  - replicateModel: String
  - succeeded: bool
  - costUsd: number (Replicate maliyeti, kâr/zarar takibi için)
```

İndeksler:
- `boutiqueId + timestamp DESC` (butik dashboard zaman serisi)
- `productId + timestamp DESC` (ürün bazlı trend)
- `referralCodeId + timestamp DESC` (kod performansı)

### 3.3 BoutiqueProductModel'e Counter Akışı

Her başarılı try-on'da iki yazma:
1. `try_on_events` koleksiyonuna yeni doküman ekle
2. `boutique_products/{productId}` dokümanında `tryOnCount` için
   `FieldValue.increment(1)`

Cloud Function (`onTryOnComplete`):
- 30 günlük rolling count'u günlük cron ile günceller (`last30DaysCount`)
- İsterse butik için günlük/haftalık özet doküman üretir

### 3.4 BoutiqueModel — Ek Alanlar

```dart
final int totalTryOns;        // tüm zamanlar
final int last30DaysTryOns;   // dashboard üstü
final String? customDomain;   // ileride white-label için (şimdilik nullable)
final List<String> productCategories; // butiğin ürün kategorileri
final String plan; // 'starter' | 'pro' | 'enterprise' — gelecek için
```

### 3.5 ReferralCodeModel — Ek Alanlar

```dart
final int totalCreditsGranted;    // bu koddan toplam ne kadar kredi dağıtıldı
final List<String> redeemedByUsers; // hangi user'lar kullandı (sınırsız kodda boş)
final String? campaignTag;        // 'instagram', 'mağaza-içi', 'newsletter' vb.
```

`campaignTag`, butiğin "hangi kanaldan gelen kod daha çok dönüyor" görmesi için.

---

## 4. Firestore Şeması (Özet)

```
users/{uid}
  email, displayName, photoUrl
  credits: int
  redeemedCodes: List<String>
  totalTryOns: int
  createdAt, lastSeenAt

boutiques/{boutiqueId}
  name, email, phone, logoUrl, instagramHandle, websiteUrl
  creditBalance, totalCreditsPurchased, totalCreditsDistributed
  totalTryOns, last30DaysTryOns
  productCategories: List<String>
  plan: 'starter'|'pro'|'enterprise'
  isActive, createdAt, updatedAt

boutiques/{boutiqueId}/products/{productId}
  name, imageUrl, description, category, sortOrder
  tryOnCount, last30DaysCount
  boutiqueWebsiteUrl (opsiyonel outbound)
  isActive, createdAt, updatedAt

boutiques/{boutiqueId}/codes/{codeId}
  code (unique), creditsPerRedemption
  maxRedemptions, currentRedemptions
  totalCreditsGranted
  campaignTag, expiresAt
  isActive, createdAt, updatedAt

try_on_events/{eventId}
  boutiqueId, productId, userId, userType
  referralCodeId, timestamp, replicateModel
  succeeded, costUsd

transactions/{txId}
  type: 'credit_purchase'|'credit_grant'|'try_on_use'|'boutique_purchase'
  userId | boutiqueId
  amount (kredi), priceUsd (varsa)
  paymentProvider, providerTxId
  timestamp, status
```

### Security Rules ana mantığı

- `users/{uid}` → sadece sahibi okur/yazar (`credits` alanı yalnız Cloud Function üzerinden değişir)
- `boutiques/{boutiqueId}` → sadece o butiğin admin email'leri okur/yazar (custom claim ile)
- `boutiques/{id}/products/*` → public read, butik admin yazar
- `boutiques/{id}/codes/*` → public read sadece `code` ile sorgu (validate için), butik admin yazar
- `try_on_events/*` → kullanıcı sadece kendi event'ini yazar, butik admin sadece okur (kendi
  butiğininkini), kimse update/delete yapamaz
- `transactions/*` → yalnız Cloud Function yazar; ilgili user/butik okur

---

## 5. Tüketici Uygulaması — Tema Migrasyonu

### 5.1 `lib/app/theme.dart` Yeniden Yaz

Eski magenta/teal/tan/peach/brown paletini sil. Yeni paleti `AppColors` adında
bir sınıfa koy:

```dart
class AppColors {
  static const Color primary = Color(0xFF4B1528);
  static const Color primaryLight = Color(0xFF72243E);
  static const Color cream = Color(0xFFF8F2E8);
  static const Color creamSoft = Color(0xFFFBF6EE);
  static const Color gold = Color(0xFFB8895E);
  static const Color goldLight = Color(0xFFFAC775);
  static const Color sage = Color(0xFF8FA68A);
  static const Color inkBlack = Color(0xFF2A1F25);
  static const Color inkMuted = Color(0xFF6B5A60);
  static const Color border = Color(0xFFE8DDD0);
}
```

`ThemeData`:
- `scaffoldBackgroundColor: AppColors.cream`
- `primaryColor: AppColors.primary`
- `colorScheme: ColorScheme.light(primary: primary, secondary: gold, ...)`
- `textTheme: GoogleFonts.interTextTheme().copyWith(...)` — başlıklarda Playfair
- `cardTheme`, `elevatedButtonTheme`, `outlinedButtonTheme`, `inputDecorationTheme` hepsi yeni stille

### 5.2 Hard-coded Renkleri Temizle

Aşağıdaki ekranlarda magenta/teal hard-coded rengi kontrol et ve `AppColors`'a çevir:
- `home_screen.dart`
- `photo_mode_screen.dart`
- `result_screen.dart`
- `templates_screen.dart`
- `credits_screen.dart`
- `boutique_catalog_screen.dart`
- `referral_screen.dart`
- `login_screen.dart`, `register_screen.dart`, `onboarding_screen.dart`

### 5.3 Yeni Ekran: Butik Vitrini (Boutique Showcase)

`boutique_catalog_screen.dart` zaten yazılmış (550 satır) ama spec'e göre:
- Başlık: butik adı (Playfair, 22sp) + butik logosu üst orta
- Alt başlık: "X model · Bahar koleksiyonu"
- Kategori filtreleri (chip'ler): `Tümü | Şal | Eşarp | Hijap | Tunik`
- Grid (2 kolon mobile, 3 kolon tablet) ürünler — sadece `imageUrl` + `name`
- Ürüne tıkla → "Bu modeli dene" CTA → photo_mode_screen'e modelId ile git
- **Fiyat YOK.** Karta ekleme/sepet yok.
- Butik websitesi varsa en altta küçük "Butik sitesini ziyaret et ↗" linki

### 5.4 Result Screen Güncellemesi

`result_screen.dart`'da, başarılı try-on sonrasında **try_on_event** logla:
```dart
await firestoreService.logTryOnEvent(
  boutiqueId: product.boutiqueId,
  productId: product.id,
  userId: currentUser?.uid,
  userType: userType,
  referralCodeId: lastUsedReferralCode?.id,
  succeeded: true,
  costUsd: 0.01,
);
```
Aynı transaction'da `tryOnCount` increment et.

---

## 6. Butik Admin Paneli (Flutter Web) — Sayfa Spec'i

`hijapp_admin/` projesi scaffold edildi. Aşağıdaki sayfaları doldur:

### 6.1 Giriş Sayfası (`/login`)

- Sade form: butik email + şifre
- "Şifremi unuttum"
- Yeni butik kaydı **self-serve değil** — Şevk manuel onaylar.
  UI'da "Butik ortağı olmak için: [iletişim email]" linki olsun.
- Sol: bordo arka plan + altın "HIJAPP Butik Paneli" başlığı + tagline
- Sağ: krem arka plan + form

### 6.2 Genel Bakış (`/dashboard`)

Üst metric grid (4 kart):
- **Kredi bakiyesi** (büyük rakam) + "Kredi al" CTA
- **Bu ay deneme** (last30DaysTryOns) + önceki aya göre %değişim
- **Kullanılan kod sayısı** (last 30d)
- **Aktif kod sayısı** (currentRedemptions < maxRedemptions ve active)

Altında 2 panel yan yana:
- **En çok denenen 5 ürün** (mockup'taki bar list)
- **Son denemeler timeline** (son 10 event, "X ürün · Y dakika önce")

En altta küçük insight kartı: "Bu ay 'Bordo İpek Şal' geçen aya göre %43 daha çok
denendi. Vitrinin üst sırasına çıkarmayı düşün."

### 6.3 Vitrin / Ürünler (`/products`)

- Üstte "Yeni ürün ekle" CTA
- Tablo / grid toggle
- Her ürün için: görsel, isim, kategori, tryOnCount, sortOrder, aktif/pasif toggle, sil/düzenle
- Drag-and-drop sıralama (sortOrder güncelle)
- Yeni ürün dialog:
  - İsim, kategori dropdown
  - Görsel yükle (Firebase Storage, 1080×1080 önerilir, max 5MB)
  - Açıklama (opsiyonel)
  - Outbound URL (opsiyonel — butiğin kendi ürün sayfası)
  - Kaydet → ürün hemen vitrine düşer

### 6.4 Kodlar (`/codes`)

- Üstte "Yeni kod oluştur" CTA
- Tablo: kod, kredi/kullanım, max kullanım, mevcut kullanım, kampanya tag, expires, durum, aksiyon
- Yeni kod dialog:
  - Kod adı (otomatik öneri: BUTIKADI-KAMPANYA-RANDOM4)
  - Kullanım başı kredi (varsayılan 5)
  - Maksimum kullanım (0 = sınırsız, varsayılan 100)
  - Kampanya etiketi (özgür text — 'instagram', 'mağaza-içi' vb.)
  - Son kullanma tarihi (opsiyonel)
- Detay görünümünde: bu kodun kullanım grafiği (gün gün), hangi userların kullandığı (kısaltılmış)
- Kod oluşturulurken **butiğin kredi bakiyesinden** `maxRedemptions × creditsPerRedemption` kadar **rezerve edilir** (gerçek düşüş kullanımda olur ama görünür bakiye düşer ki butik over-commit etmesin)

### 6.5 Analitik (`/analytics`)

- Tarih aralığı seçici (Son 7 gün / 30 gün / 90 gün / özel)
- Ana grafik: günlük try-on sayısı (line chart)
- Ürün bazlı tablo: ürün × deneme × benzersiz kullanıcı × dönüşüm (outbound link tıklama oranı varsa)
- Kategori dağılım pie chart
- Kampanya tag bazlı kod performansı tablosu

Flutter Web için: `fl_chart` paketi kullan.

### 6.6 Kredi Satın Alma (`/billing`)

- Mevcut bakiye + bu ayın tüketimi büyük rakamla
- Paket kartları (5 kademeli, segment-bazlı):
  - **Starter — 50 kredi → ₺599** (₺11.98/kredi) — küçük butik, ilk deneme
  - **Growth — 100 kredi → ₺1.000** (₺10.00/kredi) — orta butik, ana giriş paketi
  - **Pro — 500 kredi → ₺4.490** (₺8.98/kredi, %10 indirim) — büyüyen butik
  - **Premium — 2000 kredi → ₺16.990** (₺8.49/kredi, %15 indirim) — markalaşmış butik, **en popüler**
  - **Enterprise — 10000 kredi → ₺79.990** (₺8.00/kredi, %20 indirim) — Modanisa/Armine ölçeği
- Her paket kartında "X TL/kredi" + "%Y indirim" rozeti
- Premium kartında "En popüler" altın rozet (mockup'taki gibi)
- Enterprise için "Bize ulaşın" alternatifi (Şevk manuel müzakere için)
- Ödeme: iyzico (TR butikleri için kritik), Stripe (uluslararası ihtiyacında)
- Geçmiş satın alma faturaları tablosu (PDF indir)
- KDV ayrı satırda gösterilsin (B2B faturada şart)

### 6.7 Ayarlar (`/settings`)

- Butik bilgileri (isim, logo, website, Instagram)
- Kullanıcılar (butik içinde ekstra admin ekleme — ileride)
- Bildirim tercihleri (haftalık rapor email'i alınsın mı)
- API anahtarı (ileride white-label entegrasyon)
- Çıkış

---

## 7. Build Sırası (Claude Code'a önerilen sıra)

1. **Git temizliği:** Mevcut 125 değişikliği mantıklı commit'lere böl. En azından:
   - `feat: faz 0 firebase init`
   - `feat: faz 1 auth servis ve ekranları`
   - `feat: faz 2 kredi sistemi modelleri`
   - `feat: faz 3 boutique modelleri ve ekranları`
   - `chore: admin panel scaffold`

2. **Build sağlığı:** `flutter pub get`, `flutter analyze`, `flutter test` çalıştır.
   Kırıklar varsa düzelt. Mart'tan beri 2 ay geçmiş — Flutter SDK uyumsuzluğu
   olabilir.

3. **Tema migrasyonu:** Bölüm 5 — yeni `AppColors`, `google_fonts`, hard-coded
   renk temizliği.

4. **Model güncellemeleri:** Bölüm 3 — `BoutiqueProductModel` sadeleştir, yeni
   alanlar, `try_on_events` koleksiyonu hazırlığı.

5. **Result screen — analytics logging:** Her try-on bir event yaratacak.

6. **Admin panel doldurma:** Bölüm 6 sırasıyla — login, dashboard, products,
   codes, analytics, billing.

7. **Cloud Functions:** `onTryOnComplete` (counter güncelleme), `onCodeRedeem`
   (butik bakiyesi düşüşü + user'a kredi yükleme), haftalık özet email.

8. **Ödeme entegrasyonu:** iyzico web checkout (admin panel için), in-app
   purchase mobil için (sonraki faz).

9. **Test:** Birim + widget + en az 1 entegrasyon testi (kod kullanım akışı).

---

## 8. Eksik UI Bileşenleri (Reusable Widgets)

Bunları `lib/core/widgets/` altına yaz:

- `BrandButton` (primary / secondary / ghost varyantları)
- `BrandCard` (border + radius + padding standardı)
- `StatTile` (admin paneldeki metric kartlar)
- `EmptyState` (krem zemin + altın icon + helper text)
- `BoutiqueChip` (logo + isim, vitrin geçişi için)
- `CreditBadge` (bordo + altın, sayı + "deneme" yazısı)
- `TryOnSparkline` (mini bar chart, ürün kartında inline kullanım)

---

## 9. Dikkat Edilecek Edge Case'ler

- Anonim user'ın try-on event'i: `userId: null` olarak logla, `userType: 'free'`
- Butik kodu kullanılırken **kod aktif değilse / expired / max'a ulaşmış / butik bakiyesi yetmez** durumlarında net Türkçe hata mesajı
- Replicate API hatası: kredi düşmesin, retry sun, event'i `succeeded: false` logla
- Ağ kopukluğunda son try-on'u local olarak tut, online olunca sync et (ya da event'i sadece success'te logla, fail'ı görmesek de olur)
- Aynı user aynı kodu iki kez kullanamasın → `redeemedCodes` listesinde varsa reddet
- Butik silinirse ürünleri ve kodları soft-delete (`isActive: false`), event'leri tut (geçmiş bozulmasın)

---

## 10. Performans Notları

- Vitrin grid'i ilk yüklemede sadece ilk 12 ürün, sonsuz scroll ile pagination
- Ürün görsellerini `cached_network_image` ile cache'le ve `thumbnailUrl` (300×300) + `imageUrl` (1080×1080) iki versiyon Cloud Storage'da tut
- Admin panel grafikleri için son 90 gün cap, daha öncesi için arşiv view
- `try_on_events` koleksiyonu hızla büyür — 6 ay sonrasını cold storage'a almak için TTL ya da BigQuery export planla (şimdilik dert değil, not düşüldü)

---

Bu spec'i Claude Code oturumuna girdiğinde başlangıç prompt'u olarak ver:
"`HIJAPP_SPEC_v2.md`'yi oku, Bölüm 7'deki build sırasını izle, her adımda commit at."
