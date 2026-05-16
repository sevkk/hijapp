# HIJAPP — Google Stitch UI Promptları

Bu dosyadaki her prompt Stitch'e ayrı ayrı girilecek. Sırasıyla gir, her ekranı oluşturduktan sonra bir sonrakine geç.

---

## PROMPT 1 — Onboarding + Auth (Login / Register)

```
CONTEXT:
HIJAPP is a mobile app for trying on hijab patterns virtually. Users upload their photo (wearing a hijab) and a product photo (hijab fabric), and AI replaces the existing hijab pattern with the new one. The app targets Muslim women aged 18-35 who shop for hijabs online.

Brand identity: Bold, warm, confident. Primary color: #D9078F (vivid magenta), Secondary: #6FB7BF (teal), Tertiary: #D99873 (warm tan), Surface: #F2BEA0 (peach), Dark text: #592512 (dark brown), Background: #FFF8F4 (warm white). Typography: Poppins. Rounded corners (16-20px radius). The overall feel should be bold yet warm — think modern fashion app with Middle Eastern warmth.

SCREEN SET: Design 3 connected mobile screens (iPhone 15 Pro size):

1. WELCOME / ONBOARDING SCREEN:
- Full-screen gradient background (magenta #D9078F to teal #6FB7BF, top-left to bottom-right)
- Centered app logo: circular mirror shape with flowing fabric silhouette
- App name "HIJAPP" in bold white Poppins
- Tagline below: "Hayalindeki başörtüsünü sanal olarak dene" (Try your dream hijab virtually)
- Two buttons at bottom:
  - Primary: "Giriş Yap" (Sign In) — white button with magenta text
  - Secondary: "Kayıt Ol" (Register) — outlined white button
- Subtle fabric texture pattern in background at low opacity

2. LOGIN SCREEN:
- Warm white background (#FFF8F4) with gradient header (compact, magenta-to-teal)
- "Tekrar Hoş Geldin" title in dark brown (#592512)
- Email input field with envelope icon
- Password input field with lock icon and show/hide toggle
- "Giriş Yap" primary gradient button (magenta-to-teal)
- "Şifremi Unuttum" text link below in teal
- Divider with "veya" (or) text
- "Google ile Giriş" button with Google icon
- Bottom text: "Hesabın yok mu? Kayıt Ol" with tappable link

3. REGISTER SCREEN:
- Same layout as login but with:
- "Aramıza Katıl" title (Join Us)
- Name input field with person icon
- Email input field
- Password input field (with strength indicator)
- "Kayıt Ol" primary gradient button
- Terms checkbox: "Kullanım koşullarını kabul ediyorum"
- Bottom text: "Zaten hesabın var mı? Giriş Yap"

DESIGN CONSTRAINTS:
- iOS-style safe area respect (notch/dynamic island)
- Minimum 48px touch targets
- Input fields: 56px height, 16px border radius, peach border (#E8D5CB), focus state with magenta border
- All text in Turkish
```

---

## PROMPT 2 — Home Screen + Hijab Selection

```
CONTEXT:
HIJAPP is a hijab virtual try-on app. Brand colors: Primary #D9078F (magenta), Secondary #6FB7BF (teal), Tertiary #D99873 (warm tan), Surface #F2BEA0 (peach), Text #592512 (dark brown), Background #FFF8F4. Font: Poppins. This is the main screen users see after logging in.

SCREEN: Home Screen (iPhone 15 Pro)

LAYOUT (top to bottom):
1. TOP BAR:
   - Left: "HIJAPP" logo text in gradient magenta-to-teal
   - Right: Credit balance badge showing "12 ✨" in a rounded pill shape with light peach background (#F2BEA0)
   - Right edge: Profile avatar circle (32px)

2. GREETING SECTION:
   - "Merhaba, Ayşe 👋" (Hello, Ayşe) — 20px semibold dark brown
   - "Bugün ne denemek istersin?" (What would you like to try today?) — 14px muted brown subtitle

3. ACTION CARD — "Referans Kodun Var Mı?" (Got a Referral Code?):
   - Horizontal card with gradient background (magenta-to-teal)
   - Left: Gift icon (white)
   - Text: "Referans kodu gir, ücretsiz dene!" (Enter referral code, try for free!)
   - Right: Arrow chevron
   - Full width, 16px border radius, subtle shadow

4. SECTION: "Son Kullandıkların" (Recently Used):
   - Horizontal scrollable row of circular hijab thumbnails (64px diameter)
   - Each with tiny fabric preview, border in magenta
   - Last item: dashed circle with "+" icon (add new)

5. SECTION: "Başörtüsü Seç" (Choose Hijab):
   - Two big action cards side by side:
     a. "Galeriden Seç" (Pick from Gallery) — camera roll icon, light peach bg
     b. "Fotoğraf Çek" (Take Photo) — camera icon, light teal bg (#6FB7BF/10)
   - Below: "Taslaklar" (Templates) card — full width, bookmark icon, shows "3 taslak" count

6. MODE SELECTION (bottom section):
   - Two large cards stacked:
     a. "📸 Fotoğraf Modu" — "Fotoğrafını yükle, AI dönüştürsün" subtitle, gradient magenta-teal border glow
     b. "🪞 Ayna Modu" — "Gerçek zamanlı dene" subtitle, dashed outlined style
   - Each card: 80px height, 20px radius, icon left-aligned

7. BOTTOM TAB BAR:
   - 4 tabs: Ana Sayfa (Home/active), Keşfet (Explore), Krediler (Credits), Profil (Profile)
   - Active tab: magenta icon + text, others: muted brown
   - Floating style with rounded corners and subtle shadow

DESIGN FEEL: Clean, warm, lots of white space. Cards have subtle shadows. Magenta and teal used as accents, warm browns and peach tones create warmth.
```

