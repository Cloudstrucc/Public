// Compile target: .NET Framework 4.6.2
// NuGet: Newtonsoft.Json (>= 13.0.1), Portable.BouncyCastle (>= 1.9.0)

using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Runtime.Serialization;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

// BouncyCastle (AES-GCM)
using Org.BouncyCastle.Crypto.Parameters;
using Org.BouncyCastle.Crypto.Engines;
using Org.BouncyCastle.Crypto.Modes;

namespace GCForms.DotNet462
{
    // ===========================
    // DataStructures.cs (adapted)
    // ===========================
    public class PrivateApiKey
    {
        public string keyId { get; set; }
        public string key { get; set; }       // PEM-encoded RSA private key (PKCS#1 or PKCS#8)
        public string userId { get; set; }
        public string formId { get; set; }
    }

    public class NewFormSubmission
    {
        public string name { get; set; }
        public ulong createdAt { get; set; }
    }

    public class EncryptedFormSubmission
    {
        public string encryptedResponses { get; set; } // Base64(ciphertext)
        public string encryptedKey { get; set; }       // Base64(key bytes)
        public string encryptedNonce { get; set; }     // Base64(IV/nonce)
        public string encryptedAuthTag { get; set; }   // Base64(tag)
    }

    public enum FormSubmissionStatus
    {
        [EnumMember(Value = "New")] New,
        [EnumMember(Value = "Downloaded")] Downloaded,
        [EnumMember(Value = "Confirmed")] Confirmed,
        [EnumMember(Value = "Problem")] Problem,
    }

    public class Attachment
    {
        public string name { get; set; }
        public string downloadLink { get; set; }
        public bool isPotentiallyMalicious { get; set; }
    }

    public class FormSubmission
    {
        public ulong createdAt { get; set; }
        public FormSubmissionStatus status { get; set; }
        public string confirmationCode { get; set; }
        public string answers { get; set; }  // JSON string (or decrypted plaintext you set)
        public string checksum { get; set; }
        public List<Attachment> attachments { get; set; }
    }

    public class FormSubmissionProblem
    {
        public string contactEmail { get; set; }
        public string description { get; set; }
        public string preferredLanguage { get; set; }
    }

    // =================================
    // AccessTokenGenerator.cs (adapted)
    // =================================
    public static class AccessTokenGenerator
    {
        /// <summary>
        /// Builds a client assertion JWT (RS256) and exchanges it for an OAuth access token.
        /// </summary>
        public static async Task<string> GetAccessTokenAsync(
            string tokenEndpoint,
            string clientId,
            string audience,
            string privateKeyPem,
            string keyId = null,
            int lifetimeSeconds = 180)
        {
            var now = DateTimeOffset.UtcNow;
            var payload = new Dictionary<string, object>
            {
                { "iss", clientId },
                { "sub", clientId },
                { "aud", string.IsNullOrWhiteSpace(audience) ? tokenEndpoint : audience },
                { "iat", now.ToUnixTimeSeconds() },
                { "exp", now.AddSeconds(lifetimeSeconds).ToUnixTimeSeconds() },
                { "jti", Guid.NewGuid().ToString("N") }
            };

            var header = new Dictionary<string, object>
            {
                { "alg", "RS256" },
                { "typ", "JWT" }
            };
            if (!string.IsNullOrWhiteSpace(keyId))
                header["kid"] = keyId;

            // Default: sign using PEM (RSACryptoServiceProvider created from PEM)
            var clientAssertion = BuildSignedJwt(header, payload, privateKeyPem);

            using (var http = NewHttpClient())
            {
                var form = new Dictionary<string, string>
                {
                    { "grant_type", "urn:ietf:params:oauth:grant-type:jwt-bearer" },
                    { "assertion", clientAssertion }
                };

                var resp = await http.PostAsync(tokenEndpoint, new FormUrlEncodedContent(form));
                var body = await resp.Content.ReadAsStringAsync();

                if (!resp.IsSuccessStatusCode)
                    throw new InvalidOperationException("Token request failed: " + resp.StatusCode + " " + body);

                var json = JsonConvert.DeserializeObject<Dictionary<string, object>>(body);
                if (json == null || !json.ContainsKey("access_token"))
                    throw new InvalidOperationException("No access_token in token response: " + body);

                return Convert.ToString(json["access_token"]);
            }
        }

