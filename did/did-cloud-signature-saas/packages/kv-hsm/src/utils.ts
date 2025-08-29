import * as crypto from 'crypto';

export function generateRandomBytes(size: number): Buffer {
  return crypto.randomBytes(size);
}

export function createHash(data: string, algorithm: string = 'sha256'): string {
  return crypto.createHash(algorithm).update(data).digest('hex');
}
