import time
import math
import redis
from typing import Optional

class TokenBucketLimiter:
    def __init__(self, client: redis.Redis, key_prefix: str = "rl", capacity: int = 5, refill_rate: float = 5.0):
        self.client = client
        self.key_prefix = key_prefix
        self.capacity = capacity
        self.refill_rate = refill_rate  # tokens per second

    def _keys(self, name: str):
        return f"{self.key_prefix}:{name}:tokens", f"{self.key_prefix}:{name}:ts"

    def allow(self, name: str) -> bool:
        tokens_key, ts_key = self._keys(name)
        now = time.time()
        with self.client.pipeline() as pipe:
            while True:
                try:
                    pipe.watch(tokens_key, ts_key)
                    last_ts = pipe.get(ts_key)
                    tokens = pipe.get(tokens_key)
                    if last_ts is None:
                        curr_tokens = self.capacity
                        last = now
                    else:
                        last = float(last_ts)
                        curr_tokens = float(tokens) if tokens else self.capacity
                        delta = max(0.0, now - last)
                        curr_tokens = min(self.capacity, curr_tokens + delta * self.refill_rate)
                    if curr_tokens < 1.0:
                        pipe.unwatch()
                        return False
                    curr_tokens -= 1.0
                    pipe.multi()
                    pipe.set(ts_key, now)
                    pipe.set(tokens_key, curr_tokens)
                    pipe.execute()
                    return True
                except redis.WatchError:
                    continue
