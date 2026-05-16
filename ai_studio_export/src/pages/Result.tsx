import { Link } from 'react-router-dom';
import { ArrowLeft, Save, Share2, RefreshCw, ShoppingCart, Sparkles } from 'lucide-react';

export default function Result() {
  return (
    <div className="bg-background font-body text-on-surface antialiased overflow-hidden min-h-screen">
      <div className="fixed inset-0 z-0">
        <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuC7uDcXy7i1Ryz9BiaCuX2Jh9FDwJp5gStTo0AdV9aiGuDoiYnn0SmEEHEmBjOHDRYFh8TJc07h8jPqSd3frWDA-6qpqzBhf0kKvj9w7xL9YzJcXSZMg1GxU05XBSIVz2OO_RWe6UXAziv7GKOhamSNOpLxkjTaQaL5haS1YKdF_xJ60CrdHdJQYWtj1_ctZ-CbNvKw6MpzEzUyWFhxpDh0OWG04myCwaxXCYaNTYOzmsAs2Wqgx8aQlgWVbcWvLC7XGNc_CmBMSkC5" alt="Result" className="w-full h-full object-cover" />
      </div>

      <header className="fixed top-0 w-full z-50 bg-[#1c1b1d]/40 backdrop-blur-md flex items-center justify-between px-6 h-16">
        <Link to="/home" className="w-10 h-10 flex items-center justify-center text-white transition-opacity active:scale-95 duration-200">
          <ArrowLeft className="w-6 h-6" />
        </Link>
        <h1 className="font-headline font-bold text-lg tracking-tight text-white">Sonuç</h1>
        <div className="w-10"></div>
      </header>

      <main className="relative z-10 min-h-screen flex flex-col items-center justify-end pb-32">
        <div className="w-full max-w-md px-4 space-y-6">
          <div className="bg-surface-bright/70 backdrop-blur-2xl rounded-2xl p-5 shadow-[0_8px_32px_0_rgba(28,27,29,0.1)] flex items-center justify-between">
            <div className="flex flex-col items-center gap-1.5 group cursor-pointer transition-transform active:scale-90">
              <div className="w-14 h-14 rounded-full bg-surface-container-low flex items-center justify-center text-primary shadow-sm group-hover:bg-primary-container transition-colors">
                <Save className="w-7 h-7" />
              </div>
              <span className="font-label text-[11px] font-medium tracking-wide text-on-surface-variant uppercase">Kaydet</span>
            </div>

            <div className="flex flex-col items-center gap-1.5 group cursor-pointer transition-transform active:scale-90">
              <div className="w-14 h-14 rounded-full bg-surface-container-low flex items-center justify-center text-primary shadow-sm group-hover:bg-primary-container transition-colors">
                <Share2 className="w-7 h-7" />
              </div>
              <span className="font-label text-[11px] font-medium tracking-wide text-on-surface-variant uppercase">Paylaş</span>
            </div>

            <Link to="/photo-mode" className="flex flex-col items-center gap-1.5 group cursor-pointer transition-transform active:scale-90">
              <div className="w-14 h-14 rounded-full bg-surface-container-low flex items-center justify-center text-primary shadow-sm group-hover:bg-primary-container transition-colors">
                <RefreshCw className="w-7 h-7" />
              </div>
              <span className="font-label text-[11px] font-medium tracking-wide text-on-surface-variant uppercase text-center">Tekrar Dene</span>
            </Link>

            <Link to="/boutique" className="flex flex-col items-center gap-1.5 group cursor-pointer transition-transform active:scale-90">
              <div className="w-14 h-14 rounded-full bg-primary-gradient flex items-center justify-center text-on-primary-container shadow-lg shadow-primary-container/20 group-hover:opacity-90 transition-opacity">
                <ShoppingCart className="w-7 h-7" />
              </div>
              <span className="font-label text-[11px] font-medium tracking-wide text-primary font-bold uppercase">Satın Al</span>
            </Link>
          </div>

          <div className="flex justify-center items-center">
            <div className="bg-on-background/10 backdrop-blur-xl px-5 py-2.5 rounded-full border border-white/10 flex items-center gap-2">
              <span className="text-white text-sm font-medium tracking-tight font-body">Kalan kredin: <span className="font-bold">11</span></span>
              <Sparkles className="w-4 h-4 text-primary-container fill-current" />
            </div>
          </div>
        </div>
      </main>

      <div className="fixed top-20 right-6 z-50 pointer-events-none">
        <div className="bg-surface-container-lowest/90 backdrop-blur-md rounded-full px-4 py-2 flex items-center gap-2 shadow-xl border border-outline-variant/20">
          <div className="w-2 h-2 rounded-full bg-primary animate-pulse"></div>
          <span className="text-xs font-semibold text-on-surface-variant uppercase tracking-widest font-label">Mükemmel Uyum</span>
        </div>
      </div>
    </div>
  );
}
