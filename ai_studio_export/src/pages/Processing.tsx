import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Clock, Sparkles, Lightbulb, Shield, Image as ImageIcon, Hourglass } from 'lucide-react';

export default function Processing() {
  const navigate = useNavigate();

  useEffect(() => {
    const timer = setTimeout(() => {
      navigate('/result');
    }, 3000); // Simulate processing time
    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div className="bg-surface text-on-surface font-body min-h-screen flex flex-col">
      <nav className="fixed top-0 w-full z-50 bg-[#FFF8F4]/60 backdrop-blur-xl shadow-[0_8px_32_rgba(28,27,29,0.06)] flex items-center justify-between px-6 h-16">
        <div className="flex items-center gap-4">
          <button className="text-primary active:scale-95 duration-200">
            <ArrowLeft className="w-6 h-6" />
          </button>
          <h1 className="font-headline font-bold text-lg tracking-tight text-primary">Fotoğraf Modu</h1>
        </div>
        <div className="flex items-center gap-1 bg-surface-container-high px-3 py-1.5 rounded-full">
          <Clock className="w-4 h-4 text-primary" />
          <span className="font-headline font-bold text-sm tracking-tight text-primary">12sn</span>
        </div>
      </nav>

      <main className="flex-1 mt-16 px-6 pb-32 flex flex-col items-center justify-center max-w-2xl mx-auto w-full">
        <div className="relative w-full aspect-[3/4] rounded-2xl overflow-hidden shadow-[0_24px_48px_-12px_rgba(28,27,29,0.1)] bg-surface-container-low group">
          <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuD9E5uQwFE9P30ZODXD7NNrgOmZ3oEzR_UAy-cHLty-cIPTYIDFr_FzA8oAdkijM0iBCFn7ZWPaDzGtXcTBt0HnA_vT_7eZM-3tnjPduevQXjbNYM4O00l31rc9FK8wR2RCuuUGYnypd7oc-d1FaulEIclPZTZ0PXcFXQwizea8ep9kWaypcySLzRtz7UvCpMpJXWLFvGsTQBabLAbG7GGMsJCWJrukYUyM3_ShXefLemYpXsH2R9w9ogp-wwxTwspgCXzvB690WQqw" alt="Original portrait" className="w-full h-full object-cover" />
          
          <div className="absolute inset-0 bg-surface/40 backdrop-blur-2xl flex flex-col items-center justify-center p-8">
            <div className="relative flex items-center justify-center mb-8">
              <div className="absolute w-24 h-24 rounded-full bg-primary-gradient opacity-20 blur-xl"></div>
              <div className="w-16 h-16 border-4 border-surface-variant border-t-primary rounded-full animate-spin"></div>
              <div className="absolute w-8 h-8 rounded-full bg-surface-container-lowest flex items-center justify-center">
                <Sparkles className="w-4 h-4 text-primary fill-current" />
              </div>
            </div>
            
            <div className="text-center space-y-2">
              <p className="font-headline font-bold text-on-surface text-xl">AI başörtüsünü değiştiriyor...</p>
              <p className="text-on-surface-variant text-sm font-medium">Bu işlem yaklaşık 15 saniye sürer</p>
            </div>
            
            <div className="absolute bottom-8 left-0 right-0 px-8 flex justify-center">
              <div className="bg-surface-container-lowest/80 backdrop-blur-md px-4 py-3 rounded-2xl flex items-center gap-3 shadow-sm">
                <Lightbulb className="w-5 h-5 text-secondary" />
                <p className="text-xs font-medium text-on-surface-variant tracking-wide">
                  <span className="font-bold text-secondary">BİLGİ:</span> Sonucu galeriye kaydedebilirsin
                </p>
              </div>
            </div>
          </div>
        </div>

        <div className="mt-8 grid grid-cols-2 gap-4 w-full opacity-50">
          <div className="bg-surface-container-low p-4 rounded-2xl flex items-center gap-3">
            <ImageIcon className="w-5 h-5 text-primary" />
            <span className="text-[11px] font-bold uppercase tracking-widest text-on-surface-variant">4K Çözünürlük</span>
          </div>
          <div className="bg-surface-container-low p-4 rounded-2xl flex items-center gap-3">
            <Shield className="w-5 h-5 text-primary" />
            <span className="text-[11px] font-bold uppercase tracking-widest text-on-surface-variant">Gizli İşleme</span>
          </div>
        </div>
      </main>

      <div className="fixed bottom-0 w-full p-6 bg-surface/80 backdrop-blur-xl z-40">
        <div className="max-w-2xl mx-auto">
          <button className="w-full h-14 rounded-xl bg-outline-variant/30 text-on-surface/40 font-headline font-bold flex items-center justify-center gap-2 cursor-not-allowed" disabled>
            <Hourglass className="w-5 h-5 animate-pulse" />
            İşleniyor...
          </button>
        </div>
      </div>
    </div>
  );
}
