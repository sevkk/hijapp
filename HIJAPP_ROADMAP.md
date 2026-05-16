# HIJAPP — Proje Yol Haritası & Kapsamlı To-Do List

## Mevcut Durum Özeti

| Bileşen | Durum | Not |
|---------|-------|-----|
| Temel try-on (Replicate API) | ✅ Çalışıyor | prunaai/p-image-edit, $0.01/işlem |
| Günlük limit (5/gün) | ✅ Çalışıyor | SharedPreferences ile |
| Son kullanılanlar | ✅ Çalışıyor | Max 3, local storage |
| Görsel cache | ✅ Çalışıyor | MD5 hash, tekrar API çağrısı yapmıyor |
| Mock mode | ✅ Çalışıyor | --dart-define=MOCK_MODE=true |
| Galeriye kaydetme & paylaşma | ✅ Çalışıyor | image_gallery_saver + share_plus |
| Taslaklar (templates) | ⚠️ Kısmi | Storage çalışıyor, UI eksik olabilir |
| Firebase Auth | ❌ Yok | Paket var ama init yok, config dosyaları eksik |
| Kredi sistemi | ❌ Yok | Sadece günlük limit var, kredi bazlı değil |
| Referans kod sistemi | ❌ Yok | Sadece UI tasarımı hazır (React) |
| Butik admin paneli | ❌ Yok | Sadece UI tasarımı hazır (React) |
| Ödeme entegrasyonu | ❌ Yok | Premium ekranı placeholder |
| Renk paleti | ✅ Güncellendi | Yeni palet: magenta, teal, tan, peach, brown |
| UI tasarımları (React/Stitch) | ✅ Hazır | 11 ekran React kodu mevcut |

---

## FAZ 0 — Ön Hazırlık (Teste vermeden önce altyapı)

### 0.1 Firebase Kurulumu
- [ ] Firebase Console'da yeni proje oluştur (hijapp-prod)
- [ ] Android için google-services.json indir → `android/app/` dizinine koy
- [ ] iOS için GoogleService-Info.plist indir → `ios/Runner/` dizinine koy
- [ ] `main.dart`'ta `Firebase.initializeApp()` ekle
- [ ] Firebase Auth'u enable et (Email/Password + Google Sign-In)
- [ ] Firestore'u enable et (production mode)
- [ ] Firebase Storage'ı enable et
- [ ] Firestore Security Rules'ı yaz (HIJAPP_ARCHITECTURE.md'deki şema)

### 0.2 Mevcut Kodu Temizle
- [ ] `PROMPT_07_texture_overlay_fix.md` dosyasını sil
- [ ] `PROMPT_08_replicate_temizle_final.md` dosyasını sil
- [ ] `HIJAPP_arastirma_ozeti.md` dosyasını gerekiyorsa arşivle veya sil
- [ ] `theme.dart`'taki renkleri yeni palette uyumlu olduğunu doğrula
- [ ] `premium_screen.dart`'ı `credits_screen.dart` olarak yeniden adlandır veya sil (komple yeniden yazılacak)