---

## PROMPT 3 — Photo Mode Flow (3 Screens)

```
CONTEXT:
HIJAPP — hijab virtual try-on app. Colors: #D9078F magenta, #6FB7BF teal, #D99873 warm tan, #F2BEA0 peach, #592512 dark brown, #FFF8F4 background. Font: Poppins. Turkish UI.

SCREEN SET: 3 connected screens showing the photo mode try-on flow.

SCREEN 1 — PHOTO MODE (Setup):
- Back arrow top left, "Fotoğraf Modu" title center, dark brown text
- Top section: Large preview area (rounded 20px, aspect ratio 3:4) showing:
  - If no photo selected: dashed border placeholder with camera icon + "Fotoğrafını Seç" text
  - If photo selected: user's photo with subtle overlay badge "✓ Fotoğraf seçildi"
- Middle section: Selected hijab preview
  - Small card showing hijab thumbnail + name "Pembe Çiçekli" with ✕ remove button
  - If no hijab: "Başörtüsü seçilmedi" placeholder
- Source buttons row: "Galeri" | "Kamera" | "Taslaklar" — three horizontal icon buttons
- Bottom: Large gradient CTA button "Dene! ✨" (Try!) — full width
  - Disabled state (gray) when photo or hijab not selected
  - Active state: magenta-to-teal gradient with white text
- Credit cost indicator: "1 kredi kullanılacak" small text above button

SCREEN 2 — PROCESSING (Loading):
- Same layout but photo area shows the selected photo with:
  - Frosted glass overlay (blur effect)
  - Centered: Animated circular progress indicator in magenta
  - Below spinner: "AI başörtüsünü değiştiriyor..." (AI is changing the hijab...)
  - Fun fact or tip text at bottom: "💡 Bilgi: Sonucu galeriye kaydedebilirsin"
- Bottom button disabled, showing "İşleniyor..."
- Top bar shows elapsed time "⏱ 12sn"

SCREEN 3 — RESULT:
- Full screen result image (edge to edge, safe area respected)
- Top: Semi-transparent dark overlay bar with back arrow and "Sonuç" title
- Bottom action bar (floating, rounded, frosted glass background):
  - Row of 4 icon buttons:
    - 💾 "Kaydet" (Save to gallery)
    - 📤 "Paylaş" (Share)
    - 🔄 "Tekrar Dene" (Try again)
    - 🛒 "Satın Al" (Buy — only visible if from boutique catalog)
  - Below: "Kalan kredin: 11 ✨" text

TRANSITIONS: Show subtle connection between screens (arrows or flow indicators).
```

---

## PROMPT 4 — Credits Screen (B2C Purchase)

