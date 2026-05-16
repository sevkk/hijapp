import { Link, useLocation } from 'react-router-dom';
import { Home, Grid, Gift, User } from 'lucide-react';

export default function BottomNav() {
  const location = useLocation();
  const path = location.pathname;

  return (
    <nav className="fixed bottom-0 left-0 w-full flex justify-around items-center px-4 pb-6 pt-3 bg-surface/60 backdrop-blur-xl z-50 rounded-t-[3rem] shadow-[0_-4px_24px_rgba(28,27,29,0.06)]">
      <Link to="/home" className={`flex flex-col items-center justify-center transition-all duration-300 ${path === '/home' ? 'text-primary bg-primary-container/20 rounded-full px-4 py-1' : 'text-on-surface opacity-50 hover:opacity-100'}`}>
        <Home className="w-6 h-6" />
        <span className="text-[10px] uppercase tracking-wider font-medium mt-1">Ana Sayfa</span>
      </Link>
      <Link to="/boutique" className={`flex flex-col items-center justify-center transition-all duration-300 ${path === '/boutique' ? 'text-primary bg-primary-container/20 rounded-full px-4 py-1' : 'text-on-surface opacity-50 hover:opacity-100'}`}>
        <Grid className="w-6 h-6" />
        <span className="text-[10px] uppercase tracking-wider font-medium mt-1">Katalog</span>
      </Link>
      <Link to="/referral" className={`flex flex-col items-center justify-center transition-all duration-300 ${path === '/referral' ? 'text-primary bg-primary-container/20 rounded-full px-4 py-1' : 'text-on-surface opacity-50 hover:opacity-100'}`}>
        <Gift className="w-6 h-6" />
        <span className="text-[10px] uppercase tracking-wider font-medium mt-1">Referans</span>
      </Link>
      <Link to="/credits" className={`flex flex-col items-center justify-center transition-all duration-300 ${path === '/credits' ? 'text-primary bg-primary-container/20 rounded-full px-4 py-1' : 'text-on-surface opacity-50 hover:opacity-100'}`}>
        <User className="w-6 h-6" />
        <span className="text-[10px] uppercase tracking-wider font-medium mt-1">Profil</span>
      </Link>
    </nav>
  );
}
