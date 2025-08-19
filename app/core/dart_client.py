import time
import requests
from typing import Any

class DartClient:
    BASE = "https://opendart.fss.or.kr/api"

    def __init__(self, api_key: str, rate_sleep: float = 0.2):
        self.api_key = api_key
        self.rate_sleep = rate_sleep

    def _get(self, path: str, params: dict[str, Any]) -> dict[str, Any]:
        time.sleep(self.rate_sleep)
        resp = requests.get(f"{self.BASE}/{path}", params=params, timeout=20)
        try:
            return resp.json()
        except Exception:
            return {"status": "900", "message": f"http {resp.status_code}", "raw": resp.text}

    def list(self, **params) -> dict[str, Any]:
        params["crtfc_key"] = self.api_key
        return self._get("list.json", params)

    def singl_acnt_all(self, **params) -> dict[str, Any]:
        params["crtfc_key"] = self.api_key
        return self._get("fnlttSinglAcntAll.json", params)

    def company(self, **params) -> dict[str, Any]:
        params["crtfc_key"] = self.api_key
        return self._get("company.json", params)