        private static HttpClient NewHttpClient()
        {
            var handler = new HttpClientHandler
            {
                AutomaticDecompression = DecompressionMethods.GZip | DecompressionMethods.Deflate
            };
            var client = new HttpClient(handler);
            client.DefaultRequestHeaders.ExpectContinue = false;
            return client;
        }

        private static string BuildSignedJwt(
            IDictionary<string, object> header,
            IDictionary<string, object> payload,
            string privateKeyPem)
        {
            var headerJson = JsonConvert.SerializeObject(header);
            var payloadJson = JsonConvert.SerializeObject(payload);

            string headerB64 = Base64UrlEncode(Encoding.UTF8.GetBytes(headerJson));
            string payloadB64 = Base64UrlEncode(Encoding.UTF8.GetBytes(payloadJson));
            string signingInput = headerB64 + "." + payloadB64;

            using (var rsa = LoadRsaPrivateKeyFromPem(privateKeyPem))
            {
                var sig = rsa.SignData(Encoding.ASCII.GetBytes(signingInput), "SHA256");
                return signingInput + "." + Base64UrlEncode(sig);
            }
        }

        // ------------------------------
        // COMMENTED EXAMPLES (optional):
        // Sign with RSACryptoServiceProvider using a certificate in Windows Store
        // ------------------------------
        /*
        private static string BuildSignedJwtWithCertThumbprint(
            IDictionary<string, object> header,
            IDictionary<string, object> payload,
            string certThumbprint)
        {
            var headerJson = JsonConvert.SerializeObject(header);
            var payloadJson = JsonConvert.SerializeObject(payload);
            string headerB64 = Base64UrlEncode(Encoding.UTF8.GetBytes(headerJson));
            string payloadB64 = Base64UrlEncode(Encoding.UTF8.GetBytes(payloadJson));
            string signingInput = headerB64 + "." + payloadB64;

            // Find cert in CurrentUser\My (adapt store/location as needed)
            var store = new X509Store(StoreName.My, StoreLocation.CurrentUser);
            store.Open(OpenFlags.ReadOnly);
            try
            {
                var certs = store.Certificates.Find(X509FindType.FindByThumbprint, certThumbprint, false);
                if (certs.Count == 0) throw new InvalidOperationException("Cert not found: " + certThumbprint);
                var cert = certs[0];

                // Legacy RSACryptoServiceProvider path
                var rsa = cert.PrivateKey as RSACryptoServiceProvider;
                if (rsa == null) throw new InvalidOperationException("Cert does not have RSACryptoServiceProvider private key.");

                var sig = rsa.SignData(Encoding.ASCII.GetBytes(signingInput), "SHA256");
                return signingInput + "." + Base64UrlEncode(sig);
            }
            finally { store.Close(); }
        }

        private static string BuildSignedJwtWithCertFile(
            IDictionary<string, object> header,
            IDictionary<string, object> payload,
            string pfxPath,
            string pfxPassword)
        {
            var headerJson = JsonConvert.SerializeObject(header);
            var payloadJson = JsonConvert.SerializeObject(payload);
            string headerB64 = Base64UrlEncode(Encoding.UTF8.GetBytes(headerJson));
            string payloadB64 = Base64UrlEncode(Encoding.UTF8.GetBytes(payloadJson));
            string signingInput = headerB64 + "." + payloadB64;

            var cert = new X509Certificate2(pfxPath, pfxPassword, X509KeyStorageFlags.MachineKeySet | X509KeyStorageFlags.Exportable);
            var rsa = cert.PrivateKey as RSACryptoServiceProvider;
            if (rsa == null) throw new InvalidOperationException("PFX does not have RSACryptoServiceProvider private key.");

            var sig = rsa.SignData(Encoding.ASCII.GetBytes(signingInput), "SHA256");
            return signingInput + "." + Base64UrlEncode(sig);
        }
        */

        // ------------------------------
        // RSA key loading from PEM
        // ------------------------------
        private static RSACryptoServiceProvider LoadRsaPrivateKeyFromPem(string pem)
        {
            var keyData = ExtractDerFromPem(pem);
            // Try PKCS#8
            var rsa = DecodePkcs8PrivateKey(keyData);
            if (rsa != null) return rsa;
            // Try PKCS#1
            rsa = DecodePkcs1PrivateKey(keyData);
            if (rsa != null) return rsa;
            throw new NotSupportedException("Unsupported or invalid RSA private key PEM");
        }

