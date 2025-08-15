from pydantic import BaseModel, Field
from typing import Any, Dict, List, Optional

class Tool(BaseModel):
    name: str
    description: str
    inputSchema: Dict[str, Any]

class ToolCallRequest(BaseModel):
    arguments: Dict[str, Any] = Field(default_factory=dict)

class ToolCallResponse(BaseModel):
    ok: bool
    result: Any = None
    error: Optional[str] = None

# registry-like schemas
GET_FINANCIAL_STATEMENTS_SCHEMA = {
    "type": "object",
    "properties": {
        "corp_code": {"type": "string"},
        "bsns_year": {"type": "string"},
        "reprt_code": {"type": "string", "enum": ["11011","11012","11013","11014"]},
        "fs_div": {"type": "string", "enum": ["CFS","OFS"]},
        "statement_type": {"type": "string", "enum": ["재무상태표","손익계산서","현금흐름표","자본변동표"]}
    },
    "required": ["corp_code","bsns_year","reprt_code","fs_div","statement_type"]
}

GET_COMPANY_INFO_SCHEMA = {
    "type": "object",
    "properties": {
        "corp_code": {"type": "string"}
    },
    "required": ["corp_code"]
}

GET_DISCLOSURE_LIST_SCHEMA = {
    "type": "object",
    "properties": {
        "corp_code": {"type": "string"},
        "bgn_de": {"type": "string", "description": "YYYYMMDD"},
        "end_de": {"type": "string", "description": "YYYYMMDD"},
        "page_count": {"type": "integer", "default": 50}
    },
    "required": ["corp_code","bgn_de","end_de"]
}

GET_FINANCIAL_RATIOS_SCHEMA = {
    "type": "object",
    "properties": {
        "corp_code": {"type": "string"},
        "bsns_year": {"type": "string"},
        "reprt_code": {"type": "string", "enum": ["11011","11012","11013","11014"], "default": "11014"},
        "fs_div": {"type": "string", "enum": ["CFS","OFS"], "default": "CFS"}
    },
    "required": ["corp_code","bsns_year"]
}

COMPARE_FINANCIALS_SCHEMA = {
    "type": "object",
    "properties": {
        "corp_codes": {"type": "array", "items": {"type": "string"}},
        "bsns_year": {"type": "string"},
        "reprt_code": {"type": "string", "enum": ["11011","11012","11013","11014"], "default": "11014"},
        "fs_div": {"type": "string", "enum": ["CFS","OFS"], "default": "CFS"},
        "comparison_metrics": {"type": "array", "items": {"type": "string", "enum": ["매출액","영업이익","순이익","ROE","부채비율","영업이익률"]}, "default": ["매출액","영업이익","순이익"]}
    },
    "required": ["corp_codes","bsns_year"]
}

ANALYZE_TIME_SERIES_SCHEMA = {
    "type": "object",
    "properties": {
        "corp_code": {"type": "string"},
        "analysis_period": {"type": "integer", "default": 5},
        "metrics": {"type": "array", "items": {"type": "string"}, "default": ["매출액","영업이익","순이익"]},
        "reprt_code": {"type": "string", "enum": ["11014"], "default": "11014"},
        "fs_div": {"type": "string", "enum": ["CFS","OFS"], "default": "CFS"}
    },
    "required": ["corp_code"]
}

COMPARE_WITH_INDUSTRY_SCHEMA = {
    "type": "object",
    "properties": {
        "corp_code": {"type": "string"},
        "peer_corp_codes": {"type": "array", "items": {"type": "string"}},
        "bsns_year": {"type": "string"},
        "reprt_code": {"type": "string", "enum": ["11011","11012","11013","11014"], "default": "11014"},
        "fs_div": {"type": "string", "enum": ["CFS","OFS"], "default": "CFS"},
        "comparison_metrics": {"type": "array", "items": {"type": "string", "enum": ["매출액","영업이익","순이익","ROE","부채비율","영업이익률"]}, "default": ["매출액","영업이익","순이익"]}
    },
    "required": ["corp_code","peer_corp_codes","bsns_year"]
}

GENERATE_SUMMARY_REPORT_SCHEMA = {
    "type": "object",
    "properties": {
        "title": {"type": "string"},
        "content": {"type": "string"}
    },
    "required": ["title","content"]
}

EXPORT_TO_PDF_SCHEMA = {
    "type": "object",
    "properties": {
        "title": {"type": "string"},
        "content": {"type": "string"},
        "page_format": {"type": "string", "enum": ["A4","Letter"], "default": "A4"}
    },
    "required": ["title","content"]
}

GET_COMPANY_NEWS_SCHEMA = {
    "type": "object",
    "properties": {
        "query": {"type": "string"},
        "period": {"type": "string", "enum": ["day","week","month"], "default": "week"}
    },
    "required": ["query"]
}

ANALYZE_NEWS_SENTIMENT_SCHEMA = {
    "type": "object",
    "properties": {
        "query": {"type": "string"},
        "period": {"type": "string", "enum": ["day","week","month"], "default": "week"}
    },
    "required": ["query"]
}

OPTIMIZE_PORTFOLIO_SCHEMA = {
    "type": "object",
    "properties": {
        "tickers": {"type": "array", "items": {"type": "string"}},
        "budget": {"type": "number"},
        "risk": {"type": "string", "enum": ["낮음","보통","높음"], "default": "보통"}
    },
    "required": ["tickers","budget"]
}

ANALYZE_COMPETITIVE_POSITION_SCHEMA = {
    "type": "object",
    "properties": {
        "corp_code": {"type": "string"},
        "peer_corp_codes": {"type": "array", "items": {"type": "string"}}
    },
    "required": ["corp_code","peer_corp_codes"]
}

GENERATE_INDUSTRY_REPORT_SCHEMA = {
    "type": "object",
    "properties": {
        "industry": {"type": "string"}
    },
    "required": ["industry"]
}
