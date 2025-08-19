import httpx
from typing import Any, Dict

class PerplexityClient:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base = "https://api.perplexity.ai/chat/completions"

    async def search(self, query: str, recency: str | None = None) -> Dict[str, Any]:
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }
        prompt = (
            "다음 질의에 대한 한국어 뉴스 10건을 JSON 객체로만 반환하세요. 키는 'articles'이며 각 항목은 "
            "{title, content, url, source, published_date(YYYY-MM-DD)}를 포함합니다."
        )
        body = {
            "model": "sonar-small-online",
            "messages": [
                {"role": "system", "content": "너는 뉴스 수집기이다. 반드시 JSON만 반환한다."},
                {"role": "user", "content": f"질의: {query}"},
            ],
            "max_tokens": 800,
            "temperature": 0.2,
            "response_format": {"type": "json_object"},
        }
        async with httpx.AsyncClient(timeout=20) as client:
            r = await client.post(self.base, headers=headers, json=body)
            r.raise_for_status()
            j = r.json()
            content = j.get("choices", [{}])[0].get("message", {}).get("content", "{}")
            import json as _json
            try:
                return _json.loads(content)
            except Exception:
                return {"articles": []}
