import { Link } from 'react-router-dom';
import { ArrowLeft, Info, Camera, CheckCircle2, Sparkles, Gift, Lock } from 'lucide-react';
import BottomNav from '../components/BottomNav';

export default function Credits() {
  return (
    <div className="bg-surface text-on-surface min-h-screen pb-32">
      <header className="flex items-center justify-between px-6 py-4 w-full z-50 fixed top-0 bg-gradient-to-r from-[#D9078F] to-[#6FB7BF]">
        <div className="flex items-center gap-4">
          <Link to="/home" className="text-[#592512] cursor-pointer">
            <ArrowLeft className="w-6 h-6" />
          </Link>
          <h1 className="font-headline font-bold text-lg text-[#592512]">Krediler</h1>
        </div>
        <div className="w-10"></div>
      </header>

      <section className="pt-24 pb-12 px-6 bg-gradient-to-b from-[#D9078F] via-[#6FB7BF] to-surface rounded-b-[3rem] text-center shadow-sm">
        <div className="flex flex-col items-center">
          <span className="text-[48px] font-extrabold text-white drop-shadow-md leading-tight">12 ✨</span>
          <p className="text-white/80 font-medium tracking-wide mt-1">Kalan Kredin</p>
          <div className="mt-8 inline-flex items-center bg-white/20 backdrop-blur-md px-4 py-2 rounded-full border border-white/30">
            <Info className="w-4 h-4 text-white mr-2 fill-current" />
            <span className="text-xs text-white font-semibold">Her deneme 1 kredi</span>
          </div>
        </div>
      </section>

      <main className="px-6 -mt-6">
        <div className="bg-surface-container-lowest rounded-2xl p-6 shadow-sm mb-8">
          <h2 className="text-lg font-bold text-primary mb-6">Nasıl Çalışır?</h2>
          <div className="grid grid-cols-3 gap-4 relative">
            <div className="flex flex-col items-center text-center z-10">
              <div className="w-12 h-12 rounded-full bg-primary-fixed flex items-center justify-center mb-3">
                <Camera className="w-6 h-6 text-primary" />
              </div>
              <p className="text-[10px] font-bold uppercase tracking-tight text-on-surface-variant">Fotoğraf Seç</p>
            </div>
            <div className="flex flex-col items-center text-center z-10">
              <div className="w-12 h-12 rounded-full bg-secondary-fixed flex items-center justify-center mb-3">
                <CheckCircle2 className="w-6 h-6 text-secondary" />
              </div>
              <p className="text-[10px] font-bold uppercase tracking-tight text-on-surface-variant">Model Belirle</p>
            </div>
            <div className="flex flex-col items-center text-center z-10">
              <div className="w-12 h-12 rounded-full bg-tertiary-fixed flex items-center justify-center mb-3">
                <Sparkles className="w-6 h-6 text-tertiary" />
              </div>
              <p className="text-[10px] font-bold uppercase tracking-tight text-on-surface-variant">AI Dönüşümü</p>
            </div>
            <div className="absolute top-6 left-1/4 w-1/2 h-[1px] bg-outline-variant/30"></div>
          </div>
        </div>

        <div className="mb-8">
          <h2 className="text-lg font-bold text-primary mb-4 px-2">Kredi Paketleri</h2>
          <div className="flex flex-col gap-4">
            <div className="relative bg-surface-container-lowest rounded-2xl p-5 flex items-center justify-between border border-outline-variant/20">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-2xl bg-primary-container/20 flex items-center justify-center">
                  <span className="text-2xl">🪙</span>
                </div>
                <div>
                  <h3 className="font-bold text-on-surface">10 Kredi</h3>
                  <p className="text-xs text-on-surface-variant">$0.30 / kredi</p>
                </div>
              </div>
              <div className="text-right">
                <p className="font-bold text-primary mb-2">$2.99</p>
                <button className="bg-primary-gradient text-on-primary-container text-xs font-bold px-4 py-2 rounded-full shadow-sm hover:opacity-90 transition-opacity">Satın Al</button>
              </div>
            </div>

            <div className="relative bg-surface-container-lowest rounded-2xl p-6 flex items-center justify-between border-2 border-primary-container shadow-md scale-[1.02] z-10 overflow-hidden">
              <div className="absolute top-0 right-0 bg-gradient-to-l from-primary to-secondary text-white text-[10px] font-bold px-4 py-1 rounded-bl-xl uppercase tracking-widest">
                Popüler
              </div>
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-2xl bg-primary-gradient flex items-center justify-center shadow-inner">
                  <span className="text-2xl">🌟</span>
                </div>
                <div>
                  <h3 className="font-extrabold text-on-surface text-lg">25 Kredi</h3>
                  <p className="text-xs text-on-secondary-container font-medium">$0.24 / kredi</p>
                </div>
              </div>
              <div className="text-right">
                <p className="font-black text-primary text-xl mb-2">$5.99</p>
                <button className="bg-primary-gradient text-on-primary-container text-sm font-extrabold px-6 py-2.5 rounded-full shadow-md hover:scale-105 transition-transform">Satın Al</button>
              </div>
            </div>

            <div className="relative bg-surface-container-lowest rounded-2xl p-5 flex items-center justify-between border border-outline-variant/20">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-2xl bg-tertiary-container/20 flex items-center justify-center">
                  <span className="text-2xl">💎</span>
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className="font-bold text-on-surface">50 Kredi</h3>
                    <span className="bg-[#FFD700]/20 text-[#8B6914] text-[9px] font-bold px-1.5 py-0.5 rounded border border-[#FFD700]/30 uppercase tracking-tighter">En Avantajlı</span>
                  </div>
                  <p className="text-xs text-on-surface-variant">$0.20 / kredi</p>
                </div>
              </div>
              <div className="text-right">
                <p className="font-bold text-primary mb-2">$9.99</p>
                <button className="bg-primary-gradient text-on-primary-container text-xs font-bold px-4 py-2 rounded-full shadow-sm hover:opacity-90 transition-opacity">Satın Al</button>
              </div>
            </div>
          </div>
        </div>

        <div className="pt-6 border-t border-outline-variant/10 mb-12">
          <div className="flex items-center gap-3 mb-4">
            <Gift className="w-5 h-5 text-primary" />
            <p className="text-sm font-semibold text-on-surface-variant">Referans kodun var mı?</p>
          </div>
          <div className="flex gap-2">
            <input type="text" placeholder="Kodunuzu girin" className="flex-1 h-12 px-4 rounded-2xl bg-surface-container-lowest border border-outline-variant/20 focus:ring-2 focus:ring-secondary/20 focus:border-secondary transition-all outline-none text-sm font-medium" />
            <button className="h-12 px-6 bg-secondary text-white font-bold rounded-2xl text-sm hover:opacity-90 transition-opacity">Uygula</button>
          </div>
        </div>

        <footer className="flex flex-col items-center gap-4 text-center pb-8">
          <div className="flex items-center gap-2 text-on-surface-variant/60 text-xs">
            <Lock className="w-4 h-4 fill-current" />
            <span>Güvenli ödeme • Apple Pay & Google Pay</span>
          </div>
          <a href="#" className="text-secondary text-xs font-bold underline underline-offset-4 decoration-secondary/30">Kullanım Koşulları</a>
        </footer>
      </main>

      <BottomNav />
    </div>
  );
}
