import os
import asyncio
import structlog
from fastapi import FastAPI, Depends, HTTPException, Request
from fastapi.responses import JSONResponse
from typing import Any, Dict

from .core.secrets import Secrets
from .core.cache import Cache
from .core.dart_client import DartClient
from .core.services import FinancialService
from .core.rate_limit import TokenBucketLimiter
from .tool_registry import TOOLS
from .schemas import ToolCallRequest

# OpenTelemetry (basic init)
from opentelemetry import trace
from opentelemetry.sdk.resources import Service, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor

logger = structlog.get_logger()

app = FastAPI(title="OpenCorpInsight Tool API", version="0.1.0")

# OTel setup
_service_name = os.getenv("OTEL_SERVICE_NAME", "opencorpinsight-http")
_endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
if _endpoint:
    provider = TracerProvider(resource=Resource.create({"service.name": _service_name}))
    processor = BatchSpanProcessor(OTLPSpanExporter(endpoint=_endpoint))
    provider.add_span_processor(processor)
    trace.set_tracer_provider(provider)
    FastAPIInstrumentor.instrument_app(app)
    RequestsInstrumentor().instrument()

# dependencies
_cache = Cache()
_redis_client = _cache._client
_limiter = TokenBucketLimiter(_redis_client, key_prefix="rl", capacity=int(os.getenv("RL_CAP", "5")), refill_rate=float(os.getenv("RL_RATE", "5")))

@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    name = request.url.path
    if not _limiter.allow(name):
        return JSONResponse(status_code=429, content={"ok": False, "error": "rate_limited"})
    return await call_next(request)


def get_services():
    sec = Secrets()
    dart_key = sec.get_dart_key()
    if not dart_key:
        raise HTTPException(status_code=500, detail="DART API key not configured in Secrets Manager")
    dart = DartClient(dart_key)
    svc = FinancialService(dart)
    return svc

@app.get("/v1/tools")
def list_tools():
    return [t.model_dump(mode="json") for t in TOOLS]

@app.post("/v1/tools/{name}:call")
def call_tool(name: str, req: ToolCallRequest, svc: FinancialService = Depends(get_services)):
    args: Dict[str, Any] = req.arguments
    if name == "get_company_info":
        return svc.get_company_info(corp_code=args["corp_code"])
    if name == "get_disclosure_list":
        return svc.get_disclosure_list(corp_code=args["corp_code"], bgn_de=args["bgn_de"], end_de=args["end_de"], page_count=args.get("page_count",50))
    if name == "get_financial_statements":
        return svc.get_financial_statements(
            corp_code=args["corp_code"], bsns_year=args["bsns_year"], reprt_code=args["reprt_code"], fs_div=args["fs_div"], statement_type=args["statement_type"],
        )
    if name == "get_financial_ratios":
        return svc.get_financial_ratios(
            corp_code=args["corp_code"], bsns_year=args["bsns_year"], reprt_code=args.get("reprt_code","11014"), fs_div=args.get("fs_div","CFS"),
        )
    if name == "compare_financials":
        return svc.compare_financials(
            corp_codes=args["corp_codes"], bsns_year=args["bsns_year"], reprt_code=args.get("reprt_code","11014"), fs_div=args.get("fs_div","CFS"), metrics=args.get("comparison_metrics"),
        )
    if name == "analyze_time_series":
        return svc.analyze_time_series(
            corp_code=args["corp_code"], analysis_period=args.get("analysis_period",5), metrics=args.get("metrics"), reprt_code=args.get("reprt_code","11014"), fs_div=args.get("fs_div","CFS"),
        )
    if name == "compare_with_industry":
        return svc.compare_with_industry(
            corp_code=args["corp_code"], peer_corp_codes=args["peer_corp_codes"], bsns_year=args["bsns_year"], reprt_code=args.get("reprt_code","11014"), fs_div=args.get("fs_div","CFS"), metrics=args.get("comparison_metrics"),
        )
    if name == "generate_summary_report":
        return svc.generate_summary_report(title=args["title"], content=args["content"])
    if name == "export_to_pdf":
        return svc.export_to_pdf(title=args["title"], content=args["content"], page_format=args.get("page_format","A4"))
    if name == "get_company_news":
        return asyncio.run(svc.get_company_news(query=args["query"], period=args.get("period","week")))
    if name == "analyze_news_sentiment":
        return asyncio.run(svc.analyze_news_sentiment(query=args["query"], period=args.get("period","week")))
    if name == "optimize_portfolio":
        return svc.optimize_portfolio(tickers=args["tickers"], budget=args["budget"], risk=args.get("risk","보통"))
    if name == "analyze_competitive_position":
        return svc.analyze_competitive_position(corp_code=args["corp_code"], peer_corp_codes=args["peer_corp_codes"])
    if name == "generate_industry_report":
        return svc.generate_industry_report(industry=args["industry"]) 
    raise HTTPException(status_code=404, detail=f"unknown tool: {name}")