        private static byte[] ExtractDerFromPem(string pem)
        {
            var sb = new StringBuilder();
            using (var sr = new StringReader(pem))
            {
                string line;
                while ((line = sr.ReadLine()) != null)
                {
                    if (line.StartsWith("-----")) continue;
                    sb.Append(line.Trim());
                }
            }
            return Convert.FromBase64String(sb.ToString());
        }

        private static RSACryptoServiceProvider DecodePkcs1PrivateKey(byte[] der)
        {
            using (var reader = new BinaryReader(new MemoryStream(der)))
            {
                try
                {
                    ReadAsn1Sequence(reader);
                    ReadAsn1Integer(reader); // version

                    var n = ReadAsn1IntegerBytes(reader);
                    var e = ReadAsn1IntegerBytes(reader);
                    var d = ReadAsn1IntegerBytes(reader);
                    var p = ReadAsn1IntegerBytes(reader);
                    var q = ReadAsn1IntegerBytes(reader);
                    var dp = ReadAsn1IntegerBytes(reader);
                    var dq = ReadAsn1IntegerBytes(reader);
                    var iq = ReadAsn1IntegerBytes(reader);

                    var rsaParams = new RSAParameters
                    {
                        Modulus = n, Exponent = e, D = d, P = p, Q = q, DP = dp, DQ = dq, InverseQ = iq
                    };
                    var rsa = new RSACryptoServiceProvider();
                    rsa.ImportParameters(rsaParams);
                    return rsa;
                }
                catch { return null; }
            }
        }

        private static RSACryptoServiceProvider DecodePkcs8PrivateKey(byte[] der)
        {
            using (var reader = new BinaryReader(new MemoryStream(der)))
            {
                try
                {
                    ReadAsn1Sequence(reader);
                    ReadAsn1Integer(reader); // version

                    // AlgorithmIdentifier
                    ReadAsn1Sequence(reader);
                    SkipAsn1Element(reader); // OID
                    if (PeekByte(reader) == 0x05) SkipAsn1Element(reader); // NULL (optional)

                    // PrivateKey OCTET STRING (contains PKCS#1 key)
                    var pkOctets = ReadAsn1OctetString(reader);
                    return DecodePkcs1PrivateKey(pkOctets);
                }
                catch { return null; }
            }
        }

        // ASN.1 helpers (minimal)
        private static void ReadAsn1Sequence(BinaryReader r) { if (r.ReadByte() != 0x30) throw new Exception(); ReadAsn1Length(r); }
        private static byte[] ReadAsn1IntegerBytes(BinaryReader r) { if (r.ReadByte() != 0x02) throw new Exception(); int len = ReadAsn1Length(r); var data = r.ReadBytes(len); return TrimLeadingZero(data); }
        private static void ReadAsn1Integer(BinaryReader r) { if (r.ReadByte() != 0x02) throw new Exception(); int len = ReadAsn1Length(r); r.ReadBytes(len); }
        private static byte[] ReadAsn1OctetString(BinaryReader r) { if (r.ReadByte() != 0x04) throw new Exception(); int len = ReadAsn1Length(r); return r.ReadBytes(len); }
        private static void SkipAsn1Element(BinaryReader r) { r.ReadByte(); int len = ReadAsn1Length(r); r.ReadBytes(len); }
        private static int ReadAsn1Length(BinaryReader r)
        {
            int b = r.ReadByte();
            if (b < 0x80) return b;
            int count = b & 0x7F;
            if (count == 1) return r.ReadByte();
            if (count == 2) return (r.ReadByte() << 8) | r.ReadByte();
            throw new NotSupportedException("ASN.1 length too large");
        }
        private static byte PeekByte(BinaryReader r)
        {
            var stream = (MemoryStream)r.BaseStream;
            int b = stream.ReadByte();
            if (b < 0) throw new EndOfStreamException();
            stream.Position--;
            return (byte)b;
        }
        private static byte[] TrimLeadingZero(byte[] data)
        {
            if (data.Length > 1 && data[0] == 0x00)
            {
                var x = new byte[data.Length - 1];
                Buffer.BlockCopy(data, 1, x, 0, x.Length);
                return x;
            }
            return data;
        }
        private static string Base64UrlEncode(byte[] arg)
        {
            string s = Convert.ToBase64String(arg);
            s = s.Split('=')[0];
            s = s.Replace('+', '-').Replace('/', '_');
            return s;
        }
    }