```
CONTEXT:
HIJAPP — hijab try-on app. Credit-based monetization. No subscription. Users buy credit packs to try on hijab patterns. 1 try = 1 credit. Colors: #D9078F magenta, #6FB7BF teal, #D99873 warm tan, #F2BEA0 peach, #592512 dark brown, #FFF8F4 background. Poppins font. Turkish.

SCREEN: Credits / Purchase Screen (iPhone 15 Pro)

LAYOUT:
1. HEADER (gradient magenta-to-teal, rounded bottom 3rem):
   - Back arrow (white)
   - "Krediler" title (white, bold)
   - Large centered credit balance: "12 ✨" in big 48px bold white text
   - Below: "Kalan Kredin" (Your remaining credits) in white 80% opacity
   - Pill badge: "Her deneme 1 kredi" with info icon

2. HOW IT WORKS section:
   - "Nasıl Çalışır?" subheading in magenta
   - 3 horizontal steps with colored circle icons:
     - Step 1: Magenta circle — "Fotoğraf Seç"
     - Step 2: Teal circle — "Model Belirle"
     - Step 3: Warm tan circle — "AI Dönüşümü"

3. CREDIT PACKAGES:
   - "Kredi Paketleri" section title in magenta
   - 3 vertical cards:

   Card 1: "10 Kredi" — $2.99 — "$0.30/kredi" — standard card, white bg, subtle border
   Card 2: "25 Kredi" — $5.99 — "$0.24/kredi" — highlighted with "Popüler" magenta gradient badge top-right, slightly larger, magenta border, scale 1.02
   Card 3: "50 Kredi" — $9.99 — "$0.20/kredi" — "En Avantajlı" gold badge (#FFD700 accent)

   Each card: white bg, 16px radius, subtle shadow, magenta gradient "Satın Al" button

4. REFERRAL CODE SECTION:
   - Divider line
   - "Referans kodun var mı?" text with gift icon
   - Text input field + teal "Uygula" (Apply) button inline
   - Small text: "Butik referans kodu ile ücretsiz kredi kazan"

5. FOOTER:
   - "Güvenli ödeme • Apple Pay & Google Pay" with lock icon
   - Legal text link: "Kullanım Koşulları" in teal

DESIGN: Premium feel, credit balance as valuable currency. Clear visual hierarchy.
```

---

## PROMPT 5 — Referral Code Entry + Boutique Catalog

```
CONTEXT:
HIJAPP — hijab try-on app with B2B referral system. Hijab-selling BOUTIQUES give referral codes to their potential CUSTOMERS. This is NOT a friend-invite system. A boutique creates codes, distributes them (via Instagram, in-store etc.), and when a customer enters the code in the app, they see THAT BOUTIQUE'S product catalog and receive free trial credits. Colors: #D9078F magenta, #6FB7BF teal, #D99873 warm tan, #F2BEA0 peach, #592512 dark brown, #FFF8F4 background. Poppins. Turkish.

SCREEN SET: 2 connected screens.

SCREEN 1 — REFERRAL CODE ENTRY:
- Gradient hero section (magenta-to-teal) at top with rounded bottom
- Large gift icon in white circle (glassmorphism)
- Title: "Referans Kodu Gir" (Enter Referral Code) — white, 24px bold
- Subtitle: "Butikten aldığın kodu gir, ücretsiz dene!" (Enter the code from your boutique, try for free!) — white/90
- White card overlay with:
  - Code input field: centered text, letter-spacing 4px, uppercase, monospace font
  - Placeholder: "BUTIK-XXXX"
  - Magenta "Kodu Kullan" button with sparkle icon
  - Helper text: "Kod bulamadın mı? Favori butiğinden iste!"

- SUCCESS STATE (show as second variation):
  - Teal checkmark icon in circle
  - "Tebrikler!" (Congratulations!) — dark brown bold
  - "Ayşe Eşarp Butik size 5 deneme kredisi hediye etti"
  - Magenta "Ürünleri Keşfet" button with store icon → navigates to boutique catalog

- BELOW: "Nasıl Çalışır?" section with 3 numbered steps:
  1. Magenta circle "Butikten Kod Al"
  2. Teal circle "Kodu Gir"
  3. Warm tan circle "Ücretsiz Dene"

SCREEN 2 — BOUTIQUE CATALOG (opened after successful code entry):
- Top: Boutique banner header with gradient (magenta-to-teal), rounded bottom
  - Back arrow (white)
  - Boutique logo (circular, 56px, white border) + name "Ayşe Eşarp Butik" bold white
  - Instagram handle "@aysesarp" in white/80, tappable
  - Pill badge: "5 ✨ kalan krediniz" with sparkle icon

- Product grid (2 columns):
  - Each product card (white bg, 16px radius, subtle shadow):
    - Product image (hijab fabric photo, aspect 4:5, rounded top)
    - Product name: "Pembe Çiçekli İpek" — dark brown semibold
    - Price: "₺249" in magenta
    - Magenta "Dene" button with sparkle icon — small pill
    - "Satın Al" text link in teal with external link icon
  - Show 6 products

- Bottom floating bar (white/80 glassmorphism):
  - Boutique mini logo + name
  - Remaining credits pill: "5 kredi" in teal

IMPORTANT: This is NOT a general catalog or e-commerce page. Products belong to a specific boutique and are only visible after entering that boutique's referral code. The boutique's brand identity should be prominent.
```

