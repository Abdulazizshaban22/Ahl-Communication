import re, unicodedata
def normalize_text(s: str) -> str:
    s = unicodedata.normalize("NFKC", s.strip())
    s = re.sub(r"\s+", " ", s)
    return s
