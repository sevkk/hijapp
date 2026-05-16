import { Link } from 'react-router-dom';
import { Gift, ChevronRight, Plus, Image as ImageIcon, Camera, Bookmark, Camera as CameraIcon } from 'lucide-react';
import BottomNav from '../components/BottomNav';

export default function Home() {
  return (
    <div className="bg-surface text-on-surface antialiased min-h-screen pb-32">
      <header className="bg-[#FFF8F4]/60 backdrop-blur-xl fixed top-0 z-50 flex justify-between items-center w-full px-6 h-16 shadow-sm shadow-[#592512]/5">
        <div className="flex items-center gap-2">
          <span className="text-xl font-extrabold tracking-tighter bg-clip-text text-transparent bg-gradient-to-r from-primary to-secondary">HIJAPP</span>
        </div>
        <div className="flex items-center gap-3">
          <div className="bg-primary-container/30 px-3 py-1.5 rounded-full flex items-center gap-1.5">
            <span className="text-xs font-bold text-on-primary-container">12 ✨</span>
          </div>
          <div className="w-8 h-8 rounded-full overflow-hidden border-2 border-primary-container">
            <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuDX87ihe1Whsa0PBuxElsyNMEgXRaaDESEBc5cLEsFOaJI4k-stJPp6uv6hL3IMR7w0kToGxx8ZiHc2lhKV0vF8hUvfOAD8IZAhdWejVtfX1LvxYxgRy_QX4XxOC7JP8fq1N2Bhorr2TOgg6uPl2_6drnzfPBaxnTMjP87ZY0U4A-xSbpl_QyDvPuuXeysbtwQpLrEkHoPPSLRJgP-P6VobcP5nDsHM2w8jOkv-BCUnNipMvo_fJ8aRnKEtA_EGfBA5vqwJl_Zq5GjG" alt="Profile" className="w-full h-full object-cover" />
          </div>
        </div>
      </header>

      <main className="pt-20 px-6 space-y-8">
        <section className="space-y-1">
          <h2 className="text-[20px] font-bold tracking-tight text-on-surface">Merhaba, Ayşe 👋</h2>
          <p className="text-[14px] text-on-surface-variant/70">Bugün ne denemek istersin?</p>
        </section>

        <section>
          <Link to="/referral" className="bg-primary-gradient p-5 rounded-2xl shadow-[0_8px_24px_rgba(124,82,102,0.08)] flex items-center justify-between group active:scale-[0.98] transition-all cursor-pointer">
            <div className="flex items-center gap-4">
              <div className="bg-white/40 p-2.5 rounded-full">
                <Gift className="w-6 h-6 text-on-primary-container" />
              </div>
              <div className="flex flex-col">
                <span className="text-[15px] font-bold text-on-primary-container">Referans Kodun Var Mı?</span>
                <span className="text-[12px] text-on-primary-container/80">Referans kodu gir, ücretsiz dene!</span>
              </div>
            </div>
            <ChevronRight className="w-6 h-6 text-on-primary-container" />
          </Link>
        </section>

        <section className="space-y-4">
          <h3 className="text-lg font-semibold px-1">Son Kullandıkların</h3>
          <div className="flex gap-4 overflow-x-auto pb-2 -mx-6 px-6 hide-scrollbar">
            <div className="flex-shrink-0 flex flex-col items-center gap-2">
              <div className="w-16 h-16 rounded-full p-0.5 border-2 border-primary ring-2 ring-primary/10">
                <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuB5uoht6ABnGkZ_Wc98jg7s2WdsJLHqO9PzfhItuPfq_6pe0oevZIvJedwOd9sjnUh6AVk9PNrRufL2cSG3mykz9_8aUbpZvC5DrrGO5OtauEU3h2DNqHgMcKn_5eCzI-ZRd39SoPxWKuhyBs6KxHY2wpiBe2pCN4C5w0fwtReSq5ZQvlA3B9yKl0TjC2er64sLlsDzHFOuAqEgZN7DgZkDzjHA1y5V8vVdRzz5fqd55XAcLTh7e0FcfQPGx_OgtvSfMTmawM3mIXGf" alt="Hijab" className="w-full h-full object-cover rounded-full" />
              </div>
            </div>
            <div className="flex-shrink-0 flex flex-col items-center gap-2">
              <div className="w-16 h-16 rounded-full overflow-hidden">
                <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuCNYq3zGs2ovq4v6ScgMKXbj6Ce0ksq8xkDyfplsFeUOlJt_sABkshaQgxAznAuSOcV9eZACppvzmhxmsQFL6VjSf6VaXXXPcNdPQQh7dMkSt4Y5DKeSVYlcn5fYdUvjV5Sza_YE21FIqxznUW358LXkbI5QnvBO_9DPFvCA70ngN5Es9RyOY6V5PrCd5yMX0MblkyQQG6eQy843Cjl6xASSTgwt5-B7o0zhQUCLEsGzDYX7MlhWe9cuthEmtfDxqU2GQK9EJAedkjk" alt="Hijab" className="w-full h-full object-cover rounded-full" />
              </div>
            </div>
            <div className="flex-shrink-0 flex flex-col items-center gap-2">
              <div className="w-16 h-16 rounded-full overflow-hidden">
                <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuDY-gl_DtGP9TMLvH-rzzUyWp4d0Q7-xZSkEDlKcPNOIFhL0DDXJ8MIyjkV1NreVYOvuvIHLBH9zRaA4KOCAyKotzKflcoYuAaIMOc0i0xBYBlV4fK3YK9BqLnktmMU_RupOqWDpSgNLYfdMTh_jRUnagHVb4or13dDSdAVk9JlxkZG8DjSR5bHjIC-j-ytGFRwKowei87CvS-CsNgruyB075WqYo9401GurXxvyHIrl4NqLHTssvqd-PhwTAAVdd0hk6yCdLRHfe8_" alt="Hijab" className="w-full h-full object-cover rounded-full" />
              </div>
            </div>
            <div className="flex-shrink-0 flex flex-col items-center gap-2">
              <div className="w-16 h-16 rounded-full overflow-hidden">
                <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuDJmQPN-tD0dhNqLk284Q_fYrtW43_wdYEFhShj3KiKrMycP9BNW06BH1Ilde287d-LYFykA1rOUYZZPrHJYgkkaQblmP9fDxG5hcmTgARGTBCyjPMF9re7JsXWfOFOpGKSRHHVn8mfaOmzmYghCD4goqYST0c-BcPJoa-2Z_qvvFfxEBOaDXRiuUXa98CuQO6YTw8mEK4YTemarZMBVwKegqhu2G27mZ1zQHRVrmWoI9wtprTpO9Tp2FBl5rvXAaElQw4pcCZuDTDD" alt="Hijab" className="w-full h-full object-cover rounded-full" />
              </div>
            </div>
            <div className="flex-shrink-0 flex flex-col items-center gap-2">
              <div className="w-16 h-16 rounded-full border-2 border-dashed border-outline-variant flex items-center justify-center bg-surface-container-low">
                <Plus className="w-6 h-6 text-outline" />
              </div>
            </div>
          </div>
        </section>

        <section className="space-y-4">
          <h3 className="text-lg font-semibold px-1">Başörtüsü Seç</h3>
          <div className="grid grid-cols-2 gap-4">
            <Link to="/photo-mode" className="bg-primary-container/10 p-5 rounded-2xl flex flex-col gap-3 active:scale-[0.97] transition-transform">
              <div className="bg-primary-container/20 w-10 h-10 rounded-full flex items-center justify-center">
                <ImageIcon className="w-5 h-5 text-primary" />
              </div>
              <span className="font-bold text-sm text-on-primary-container">Galeriden Seç</span>
            </Link>
            <Link to="/photo-mode" className="bg-secondary-container/10 p-5 rounded-2xl flex flex-col gap-3 active:scale-[0.97] transition-transform">
              <div className="bg-secondary-container/20 w-10 h-10 rounded-full flex items-center justify-center">
                <Camera className="w-5 h-5 text-secondary" />
              </div>
              <span className="font-bold text-sm text-on-secondary-container">Fotoğraf Çek</span>
            </Link>
            <div className="col-span-2 bg-surface-container-low p-4 rounded-2xl flex items-center justify-between group active:scale-[0.98] transition-transform">
              <div className="flex items-center gap-3">
                <div className="bg-surface-container-high w-10 h-10 rounded-full flex items-center justify-center">
                  <Bookmark className="w-5 h-5 text-on-surface-variant fill-current" />
                </div>
                <div className="flex flex-col">
                  <span className="font-bold text-sm text-on-surface">Taslaklar</span>
                  <span className="text-[12px] text-on-surface-variant/60">3 taslak</span>
                </div>
              </div>
              <ChevronRight className="w-6 h-6 text-outline" />
            </div>
          </div>
        </section>

        <section className="space-y-4">
          <Link to="/photo-mode" className="relative group cursor-pointer active:scale-[0.99] transition-all block">
            <div className="absolute -inset-0.5 bg-gradient-to-r from-primary-container to-secondary-fixed-dim rounded-2xl blur opacity-30 group-hover:opacity-50 transition duration-1000 group-hover:duration-200"></div>
            <div className="relative bg-surface-container-lowest h-20 rounded-2xl flex items-center px-6 gap-4 border border-outline-variant/10 shadow-sm">
              <span className="text-2xl">📸</span>
              <div className="flex flex-col">
                <span className="font-bold text-on-surface">Fotoğraf Modu</span>
                <span className="text-xs text-on-surface-variant/60">Fotoğrafını yükle, AI dönüştürsün</span>
              </div>
            </div>
          </Link>
          <div className="h-20 rounded-2xl border-2 border-dashed border-outline-variant/40 flex items-center px-6 gap-4 bg-surface/50 active:scale-[0.99] transition-all cursor-pointer">
            <span className="text-2xl">🪞</span>
            <div className="flex flex-col">
              <span className="font-bold text-on-surface">Ayna Modu</span>
              <span className="text-xs text-on-surface-variant/60">Gerçek zamanlı dene</span>
            </div>
          </div>
        </section>
      </main>

      <BottomNav />
    </div>
  );
}