    // ==================================================
    // FormSubmissionIntegrityVerifier.cs (adapted)
    // ==================================================
    public static class FormSubmissionIntegrityVerifier
    {
        public static bool VerifyChecksum(string answersJson, string expectedChecksumBase64)
        {
            if (string.IsNullOrEmpty(expectedChecksumBase64)) return false;

            using (var sha = SHA256.Create())
            {
                var bytes = Encoding.UTF8.GetBytes(answersJson ?? "");
                var hash = sha.ComputeHash(bytes);
                var actual = Convert.ToBase64String(hash);
                return SlowEquals(actual, expectedChecksumBase64);
            }
        }

        private static bool SlowEquals(string a, string b)
        {
            if (a == null || b == null || a.Length != b.Length) return false;
            int diff = 0;
            for (int i = 0; i < a.Length; i++) diff |= a[i] ^ b[i];
            return diff == 0;
        }
    }

    // ==========================================
    // FormSubmissionDecrypter.cs (with BC GCM)
    // ==========================================
    public static class FormSubmissionDecrypter
    {
        /// <summary>
        /// Decrypts AES-GCM payloads using BouncyCastle.
        /// - encryptedResponses: Base64(ciphertext)
        /// - encryptedKey:       Base64(symmetric key bytes)
        /// - encryptedNonce:     Base64(nonce/IV)
        /// - encryptedAuthTag:   Base64(GCM tag)
        /// Returns UTF-8 plaintext.
        /// </summary>
        public static string DecryptResponsesAesGcm(EncryptedFormSubmission enc)
        {
            if (enc == null) throw new ArgumentNullException("enc");

            var cipherText = Convert.FromBase64String(enc.encryptedResponses);
            var key = Convert.FromBase64String(enc.encryptedKey);
            var nonce = Convert.FromBase64String(enc.encryptedNonce);
            var tag = Convert.FromBase64String(enc.encryptedAuthTag);

            // BouncyCastle expects ciphertext || tag as a single buffer
            var input = new byte[cipherText.Length + tag.Length];
            Buffer.BlockCopy(cipherText, 0, input, 0, cipherText.Length);
            Buffer.BlockCopy(tag, 0, input, cipherText.Length, tag.Length);

            var parameters = new AeadParameters(new KeyParameter(key), tag.Length * 8, nonce, null);
            var gcm = new GcmBlockCipher(new AesFastEngine());
            gcm.Init(false, parameters); // false = decrypt

            var output = new byte[gcm.GetOutputSize(input.Length)];
            int len = gcm.ProcessBytes(input, 0, input.Length, output, 0);
            len += gcm.DoFinal(output, len);

            return Encoding.UTF8.GetString(output, 0, len);
        }

        // ------------------------------
        // COMMENTED EXAMPLE (optional):
        // If you ever upgrade to .NET ≥ 4.7.2 + extra libs, or .NET Core, you could
        // use platform AesGcm; not available in .NET 4.6.2.
        // ------------------------------
        /*
        public static string DecryptWithAesGcmPlatform(byte[] key, byte[] nonce, byte[] cipher, byte[] tag)
        {
            using (var aes = new System.Security.Cryptography.AesGcm(key))
            {
                var plaintext = new byte[cipher.Length];
                aes.Decrypt(nonce, cipher, tag, plaintext, null);
                return Encoding.UTF8.GetString(plaintext);
            }
        }
        */
    }

    // ===============================
    // GCFormsApiClient.cs (adapted)
    // ===============================
    public class GCFormsApiClient : IDisposable
    {
        private readonly HttpClient _http;

        public GCFormsApiClient(string baseUrl, string accessToken)
        {
            var handler = new HttpClientHandler
            {
                AutomaticDecompression = DecompressionMethods.GZip | DecompressionMethods.Deflate
            };
            _http = new HttpClient(handler);
            _http.BaseAddress = new Uri(AppendSlash(baseUrl));
            _http.DefaultRequestHeaders.Add("Authorization", "Bearer " + accessToken);
        }

