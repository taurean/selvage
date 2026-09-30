# AT Protocol OAuth: Confidential Client (Server-Side)

> **SvelteKit users:** This is not the right skill. See `oauth-sveltekit-browser.md` instead.
> That skill covers SvelteKit + `@atproto/oauth-client-browser` + server session cookies,
> which is the correct architecture for SvelteKit on Cloudflare Pages.

---

This guide covers **confidential client** ATProtocol OAuth — server-side apps (Go, Python, Node without a browser client library) that manually implement DPoP, PKCE, PAR, and client assertions using `private_key_jwt` authentication.

Use this when:
- Building a non-SvelteKit backend (Go, Python, raw Node)
- You need to sign API requests server-side with DPoP
- Your app needs long-lived server-held session tokens (not just a DID)

## References

- ATProtocol OAuth Specification: https://atproto.com/specs/oauth
- ATProtocol OAuth Guide: https://atproto.com/guides/oauth
- Bluesky Cookbook (Go): https://github.com/bluesky-social/cookbook/tree/main/go-oauth-web-app
- Bluesky Cookbook (Python): https://github.com/bluesky-social/cookbook/tree/main/python-oauth-web-app

## Client Metadata

Serve at `GET /oauth-client-metadata.json`. The URL is your `client_id`.

```json
{
  "application_type": "web",
  "client_id": "https://example.com/oauth-client-metadata.json",
  "client_name": "Your App",
  "client_uri": "https://example.com",
  "dpop_bound_access_tokens": true,
  "grant_types": ["authorization_code", "refresh_token"],
  "jwks": {
    "keys": [{
      "alg": "ES256", "crv": "P-256", "kid": "did:key:zDnae...",
      "kty": "EC", "use": "sig", "x": "...", "y": "..."
    }]
  },
  "redirect_uris": ["https://example.com/auth/callback"],
  "response_types": ["code"],
  "scope": "atproto",
  "token_endpoint_auth_method": "private_key_jwt",
  "token_endpoint_auth_signing_alg": "ES256"
}
```

## Key Generation

```bash
# Using goat CLI (recommended)
brew install goat
goat key generate -t p256 -o jwk
```

The JWK's `d` field is the private key — store securely. Strip `d` for the public JWK in metadata.

## Flow Summary

```
1. User submits handle/DID
2. Resolve handle → DID → PDS → auth server metadata
3. Generate: PKCE verifier/challenge, state, DPoP key pair
4. Store state (PKCE verifier, DPoP key, issuer, token endpoint)
5. PAR request with DPoP proof + client assertion JWT → get request_uri
6. Handle DPoP nonce challenge if 400 use_dpop_nonce (retry once)
7. Redirect to authorization_endpoint?client_id=...&request_uri=...
8. Callback: validate state + iss, exchange code for tokens with DPoP proof
9. Store session: DID, tokens, DPoP key, separate nonces for auth server and PDS
10. API requests: DPoP proof with ath (access token hash) claim
11. Logout: revoke token, clear session
```

## Key Implementation Details

**PAR request** (POST to `pushed_authorization_request_endpoint`):
- `Content-Type: application/x-www-form-urlencoded`
- `DPoP: <proof_jwt>` header
- Body: `response_type=code&code_challenge=...&code_challenge_method=S256&client_id=...&state=...&redirect_uri=...&scope=atproto&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer&client_assertion=<jwt>`

**DPoP proof JWT** (signed with per-session P-256 key):
- Header: `{"typ":"dpop+jwt","alg":"ES256","jwk":{public key}}`
- Claims: `{"jti":"<unique>","htm":"POST","htu":"<endpoint-no-query>","iat":<now>,"exp":<now+30>}`
- For resource requests add: `"ath":"<base64url(sha256(access_token))>"` and use 10s expiry

**Client assertion JWT** (signed with your app's signing key):
- Header: `{"typ":"JWT","alg":"ES256","kid":"<your-key-kid>"}`
- Claims: `{"iss":"<client_id>","sub":"<client_id>","aud":"<issuer>","jti":"<unique>","iat":<now>,"exp":<now+30>}`

**Session storage fields**: `did`, `access_token`, `refresh_token`, `dpop_private_key`, `dpop_authserver_nonce`, `dpop_pds_nonce`, `token_endpoint`, `expires_at`

**Token refresh**: Check `expires_at` within 5 minutes; refresh proactively. Single-use refresh tokens rotate on use.

**DPoP nonce errors**: On `use_dpop_nonce` error, extract `DPoP-Nonce` header, add `"nonce"` claim to DPoP proof, retry once.
