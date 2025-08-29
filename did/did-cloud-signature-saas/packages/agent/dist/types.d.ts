export interface DIDDocument {
    id: string;
    controller: string;
    verificationMethod: any[];
    authentication: any[];
}
export interface VerifiableCredential {
    "@context": string[];
    type: string[];
    issuer: string;
    credentialSubject: any;
    proof: any;
}
