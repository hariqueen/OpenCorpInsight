import os
import redis
import json
from typing import Any

class Cache:
    def __init__(self):
        self._client = redis.Redis(
            host=os.getenv("REDIS_HOST", "localhost"),
            port=int(os.getenv("REDIS_PORT", "6379")),
            db=int(os.getenv("REDIS_DB", "0")),
            decode_responses=True,
        )
        self.default_ttl = int(os.getenv("CACHE_TTL", "600"))

    def get(self, key: str) -> Any | None:
        v = self._client.get(key)
        if v is None:
            return None
        try:
            return json.loads(v)
        except Exception:
            return v

    def set(self, key: str, value: Any, ttl: int | None = None) -> None:
        s = json.dumps(value, ensure_ascii=False)
        self._client.setex(key, ttl or self.default_ttl, s)
