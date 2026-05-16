/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { Link } from 'react-router-dom';
import { ArrowLeft, Gift, Sparkles, Store, CheckCircle2 } from 'lucide-react';
import { useState } from 'react';

export default function Referral() {
  const [code, setCode] = useState('');
  const [isSuccess, setIsSuccess] = useState(false);

  const handleRedeem = () => {
    if (code.trim().length > 0) {
      setIsSuccess(true);
    }
  };

  return (
    <div className="bg-surface text-on-surface min-h-screen">
      {/* Header */}
      <header className="bg-[#FFF8F4]/80 backdrop-blur-xl fixed top-0 z-40 w-full px-6 h-16 flex items-center justify-between shadow-sm">
        <div className="flex items-center gap-4">
          <Link to="/home" className="text-primary active:scale-95 transition-transform">
            <ArrowLeft className="w-6 h-6" />
          </Link>
          <h1 className="text-lg font-bold text-[#592512]">Referans Kodu</h1>
        </div>
        <div className="w-10"></div>
      </header>

      <main className="pt-20 px-6 space-y-8">
        {/* Hero Section */}
        <section className="bg-primary-gradient rounded-3xl p-8 text-center shadow-lg shadow-[#D9078F]/15 relative overflow-hidden">
          <div className="absolute -top-10 -right-10 w-32 h-32 bg-white/15 rounded-full blur-2xl"></div>
          <div className="absolute -bottom-10 -left-10 w-32 h-32 bg-white/15 rounded-full blur-2xl"></div>

          <div className="relative z-10 flex flex-col items-center">
            <div className="w-20 h-20 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center mb-5">
              <Gift className="w-10 h-10 text-white" />
            </div>
            <h2 className="text-2xl font-extrabold text-white mb-2">Referans Kodu Gir</h2>
            <p className="text-white/90 text-sm mb-8 max-w-[280px] leading-relaxed">
              Butikten aldığın kodu gir, o butiğin ürünlerini <span className="font-bold">ücretsiz</span> dene!
            </p>

            {/* Code Input */}
            {!isSuccess ? (
              <div className="bg-white/90 backdrop-blur-md w-full rounded-2xl p-5 flex flex-col gap-4">
                <div className="flex items-center bg-[#FFF8F4] rounded-xl p-3 border border-[#E8D5CB]">
                  <input
                    type="text"
                    placeholder="BUTIK-XXXX"
                    value={code}
                    onChange={(e) => setCode(e.target.value.toUpperCase())}
                    className="flex-1 bg-transparent text-center font-mono font-bold text-xl tracking-[0.25em] text-[#592512] placeholder:text-[#A08070] placeholder:tracking-[0.25em] outline-none"
                  />
                </div>
                <button
                  onClick={handleRedeem}
                  className="w-full py-3.5 bg-[#D9078F] text-white font-bold rounded-xl flex items-center justify-center gap-2 active:scale-[0.98] transition-transform shadow-md shadow-[#D9078F]/30"
                >
                  <Sparkles className="w-5 h-5" />
                  Kodu Kullan
                </button>
                <p className="text-xs text-[#8B6B5A]">Kod bulamadın mı? Favori butiğinden iste!</p>
              </div>
            ) : (
              /* Success State */
              <div className="bg-white/90 backdrop-blur-md w-full rounded-2xl p-6 flex flex-col items-center gap-4">
                <div className="w-16 h-16 rounded-full bg-[#6FB7BF]/20 flex items-center justify-center">
                  <CheckCircle2 className="w-10 h-10 text-[#6FB7BF]" />
                </div>
                <h3 className="text-xl font-extrabold text-[#592512]">Tebrikler!</h3>
                <p className="text-sm text-[#8B6B5A] text-center">
                  <span className="font-bold text-[#D9078F]">Ayşe Eşarp Butik</span> size{' '}
                  <span className="font-bold text-[#6FB7BF]">5 deneme kredisi</span> hediye etti
                </p>
                <Link
                  to="/boutique"
                  className="w-full py-3.5 bg-[#D9078F] text-white font-bold rounded-xl flex items-center justify-center gap-2 active:scale-[0.98] transition-transform shadow-md"
                >
                  <Store className="w-5 h-5" />
                  Ürünleri Keşfet
                </Link>
              </div>
            )}
          </div>
        </section>

        {/* How It Works */}
        <section className="pb-12">
          <h3 className="text-lg font-bold mb-5 px-1 text-[#592512]">Nasıl Çalışır?</h3>
          <div className="space-y-4 relative before:absolute before:inset-0 before:ml-5 before:-translate-x-px before:h-full before:w-0.5 before:bg-gradient-to-b before:from-transparent before:via-[#E8D5CB] before:to-transparent">

            <div className="relative flex items-center justify-between group">
              <div className="flex items-center justify-center w-10 h-10 rounded-full border-4 border-[#FFF8F4] bg-[#D9078F] text-white font-bold z-10 shadow-sm text-sm">
                1
              </div>
              <div className="w-[calc(100%-4rem)] bg-white p-4 rounded-2xl border border-[#E8D5CB] shadow-sm">
                <h4 className="font-bold text-sm mb-1 text-[#592512]">Butikten Kod Al</h4>
                <p className="text-xs text-[#8B6B5A]">Favori eşarp butiğinden HIJAPP referans kodunu iste.</p>
              </div>
            </div>

            <div className="relative flex items-center justify-between group">
              <div className="flex items-center justify-center w-10 h-10 rounded-full border-4 border-[#FFF8F4] bg-[#6FB7BF] text-white font-bold z-10 shadow-sm text-sm">
                2
              </div>
              <div className="w-[calc(100%-4rem)] bg-white p-4 rounded-2xl border border-[#E8D5CB] shadow-sm">
                <h4 className="font-bold text-sm mb-1 text-[#592512]">Kodu Gir</h4>
                <p className="text-xs text-[#8B6B5A]">Yukarıdaki alana butik kodunu yaz ve "Kodu Kullan" butonuna bas.</p>
              </div>
            </div>

            <div className="relative flex items-center justify-between group">
              <div className="flex items-center justify-center w-10 h-10 rounded-full border-4 border-[#FFF8F4] bg-[#D99873] text-white font-bold z-10 shadow-sm text-sm">
                3
              </div>
              <div className="w-[calc(100%-4rem)] bg-white p-4 rounded-2xl border border-[#E8D5CB] shadow-sm">
                <h4 className="font-bold text-sm mb-1 text-[#592512]">Ücretsiz Dene</h4>
                <p className="text-xs text-[#8B6B5A]">Butiğin ürünlerini gör ve hediye kredilerle sanal olarak dene!</p>
              </div>
            </div>
          </div>
        </section>
      </main>
    </div>
  );
}
