import time, json, requests, jwt
from jwt.algorithms import RSAAlgorithm

class JWTVerifier:
    def __init__(self, issuer, audience=None, jwks_url=None):
        self.issuer = issuer
        self.audience = audience
        self.jwks_url = jwks_url
        self.keys = {}

    def _get_key(self, kid):
        if kid in self.keys: return self.keys[kid]
        jwks = requests.get(self.jwks_url, timeout=5).json()
        for k in jwks.get('keys', []):
            if k.get('kid') == kid:
                pub = RSAAlgorithm.from_jwk(json.dumps(k))
                self.keys[kid] = pub
                return pub
        raise Exception('kid not found')

    def verify(self, token):
        header = jwt.get_unverified_header(token)
        pub = self._get_key(header.get('kid'))
        payload = jwt.decode(token, pub, algorithms=['RS256'], issuer=self.issuer, audience=self.audience, options={'require': ['exp','iss']})
        return payload
