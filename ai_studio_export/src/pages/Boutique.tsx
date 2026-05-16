/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { Link } from 'react-router-dom';
import { ArrowLeft, ExternalLink, Sparkles, Instagram, ShoppingBag } from 'lucide-react';

export default function Boutique() {
  const boutique = {
    name: 'Ayşe Eşarp Butik',
    instagram: '@aysesarp',
    logo: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDX87ihe1Whsa0PBuxElsyNMEgXRaaDESEBc5cLEsFOaJI4k-stJPp6uv6hL3IMR7w0kToGxx8ZiHc2lhKV0vF8hUvfOAD8IZAhdWejVtfX1LvxYxgRy_QX4XxOC7JP8fq1N2Bhorr2TOgg6uPl2_6drnzfPBaxnTMjP87ZY0U4A-xSbpl_QyDvPuuXeysbtwQpLrEkHoPPSLRJgP-P6VobcP5nDsHM2w8jOkv-BCUnNipMvo_fJ8aRnKEtA_EGfBA5vqwJl_Zq5GjG',
    credits: 5,
  };

  const products = [
    {
      id: 1,
      name: 'Pembe Çiçekli İpek',
      price: '₺249',
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCUTJ11-TcBfMuuodUzUDWBklVZ6KnUjnEEWLgaeHNd8h5P5wutgrJiLk9_f1_dDIHJKllLahUqz3jAGGLtz1Yewjw1-jeVejmYHLIlZCWHLozZg99-6vVZFteGgUWdDgj8U_3sXmtE_6FdypDVooAYgS6ihWSL0SSsSy6Tld7g-6fNoYGAAx7Yl2z7plUllcnJuGWRgd8q2FF1ohXj717EJ_NY3ngAvMKQTRukwgCSJ6PPL_nPBWK578oFR0sCeKHZ2FGz_Zqz-pe2',
    },
    {
      id: 2,
      name: 'Turkuaz Pamuklu',
      price: '₺189',
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB5uoht6ABnGkZ_Wc98jg7s2WdsJLHqO9PzfhItuPfq_6pe0oevZIvJedwOd9sjnUh6AVk9PNrRufL2cSG3mykz9_8aUbpZvC5DrrGO5OtauEU3h2DNqHgMcKn_5eCzI-ZRd39SoPxWKuhyBs6KxHY2wpiBe2pCN4C5w0fwtReSq5ZQvlA3B9yKl0TjC2er64sLlsDzHFOuAqEgZN7DgZkDzjHA1y5V8vVdRzz5fqd55XAcLTh7e0FcfQPGx_OgtvSfMTmawM3mIXGf',
    },
    {
      id: 3,
      name: 'Toprak Tonlu Şifon',
      price: '₺310',
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCNYq3zGs2ovq4v6ScgMKXbj6Ce0ksq8xkDyfplsFeUOlJt_sABkshaQgxAznAuSOcV9eZACppvzmhxmsQFL6VjSf6VaXXXPcNdPQQh7dMkSt4Y5DKeSVYlcn5fYdUvjV5Sza_YE21FIqxznUW358LXkbI5QnvBO_9DPFvCA70ngN5Es9RyOY6V5PrCd5yMX0MblkyQQG6eQy843Cjl6xASSTgwt5-B7o0zhQUCLEsGzDYX7MlhWe9cuthEmtfDxqU2GQK9EJAedkjk',
    },
    {
      id: 4,
      name: 'Bej Desenli Penye',
      price: '₺175',
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDY-gl_DtGP9TMLvH-rzzUyWp4d0Q7-xZSkEDlKcPNOIFhL0DDXJ8MIyjkV1NreVYOvuvIHLBH9zRaA4KOCAyKotzKflcoYuAaIMOc0i0xBYBlV4fK3YK9BqLnktmMU_RupOqWDpSgNLYfdMTh_jRUnagHVb4or13dDSdAVk9JlxkZG8DjSR5bHjIC-j-ytGFRwKowei87CvS-CsNgruyB075WqYo9401GurXxvyHIrl4NqLHTssvqd-PhwTAAVdd0hk6yCdLRHfe8_',
    },
    {
      id: 5,
      name: 'Bordo İpek Saten',
      price: '₺420',
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDJmQPN-tD0dhNqLk284Q_fYrtW43_wdYEFhShj3KiKrMycP9BNW06BH1Ilde287d-LYFykA1rOUYZZPrHJYgkkaQblmP9fDxG5hcmTgARGTBCyjPMF9re7JsXWfOFOpGKSRHHVn8mfaOmzmYghCD4goqYST0c-BcPJoa-2Z_qvvFfxEBOaDXRiuUXa98CuQO6YTw8mEK4YTemarZMBVwKegqhu2G27mZ1zQHRVrmWoI9wtprTpO9Tp2FBl5rvXAaElQw4pcCZuDTDD',
    },
    {
      id: 6,
      name: 'Mint Yeşili Voile',
      price: '₺220',
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDX87ihe1Whsa0PBuxElsyNMEgXRaaDESEBc5cLEsFOaJI4k-stJPp6uv6hL3IMR7w0kToGxx8ZiHc2lhKV0vF8hUvfOAD8IZAhdWejVtfX1LvxYxgRy_QX4XxOC7JP8fq1N2Bhorr2TOgg6uPl2_6drnzfPBaxnTMjP87ZY0U4A-xSbpl_QyDvPuuXeysbtwQpLrEkHoPPSLRJgP-P6VobcP5nDsHM2w8jOkv-BCUnNipMvo_fJ8aRnKEtA_EGfBA5vqwJl_Zq5GjG',
    },
  ];

  return (
    <div className="bg-[#FFF8F4] text-[#592512] min-h-screen pb-8">
      {/* Boutique Header Banner */}
      <header className="bg-primary-gradient pt-14 pb-6 px-6 rounded-b-[2rem] shadow-lg shadow-[#D9078F]/10 relative overflow-hidden">
        <div className="absolute -top-10 -right-10 w-40 h-40 bg-white/10 rounded-full blur-3xl"></div>

        <div className="relative z-10">
          <Link to="/home" className="text-white mb-4 inline-block active:scale-95 transition-transform">
            <ArrowLeft className="w-6 h-6" />
          </Link>

          <div className="flex items-center gap-4 mb-4">
            <div className="w-14 h-14 rounded-full overflow-hidden border-3 border-white/40 shadow-md">
              <img src={boutique.logo} alt={boutique.name} className="w-full h-full object-cover" />
            </div>
            <div>
              <h1 className="text-xl font-extrabold text-white">{boutique.name}</h1>
              <div className="flex items-center gap-1.5 text-white/80">
                <Instagram className="w-3.5 h-3.5" />
                <span className="text-xs font-medium">{boutique.instagram}</span>
              </div>
            </div>
          </div>

          <div className="inline-flex items-center bg-white/20 backdrop-blur-md px-4 py-2 rounded-full border border-white/20">
            <Sparkles className="w-4 h-4 text-white mr-2" />
            <span className="text-sm font-bold text-white">{boutique.credits} kalan krediniz</span>
          </div>
        </div>
      </header>

      {/* Products Grid */}
      <main className="px-5 mt-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-bold text-[#592512]">Ürünler</h2>
          <span className="text-xs text-[#8B6B5A] font-medium">{products.length} ürün</span>
        </div>

        <div className="grid grid-cols-2 gap-4">
          {products.map((product) => (
            <div key={product.id} className="bg-white rounded-2xl overflow-hidden shadow-sm border border-[#E8D5CB]/50 group">
              <div className="relative aspect-[4/5] overflow-hidden">
                <img
                  src={product.image}
                  alt={product.name}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
              </div>
              <div className="p-3">
                <h3 className="text-sm font-semibold leading-tight mb-1.5 line-clamp-1 text-[#592512]">{product.name}</h3>
                <div className="flex items-center justify-between">
                  <span className="font-bold text-[#D9078F]">{product.price}</span>
                  <Link
                    to="/photo-mode"
                    className="text-[10px] font-bold bg-[#D9078F] text-white px-3 py-1.5 rounded-lg active:scale-95 transition-transform flex items-center gap-1"
                  >
                    <Sparkles className="w-3 h-3" />
                    Dene
                  </Link>
                </div>
                <a
                  href="#"
                  className="flex items-center gap-1 text-[10px] text-[#6FB7BF] font-semibold mt-2 hover:underline"
                >
                  <ShoppingBag className="w-3 h-3" />
                  Satın Al
                  <ExternalLink className="w-2.5 h-2.5" />
                </a>
              </div>
            </div>
          ))}
        </div>
      </main>

      {/* Bottom Info Bar */}
      <div className="fixed bottom-0 left-0 right-0 bg-white/80 backdrop-blur-xl border-t border-[#E8D5CB]/50 px-6 py-3 flex items-center justify-between z-40">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-full overflow-hidden border-2 border-[#D9078F]/30">
            <img src={boutique.logo} alt="" className="w-full h-full object-cover" />
          </div>
          <span className="text-xs font-semibold text-[#592512]">{boutique.name}</span>
        </div>
        <div className="flex items-center gap-1.5 bg-[#6FB7BF]/10 px-3 py-1.5 rounded-full">
          <Sparkles className="w-3.5 h-3.5 text-[#6FB7BF]" />
          <span className="text-xs font-bold text-[#6FB7BF]">{boutique.credits} kredi</span>
        </div>
      </div>
    </div>
  );
}
