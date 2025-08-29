export function generateDID(method: string, identifier: string): string {
  return `did:${method}:${identifier}`;
}

export function parseDID(did: string): { method: string; identifier: string } {
  const parts = did.split(':');
  return { method: parts[1], identifier: parts.slice(2).join(':') };
}
