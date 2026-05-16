# HIJAPP — Uygulama Özeti ve Model Araştırma Briefi

## Uygulama Nedir?

HIJAPP, başörtüsü takan kadınların satın almak istedikleri başörtüsü desenini kendi fotoğraflarında veya gerçek zamanlı kamera görüntüsünde (ayna modu) deneyebildiği bir mobil uygulamadır. Kullanıcı zaten başörtülü olan kendi fotoğrafını yükler, denemek istediği ürünün fotoğrafını yükler, yapay zeka mevcut başörtüsünün desenini yeni ürünün deseniyle değiştirir.

## Nasıl Çalışıyor?

İki modu var:

Fotoğraf Modu: Kullanıcı kendi fotoğrafını ve denemek istediği başörtüsünün fotoğrafını yükler. AI işlem yapar, sonucu gösterir. Kullanıcı kaydeder veya paylaşır.

Ayna Modu: Kullanıcı kamerayı açar, seçtiği deseni gerçek zamanlı olarak kendi başörtüsünde görür. Fotoğraf veya video çekebilir.

## Teknik Altyapı

- Flutter (iOS + Android, tek codebase)
- State management: Riverpod
- Gerçek zamanlı yüz tespiti: Google ML Kit (MediaPipe Face Detection)
- Fotoğraf modu AI: Şu an Replicate API üzerinden prunaai/p-image-edit modeli
- Tüm kullanıcı fotoğrafları cihazda kalır, sunucuya yüklenmez

## İş Modeli

Freemium: Ücretsiz kullanıcılar günde sınırlı sayıda deneme yapabilir (reklam destekli). Premium kullanıcılar ($4.99/ay veya $29.99/yıl) daha yüksek günlük limit, video kayıt ve reklamsız deneyim alır.

## Mevcut Durum ve Sorun

Fotoğraf modunda prunaai/p-image-edit modelini kullanıyoruz. Sonuç kalitesi çok iyi ama işlem başı maliyet $0.01. Kullanıcı sayısı artınca bu maliyet sürdürülebilir değil — özellikle ücretsiz kullanıcılar ve yoğun kullanan premium kullanıcılar için kâr marjı çok dar.

## Araştırılması Gereken Konu

Fotoğraf modunda kullanılabilecek alternatif AI modelleri arıyoruz. Amaç: aynı veya yakın kalitede sonuç, daha düşük maliyet. İdeal senaryo cihaz üzerinde (on-device) çalışan bir model bulmak — bu durumda API maliyeti tamamen sıfır olur.

## Aradığımız Model Özellikleri

1. Girdi: Bir kişi fotoğrafı (başörtülü) + bir başörtüsü ürün fotoğrafı (desen/renk)
2. Çıktı: Kişinin fotoğrafındaki başörtüsü deseninin ürün fotoğrafındaki desenle değiştirilmiş hali
3. Bu aslında bir "virtual try-on" problemi ama giysi yerine başörtüsü odaklı
4. Kalite gereksinimleri: Fotogerçekçi sonuç, doğal ışık/gölge uyumu, kumaş kıvrımlarına uygun desen yerleşimi

## Şu Ana Kadar Bilinen Alternatifler

API bazlı (bulut):
- prunaai/p-image-edit (Replicate) — şu anki, $0.01/işlem, kalite çok iyi
- IDM-VTON (Replicate) — $0.025/işlem, SOTA seviyesi virtual try-on
- FASHN VTON v1.6 (fashn.ai) — $0.075/işlem, profesyonel kalite
- CatVTON (Replicate) — $0.01-0.02/işlem, hafif model (899M parametre)

Açık kaynak (self-host):
- CatVTON — <8GB VRAM, açık kaynak, en hafif seçenek
- FASHN VTON v1.5 — ~8GB VRAM, açık kaynak, mask gerektirmiyor
- IDM-VTON — ~16GB VRAM, en yüksek kalite ama ağır
- OOTDiffusion — ~12GB VRAM, olgun proje (6.3k GitHub star)

Cihaz üzerinde (on-device):
- Henüz uygun model bulunamadı. Virtual try-on modelleri çok ağır (en hafifi 899M parametre), telefonda çalıştırmak şu an gerçekçi değil.

## Mevcut Rakipler

- TryHijab (tryhijab.com) — Web tabanlı, başörtüsüz fotoğrafa hijab ekliyor (farklı kullanım senaryosu)
- HijabAI (hijabai.com) — App Store + Play Store'da var, AI hijab headshot üretiyor (farklı kullanım senaryosu)
- Hijab.studio — Ücretsiz web aracı, basit hijab try-on
- Pixelcut AI — Genel amaçlı hijab photo editor

Not: Bu rakiplerin hiçbiri bizim yaptığımız şeyi yapmıyor. Onlar başörtüsüz birine hijab ekliyor, biz ise zaten başörtülü birinin desenini değiştiriyoruz. Farklı bir pazar segmentindeyiz.

## Sorular

1. Daha ucuz veya ücretsiz çalışan başka virtual try-on modelleri var mı?
2. On-device çalışabilecek hafif bir segmentasyon + texture transfer pipeline'ı kurulabilir mi?
3. Self-host için en düşük maliyetli GPU sunucu seçenekleri neler? (RunPod, Vast.ai, Lambda vb.)
4. Image inpainting veya style transfer tabanlı alternatif yaklaşımlar denenebilir mi?
5. Kendi özel modelimizi fine-tune etmek mantıklı mı, ne kadar veri ve süre gerektirir?
