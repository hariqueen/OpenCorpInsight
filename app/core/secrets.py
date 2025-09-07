import os
import json
import boto3
from botocore.exceptions import ClientError
from typing import Optional, Dict

class Secrets:
    def __init__(self, region: Optional[str] = None):
        self._region = region or os.getenv("AWS_REGION", "ap-northeast-2")
        self._boto = boto3.session.Session().client("secretsmanager", region_name=self._region)
        self._cache: Dict[str, str] = {}

    def get(self, name: str) -> Optional[str]:
        if name in self._cache:
            return self._cache[name]
        try:
            resp = self._boto.get_secret_value(SecretId=name)
            val = resp.get("SecretString")
            if val:
                self._cache[name] = val
                return val
        except ClientError:
            return None
        return None

    def get_dart_key(self) -> Optional[str]:
        s = self.get("OPENCORPINSIGHT_SECRETS")
        if s:
            try:
                data = json.loads(s)
                if isinstance(data, dict):
                    key = data.get("DART_API_KEY") or data.get("dart_api_key")
                    # JSON 문자열인 경우 파싱
                    if key and key.startswith('{'):
                        try:
                            key_data = json.loads(key)
                            return key_data.get("DART_API_KEY") or key_data.get("dart_api_key")
                        except:
                            pass
                    return key
            except Exception:
                pass
        s = self.get("DART_API_KEY")
        # JSON 문자열인 경우 파싱
        if s and s.startswith('{'):
            try:
                data = json.loads(s)
                return data.get("DART_API_KEY") or data.get("dart_api_key")
            except:
                pass
        return s

    def get_perplexity_key(self) -> Optional[str]:
        s = self.get("OPENCORPINSIGHT_SECRETS")
        if s:
            try:
                data = json.loads(s)
                if isinstance(data, dict):
                    return data.get("PERPLEXITY_API_KEY") or data.get("perplexity_api_key")
            except Exception:
                pass
        s = self.get("PERPLEXITY_API_KEY")
        return s

    def get_gpt_key(self) -> Optional[str]:
        s = self.get("OPENCORPINSIGHT_SECRETS")
        if s:
            try:
                data = json.loads(s)
                if isinstance(data, dict):
                    return data.get("GPT_API_KEY") or data.get("gpt_api_key")
            except Exception:
                pass
        s = self.get("GPT_API_KEY")
        return s

    def get_gpt_key(self) -> Optional[str]:
        s = self.get("OPENCORPINSIGHT_SECRETS")
        if s:
            try:
                data = json.loads(s)
                if isinstance(data, dict):
                    return data.get("GPT_API_KEY") or data.get("gpt_api_key")
            except Exception:
                pass
        s = self.get("GPT_API_KEY")
        return s
