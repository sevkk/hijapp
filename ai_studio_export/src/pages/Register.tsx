import { Link } from 'react-router-dom';
import { User, Mail, Lock, Eye, Check } from 'lucide-react';

export default function Register() {
  return (
    <div className="bg-surface font-body text-on-surface min-h-screen flex flex-col">
      <header className="relative w-full h-48 bg-gradient-to-br from-primary-container via-secondary-fixed-dim to-secondary-fixed rounded-b-lg overflow-hidden flex flex-col items-center justify-end pb-8 shadow-sm">
        <div className="absolute inset-0 opacity-20 mix-blend-overlay">
          <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuA8EqTvMyy6mGuk_1srfLmLMMJSmaV7gDyp6Axf0U0XGXL33zFlzdWF0W77btSqVt4nMOXMSEBzMqENeBDg8vhStHDXCl3gqQdb5XYUrM57KQnNvr5_Py8qxwedEq8ufwho6vip-lUAerJqIVoNhUwJdM04GB7oO_ef1p3VzXU2080xebnpB0IVaXorSX-FIBfpQsplNJb9BNno42hbF_Jm9nKPqLpw3BNdrg8K5-fZo2EnUVXs96A_919wBAuR1e4x9dYXTkMnH46k" className="w-full h-full object-cover" alt="texture" />
        </div>
        <div className="safe-top w-full"></div>
        <div className="relative z-10 text-center px-6">
          <h1 className="font-headline font-bold text-3xl text-on-primary-container tracking-tight">Aramıza Katıl</h1>
          <p className="font-body text-sm text-on-primary-container/70 mt-1">Stil yolculuğuna bugün başla</p>
        </div>
      </header>

      <main className="flex-grow px-8 pt-10 pb-12 flex flex-col max-w-md mx-auto w-full">
        <form className="space-y-6">
          <div className="space-y-2">
            <label className="block text-xs font-bold text-on-surface-variant uppercase tracking-widest ml-1">AD SOYAD</label>
            <div className="relative flex items-center group">
              <User className="absolute left-4 w-5 h-5 text-on-surface-variant group-focus-within:text-secondary transition-colors" />
              <input type="text" placeholder="İsminiz" className="w-full h-14 pl-12 pr-4 bg-surface-container-lowest border border-outline-variant/20 rounded-2xl focus:ring-2 focus:ring-secondary/20 focus:border-secondary outline-none transition-all placeholder:text-on-surface-variant/40" />
            </div>
          </div>

          <div className="space-y-2">
            <label className="block text-xs font-bold text-on-surface-variant uppercase tracking-widest ml-1">E-POSTA</label>
            <div className="relative flex items-center group">
              <Mail className="absolute left-4 w-5 h-5 text-on-surface-variant group-focus-within:text-secondary transition-colors" />
              <input type="email" placeholder="ornek@mail.com" className="w-full h-14 pl-12 pr-4 bg-surface-container-lowest border border-outline-variant/20 rounded-2xl focus:ring-2 focus:ring-secondary/20 focus:border-secondary outline-none transition-all placeholder:text-on-surface-variant/40" />
            </div>
          </div>

          <div className="space-y-2">
            <label className="block text-xs font-bold text-on-surface-variant uppercase tracking-widest ml-1">ŞİFRE</label>
            <div className="relative flex items-center group">
              <Lock className="absolute left-4 w-5 h-5 text-on-surface-variant group-focus-within:text-secondary transition-colors" />
              <input type="password" placeholder="••••••••" className="w-full h-14 pl-12 pr-4 bg-surface-container-lowest border border-outline-variant/20 rounded-2xl focus:ring-2 focus:ring-secondary/20 focus:border-secondary outline-none transition-all placeholder:text-on-surface-variant/40" />
              <Eye className="absolute right-4 w-5 h-5 text-on-surface-variant cursor-pointer hover:text-secondary" />
            </div>
            <div className="flex items-center gap-1.5 px-1 mt-2">
              <div className="h-1 flex-grow bg-primary-container rounded-full"></div>
              <div className="h-1 flex-grow bg-primary-container rounded-full"></div>
              <div className="h-1 flex-grow bg-surface-container-highest rounded-full"></div>
              <div className="h-1 flex-grow bg-surface-container-highest rounded-full"></div>
              <span className="text-[10px] font-bold text-primary ml-2 tracking-wide uppercase">Güçlü Değil</span>
            </div>
          </div>

          <label className="flex items-start gap-3 cursor-pointer group mt-4">
            <div className="relative flex items-center justify-center mt-0.5">
              <input type="checkbox" className="peer appearance-none w-5 h-5 border-2 border-outline-variant/40 rounded-md checked:bg-secondary checked:border-secondary transition-all" />
              <Check className="absolute text-white w-3 h-3 scale-0 peer-checked:scale-100 transition-transform" strokeWidth={3} />
            </div>
            <span className="text-sm text-on-surface-variant/80 font-medium leading-tight">
              Kullanım koşullarını kabul ediyorum
            </span>
          </label>

          <Link to="/home" className="w-full h-[56px] bg-gradient-to-r from-primary-container to-secondary-fixed-dim text-on-primary-container font-bold text-lg rounded-xl shadow-[0_12px_24px_-8px_rgba(232,180,203,0.5)] active:scale-[0.98] transition-all flex items-center justify-center gap-2 mt-8">
            Kayıt Ol
          </Link>
        </form>

        <div className="relative flex items-center py-8">
          <div className="flex-grow border-t border-outline-variant/10"></div>
          <span className="flex-shrink mx-4 text-xs font-bold text-outline-variant uppercase tracking-[0.2em]">VEYA</span>
          <div className="flex-grow border-t border-outline-variant/10"></div>
        </div>

        <div className="flex gap-4">
          <button className="flex-1 h-14 bg-surface-container-low rounded-2xl flex items-center justify-center border border-outline-variant/10 hover:bg-surface-container transition-colors">
            <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuBlZbleFYpDn0b2uo2Iun806Ogl7vppXfNc2LDdkIePZq25ms-vY8FDdP9ZzsHYFrJxCs1wCMXMiHXLzi2SYMUd7mXAuiprViW8K_cR9nTcSUagIWlg7vL_R_UonlWHYvXDuN5vo3x6Y-1hLzYvNt6XG6BqHVfYCPw6VjyGDWgF9yJlqydJxwboIMCHba_jakqeju7Sdq3ydNWtJGkBMyGeAN7TgIpHPIjB3j6tzhyCSBObJmi9jYDvFXXh3EJo8hg2pUV-vMjpXR-O" alt="Google" className="w-5 h-5" />
          </button>
          <button className="flex-1 h-14 bg-surface-container-low rounded-2xl flex items-center justify-center border border-outline-variant/10 hover:bg-surface-container transition-colors">
            <img src="https://lh3.googleusercontent.com/aida-public/AB6AXuAk-xlBLG3k4FBQRRFIw3WRyS7YIcpmoBMlf5CV2Rceg6c0P-AxAj7tg56XGa_fOi5ths4UwJ9-H8hfcDkgPN56DjACumiDE5RVDd-8XvE1eN58l_Vb6dui6m2htpsJNNa3YU_1d65QBwuL3-ZoY8RMIFOO0bHCyjb1d6EvCTp0im1V6_4vNnoqH7yQuqJ2RV6UwwIbtWwvL2LjJzy9JAPegMveM-_nJeu6Ygjb67ABExrDj6ieHkMQoHUFYFpDAuhH8XImWR8f9VvD" alt="Apple" className="w-5 h-5" />
          </button>
        </div>

        <div className="mt-auto pt-10 text-center">
          <p className="text-on-surface-variant text-sm font-medium">
            Zaten hesabın var mı? 
            <Link to="/login" className="text-secondary font-bold ml-1 hover:underline decoration-secondary/30 transition-all">Giriş Yap</Link>
          </p>
        </div>
      </main>
      <div className="h-8"></div>
    </div>
  );
}
