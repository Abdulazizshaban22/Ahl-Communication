from collections import deque, defaultdict
from time import time

class State:
    def __init__(self, max_items: int = 200):
        self.ts = 0
        self.asr = deque(maxlen=max_items)
        self.emotion = deque(maxlen=max_items)
        self.suggestions = deque(maxlen=max_items)
        self.kpi = defaultdict(float)

    def snapshot(self):
        return {
            "ts": time(),
            "asr": list(self.asr),
            "emotion": list(self.emotion),
            "suggestions": list(self.suggestions),
            "kpi": dict(self.kpi),
        }

STATE = State()
