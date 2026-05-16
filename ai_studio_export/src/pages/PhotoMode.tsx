import { Link } from 'react-router-dom';
import { ArrowLeft, CheckCircle2, X, Image as ImageIcon, Camera, BookOpen } from 'lucide-react';

export default function PhotoMode() {
  return (
    <div className="bg-surface font-body text-on-surface min-h-screen pb-32">
      <header className="fixed top-0 w-full z-50 bg-[#FFF8F4]/60 backdrop-blur-xl flex items-center justify-between px-6 h-16 shadow-[0_8px_32px_0_rgba(28,27,29,0.06)]">
        <Link to="/home" className="flex items-center justify-center w-10 h-10 rounded-full text-primary active:scale-95 transition-transform">
          <ArrowLeft className="w-6 h-6" />
        </Link>
        <h1 className="font-headline font-bold text-lg tracking-tight text-primary">Fotoğraf Modu</h1>
        <div className="w-10"></div>
      </header>

      <main className="pt-20 px-6 max-w-md mx-auto space-y-8">
        <section className="relative group">
          <div className="aspect-[3/4] rounded-2xl overflow-hidden bg-surface-container-low shadow-sm transition-all duration-500 hover:shadow-lg">
            <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuBGgbSsxQ96QSCVcxu3FDIyMWXDP08hJzfJmHZFEyNhbosirTSzpfbt1yDM1D06rDNSbbGxDoI_FbNJJD3xCPcPIouv8REY5eB6K58R8U0htMLgAGeQDergSvURlBuISCugg-L7DSx-OJisMdqTGg4-gw5HcgftSIJNJVGsLz5EXi1oq4d12Q4yKBJeSv4vYVUwuTPWj5FuYFEOb9geOjKPe8Od2G0XStGACH5cQJyx-JpP6UJ4JQ_tS97js5PLA04U_ZPrW6phI0mc" alt="User Portrait" className="w-full h-full object-cover" />
            
            <div className="absolute top-4 right-4 glass-panel px-4 py-2 rounded-full flex items-center gap-2 shadow-sm">
              <CheckCircle2 className="w-5 h-5 text-primary fill-current" />
              <span className="font-body text-[12px] font-semibold text-on-primary-container">✓ Fotoğraf seçildi</span>
            </div>
          </div>
        </section>

        <section>
          <div className="bg-surface-container-lowest p-4 rounded-2xl flex items-center justify-between shadow-[0_4px_24px_rgba(0,0,0,0.04)] border border-transparent hover:border-outline-variant/30 transition-all">
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 rounded-full overflow-hidden border-2 border-primary-container p-0.5">
                <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuCUTJ11-TcBfMuuodUzUDWBklVZ6KnUjnEEWLgaeHNd8h5P5wutgrJiLk9_f1_dDIHJKllLahUqz3jAGGLtz1Yewjw1-jeVejmYHLIlZCWHLozZg99-6vVZFteGgUWdDgj8U_3sXmtE_6FdypDVooAYgS6ihWSL0SSsSy6Tld7g-6fNoYGAAx7Yl2z7plUllcnJuGWRgd8q2FF1ohXj717EJ_NY3ngAvMKQTRukwgCSJ6PPL_nPBWK578oFR0sCeKHZ2FGz_Zqz-pe2" alt="Fabric Pattern" className="w-full h-full object-cover rounded-full" />
              </div>
              <div>
                <h3 className="font-headline font-semibold text-on-surface">Pembe Çiçekli</h3>
                <p className="text-[11px] font-medium text-on-surface-variant tracking-wider uppercase opacity-70">Premium Şifon</p>
              </div>
            </div>
            <button className="w-8 h-8 rounded-full bg-surface-container flex items-center justify-center text-on-surface-variant hover:bg-error-container hover:text-on-error-container transition-colors">
              <X className="w-5 h-5" />
            </button>
          </div>
        </section>

        <section className="grid grid-cols-3 gap-3">
          <button className="flex flex-col items-center justify-center py-4 px-2 rounded-2xl bg-surface-container-lowest border border-outline-variant/20 hover:bg-primary-container/10 transition-colors group">
            <ImageIcon className="w-6 h-6 text-primary mb-2 transition-transform group-active:scale-90" />
            <span className="text-[11px] font-medium text-on-surface-variant font-label">Galeri</span>
          </button>
          <button className="flex flex-col items-center justify-center py-4 px-2 rounded-2xl bg-surface-container-lowest border border-outline-variant/20 hover:bg-primary-container/10 transition-colors group">
            <Camera className="w-6 h-6 text-primary mb-2 transition-transform group-active:scale-90" />
            <span className="text-[11px] font-medium text-on-surface-variant font-label">Kamera</span>
          </button>
          <button className="flex flex-col items-center justify-center py-4 px-2 rounded-2xl bg-surface-container-lowest border border-outline-variant/20 hover:bg-primary-container/10 transition-colors group">
            <BookOpen className="w-6 h-6 text-primary mb-2 transition-transform group-active:scale-90" />
            <span className="text-[11px] font-medium text-on-surface-variant font-label">Taslaklar</span>
          </button>
        </section>
      </main>

      <footer className="fixed bottom-0 w-full bg-[#FFF8F4]/80 backdrop-blur-2xl px-6 pt-4 pb-10 rounded-t-[3rem] shadow-[0_-8px_32px_0_rgba(28,27,29,0.04)] z-50">
        <div className="max-w-md mx-auto space-y-4">
          <div className="flex items-center justify-center gap-1.5 opacity-70">
            <span className="text-[14px] text-primary">🪙</span>
            <span className="text-[11px] font-medium font-body text-on-surface-variant">1 kredi kullanılacak</span>
          </div>
          <Link to="/processing" className="w-full h-[56px] rounded-xl bg-primary-gradient flex items-center justify-center shadow-[0_8px_24px_rgba(232,180,203,0.4)] active:scale-[0.98] transition-all group">
            <span className="font-headline font-bold text-on-primary-container text-lg flex items-center gap-2">
              Dene! 
              <span className="group-hover:rotate-12 transition-transform">✨</span>
            </span>
          </Link>
        </div>
      </footer>
    </div>
  );
}
