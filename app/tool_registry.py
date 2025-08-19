from typing import List
from .schemas import (
    Tool,
    GET_FINANCIAL_STATEMENTS_SCHEMA,
    GET_COMPANY_INFO_SCHEMA,
    GET_DISCLOSURE_LIST_SCHEMA,
    GET_FINANCIAL_RATIOS_SCHEMA,
    COMPARE_FINANCIALS_SCHEMA,
    ANALYZE_TIME_SERIES_SCHEMA,
    COMPARE_WITH_INDUSTRY_SCHEMA,
)

TOOLS: List[Tool] = [
    Tool(
        name="get_company_info",
        description="기업 기본정보 조회(상장사만)",
        inputSchema=GET_COMPANY_INFO_SCHEMA,
    ),
    Tool(
        name="get_disclosure_list",
        description="공시 목록 조회(정기/분기/반기 등 필터는 pblntf_ty/detail은 내부 기본값 사용 또는 확장)",
        inputSchema=GET_DISCLOSURE_LIST_SCHEMA,
    ),
    Tool(
        name="get_financial_statements",
        description="단일회사 재무제표 조회(상장사만). corp_code, 연도, 보고서코드, fs_div, 유형 지정",
        inputSchema=GET_FINANCIAL_STATEMENTS_SCHEMA,
    ),
    Tool(
        name="get_financial_ratios",
        description="기초 재무비율(ROE/ROA/부채/유동 등) 계산(간단 버전)",
        inputSchema=GET_FINANCIAL_RATIOS_SCHEMA,
    ),
    Tool(
        name="compare_financials",
        description="여러 상장사의 주요 지표 비교",
        inputSchema=COMPARE_FINANCIALS_SCHEMA,
    ),
    Tool(
        name="analyze_time_series",
        description="최근 N년 연간 재무 트렌드 분석(간단)",
        inputSchema=ANALYZE_TIME_SERIES_SCHEMA,
    ),
    Tool(
        name="compare_with_industry",
        description="피어 그룹(상장사)과의 간단 비교",
        inputSchema=COMPARE_WITH_INDUSTRY_SCHEMA,
    ),
    Tool(
        name="generate_summary_report",
        description="간단 텍스트 기반 요약 리포트 생성",
        inputSchema=GENERATE_SUMMARY_REPORT_SCHEMA,
    ),
    Tool(
        name="export_to_pdf",
        description="리포트를 PDF로 내보내기(간단)",
        inputSchema=EXPORT_TO_PDF_SCHEMA,
    ),
    Tool(
        name="get_company_news",
        description="Perplexity 검색 기반 기업 뉴스(간단)",
        inputSchema=GET_COMPANY_NEWS_SCHEMA,
    ),
    Tool(
        name="analyze_news_sentiment",
        description="간단 키워드 기반 감성 요약(Perplexity 데이터)",
        inputSchema=ANALYZE_NEWS_SENTIMENT_SCHEMA,
    ),
    Tool(
        name="optimize_portfolio",
        description="간단 포트폴리오 배분(샘플)",
        inputSchema=OPTIMIZE_PORTFOLIO_SCHEMA,
    ),
    Tool(
        name="analyze_competitive_position",
        description="피어 대비 간단 비교 요약",
        inputSchema=ANALYZE_COMPETITIVE_POSITION_SCHEMA,
    ),
    Tool(
        name="generate_industry_report",
        description="업계 키워드 요약(샘플)",
        inputSchema=GENERATE_INDUSTRY_REPORT_SCHEMA,
    ),
]
