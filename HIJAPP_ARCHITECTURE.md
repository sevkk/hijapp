# HIJAPP — Tam Sistem Mimarisi & Implementasyon Planı

## 1. Proje Özeti

HIJAPP, kullanıcıların başörtüsü desenlerini sanal olarak denemelerini sağlayan bir Flutter uygulamasıdır. Kullanıcı kendi fotoğrafını (başörtülü) ve bir ürün fotoğrafını yükler, AI mevcut başörtüsünün desenini yenisiyle değiştirir.

**Teknik Stack:**
- Flutter (iOS + Android + Web Admin Panel)
- Firebase (Auth + Firestore + Storage)
- Replicate API — prunaai/p-image-edit ($0.01/işlem)
- Riverpod (state management)

---

## 2. İş Modeli

### 2.1 B2C — Bireysel Kullanıcı (Kredi Bazlı)
- Kayıt: Email + şifre (Firebase Auth)
- Her fotoğraf deneme = 1 kredi harcar
- Yeni kullanıcıya 3 ücretsiz deneme kredisi (onboarding)
- Kredi paketleri (App Store / Google Play in-app purchase):
  - 10 kredi — $2.99
  - 25 kredi — $5.99
  - 50 kredi — $9.99

### 2.2 B2B — Butik Tarafı (Kredi Bazlı, Self-Serve)
- Butik kendi hesabını oluşturur (web admin panel)
- Kredi paketleri (butik fiyatlandırma):
  - 100 kredi — $25 (deneme paketi, tek seferlik)
  - 250 kredi — $100
  - 500 kredi — $200
- Butik referans kodları oluşturur
- Her koda istediği miktarda kredi atar (kendi havuzundan)
- Ürünlerini admin panelden yükler (fotoğraf, isim, fiyat, satın alma linki)
- Müşteri referans kodla girdiğinde o butiğin ürünlerini görür + kredi tanımlanır

### 2.3 Gelir Akışı
```
Kullanıcı → Kredi satın alır → Replicate API maliyeti ($0.01) düşülür → Kâr
Butik → Toplu kredi alır → Referans kodlarla dağıtır → Müşterileri ürün dener → Satış artar
```

---

## 3. Firebase Veritabanı Şeması (Firestore)

### 3.1 `users` Collection
```
users/{uid}
├── email: string
├── displayName: string (nullable)
├── credits: number (bireysel satın alınan krediler)
├── totalCreditsUsed: number
├── createdAt: timestamp
├── updatedAt: timestamp
└── redeemedCodes: array<string> (kullanılan referans kodları — aynı kodu tekrar kullanmasın)
```

### 3.2 `boutiques` Collection
```
boutiques/{boutiqueId}
├── name: string (butik adı)
├── email: string
├── phone: string (nullable)
├── logoUrl: string (nullable)
├── instagramHandle: string (nullable)
├── websiteUrl: string (nullable)
├── creditBalance: number (kalan kredi havuzu)
├── totalCreditsPurchased: number
├── totalCreditsDistributed: number (kodlara dağıtılan)
├── isActive: boolean
├── createdAt: timestamp
└── updatedAt: timestamp
```

### 3.3 `boutique_products` Collection
```
boutique_products/{productId}
├── boutiqueId: string (ref → boutiques)
├── name: string (ürün adı)
├── imageUrl: string (Firebase Storage'daki ürün görseli)
├── price: string (nullable, örn: "249 TL")
├── purchaseUrl: string (nullable, satın alma linki)
├── isActive: boolean
├── sortOrder: number
├── createdAt: timestamp
└── updatedAt: timestamp
```

### 3.4 `referral_codes` Collection
```
referral_codes/{codeId}
├── code: string (unique, örn: "BUTIK-AYSE-2024")
├── boutiqueId: string (ref → boutiques)
├── creditsPerRedemption: number (bu kodla giren her müşteriye kaç kredi)
├── maxRedemptions: number (max kaç kişi kullanabilir, 0 = sınırsız)
├── currentRedemptions: number
├── isActive: boolean
├── expiresAt: timestamp (nullable)
├── createdAt: timestamp
└── updatedAt: timestamp
```

### 3.5 `user_boutique_credits` Collection
```
user_boutique_credits/{docId}
├── userId: string (ref → users)
├── boutiqueId: string (ref → boutiques)
├── code: string (hangi kodla geldi)
├── remainingCredits: number
├── totalCreditsReceived: number
├── createdAt: timestamp
└── updatedAt: timestamp
```

