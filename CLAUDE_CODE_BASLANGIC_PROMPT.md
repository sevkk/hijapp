# Claude Code Başlangıç Prompt'u

> Bunu Claude Code oturumunu açtığında **ilk mesaj olarak** yapıştır.
> Code, projeyi okuyup yol haritasını anlayacak ve adım adım ilerleyecek.

---

```
HIJAPP projesinde 2 ay aradan sonra devam ediyoruz. Strateji ve tüm tasarım kararları
HIJAPP_SPEC_v2.md dosyasında, manuel/operasyonel iş listesi HIJAPP_MANUEL_LISTE.md'de.

Önce bu iki dosyayı oku ve özümse:
1. HIJAPP_SPEC_v2.md (Bölüm 0'daki karar özetine özellikle dikkat et)
2. HIJAPP_MANUEL_LISTE.md (E bölümü çözülmüş kararları içeriyor)

Mevcut durum:
- Firebase projesi hazır, Blaze plan (500 TL aylık limit ile), Authentication açık,
  Firestore boş ve temiz, Cloud Functions aktivasyonu deployment sırasında olacak,
  Storage henüz manuel aktive edilmemiş olabilir (ürün görseli aşamasına gelene kadar
  sorun değil)
- Replicate token aktif, $9.94 bakiye
- Mart-Nisan 2026 arasında ~125 dosya değişikliği commit'lenmemiş halde duruyor
- prunaai/p-image-edit modeli kullanılıyor, mirror mode atıldı
- lib/ altında auth, credits, boutique, photo_mode feature'ları kısmen yazılmış ama
  yeni spec'le tutarsız (eski magenta+teal paleti, BoutiqueProductModel'de price var,
  try_on_events yok, vs.)

Yapılacak iş — Spec Bölüm 7'deki build sırasıyla:

ADIM 1 — Git temizliği
- git status'a bak, 2 ay önceki işleri mantıklı commit gruplarına böl
- En azından şu commit'ler olsun:
  - feat: faz 0 firebase init ve config dosyaları
  - feat: faz 1 auth servis ve ekranları (firebase auth, login/register/onboarding)
  - feat: faz 2 kredi modelleri (user_model güncellemesi, transaction_model)
  - feat: faz 3 butik modelleri ve ekranları (boutique, referral, credits screens)
  - chore: admin panel scaffold (hijapp_admin/)
  - chore: dokumantasyon (HIJAPP_ROADMAP, HIJAPP_ARCHITECTURE, STITCH_PROMPTS)
- Her commit öncesi dosyaları kısaca incele, yanlışlıkla hassas veri (.env, gerçek
  API key) varsa beni uyar, ben çıkarayım sonra commit'le

ADIM 2 — Build sağlığı
- flutter pub get
- flutter analyze (uyarıları listele, hangileri Mart'tan beri SDK uyumsuzluğu)
- flutter test (var olan testler hâlâ geçiyor mu)
- Kırıklar varsa minimum müdahale ile düzelt, ana refactor sonraki adımlarda

ADIM 3 — Tema migrasyonu (Spec Bölüm 5)
- lib/app/theme.dart'ı tamamen yeniden yaz, AppColors sınıfını ekle
- google_fonts paketini pubspec.yaml'a ekle, Playfair Display + Inter kur
- Eski palette renklerini (magenta, teal, tan, peach, brown) tüm ekranlardan temizle
- 9 ekranı gez, hard-coded renkleri AppColors'a çevir
- Bu adım sonunda commit: feat: tema migrasyonu - Saray paleti (bordo + krem + altın)

ADIM 4 — Model güncellemeleri (Spec Bölüm 3)
- BoutiqueProductModel: price ve purchaseUrl'ü çıkar, boutiqueWebsiteUrl ekle (opsiyonel),
  tryOnCount, last30DaysCount, category alanları ekle
- BoutiqueModel: totalTryOns, last30DaysTryOns, productCategories, plan ekle
- ReferralCodeModel: totalCreditsGranted, redeemedByUsers, campaignTag ekle
- Yeni model: TryOnEvent (lib/core/models/try_on_event_model.dart)
- firestore_service.dart'a şu metotları ekle:
  - logTryOnEvent(...)
  - getBoutiqueAnalytics(boutiqueId, dateRange)
  - getTopProducts(boutiqueId, limit)
  - getProductsByCategory(boutiqueId, category)

ADIM 5 — Result screen analytics logging
- result_screen.dart'ta her başarılı try-on'da:
  - try_on_events koleksiyonuna yeni doküman
  - boutique_products/{productId}.tryOnCount += 1 (FieldValue.increment)
  - boutique.totalTryOns += 1
- Hata durumunda event succeeded=false ile loglansın

ADIM 6 — Admin panel doldurma (Spec Bölüm 6) — Bunu çok parçalara ayır:
- 6a: hijapp_admin/lib/app/theme.dart (mobile ile paylaşılan AppColors'u import et)
- 6b: Login sayfası (/login)
- 6c: Genel bakış (/dashboard) — metric cards + en çok denenen ürünler + son denemeler
- 6d: Vitrin yönetimi (/products) — CRUD + drag&drop sortOrder + görsel yükleme
- 6e: Kodlar (/codes) — CRUD + kampanya tag + bakiye rezervasyonu
- 6f: Analitik (/analytics) — fl_chart ile günlük try-on grafiği + ürün tablosu
- 6g: Kredi satın alma (/billing) — paket kartları (iyzico entegrasyonu sonraki faz)
- 6h: Ayarlar (/settings)

ADIM 7 — Cloud Functions (functions/ dizini)
- onTryOnComplete: counter güncelleme, batch yazma
- onCodeRedeem: butik bakiyesi düşüşü + user credit yükleme + transaction kaydı
- weeklyBoutiqueReport: haftalık özet email (Cloud Scheduler ile pazartesi 09:00 TR)
- Firebase Functions emulator ile lokal test et

ADIM 8 — Ödeme entegrasyonu (önce iyzico)
- Functions'a iyzico checkout endpoint'i
- Admin panel /billing sayfasında ödeme akışı
- Webhook ile transaction tamamlama
- Test mode'da başla

ADIM 9 — Reusable widget'ları topla (Spec Bölüm 8)
- lib/core/widgets/ altında: BrandButton, BrandCard, StatTile, EmptyState,
  BoutiqueChip, CreditBadge, TryOnSparkline
- Önceki ekranları bu widget'ları kullanacak şekilde refactor et

ADIM 10 — Testler
- Birim testler: auth_service, credit_service, firestore_service
- Widget testler: login, register, photo_mode_screen, result_screen
- 1 entegrasyon testi: kod kullanma akışı (kod gir → kredi yükle → try-on yap → event log)

Önemli kurallar:
- HER adım sonunda commit at
- API key, token, gerçek email gibi hassas veriyi koda HARDCODE ETME, .env veya
  Firebase Remote Config kullan
- Şema değişikliklerinde Firestore security rules da güncelle
- Adım 6'da admin paneli mobile-responsive olsun ama öncelik desktop
- Tema renklerini sadece AppColors üzerinden kullan, hex değerlerini ekrana yazma
- Türkçe metin için: dosya bazında AppStrings sınıfı kur, sonradan i18n için kolay olsun
- Bir adımda sıkışırsan beni durdur, sonraki adıma geçme

İlk işin Adım 1: git temizliği. git status çıktısını göster ve commit planını
önce bana özet halinde sun, onaylayınca uygula.
```