### 0.3 Yeni Paket Bağımlılıkları
- [ ] `pubspec.yaml`'a ekle: `firebase_storage`, `cached_network_image`, `url_launcher`
- [ ] `in_app_purchase` paketini henüz ekleme (Faz 3'te)
- [ ] `flutter pub get` çalıştır, tüm bağımlılıkları doğrula

---

## FAZ 1 — Auth + Kullanıcı Sistemi (Tahmini: 3-4 gün)

### 1.1 Auth Servisi
- [ ] `lib/core/services/auth_service.dart` oluştur
  - [ ] `signInWithEmail(email, password)`
  - [ ] `registerWithEmail(email, password, displayName)`
  - [ ] `signOut()`
  - [ ] `getCurrentUser()`
  - [ ] `onAuthStateChanged` stream
  - [ ] Google Sign-In entegrasyonu (opsiyonel, sonra da eklenebilir)
- [ ] Riverpod provider'ları: `authServiceProvider`, `authStateProvider`, `currentUserProvider`

### 1.2 Auth UI Ekranları
- [ ] `lib/features/auth/login_screen.dart` — React export'tan Flutter'a çevir
  - [ ] Email + şifre input
  - [ ] "Giriş Yap" butonu
  - [ ] "Şifremi Unuttum" linki
  - [ ] "Kayıt Ol" navigasyon linki
  - [ ] Hata mesajları (yanlış şifre, kullanıcı bulunamadı vb.)
- [ ] `lib/features/auth/register_screen.dart` — React export'tan Flutter'a çevir
  - [ ] İsim + email + şifre inputları
  - [ ] Şifre güçlülük göstergesi
  - [ ] Kullanım koşulları checkbox'ı
  - [ ] "Kayıt Ol" butonu
  - [ ] Başarılı kayıtta Firestore'a user dokümanı oluştur (3 ücretsiz kredi)
- [ ] `lib/features/auth/onboarding_screen.dart` — Karşılama ekranı

### 1.3 User Model Güncelleme
- [ ] `user_model.dart`'ı güncelle:
  - [ ] `isPremium` → `credits` (int)
  - [ ] `redeemedCodes` (List<String>) ekle
  - [ ] `totalCreditsUsed` ekle
  - [ ] `createdAt`, `updatedAt` ekle
  - [ ] `canProcess` → kredi kontrolü yapacak şekilde güncelle
  - [ ] Firestore'dan okuma/yazma (fromFirestore / toFirestore)

### 1.4 Router Güncelleme
- [ ] `router.dart`'a yeni route'lar ekle: `/login`, `/register`, `/onboarding`
- [ ] Auth guard: giriş yapılmamışsa → onboarding, yapılmışsa → home
- [ ] Splash screen: Firebase init + auth state check

### 1.5 Firestore Servisi
- [ ] `lib/core/services/firestore_service.dart` oluştur
  - [ ] `getUser(uid)` → UserModel
  - [ ] `createUser(uid, email, displayName)` → ilk kayıt, 3 kredi
  - [ ] `updateUser(uid, data)`
  - [ ] `addTransaction(TransactionModel)`
- [ ] Riverpod provider: `firestoreServiceProvider`

---

## FAZ 2 — Kredi Sistemi (Tahmini: 3-4 gün)

### 2.1 Kredi Servisi
- [ ] `lib/core/services/credit_service.dart` oluştur
  - [ ] `getPersonalCredits(uid)` → int
  - [ ] `getBoutiqueCredits(uid, boutiqueId)` → int
  - [ ] `getTotalCredits(uid)` → int (kişisel + tüm butik)
  - [ ] `useCredit(uid, {String? boutiqueId})` → bool (Firestore transaction ile atomik)
  - [ ] `addCredits(uid, amount, source)` → void
  - [ ] `canProcess(uid, {String? boutiqueId})` → bool
- [ ] Riverpod providers: `creditServiceProvider`, `userCreditsProvider`

### 2.2 Photo Mode Entegrasyonu
- [ ] `photo_mode_provider.dart` güncelle:
  - [ ] `canProcess()` → creditService.canProcess() kullanacak
  - [ ] `processPhoto()` → başarılı işlemden sonra creditService.useCredit() çağıracak
  - [ ] Kredi bittiyse → "Kredi Al" dialog göster
  - [ ] Butik ürünü deniyorsa → butik kredisinden düş

### 2.3 Kredi Ekranı (Credits Screen)
- [ ] `lib/features/credits/credits_screen.dart` oluştur (React export'tan çevir)
  - [ ] Gradient header: kalan kredi bakiyesi
  - [ ] "Nasıl Çalışır?" bölümü (3 adım)
  - [ ] Kredi paketleri kartları (10/$2.99, 25/$5.99, 50/$9.99)
  - [ ] "Satın Al" butonu (Faz 3'te aktif olacak, şimdi placeholder)
  - [ ] Referans kodu giriş alanı (alttaki input + "Uygula" butonu)
- [ ] `lib/features/credits/credits_provider.dart`
- [ ] `router.dart`'a `/credits` route ekle

### 2.4 Home Ekranı Güncelleme
- [ ] Üst bar'a kredi bakiyesi badge'i ekle
- [ ] "Referans Kodun Var Mı?" kartını ekle
- [ ] Alt navigasyon bar'ı ekle (Ana Sayfa, Keşfet, Krediler, Profil)
- [ ] Selamlama bölümü: "Merhaba, {isim}" (Firebase Auth'tan)

### 2.5 Profil Ekranı
- [ ] `lib/features/profile/profile_screen.dart` oluştur
  - [ ] Kullanıcı bilgileri (isim, email)
  - [ ] Kredi bakiyesi
  - [ ] Hesap ayarları
  - [ ] "Çıkış Yap" butonu
- [ ] `router.dart`'a `/profile` route ekle

### 2.6 Transaction Model & Logging
- [ ] `lib/core/models/transaction_model.dart` oluştur
- [ ] Her kredi harcamasında/eklenmesinde transaction log yazılacak

---

## FAZ 3 — Referans Kod Sistemi + Butik Kataloğu (Tahmini: 4-5 gün)

### 3.1 Yeni Modeller
- [ ] `lib/core/models/boutique_model.dart`
- [ ] `lib/core/models/boutique_product_model.dart`
- [ ] `lib/core/models/referral_code_model.dart`

### 3.2 Referans Kod Servisi
- [ ] `lib/core/services/referral_service.dart` oluştur
  - [ ] `validateCode(code)` → ValidationResult (anlık UI feedback)
  - [ ] `redeemCode(uid, code)` → RedeemResult
    - [ ] Kod var mı? Aktif mi? Süresi dolmuş mu?
    - [ ] maxRedemptions aşılmış mı?
    - [ ] Bu kullanıcı daha önce bu kodu kullanmış mı?
    - [ ] user_boutique_credits dokümanı oluştur/güncelle
    - [ ] referral_codes.currentRedemptions += 1
    - [ ] users.redeemedCodes'a ekle
    - [ ] Transaction log yaz
  - [ ] `getBoutiqueFromCode(code)` → BoutiqueModel

### 3.3 Referans Kod Ekranı
- [ ] `lib/features/referral/referral_screen.dart` (React export'tan çevir)
  - [ ] Kod giriş alanı (büyük harf, monospace, letter-spacing)
  - [ ] "Kodu Kullan" butonu
  - [ ] Başarı durumu: butik ismi + kredi miktarı göster
  - [ ] "Ürünleri Keşfet" butonu → boutique catalog'a yönlendir
  - [ ] "Nasıl Çalışır?" adımları
- [ ] `lib/features/referral/referral_provider.dart`
- [ ] `router.dart`'a `/referral` route ekle

### 3.4 Butik Katalog Ekranı
- [ ] `lib/features/boutique_catalog/boutique_catalog_screen.dart` (React export'tan çevir)
  - [ ] Butik header: logo, isim, Instagram, kalan kredi
  - [ ] Ürün grid'i (2 kolon): resim, isim, fiyat, "Dene" butonu, "Satın Al" linki
  - [ ] "Dene" → photo_mode'a yönlendir, seçili ürün otomatik hijab olarak atansın
  - [ ] "Satın Al" → url_launcher ile external link aç
  - [ ] Alt bar: butik logo + kalan kredi
- [ ] `lib/features/boutique_catalog/boutique_catalog_provider.dart`
- [ ] `router.dart`'a `/boutique-catalog/:boutiqueId` route ekle

---

## FAZ 4 — Butik Admin Paneli (Flutter Web) (Tahmini: 5-7 gün)

### 4.1 Proje Kurulumu
- [ ] Yeni Flutter Web projesi oluştur: `hijapp_admin`
- [ ] Firebase paketlerini ekle (aynı Firebase projesi)
- [ ] Shared model sınıflarını kopyala veya monorepo yapısı kur

### 4.2 Auth
- [ ] Admin giriş ekranı (email/şifre)
- [ ] Butik kaydı ekranı (self-serve):
  - [ ] Butik adı, email, telefon, Instagram, website
  - [ ] Kayıtta Firestore'da boutiques dokümanı oluştur

### 4.3 Dashboard
- [ ] İstatistik kartları: kalan kredi, aktif kodlar, toplam müşteri, bu ay deneme
- [ ] Son 30 gün kullanım grafiği (fl_chart veya charts_flutter)
- [ ] Kod performansı donut chart
- [ ] Son işlemler tablosu

### 4.4 Ürün Yönetimi
- [ ] Ürün listesi (grid view)
- [ ] Ürün ekleme formu + Firebase Storage'a fotoğraf upload
- [ ] Ürün düzenleme
- [ ] Ürün silme / deaktive etme
- [ ] Sıralama (drag-drop veya numara)

### 4.5 Referans Kod Yönetimi
- [ ] Kod listesi (tablo) + kullanım istatistikleri
- [ ] Yeni kod oluşturma:
  - [ ] Kod adı (otomatik üretme opsiyonu)
  - [ ] Kişi başı kredi miktarı
  - [ ] Max kullanım sayısı (sınırsız opsiyonu)
  - [ ] Son kullanma tarihi (süresiz opsiyonu)
  - [ ] Kredi ön-ayırma: butik havuzundan düşürme
- [ ] Kod deaktive etme (kullanılmayan krediler havuza geri döner)

### 4.6 Kredi Satın Alma
- [ ] Paket seçim ekranı: 100/$25, 250/$100, 500/$200
- [ ] Ödeme entegrasyonu (Faz 5'te aktif)
- [ ] Kredi geçmişi tablosu

### 4.7 Deploy
- [ ] Firebase Hosting yapılandır
- [ ] `firebase deploy --only hosting`
- [ ] Domain ayarla: admin.hijapp.com veya hijapp-admin.web.app

---

## FAZ 5 — Ödeme Entegrasyonu (Tahmini: 4-5 gün)

### 5.1 B2C — In-App Purchase (Mobil)
- [ ] `in_app_purchase` paketini pubspec'e ekle
- [ ] **Apple App Store:**
  - [ ] App Store Connect'te consumable product'lar tanımla (credits_10, credits_25, credits_50)
  - [ ] Sandbox test hesabı oluştur
  - [ ] StoreKit 2 configuration
- [ ] **Google Play Store:**
  - [ ] Play Console'da in-app product'lar tanımla
  - [ ] Test lisansı ayarla
- [ ] `lib/core/services/purchase_service.dart` oluştur
  - [ ] Ürün listesi çek
  - [ ] Satın alma akışı başlat
  - [ ] Purchase verification (receipt validation)
  - [ ] Başarılıysa Firestore'da kredi ekle
- [ ] Credits ekranındaki "Satın Al" butonlarını aktif et
- [ ] **Cloud Functions (opsiyonel ama önerilen):**
  - [ ] Server-side receipt validation (sahte satın almaları engelle)
  - [ ] Webhook endpoint for purchase events

### 5.2 B2B — Web Ödeme (Admin Panel)
- [ ] **Ödeme sağlayıcısı seç:** Stripe veya iyzico
- [ ] Stripe entegrasyonu:
  - [ ] Stripe hesabı oluştur
  - [ ] Checkout Session oluşturma API'si
  - [ ] Success/Cancel redirect sayfaları
  - [ ] Webhook: payment_intent.succeeded → Firestore kredi güncelle
- [ ] Veya iyzico entegrasyonu (Türkiye odaklıysa):
  - [ ] iyzico hesabı oluştur
  - [ ] Checkout Form entegrasyonu
  - [ ] Callback URL'ler
- [ ] Admin paneldeki "Kredi Satın Al" sayfasını aktif et

---

## FAZ 6 — Test Aşaması (Tahmini: 5-7 gün)

### 6.1 Birim Testler (Unit Tests)
- [ ] `credit_service_test.dart` — kredi ekleme, düşme, atomik işlem
- [ ] `referral_service_test.dart` — kod doğrulama, kullanma, limit kontrolleri
- [ ] `auth_service_test.dart` — kayıt, giriş, çıkış
- [ ] `replicate_service_test.dart` — mock mode, cache, hata senaryoları

### 6.2 Widget Testler
- [ ] Login/Register ekranları — form validasyonu
- [ ] Credits ekranı — paket gösterimi, bakiye
- [ ] Referral ekranı — kod girişi, başarı/hata durumları
- [ ] Photo Mode — kredi kontrolü, işleme akışı

### 6.3 Entegrasyon Testleri
- [ ] Tam akış: Kayıt → Kredi al → Fotoğraf işle → Sonuç kaydet
- [ ] Referans kod akışı: Kod gir → Butik katalog → Ürün dene
- [ ] Kredi bitmesi durumu: İşlem engelleme → Kredi al dialog

### 6.4 Gerçek Cihaz Testleri
- [ ] **Android fiziksel cihaz:**
  - [ ] Kamera erişimi (fotoğraf çekme)
  - [ ] Galeri erişimi (fotoğraf seçme)
  - [ ] Galeriye kaydetme
  - [ ] Paylaşma (WhatsApp, Instagram Story vb.)
  - [ ] In-app purchase (sandbox)
- [ ] **iOS fiziksel cihaz (veya TestFlight):**
  - [ ] Aynı test senaryoları
  - [ ] StoreKit sandbox purchase
  - [ ] Face ID / Touch ID (opsiyonel auth için)

### 6.5 Edge Case & Hata Senaryoları
- [ ] İnternet bağlantısı yokken işlem deneme
- [ ] Replicate API rate limit (429 hata)
- [ ] Replicate API timeout (90sn)
- [ ] Aynı referans kodu tekrar girme
- [ ] Süresi dolmuş referans kodu
- [ ] Max kullanıma ulaşmış kod
- [ ] Kredi 0 iken işlem deneme
- [ ] Çok büyük fotoğraf yükleme (10MB+)
- [ ] Uygulamayı işlem sırasında kapatma
- [ ] Aynı anda birden fazla işlem deneme

### 6.6 Performans Testleri
- [ ] İlk açılış süresi < 3 saniye
- [ ] Fotoğraf işleme ortalama süresi (hedef: < 30sn)
- [ ] Bellek kullanımı (büyük görsellerde memory leak kontrolü)
- [ ] Cache boyutu yönetimi (çok fazla cached image birikiyor mu?)

### 6.7 Admin Panel Testleri
- [ ] Ürün ekleme/düzenleme/silme akışı
- [ ] Referans kod oluşturma ve dağıtma
- [ ] Kredi satın alma akışı
- [ ] Dashboard istatistiklerinin doğruluğu
- [ ] Responsive tasarım (tablet, laptop, desktop)

---

## FAZ 7 — Yayına Hazırlık (Tahmini: 3-5 gün)

### 7.1 App Store Hazırlığı (iOS)
- [ ] Apple Developer hesabı ($99/yıl) — varsa kontrol et
- [ ] App Store Connect'te uygulama kaydı oluştur
- [ ] Bundle ID: com.hijapp.app (veya benzeri)
- [ ] App Store görselleri hazırla:
  - [ ] iPhone 6.7" screenshots (5-10 adet)
  - [ ] iPhone 6.1" screenshots
  - [ ] iPad screenshots (opsiyonel)
  - [ ] App icon (1024x1024)
- [ ] App Store açıklaması (store_listing.md'yi güncelle):
  - [ ] Türkçe ve İngilizce
  - [ ] Anahtar kelimeler
  - [ ] "Yenilikler" bölümü
- [ ] Gizlilik politikası URL'si (privacy_policy.html'i host et)
- [ ] Destek URL'si
- [ ] In-app purchase ürünlerini "Ready to Submit" yap
- [ ] App Review bilgileri:
  - [ ] Demo hesap bilgileri (test için)
  - [ ] Uygulamanın ne yaptığına dair açıklama
  - [ ] Referans kod test edebilmeleri için demo kod

### 7.2 Google Play Store Hazırlığı (Android)
- [ ] Google Play Developer hesabı ($25 tek seferlik)
- [ ] Play Console'da uygulama oluştur
- [ ] Package name: com.hijapp.app
- [ ] Store listing görselleri:
  - [ ] Feature graphic (1024x500)
  - [ ] Phone screenshots (2-8 adet)
  - [ ] Tablet screenshots (opsiyonel)
- [ ] İçerik derecelendirmesi anketi doldur
- [ ] Data safety form doldur
- [ ] Target audience & content beyanı
- [ ] In-app product'ları "Active" yap

### 7.3 Build & Release Yapılandırması
- [ ] **Android:**
  - [ ] `android/app/build.gradle` — release signing config
  - [ ] Keystore oluştur (upload key + app signing key)
  - [ ] ProGuard/R8 minification
  - [ ] `flutter build appbundle --release`
- [ ] **iOS:**
  - [ ] Xcode'da signing & capabilities
  - [ ] Provisioning profile (distribution)
  - [ ] `flutter build ipa --release`
  - [ ] Archive → App Store Connect'e yükle

### 7.4 API Key Güvenliği
- [ ] Replicate API key'i koddan çıkar
  - [ ] `--dart-define` ile geçir (mevcut durum, ama build sırasında CI/CD'ye ekle)
  - [ ] Veya Cloud Functions üzerinden proxy (daha güvenli)
- [ ] Firebase API key'leri .gitignore'a ekle
- [ ] Repo'da hiçbir secret kalmamalı

### 7.5 Analytics & Crash Reporting
- [ ] Firebase Analytics entegre et
  - [ ] Ekran görüntülenmeleri
  - [ ] Kredi satın alma event'leri
  - [ ] Referans kod kullanım event'leri
  - [ ] Fotoğraf işleme event'leri
- [ ] Firebase Crashlytics entegre et
  - [ ] Crash raporları
  - [ ] Non-fatal error tracking

### 7.6 Hukuki Gereklilikler
- [ ] Gizlilik politikası güncelle (kredi sistemi, Firebase veri toplama)
- [ ] Kullanım koşulları hazırla
- [ ] KVKK uyumluluğu (Türkiye kullanıcıları için)
- [ ] GDPR uyumluluğu (AB kullanıcıları için, opsiyonel)
- [ ] Veri silme mekanizması (hesap silme butonu — App Store zorunlu)

### 7.7 Altyapı Dokümanları
- [ ] `store_listing.md` güncelle (yeni iş modeli, kredi bazlı açıklama)
- [ ] `privacy_policy.html` güncelle
- [ ] `landing_page.html` güncelle (B2B bölümü ekle)
- [ ] Admin panel landing page (butikler için kayıt sayfası)

---

## FAZ 8 — Yayın Sonrası (Ongoing)

### 8.1 İlk Hafta
- [ ] Crashlytics raporlarını günlük takip et
- [ ] Kullanıcı geri bildirimlerini topla
- [ ] Replicate API kullanımını ve maliyetini izle
- [ ] İlk butik ortağını bul ve pilot anlaşma yap

### 8.2 İlk Ay
- [ ] A/B test: kredi fiyatlandırması optimize et
- [ ] Kullanıcı retention metrikleri analiz et
- [ ] Push notification altyapısı (Firebase Cloud Messaging)
- [ ] İkinci/üçüncü butik ortaklıkları

### 8.3 Gelecek Özellikler (Backlog)
- [ ] Ayna Modu (Mirror Mode) — gerçek zamanlı kamera deneme (MediaPipe)
- [ ] Sosyal özellikler: sonuçları uygulama içinde paylaşma
- [ ] Favoriler listesi
- [ ] AI model kalitesini artırma (yeni Replicate modelleri test et)
- [ ] Farklı dil desteği (Arapça, Malezce, Endonezce)
- [ ] Android widget (günün başörtüsü önerisi)
- [ ] Butik admin panelinde detaylı analytics dashboard

---

## Zaman Çizelgesi Özeti

| Faz | Süre | Açıklama |
|-----|------|----------|
| Faz 0 | 1-2 gün | Firebase kurulum + kod temizliği |
| Faz 1 | 3-4 gün | Auth + kullanıcı sistemi |
| Faz 2 | 3-4 gün | Kredi sistemi |
| Faz 3 | 4-5 gün | Referans kod + butik kataloğu |
| Faz 4 | 5-7 gün | Admin paneli (Flutter Web) |
| Faz 5 | 4-5 gün | Ödeme entegrasyonu |
| Faz 6 | 5-7 gün | Test |
| Faz 7 | 3-5 gün | Yayına hazırlık |
| **TOPLAM** | **~28-39 gün** | **~5-7 hafta** |

---

## Kritik Bağımlılıklar

1. **Fiziksel cihaz olmadan test edilemez:** Kamera, galeri, in-app purchase
2. **Apple Developer hesabı:** iOS yayın + in-app purchase test
3. **Google Play hesabı:** Android yayın
4. **Stripe/iyzico hesabı:** B2B ödeme
5. **İlk butik ortağı:** Referans kod sistemini gerçek dünyada test etmek için en az 1 butik lazım
6. **Replicate kredi bakiyesi:** API çağrıları için yeterli bakiye ($5+ önerilen)