### 3.6 `transactions` Collection (audit log)
```
transactions/{txId}
├── userId: string
├── type: string ("credit_purchase" | "credit_use" | "referral_redeem" | "boutique_purchase")
├── amount: number (pozitif = ekleme, negatif = kullanım)
├── creditSource: string ("personal" | "boutique:{boutiqueId}")
├── boutiqueId: string (nullable)
├── referralCode: string (nullable)
├── description: string
├── createdAt: timestamp
```

---

## 4. Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Kullanıcılar sadece kendi dokümanlarını okur/yazar
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }

    // Butik: sadece kendi dokümanını okur/yazar
    match /boutiques/{boutiqueId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && get(/databases/$(database)/documents/boutiques/$(boutiqueId)).data.email == request.auth.token.email;
    }

    // Ürünler: herkes okuyabilir (müşteri görecek), sadece butik sahibi yazar
    match /boutique_products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && exists(/databases/$(database)/documents/boutiques/$(resource.data.boutiqueId))
        && get(/databases/$(database)/documents/boutiques/$(resource.data.boutiqueId)).data.email == request.auth.token.email;
    }

    // Referans kodları: herkes okuyabilir (doğrulama), sadece butik sahibi yazar
    match /referral_codes/{codeId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && exists(/databases/$(database)/documents/boutiques/$(resource.data.boutiqueId))
        && get(/databases/$(database)/documents/boutiques/$(resource.data.boutiqueId)).data.email == request.auth.token.email;
    }

    // User-boutique kredileri: sadece kullanıcı ve Cloud Functions yazar
    match /user_boutique_credits/{docId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
      allow update: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    // Transactions: sadece okuma (yazma Cloud Functions'tan)
    match /transactions/{txId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## 5. Uygulama Mimarisi (Flutter)

### 5.1 Mevcut Dosya Yapısı (Korunacak)
```
lib/
├── main.dart
├── app/
│   ├── router.dart              ← güncellenecek (yeni route'lar)
│   └── theme.dart
├── core/
│   ├── models/
│   │   ├── hijab_image.dart
│   │   ├── user_model.dart      ← güncellenecek (kredi sistemi)
│   │   └── user_template.dart
│   ├── services/
│   │   ├── replicate_service.dart   ← DOKUNMA
│   │   └── storage_service.dart     ← güncellenecek
│   └── utils/
│       ├── constants.dart           ← güncellenecek (yeni limitler)
│       └── image_utils.dart
└── features/
    ├── home/
    ├── photo_mode/
    ├── mirror_mode/
    ├── templates/
    └── premium/                     ← komple yeniden yazılacak
```

### 5.2 Eklenecek Yeni Dosyalar
```
lib/
├── core/
│   ├── models/
│   │   ├── boutique_model.dart          ← YENİ
│   │   ├── boutique_product_model.dart  ← YENİ
│   │   ├── referral_code_model.dart     ← YENİ
│   │   └── transaction_model.dart       ← YENİ
│   └── services/
│       ├── auth_service.dart            ← YENİ (Firebase Auth)
│       ├── firestore_service.dart       ← YENİ (Firestore CRUD)
│       ├── credit_service.dart          ← YENİ (kredi yönetimi)
│       └── referral_service.dart        ← YENİ (referans kod işlemleri)
└── features/
    ├── auth/                            ← YENİ
    │   ├── auth_provider.dart
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── credits/                         ← YENİ (premium yerine)
    │   ├── credits_provider.dart
    │   └── credits_screen.dart          ← kredi paketleri satın alma
    ├── referral/                        ← YENİ
    │   ├── referral_provider.dart
    │   └── referral_screen.dart         ← referans kodu girme
    └── boutique_catalog/                ← YENİ
        ├── boutique_catalog_provider.dart
        └── boutique_catalog_screen.dart ← butik ürünleri listeleme + deneme
```

### 5.3 Admin Panel (Flutter Web — Ayrı Proje)
```
hijapp_admin/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── router.dart
│   │   └── theme.dart
│   ├── core/
│   │   ├── models/    (shared models)
│   │   └── services/  (Firebase services)
│   └── features/
│       ├── auth/
│       │   └── admin_login_screen.dart
│       ├── dashboard/
│       │   └── dashboard_screen.dart       ← toplam kredi, aktif kodlar, istatistikler
│       ├── products/
│       │   ├── products_list_screen.dart    ← ürün listesi + CRUD
│       │   └── product_form_screen.dart     ← ürün ekleme/düzenleme
│       ├── referral_codes/
│       │   ├── codes_list_screen.dart       ← kodlar listesi + istatistik
│       │   └── code_form_screen.dart        ← yeni kod oluşturma
│       └── credits/
│           └── purchase_credits_screen.dart ← kredi satın alma
```

---

## 6. Kritik Akışlar (Flow)

### 6.1 Kullanıcı Kayıt & Giriş
```
Uygulama açılır
  → Firebase Auth durumu kontrol edilir
  → Giriş yapılmamışsa → Login/Register ekranı
  → Giriş yapılmışsa → Home ekranı
  → Firestore'dan user dokümanı çekilir (kredi bakiyesi vb.)
```

### 6.2 Bireysel Kredi Satın Alma (B2C)
```
Kullanıcı "Kredi Al" butonuna basar
  → Kredi paketleri gösterilir (10/25/50)
  → In-app purchase (RevenueCat veya doğrudan StoreKit/BillingClient)
  → Başarılıysa → Firestore users/{uid}.credits += satın alınan miktar
  → Transaction log yazılır
```

### 6.3 Referans Kod Kullanma
```
Kullanıcı "Referans Kod Gir" butonuna basar (profil veya ana sayfada)
  → Kodu girer
  → Firestore'dan referral_codes kontrol edilir:
    - Kod var mı? Aktif mi? Süresi geçmiş mi? maxRedemptions aşılmış mı?
    - Bu kullanıcı daha önce bu kodu kullanmış mı? (users/{uid}.redeemedCodes kontrolü)
  → Geçerliyse:
    - user_boutique_credits dokümanı oluşturulur/güncellenir
    - referral_codes.currentRedemptions += 1
    - boutiques.totalCreditsDistributed += creditsPerRedemption
    - users/{uid}.redeemedCodes array'ine kod eklenir
    - Transaction log yazılır
  → Butik katalog sayfasına yönlendirilir
```

### 6.4 Fotoğraf İşleme (Kredi Harcama)
```
Kullanıcı fotoğraf + başörtüsü seçer → "Dene!" basar
  → Kredi kontrolü:
    1. Önce kişisel kredi (users/{uid}.credits) kontrol edilir
    2. Eğer butik kataloğundan deniyorsa → user_boutique_credits kontrol edilir
  → Kredi varsa:
    - replicate_service.processHijabTryOn() çağrılır (DOKUNULMADI)
    - Başarılıysa → ilgili kredi 1 düşürülür
    - Transaction log yazılır
    - Sonuç gösterilir
  → Kredi yoksa:
    - "Kredin bitti! Kredi satın al." dialog gösterilir
```

### 6.5 Butik Ürün Deneme (Referans Kodla)
```
Kullanıcı referans kodla girdikten sonra butik kataloğu açılır
  → Butiğin ürünleri listelenir (boutique_products where boutiqueId == X)
  → Ürüne tıklar → Ürün görseli otomatik hijab olarak seçilir
  → Kullanıcı kendi fotoğrafını seçer (veya daha önce seçilmişse direkt)
  → "Dene!" → Butik kredisinden 1 düşülür
  → Sonuç ekranında "Bu ürünü satın al" butonu (purchaseUrl'e yönlendirme)
```

### 6.6 Butik Admin Paneli Akışları
```
Butik kayıt olur (web)
  → Firebase Auth ile email/şifre
  → Firestore'da boutiques dokümanı oluşturulur

Ürün yönetimi:
  → Ürün ekle: fotoğraf + isim + fiyat + satın alma linki
  → Fotoğraf Firebase Storage'a yüklenir
  → Firestore boutique_products'a yazılır
  → Ürün düzenle/sil/sırala

Referans kod yönetimi:
  → Yeni kod oluştur: kod adı + kaç kredi + max kullanım + son tarih
  → Kredi butik havuzundan düşülür (ön-ayırma)
  → Kodlar listesi: hangi kod kaç kez kullanılmış, kalan kredi
  → Kod deaktive et / sil

Kredi satın alma:
  → 100 ($25) / 250 ($50) / 500 ($100) paketler
  → Ödeme sonrası boutiques.creditBalance += miktar
```

---

## 7. Mevcut Kodda Yapılacak Değişiklikler

### 7.1 `user_model.dart` — Güncelle
```dart
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final int credits;                    // isPremium → credits
  final int totalCreditsUsed;
  final List<String> redeemedCodes;     // YENİ
  final DateTime createdAt;
  final DateTime updatedAt;

  // canProcess artık kredi kontrolü yapacak
  bool get canProcess => credits > 0;

  // Butik kredisi kontrolü ayrı service'te
}
```

### 7.2 `constants.dart` — Güncelle
```dart
class AppLimits {
  static const int freeTrialCredits = 3;        // yeni kullanıcıya hediye
  static const int maxRecentHijabs = 10;         // limit kaldırıldı (artık kredi bazlı)
  static const int maxTemplates = 20;            // artırıldı
}

class CreditPackages {
  // B2C
  static const Map<String, dynamic> personal10 = {'credits': 10, 'price': 2.99, 'id': 'credits_10'};
  static const Map<String, dynamic> personal25 = {'credits': 25, 'price': 5.99, 'id': 'credits_25'};
  static const Map<String, dynamic> personal50 = {'credits': 50, 'price': 9.99, 'id': 'credits_50'};

  // B2B
  static const Map<String, dynamic> boutique100 = {'credits': 100, 'price': 25.0, 'id': 'boutique_100'};
  static const Map<String, dynamic> boutique250 = {'credits': 250, 'price': 100.0, 'id': 'boutique_250'};
  static const Map<String, dynamic> boutique500 = {'credits': 500, 'price': 200.0, 'id': 'boutique_500'};
}
```

### 7.3 `premium_screen.dart` → `credits_screen.dart` — Komple Yeniden Yaz
- Eski: Aylık/Yıllık abonelik kartları
- Yeni: Kredi paketleri (10/25/50), mevcut bakiye gösterimi, referans kod girme butonu

### 7.4 `router.dart` — Yeni Route'lar Ekle
```dart
static const String login = '/login';
static const String register = '/register';
static const String credits = '/credits';          // eski premium
static const String referral = '/referral';
static const String boutiqueCatalog = '/boutique-catalog';
```

### 7.5 `replicate_service.dart` — DOKUNMA ⛔
Bu dosya olduğu gibi kalacak. Kredi kontrolü bu servisin dışında, provider seviyesinde yapılacak.

### 7.6 `photo_mode_provider.dart` — Güncelle
```dart
// processPhoto() içinde kredi kontrolü ekle:
// 1. creditService.hasCredits(userId) kontrol et
// 2. İşlem başarılıysa creditService.useCredit(userId, source) çağır
// 3. Kredi yoksa CreditExhaustedException fırlat
```

---

## 8. Yeni Servisler

### 8.1 `auth_service.dart`
```
- signInWithEmail(email, password) → UserCredential
- registerWithEmail(email, password) → UserCredential + Firestore user dokümanı oluştur
- signOut()
- getCurrentUser() → User?
- onAuthStateChanged → Stream<User?>
```

### 8.2 `firestore_service.dart`
```
- getUser(uid) → UserModel
- updateUser(uid, data)
- getBoutique(boutiqueId) → BoutiqueModel
- getBoutiqueProducts(boutiqueId) → List<BoutiqueProductModel>
- getReferralCode(code) → ReferralCodeModel?
- getUserBoutiqueCredits(userId) → List<UserBoutiqueCreditModel>
- addTransaction(TransactionModel)
```

### 8.3 `credit_service.dart`
```
- getPersonalCredits(uid) → int
- getBoutiqueCredits(uid, boutiqueId) → int
- getTotalAvailableCredits(uid) → int (kişisel + tüm butik)
- useCredit(uid, {boutiqueId?}) → bool
  → Butik ürünü deniyorsa butik kredisinden düş
  → Kişisel deniyorsa kişisel krediden düş
- addCredits(uid, amount, source)
- canProcess(uid, {boutiqueId?}) → bool
```

### 8.4 `referral_service.dart`
```
- redeemCode(uid, code) → RedeemResult
  → Kod doğrulama (aktif mi, süresi geçmiş mi, max kullanım aşılmış mı)
  → Kullanıcı daha önce kullanmış mı
  → user_boutique_credits oluştur
  → referral_codes.currentRedemptions güncelle
  → users.redeemedCodes'a ekle
  → Transaction log yaz
- validateCode(code) → ValidationResult (UI'da anlık kontrol için)
```

---

## 9. Admin Panel (Flutter Web)

### 9.1 Neden Flutter Web?
- Aynı dil (Dart), aynı Firebase paketleri
- Model sınıfları paylaşılabilir
- Tek geliştirici için en verimli yol

### 9.2 Admin Panel Sayfaları
1. **Login** — Email/şifre ile giriş
2. **Dashboard** — Kalan kredi, aktif kodlar, toplam müşteri, son 7 gün istatistik
3. **Ürünler** — Liste + Ekle/Düzenle/Sil/Sırala, fotoğraf upload (Firebase Storage)
4. **Referans Kodlar** — Liste + Oluştur/Deaktive, her kodun kullanım istatistiği
5. **Kredi Satın Al** — 100 ($25) / 250 ($100) / 500 ($200) paketler

### 9.3 Admin Panel Hosting
- Firebase Hosting (ücretsiz tier yeterli)
- URL: admin.hijapp.com veya hijapp-admin.web.app

---

## 10. Ödeme Sistemi

### 10.1 B2C (Mobil Uygulama)
- **iOS**: StoreKit 2 via in_app_purchase Flutter paketi
- **Android**: Google Play Billing via in_app_purchase Flutter paketi
- Consumable product olarak tanımlanacak (tek seferlik, abonelik değil)
- Product ID'ler: `credits_10`, `credits_25`, `credits_50`

### 10.2 B2B (Admin Panel - Web)
- **Stripe** veya **iyzico** (Türkiye için)
- Web üzerinden ödeme, in-app purchase komisyonu yok
- Stripe Checkout Session → webhook → Firestore güncelle

---

## 11. Firebase Storage Yapısı
```
hijapp-storage/
├── boutique_logos/{boutiqueId}/logo.jpg
├── boutique_products/{boutiqueId}/{productId}/product.jpg
└── user_results/{uid}/{timestamp}.jpg (opsiyonel — sonuç kaydetme)
```

---

## 12. Implementasyon Sırası (Önerilen)

### Faz 1: Auth + Kredi Sistemi (B2C) — 1 hafta
1. Firebase projesini kur (Firebase Console)
2. `auth_service.dart` — kayıt/giriş
3. Login/Register ekranları
4. `user_model.dart` güncelle (kredi bazlı)
5. `credit_service.dart` — kredi kontrolü
6. `credits_screen.dart` — kredi paketleri UI (ödeme placeholder)
7. `photo_mode_provider.dart` — kredi kontrolü entegre et
8. `constants.dart` güncelle
9. `router.dart` güncelle

### Faz 2: Referans Kod Sistemi — 3 gün
1. `referral_service.dart`
2. `referral_screen.dart` — kod girme UI
3. `boutique_catalog_screen.dart` — butik ürün listesi
4. Yeni modeller: `referral_code_model.dart`, `boutique_model.dart`, `boutique_product_model.dart`
5. Home ekranına "Referans Kod Gir" butonu

### Faz 3: Admin Panel (Flutter Web) — 1 hafta
1. Yeni Flutter Web projesi oluştur
2. Auth ekranı
3. Dashboard
4. Ürün CRUD + Firebase Storage upload
5. Referans kod yönetimi
6. Kredi satın alma (Stripe/iyzico placeholder)
7. Firebase Hosting deploy

### Faz 4: Ödeme Entegrasyonu — 3-5 gün
1. B2C: in_app_purchase paketi + App Store/Play Store ürün tanımlama
2. B2B: Stripe veya iyzico entegrasyonu (admin panel)
3. Webhook → Firestore kredi güncelleme

### Faz 5: Test & Polish — 3 gün
1. Tüm akışları test et
2. Edge case'ler (kredi bitmiş, kod expired, aynı kod tekrar vb.)
3. Error handling & loading states
4. Analytics (Firebase Analytics)
5. Store listing & privacy policy güncelle

---

## 13. pubspec.yaml Eklenecek Paketler

```yaml
dependencies:
  # Mevcut (zaten var):
  firebase_core: ^3.12.1
  firebase_auth: ^5.5.1
  cloud_firestore: ^5.6.5

  # Eklenecek:
  firebase_storage: ^12.4.4      # Ürün görselleri upload
  in_app_purchase: ^3.2.0        # B2C kredi satın alma
  cached_network_image: ^3.4.1   # Butik ürün görselleri cache
  url_launcher: ^6.3.1           # "Satın al" butonu → web link
```

---

## 14. Dikkat Edilecekler

1. **replicate_service.dart'a DOKUNMA** — API key dart-define ile geçiriliyor, işlem mantığı çalışıyor.
2. **Kredi düşme işlemi atomik olmalı** — Firestore transaction kullan, race condition önle.
3. **Referans kod suistimali** — Email ile kayıt zorunlu, aynı kullanıcı aynı kodu 1 kez kullanabilir.
4. **Butik kredi ön-ayırma** — Butik kod oluştururken kredi havuzundan düşülür. Kod silinirse/deaktive edilirse kullanılmamış krediler havuza geri döner.
5. **Offline durumu** — SharedPreferences'ta son bilinen kredi sayısını cache'le. Online olunca senkronize et.
6. **In-app purchase doğrulama** — Server-side receipt validation (Cloud Functions) ile sahte satın almaları engelle.
