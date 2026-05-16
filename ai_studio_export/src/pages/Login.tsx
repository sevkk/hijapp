import { Link } from 'react-router-dom';
import { Mail, Lock, Eye, ArrowRight } from 'lucide-react';

export default function Login() {
  return (
    <div className="min-h-screen flex flex-col relative bg-surface">
      <header className="bg-primary-gradient w-full pt-16 pb-12 px-8 rounded-b-[2rem] shadow-lg relative overflow-hidden">
        <div className="absolute -top-10 -right-10 w-40 h-40 bg-white/10 rounded-full blur-3xl"></div>
        <div className="absolute -bottom-10 -left-10 w-32 h-32 bg-secondary-fixed/20 rounded-full blur-2xl"></div>
        <div className="relative z-10 flex flex-col items-center">
          <div className="text-on-primary-container font-headline font-extrabold text-2xl tracking-[0.2em] mb-2 uppercase">
            HIJAPP
          </div>
          <div className="w-12 h-1 bg-on-primary-container/20 rounded-full"></div>
        </div>
      </header>

      <main className="flex-grow px-8 pt-10 pb-8 flex flex-col">
        <div className="mb-10 text-center">
          <h1 className="font-headline font-bold text-3xl text-on-surface mb-2 tracking-tight">
            Tekrar Hoş Geldin
          </h1>
          <p className="text-on-surface-variant font-body text-sm leading-relaxed">
            Moda dolu dünyamıza geri dönmek için giriş yap.
          </p>
        </div>

        <form className="space-y-4">
          <div className="relative group">
            <div className="absolute inset-y-0 left-4 flex items-center pointer-events-none text-outline">
              <Mail className="w-5 h-5" />
            </div>
            <input 
              type="email" 
              placeholder="E-posta Adresi" 
              className="w-full h-14 pl-12 pr-4 bg-surface-container-lowest border border-outline-variant/30 rounded-2xl font-body text-on-surface placeholder-outline focus:outline-none focus:ring-2 focus:ring-secondary/20 focus:border-secondary transition-all"
            />
          </div>

          <div className="relative group">
            <div className="absolute inset-y-0 left-4 flex items-center pointer-events-none text-outline">
              <Lock className="w-5 h-5" />
            </div>
            <input 
              type="password" 
              placeholder="Şifre" 
              className="w-full h-14 pl-12 pr-12 bg-surface-container-lowest border border-outline-variant/30 rounded-2xl font-body text-on-surface placeholder-outline focus:outline-none focus:ring-2 focus:ring-secondary/20 focus:border-secondary transition-all"
            />
            <button type="button" className="absolute inset-y-0 right-4 flex items-center text-outline hover:text-secondary transition-colors">
              <Eye className="w-5 h-5" />
            </button>
          </div>

          <div className="flex justify-end pt-1">
            <a href="#" className="text-secondary font-label font-semibold text-xs uppercase tracking-wider hover:opacity-80 transition-opacity">
              Şifremi Unuttum
            </a>
          </div>

          <Link to="/home" className="w-full h-14 mt-4 bg-primary-gradient text-on-primary font-headline font-bold rounded-xl shadow-md hover:shadow-lg active:scale-[0.98] transition-all flex items-center justify-center gap-2">
            <span>Giriş Yap</span>
            <ArrowRight className="w-5 h-5" />
          </Link>
        </form>

        <div className="relative my-10 flex items-center">
          <div className="flex-grow h-[1px] bg-outline-variant/20"></div>
          <span className="px-4 text-xs font-label text-outline uppercase tracking-widest bg-surface">veya</span>
          <div className="flex-grow h-[1px] bg-outline-variant/20"></div>
        </div>

        <button className="w-full h-14 bg-surface-container-lowest border border-outline-variant/30 rounded-2xl flex items-center justify-center gap-3 hover:bg-surface-container-low transition-colors group">
          <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuCDT6vsAdZ7UDB59dOsLlcaWRGG6ZH0cIFzM-ralTIThyxHQb7i0AIWvWJWRqtDT2TYtg8T0acXsU32Qfpr3HTzJaD73KtPzREgqIEwOZsV7710pKwKr2BXEpydNhSVmNAkKC0CkDej7NaTX7U9AqS5IVpK0W_JWuzI4GxGr3J8q-cThOr8zQ6yqgd9DNMe-Okz_5VsDI1HTNvDzhb0Gecz1aiQlUiQ-HU9_A25ai0StV_wAykA01W4QcgZmqVQ9zobQR9Iz2_bh9Q_" alt="Google" className="w-5 h-5 group-hover:scale-110 transition-transform" />
          <span className="font-body font-medium text-on-surface-variant text-sm">Google ile Giriş Yap</span>
        </button>

        <div className="flex-grow"></div>

        <footer className="mt-8 mb-4 text-center">
          <p className="font-body text-sm text-on-surface-variant">
            Hesabın yok mu? 
            <Link to="/register" className="text-secondary font-bold ml-1 hover:underline underline-offset-4 decoration-secondary/30 transition-all">
              Kayıt Ol
            </Link>
          </p>
        </footer>
      </main>
    </div>
  );
}