---

## Kullanım

1. Terminal aç → `cd C:\Users\Gaming\Desktop\PROJELER\HIJAPP`
2. Claude Code başlat: `claude` (kurulu değilse: `npm install -g @anthropic-ai/claude-code`)
3. Yukarıdaki kod bloğunun **tamamını** kopyala, ilk mesaj olarak yapıştır
4. Code spec'i okuyup git planını önerecek, sen onayla → işler başlar

## Code Çalışırken Aklında Olsun

- Code uzun bir prompt zinciri çalıştırır, oturumu bir kerede bitmeyebilir. Aynı
  oturuma devam etmek için `claude --resume` kullan.
- Her commit'i Code at, sen `git log` ile takip et.
- Kafan karışırsa "şimdi hangi adımdayız" diye sor, Code TaskList tutar.
- Replicate API key'i .env'e koyarken: `flutter pub get` sonrası `flutter_dotenv`
  paketi ekleyecek, .env dosyasını .gitignore'a eklemesini iste.

## Sıkıştığında Bana Gel

- Tasarım kararı gerekiyorsa (yeni ekran, palet sapması, UX seçim) → Cowork moduna
  dön, ben karar veririm.
- Yeni iş kararı (yeni paket fiyatı, yeni butik feature) → keza buraya dön.
- Sadece kod yazımı / hata ayıklama → Code'da kal.
