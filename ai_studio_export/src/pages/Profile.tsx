import { Link } from 'react-router-dom';
import { Settings, ChevronRight, CreditCard, Bell, HelpCircle, LogOut, Edit2 } from 'lucide-react';
import BottomNav from '../components/BottomNav';

export default function Profile() {
  return (
    <div className="bg-surface text-on-surface min-h-screen pb-32">
      <header className="bg-[#FFF8F4]/80 backdrop-blur-xl fixed top-0 z-40 w-full px-6 h-16 flex items-center justify-between shadow-sm">
        <h1 className="text-2xl font-extrabold tracking-tight text-primary">Profil</h1>
        <button className="w-10 h-10 rounded-full bg-surface-container-low flex items-center justify-center text-on-surface-variant active:scale-95 transition-transform">
          <Settings className="w-5 h-5" />
        </button>
      </header>

      <main className="pt-24 px-6 space-y-6">
        <section className="bg-surface-container-lowest rounded-3xl p-6 shadow-sm border border-outline-variant/20 flex flex-col items-center text-center relative">
          <button className="absolute top-4 right-4 w-8 h-8 rounded-full bg-surface-container flex items-center justify-center text-on-surface-variant active:scale-90 transition-transform">
            <Edit2 className="w-4 h-4" />
          </button>
          
          <div className="w-24 h-24 rounded-full overflow-hidden border-4 border-primary-container mb-4 relative">
            <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuDX87ihe1Whsa0PBuxElsyNMEgXRaaDESEBc5cLEsFOaJI4k-stJPp6uv6hL3IMR7w0kToGxx8ZiHc2lhKV0vF8hUvfOAD8IZAhdWejVtfX1LvxYxgRy_QX4XxOC7JP8fq1N2Bhorr2TOgg6uPl2_6drnzfPBaxnTMjP87ZY0U4A-xSbpl_QyDvPuuXeysbtwQpLrEkHoPPSLRJgP-P6VobcP5nDsHM2w8jOkv-BCUnNipMvo_fJ8aRnKEtA_EGfBA5vqwJl_Zq5GjG" alt="Profile" className="w-full h-full object-cover" />
          </div>
          
          <h2 className="text-xl font-bold mb-1">Ayşe Yılmaz</h2>
          <p className="text-sm text-on-surface-variant mb-4">ayse.yilmaz@example.com</p>
          
          <div className="w-full bg-primary-container/30 rounded-2xl p-4 flex items-center justify-between">
            <div className="flex flex-col items-start">
              <span className="text-xs font-bold text-primary uppercase tracking-wider">Mevcut Kredi</span>
              <span className="text-2xl font-extrabold text-on-primary-container">12 ✨</span>
            </div>
            <Link to="/credits" className="bg-primary text-white text-xs font-bold px-4 py-2 rounded-full active:scale-95 transition-transform">
              Kredi Al
            </Link>
          </div>
        </section>

        <section className="space-y-2">
          <h3 className="text-sm font-bold text-on-surface-variant px-2 uppercase tracking-wider mb-2">Hesap</h3>
          
          <div className="bg-surface-container-lowest rounded-2xl overflow-hidden border border-outline-variant/20 shadow-sm">
            <Link to="/credits" className="flex items-center justify-between p-4 border-b border-outline-variant/10 active:bg-surface-container-low transition-colors">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-secondary-container/50 flex items-center justify-center">
                  <CreditCard className="w-4 h-4 text-secondary" />
                </div>
                <span className="font-semibold text-sm">Abonelik & Krediler</span>
              </div>
              <ChevronRight className="w-5 h-5 text-outline" />
            </Link>
            
            <div className="flex items-center justify-between p-4 border-b border-outline-variant/10 active:bg-surface-container-low transition-colors cursor-pointer">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-tertiary-container/50 flex items-center justify-center">
                  <Bell className="w-4 h-4 text-tertiary" />
                </div>
                <span className="font-semibold text-sm">Bildirimler</span>
              </div>
              <ChevronRight className="w-5 h-5 text-outline" />
            </div>
            
            <div className="flex items-center justify-between p-4 active:bg-surface-container-low transition-colors cursor-pointer">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-primary-container/50 flex items-center justify-center">
                  <HelpCircle className="w-4 h-4 text-primary" />
                </div>
                <span className="font-semibold text-sm">Yardım & Destek</span>
              </div>
              <ChevronRight className="w-5 h-5 text-outline" />
            </div>
          </div>
        </section>

        <section>
          <button className="w-full bg-error-container/30 text-error font-bold rounded-2xl p-4 flex items-center justify-center gap-2 active:scale-[0.98] transition-transform">
            <LogOut className="w-5 h-5" />
            Çıkış Yap
          </button>
        </section>
      </main>

      <BottomNav />
    </div>
  );
}
