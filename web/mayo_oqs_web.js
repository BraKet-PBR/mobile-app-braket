(function () {
  let mayoPromise;

  function bytesToBase64Url(bytes) {
    let binary = '';
    const chunkSize = 0x8000;
    for (let i = 0; i < bytes.length; i += chunkSize) {
      binary += String.fromCharCode.apply(null, bytes.subarray(i, i + chunkSize));
    }
    return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/g, '');
  }

  function base64UrlToBytes(value) {
    const base64 = value.replace(/-/g, '+').replace(/_/g, '/');
    const padded = base64.padEnd(base64.length + ((4 - base64.length % 4) % 4), '=');
    const binary = atob(padded);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i += 1) {
      bytes[i] = binary.charCodeAt(i);
    }
    return bytes;
  }

  async function getMayo() {
    if (!mayoPromise) {
      mayoPromise = import('./liboqs-js/src/algorithms/sig/mayo/mayo-1.js')
        .then(async (oqs) => oqs.createMAYO1())
        .catch((error) => {
          throw new Error(
            'Nie udalo sie zaladowac MAYO-1 WASM dla web. ' +
              'Sprawdz czy pliki web/liboqs-js zostaly skopiowane do build/web. ' +
              (error && error.message ? error.message : error)
          );
        });
    }
    return mayoPromise;
  }

  window.braketMayo = {
    async generateKeyPair() {
      const mayo = await getMayo();
      const keyPair = mayo.generateKeyPair();
      return {
        publicKey: bytesToBase64Url(keyPair.publicKey),
        privateKey: bytesToBase64Url(keyPair.secretKey || keyPair.privateKey),
      };
    },

    async sign(message, privateKey) {
      const mayo = await getMayo();
      const signature = mayo.sign(base64UrlToBytes(message), base64UrlToBytes(privateKey));
      return bytesToBase64Url(signature);
    },

    async verify(message, signature, publicKey) {
      const mayo = await getMayo();
      return mayo.verify(
        base64UrlToBytes(message),
        base64UrlToBytes(signature),
        base64UrlToBytes(publicKey)
      );
    },
  };
})();
