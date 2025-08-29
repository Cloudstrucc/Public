export function generateDID(method, identifier) {
    return `did:${method}:${identifier}`;
}
export function parseDID(did) {
    const parts = did.split(':');
    return { method: parts[1], identifier: parts.slice(2).join(':') };
}