        public void Dispose()
        {
            if (_http != null) _http.Dispose();
        }

        public async Task<List<FormSubmission>> GetNewSubmissionsAsync(string formId)
        {
            // Adjust the endpoint/shape to your tenant’s actual API surface.
            var url = "v1/forms/" + Uri.EscapeDataString(formId) + "/submissions?status=New";
            var resp = await _http.GetAsync(url);
            var body = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
                throw new InvalidOperationException("API call failed: " + resp.StatusCode + " " + body);

            var list = JsonConvert.DeserializeObject<List<FormSubmission>>(body);
            return list ?? new List<FormSubmission>();
        }

        public async Task ConfirmDownloadedAsync(string formId, string confirmationCode)
        {
            var url = "v1/forms/" + Uri.EscapeDataString(formId) + "/submissions/" +
                      Uri.EscapeDataString(confirmationCode) + "/confirm";

            var req = new HttpRequestMessage(HttpMethod.Post, url)
            {
                Content = new StringContent("{}", Encoding.UTF8, "application/json")
            };
            var resp = await _http.SendAsync(req);
            var body = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
                throw new InvalidOperationException("Confirm failed: " + resp.StatusCode + " " + body);
        }

        private static string AppendSlash(string s) => s.EndsWith("/") ? s : (s + "/");
    }

    // =============
    // Program.cs
    // =============
    internal class Program
    {
        // Fill these from your environment/config
        private static readonly string FormsBaseUrl = "https://api.forms-formulaires.alpha.canada.ca/";
        private static readonly string TokenEndpoint = "https://oauth/v2/token";
        private static readonly string ClientId = "<client-id>";
        private static readonly string Audience = TokenEndpoint;

        private static readonly string PrivateKeyPem = @"-----BEGIN PRIVATE KEY-----
MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIw...
-----END PRIVATE KEY-----";

        private static readonly string FormId = "<form-id>";

        private static int Main(string[] args)
        {
            try
            {
                RunAsync().GetAwaiter().GetResult();
                return 0;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine("ERROR: " + ex.Message);
                return 1;
            }
        }

        private static async Task RunAsync()
        {
            Console.WriteLine("Requesting access token...");
            var accessToken = await AccessTokenGenerator.GetAccessTokenAsync(
                tokenEndpoint: TokenEndpoint,
                clientId: ClientId,
                audience: Audience,
                privateKeyPem: PrivateKeyPem,
                keyId: null,
                lifetimeSeconds: 180);

            Console.WriteLine("Access token acquired.");

            using (var client = new GCFormsApiClient(FormsBaseUrl, accessToken))
            {
                Console.WriteLine("Fetching NEW submissions...");
                var subs = await client.GetNewSubmissionsAsync(FormId);
                Console.WriteLine("Found: " + subs.Count);

                foreach (var s in subs)
                {
                    Console.WriteLine("----");
                    Console.WriteLine("ConfirmationCode: " + s.confirmationCode);
                    Console.WriteLine("Status: " + s.status);
                    Console.WriteLine("CreatedAt (epoch?): " + s.createdAt);
                    Console.WriteLine("Checksum: " + s.checksum);

                    // If your API returns encrypted fields separately, you’d construct EncryptedFormSubmission here.
                    // Example (pseudo — adapt to your payload contract):
                    // var enc = new EncryptedFormSubmission {
                    //     encryptedResponses = s.answersCipherB64,
                    //     encryptedKey = s.keyB64,
                    //     encryptedNonce = s.nonceB64,
                    //     encryptedAuthTag = s.tagB64
                    // };
                    // var plaintext = FormSubmissionDecrypter.DecryptResponsesAesGcm(enc);
                    // s.answers = plaintext;

                    bool ok = FormSubmissionIntegrityVerifier.VerifyChecksum(s.answers, s.checksum);
                    Console.WriteLine("Checksum verified? " + ok);

                    // Optionally confirm
                    // await client.ConfirmDownloadedAsync(FormId, s.confirmationCode);
                }
            }

            Console.WriteLine("Done.");
        }
    }
}