---

## PROMPT 6 — Boutique Admin Panel (Web Dashboard)

```
CONTEXT:
HIJAPP Admin Panel — a web dashboard for hijab boutique owners to manage their products, referral codes, and credits on the HIJAPP platform. Boutiques upload their hijab products, create referral codes for customers, and track usage analytics. Brand colors: #D9078F magenta, #6FB7BF teal, #D99873 warm tan, #F2BEA0 peach, #592512 dark brown, #FFF8F4 background — with a more professional/dashboard feel. Poppins font. Turkish UI. Desktop layout (1440px wide).

SCREEN: Admin Dashboard (Main View after login)

LAYOUT:
1. LEFT SIDEBAR (240px, white bg, full height):
   - Top: HIJAPP logo + "Butik Paneli" subtitle in dark brown
   - Nav items with icons:
     - 📊 "Gösterge Paneli" (Dashboard) — active state: magenta bg tint (#D9078F/10)
     - 📦 "Ürünler" (Products)
     - 🏷️ "Referans Kodlar" (Referral Codes)
     - 💰 "Krediler" (Credits)
     - ⚙️ "Ayarlar" (Settings)
   - Bottom: Boutique name + avatar, "Çıkış Yap" (Logout)

2. MAIN CONTENT:
   a. TOP BAR:
      - Page title: "Gösterge Paneli" in dark brown
      - Right: Notification bell + boutique name + avatar dropdown

   b. STAT CARDS ROW (4 cards):
      - "Kalan Kredi": 847 — magenta icon circle, green trend arrow
      - "Aktif Kodlar": 12 — teal icon circle
      - "Toplam Müşteri": 234 — warm tan icon circle
      - "Bu Ay Deneme": 156 — peach icon circle
      Each card: white, rounded 12px, subtle shadow

   c. CHART SECTION (2 columns):
      - Left (60%): "Son 30 Gün — Kullanım" line chart
        - Gradient fill under the line (magenta)
      - Right (40%): "Kod Performansı" — donut chart
        - Segments in magenta, teal, warm tan, peach colors

   d. RECENT ACTIVITY TABLE:
      - "Son İşlemler" title
      - Columns: Tarih | Müşteri | Referans Kod | İşlem | Kredi
      - Clean table with alternating warm white/peach row colors
      - Pagination at bottom

3. FLOATING ACTION:
   - Bottom-right: "Yeni Kod Oluştur" magenta gradient FAB with + icon

DESIGN: Professional, data-rich but not cluttered. White and warm tones dominate, magenta for primary actions, teal for secondary elements.
```

---

## PROMPT 7 — Admin: Product Management

```
CONTEXT:
HIJAPP Boutique Admin Panel — web dashboard. Product management page where boutique owners add, edit, and organize their hijab products. These products appear in the mobile app when customers enter the boutique's referral code. Desktop (1440px). Colors: #D9078F magenta, #6FB7BF teal, #D99873 warm tan, #592512 dark brown, #FFF8F4 background. Poppins. Turkish.

SCREEN: Products Page with Add Product Modal

LEFT SIDEBAR: Same as dashboard (Products tab active with magenta highlight)

MAIN CONTENT:
1. PAGE HEADER:
   - "Ürünler" title in dark brown
   - Right: "Ürün Ekle" magenta gradient button with + icon
   - Search input: "Ürün ara..." (Search products)
   - Filter: "Tümü | Aktif | Pasif" toggle pills

2. PRODUCT GRID (3 columns):
   - Each product card (white, 12px radius, shadow):
     - Product image (square, top of card, 1:1 aspect ratio)
     - Name: "Pembe Çiçekli İpek Eşarp" — bold 14px dark brown
     - Price: "₺249" — magenta text
     - Status badge: "Aktif" teal pill or "Pasif" gray pill
     - Stats row: "👁 45 görüntülenme • 12 deneme"
     - Action icons: Edit (pencil) | Deactivate (eye-slash) | Delete (trash, red)
   - Show 6 product cards

3. ADD PRODUCT MODAL (overlaying, centered, 560px wide):
   - Title: "Yeni Ürün Ekle" dark brown
   - Image upload area: Dashed border rectangle, drag-drop zone
     - "Ürün fotoğrafını sürükle veya seç" text
     - "JPG, PNG — max 5MB" subtitle
   - Form fields with peach borders, magenta focus state:
     - "Ürün Adı" text input
     - "Fiyat" text input with "₺" prefix
     - "Satın Alma Linki" URL input
     - "Sıra" number input
   - Toggle: "Aktif" — on/off switch
   - Buttons: "İptal" (Cancel, outlined) | "Ürünü Ekle" (magenta gradient)

DESIGN: Clean, functional. Modal with frosted backdrop.
```

