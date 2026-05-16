// iyzipay package'inde resmi type yok; minimum surface'i bildir.
declare module 'iyzipay' {
  type Cb<T = unknown> = (err: unknown, result: T) => void;

  interface IyzipayConfig {
    apiKey: string;
    secretKey: string;
    uri: string;
  }

  class Iyzipay {
    constructor(config: IyzipayConfig);
    checkoutFormInitialize: {
      create(request: Record<string, unknown>, cb: Cb): void;
    };
    checkoutForm: {
      retrieve(request: { token: string; locale?: string }, cb: Cb): void;
    };
  }

  export default Iyzipay;
}
