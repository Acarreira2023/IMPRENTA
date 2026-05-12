import CryptoJS from 'crypto-js';

const getSeedA = () => import.meta.env.VITE_SEED_A || 'imprenta-seed-alpha';
const getSeedB = () => import.meta.env.VITE_SEED_B || 'imprenta-seed-beta';

export const doubleEncrypt = (text: string): string => {
  const layer1 = CryptoJS.AES.encrypt(text, getSeedA()).toString();
  return CryptoJS.AES.encrypt(layer1, getSeedB()).toString();
};

export const verifyPassword = (password: string, encrypted: string): boolean => {
  try {
    return doubleEncrypt(password) === encrypted;
  } catch {
    return false;
  }
};

// Para el primer login (solo Capa A)
export const encryptSingleLayer = (text: string): string => {
  return CryptoJS.AES.encrypt(text, getSeedA()).toString();
};

export const verifySingleLayer = (password: string, encrypted: string): boolean => {
  return CryptoJS.AES.encrypt(password, getSeedA()).toString() === encrypted;
};