---

## PROMPT 8 — Admin: Referral Code Management

```
CONTEXT:
HIJAPP Boutique Admin Panel — web dashboard for hijab boutique owners. Referral code management page where boutiques create and manage codes that give their customers free trial credits on the HIJAPP mobile app. Desktop 1440px. Colors: #D9078F magenta, #6FB7BF teal, #D99873 warm tan, #592512 dark brown, #FFF8F4 background. Poppins. Turkish.

SCREEN: Referral Codes Page with Create Code Modal

LEFT SIDEBAR: Same (Referral Codes tab active)

MAIN CONTENT:
1. PAGE HEADER:
   - "Referans Kodlar" title dark brown
   - Subtitle: "Kalan kredi havuzu: 847 ✨" in a teal pill badge
   - Right: "Yeni Kod Oluştur" magenta gradient button

2. CODES TABLE (full width):
   - Column headers in dark brown
   - Sample rows:
     - AYSE-VIP | 10 kredi | 23/50 kullanım | 🟢 Aktif | 15 Mar 2026 | 15 Jun 2026 | [Düzenle] [Durdur]
     - AYSE-INSTA | 5 kredi | 112/∞ | 🟢 Aktif | 01 Mar 2026 | — | [Düzenle] [Durdur]
     - AYSE-FUAR | 3 kredi | 50/50 | 🔴 Tükendi | 20 Feb 2026 | 28 Feb 2026 | [Düzenle]
     - AYSE-TEST | 1 kredi | 5/10 | ⏸️ Durduruldu | 10 Jan 2026 | — | [Düzenle] [Etkinleştir]
   - Progress bar in "Kullanım" column (magenta gradient fill)
   - Row hover: subtle peach tint (#F2BEA0/20)

3. CODE STATS CARDS (above table, 3 cards):
   - "Toplam Kodlar": 8 — magenta icon
   - "Aktif Kodlar": 4 — teal icon
   - "Dağıtılan Kredi": 523 — warm tan icon

4. CREATE CODE MODAL (centered, 480px wide):
   - Title: "Yeni Referans Kodu Oluştur"
   - Form:
     - "Kod Adı" — text input, uppercase, placeholder: "BUTIK-XXXX"
       - "Otomatik Oluştur" small teal text button
     - "Kişi Başı Kredi" — number input with +/- stepper buttons
       - Dynamic text: "Bu kod için toplam: X kredi havuzunuzdan düşecek"
     - "Maksimum Kullanım" — number input
       - Toggle: "Sınırsız" checkbox
     - "Son Kullanma Tarihi" — date picker
       - Toggle: "Süresiz" checkbox
   - Warning box: "⚠️ Havuzunuzda 847 kredi kaldı. Bu ayarlarla en fazla 84 müşteri kullanabilir."
   - Buttons: "İptal" (outlined) | "Kodu Oluştur" (magenta gradient)

DESIGN: Data-focused, professional. Color-coded status badges. Progress bars use magenta gradient fill.
```

---

## KULLANIM TALİMATI

1. Stitch'e her promptu ayrı ayrı gir
2. Her ekranı oluşturduktan sonra gerekirse "make the buttons larger" gibi küçük düzeltme promptları ver
3. Tüm ekranlar tamamlandığında Stitch'in export özelliğiyle Figma veya PNG olarak dışarı al
4. Ekranlar arası bağlantı için Stitch'in "flow" özelliğini kullan

**Renk Paleti Referansı:**
| Rol | Hex | Açıklama |
|-----|-----|----------|
| Primary | #D9078F | Vivid magenta — ana marka rengi, CTA butonlar |
| Secondary | #6FB7BF | Teal — tamamlayıcı, ikincil aksiyonlar |
| Tertiary | #D99873 | Warm tan — aksan, üçüncül öğeler |
| Surface | #F2BEA0 | Peach — kart yüzeyleri, badge'ler |
| Dark/Text | #592512 | Dark brown — başlıklar, metin |
| Background | #FFF8F4 | Warm white — sayfa arka planı |

**Sıra önerisi:** Prompt 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8
(Önce mobil app, sonra admin panel)
