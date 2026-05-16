import { Link } from 'react-router-dom';
import { Smile } from 'lucide-react';

export default function Onboarding() {
  return (
    <main className="relative w-full h-screen bg-gradient-to-br from-primary-container to-secondary-fixed-dim flex flex-col items-center justify-between overflow-hidden">
      <div className="absolute inset-0 pointer-events-none opacity-40 bg-[url('data:image/svg+xml,%3Csvg width=\'100\' height=\'100\' viewBox=\'0 0 100 100\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cpath d=\'M11 18c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm48 25c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm-43-7c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm63 31c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM34 90c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm56-76c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM12 86c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm28-65c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm23-11c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-6 60c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm29 22c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zM32 35c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zM54 10c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zm35 54c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM16 8c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zm56 82c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM21 54c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM33 46c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zm14 34c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zm33-40c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zm18 43c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2z\' fill=\'%23ffffff\' fill-opacity=\'0.05\' fill-rule=\'evenodd\'/%3E%3C/svg%3E')]"></div>
      
      <div className="h-14 w-full"></div>
      
      <div className="flex-grow flex flex-col items-center justify-center px-10 text-center z-10">
        <div className="relative mb-10">
          <div className="w-32 h-32 rounded-full bg-white/20 backdrop-blur-xl flex items-center justify-center shadow-[0_8px_32px_0_rgba(124,82,102,0.15)] overflow-hidden">
            <div className="absolute inset-0 bg-gradient-to-tr from-white/10 to-transparent"></div>
            <div className="w-20 h-20 rounded-full border-2 border-white/40 flex items-center justify-center">
              <Smile className="text-white w-12 h-12 opacity-90" />
            </div>
          </div>
          <div className="absolute -top-4 -right-4 w-12 h-12 bg-white/10 rounded-full blur-xl"></div>
          <div className="absolute -bottom-6 -left-2 w-16 h-16 bg-white/5 rounded-full blur-2xl"></div>
        </div>
        
        <h1 className="font-headline text-5xl font-extrabold text-white tracking-tighter mb-4 drop-shadow-sm">
          HIJAPP
        </h1>
        <p className="text-white/90 font-medium text-lg leading-relaxed max-w-[280px]">
          Hayalindeki başörtüsünü sanal olarak dene
        </p>
      </div>
      
      <div className="h-1 w-full bg-gradient-to-r from-transparent via-white/10 to-transparent mb-8"></div>
      
      <div className="w-full px-8 pb-12 flex flex-col gap-4 z-10">
        <Link to="/login" className="w-full h-[56px] bg-white text-primary font-bold text-lg rounded-xl shadow-lg active:scale-95 transition-all duration-200 flex items-center justify-center">
          Giriş Yap
        </Link>
        <Link to="/register" className="w-full h-[56px] border-2 border-white/60 bg-white/10 backdrop-blur-md text-white font-semibold text-lg rounded-xl active:scale-95 transition-all duration-200 flex items-center justify-center">
          Kayıt Ol
        </Link>
        <Link to="/home" className="mt-4 text-white/70 text-sm font-medium hover:text-white transition-colors text-center">
          Misafir olarak devam et
        </Link>
      </div>
      
      <div className="absolute -bottom-20 -left-20 w-80 h-80 bg-white/20 rounded-full blur-[100px] pointer-events-none"></div>
      <div className="absolute top-20 -right-20 w-60 h-60 bg-[#6FB7BF]/40 rounded-full blur-[100px] pointer-events-none"></div>
    </main>
  );
}
