import os
import json
import logging
import requests
import zipfile
import io
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from flask import Flask, request, jsonify
from flask_cors import CORS

# MCP Secrets 클래스 사용
try:
    from app.core.secrets import Secrets
    _mcp_secrets = Secrets()
    
    # MCP Secrets에서 API 키 로드
    DART_API_KEY = _mcp_secrets.get_dart_key()
    PERPLEXITY_API_KEY = _mcp_secrets.get_perplexity_key()
    GPT_API_KEY = _mcp_secrets.get_gpt_key()
    
    print(f"✅ MCP Secrets에서 API 키 로드 성공")
    
except Exception as e:
    print(f"❌ MCP Secrets 초기화 실패: {e}")
    print("❌ AWS Secrets Manager에서 API 키를 가져올 수 없습니다.")
    exit(1)

# API 키 로딩 결과 로그
print(f"🔍 API 키 로딩 결과:")
print(f"   - DART_API_KEY: {'설정됨' if DART_API_KEY else 'None'} ({DART_API_KEY[:10] if DART_API_KEY else 'N/A'}...)")
print(f"   - PERPLEXITY_API_KEY: {'설정됨' if PERPLEXITY_API_KEY else 'None'} ({PERPLEXITY_API_KEY[:10] if PERPLEXITY_API_KEY else 'N/A'}...)")
print(f"   - GPT_API_KEY: {'설정됨' if GPT_API_KEY else 'None'} ({GPT_API_KEY[:10] if GPT_API_KEY else 'N/A'}...)")

# 필수 키 검증 (최소 DART 키) - 로컬 테스트용으로 경고만 표시
if not DART_API_KEY:
    print("⚠️ DART_API_KEY가 설정되지 않았습니다! 일부 기능이 제한됩니다.")
    print("⚠️ 로컬 테스트를 위해 서버는 계속 실행됩니다.")
    print("⚠️ 실제 기능 테스트를 위해서는 DART API 키를 설정하세요.")
else:
    print("✅ DART_API_KEY 설정됨")

# Flask 앱 초기화
app = Flask(__name__)
CORS(app, origins=["http://localhost:8080", "http://localhost:8081", "http://127.0.0.1:8080", "http://127.0.0.1:8081"])

# --- MCP 코어 연동 초기화 ---
try:
    from app.core.dart_client import DartClient
    from app.core.services import FinancialService

    _DART_CLIENT = DartClient(DART_API_KEY)
    _MCP_SVC = FinancialService(_DART_CLIENT)
    
    # MCP 초기화 상태 로그
    print(f"✅ MCP 서비스 초기화 성공")
    print(f"   - DART API Key: {'설정됨' if DART_API_KEY else 'None'}")
    print(f"   - Perplexity API Key: {'설정됨' if PERPLEXITY_API_KEY else 'None'}")
    print(f"   - GPT API Key: {'설정됨' if GPT_API_KEY else 'None'}")
    
except Exception as _mcp_init_err:
    logger = logging.getLogger(__name__)
    logger.warning(f"MCP 초기화 경고: {getattr(_mcp_init_err, 'message', _mcp_init_err)}")
    print(f"❌ MCP 서비스 초기화 실패: {_mcp_init_err}")
    _MCP_SVC = None

# DB API 서버 설정 (로컬 테스트용으로 비활성화)
DB_API_BASE_URL = None  # 로컬 테스트에서는 DB 저장 비활성화
# DB_API_BASE_URL = "http://43.203.170.37:8080"  # 실제 서버 주소 (필요시 주석 해제)

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 글로벌 캐시
CORP_CODE_CACHE = {}

def get_corp_code(corp_name: str) -> str:
    """기업 고유번호 조회"""
    if corp_name in CORP_CODE_CACHE:
        return CORP_CODE_CACHE[corp_name]
    
    # DART API 키가 없으면 기본 기업 코드 반환
    if not DART_API_KEY:
        logger.warning(f"DART API 키가 없어 기본 기업 코드를 반환합니다. (corp_name: {corp_name})")
        # 일반적인 기업명에 대한 기본 코드 매핑
        default_codes = {
            '삼성전자': '00126380',
            '애플': '00126380',  # 임시로 삼성전자 코드 사용
            '구글': '00126380',  # 임시로 삼성전자 코드 사용
            '테슬라': '00126380',  # 임시로 삼성전자 코드 사용
        }
        return default_codes.get(corp_name, '00126380')  # 기본값: 삼성전자
    
    try:
        zip_url = f'https://opendart.fss.or.kr/api/corpCode.xml?crtfc_key={DART_API_KEY}'
        response = requests.get(zip_url, timeout=30)
        
        with zipfile.ZipFile(io.BytesIO(response.content)) as zf:
            corp_bytes = zf.read('CORPCODE.xml')
            try:
                xml_str = corp_bytes.decode('euc-kr')
            except UnicodeDecodeError:
                xml_str = corp_bytes.decode('utf-8')
        
        root = ET.fromstring(xml_str)
        
        for item in root.findall('.//list'):
            name = item.find('corp_name').text
            code = item.find('corp_code').text
            
            if corp_name in name:
                CORP_CODE_CACHE[corp_name] = code
                return code
                
        raise ValueError(f"기업 '{corp_name}'을 찾을 수 없습니다.")
        
    except Exception as e:
        logger.error(f"기업 코드 조회 오류: {e}")
        raise

def get_financial_data(corp_code: str, year: str = '2023') -> Dict:
    """재무제표 데이터 조회 - pandas 없이 순수 Python 사용"""
    # DART API 키가 없으면 샘플 데이터 반환
    if not DART_API_KEY:
        logger.warning(f"DART API 키가 없어 샘플 데이터를 반환합니다. (corp_code: {corp_code}, year: {year})")
        return {
            'revenue': 1000000000000,  # 1조원
            'operating_profit': 100000000000,  # 1000억원
            'net_profit': 80000000000,  # 800억원
            'total_assets': 2000000000000,  # 2조원
            'total_debt': 800000000000,  # 8000억원
            'total_equity': 1200000000000  # 1.2조원
        }
    
    try:
        # 올바른 API 엔드포인트 사용
        url = 'https://opendart.fss.or.kr/api/fnlttSinglAcnt.json'
        params = {
            'crtfc_key': DART_API_KEY,
            'corp_code': corp_code,
            'bsns_year': year,
            'reprt_code': '11011'  # 사업보고서 (연간 데이터)
        }
        
        logger.info(f"DART API 호출: {url} with params: {params}")
        
        response = requests.get(url, params=params, timeout=30)
        
        logger.info(f"DART API 응답 상태: {response.status_code}")
        
        if response.status_code != 200:
            raise ValueError(f"HTTP 오류: {response.status_code}")
        
        data = response.json()
        logger.info(f"DART API 응답 데이터: status={data.get('status')}, message={data.get('message')}")
        
        if data['status'] != '000':
            raise ValueError(f"DART API 오류: {data.get('message', '알 수 없는 오류')}")
        
        if 'list' not in data or not data['list']:
            raise ValueError(f"재무 데이터가 없습니다: {year}년 {corp_code}")
        
        # pandas 대신 순수 Python 사용
        financial_list = data['list']
        financial_data = {}
        
        # CFS (연결재무제표) 우선, 없으면 OFS (개별재무제표) 사용
        cfs_data = [item for item in financial_list if item.get('fs_div') == 'CFS']
        if not cfs_data:
            ofs_data = [item for item in financial_list if item.get('fs_div') == 'OFS']
            if ofs_data:
                filtered_data = ofs_data
                logger.info("CFS 없음, OFS 사용")
            else:
                raise ValueError("연결재무제표(CFS)와 개별재무제표(OFS) 모두 없습니다")
        else:
            filtered_data = cfs_data
            logger.info("CFS 사용")
        
        # 손익계산서(IS)에서 주요 지표 추출
        income_statement = [item for item in filtered_data if item.get('sj_div') == 'IS']
        if income_statement:
            # 매출액 찾기 (다양한 계정명 고려)
            revenue_patterns = ['매출액', '수익(매출액)', '영업수익', '매출', '총매출액']
            for pattern in revenue_patterns:
                for item in income_statement:
                    account_nm = item.get('account_nm', '')
                    if pattern in account_nm:
                        amount = item.get('thstrm_amount', '')
                        if amount and amount != '-':
                            try:
                                financial_data['revenue'] = float(amount.replace(',', ''))
                                logger.info(f"매출액 발견: {pattern} = {financial_data['revenue']}")
                                break
                            except ValueError:
                                continue
                if 'revenue' in financial_data:
                    break
            
            # 영업이익 찾기
            operating_patterns = ['영업이익', '영업손익', '영업이익(손실)']
            for pattern in operating_patterns:
                for item in income_statement:
                    account_nm = item.get('account_nm', '')
                    if pattern in account_nm:
                        amount = item.get('thstrm_amount', '')
                        if amount and amount != '-':
                            try:
                                financial_data['operating_profit'] = float(amount.replace(',', ''))
                                logger.info(f"영업이익 발견: {pattern} = {financial_data['operating_profit']}")
                                break
                            except ValueError:
                                continue
                if 'operating_profit' in financial_data:
                    break
            
            # 당기순이익 찾기
            net_patterns = ['당기순이익', '순이익', '당기순손익', '당기순이익(손실)']
            for pattern in net_patterns:
                for item in income_statement:
                    account_nm = item.get('account_nm', '')
                    if pattern in account_nm:
                        amount = item.get('thstrm_amount', '')
                        if amount and amount != '-':
                            try:
                                financial_data['net_profit'] = float(amount.replace(',', ''))
                                logger.info(f"당기순이익 발견: {pattern} = {financial_data['net_profit']}")
                                break
                            except ValueError:
                                continue
                if 'net_profit' in financial_data:
                    break
        
        # 재무상태표(BS)에서 주요 지표 추출
        balance_sheet = [item for item in filtered_data if item.get('sj_div') == 'BS']
        if balance_sheet:
            # 자산총계 찾기
            asset_patterns = ['자산총계', '총자산', '자산합계']
            for pattern in asset_patterns:
                for item in balance_sheet:
                    account_nm = item.get('account_nm', '')
                    if pattern in account_nm:
                        amount = item.get('thstrm_amount', '')
                        if amount and amount != '-':
                            try:
                                financial_data['total_assets'] = float(amount.replace(',', ''))
                                logger.info(f"자산총계 발견: {pattern} = {financial_data['total_assets']}")
                                break
                            except ValueError:
                                continue
                if 'total_assets' in financial_data:
                    break
            
            # 부채총계 찾기
            debt_patterns = ['부채총계', '총부채', '부채합계']
            for pattern in debt_patterns:
                for item in balance_sheet:
                    account_nm = item.get('account_nm', '')
                    if pattern in account_nm:
                        amount = item.get('thstrm_amount', '')
                        if amount and amount != '-':
                            try:
                                financial_data['total_debt'] = float(amount.replace(',', ''))
                                logger.info(f"부채총계 발견: {pattern} = {financial_data['total_debt']}")
                                break
                            except ValueError:
                                continue
                if 'total_debt' in financial_data:
                    break
            
            # 자본총계 찾기
            equity_patterns = ['자본총계', '총자본', '자본합계', '자본']
            for pattern in equity_patterns:
                for item in balance_sheet:
                    account_nm = item.get('account_nm', '')
                    if pattern in account_nm:
                        amount = item.get('thstrm_amount', '')
                        if amount and amount != '-':
                            try:
                                financial_data['total_equity'] = float(amount.replace(',', ''))
                                logger.info(f"자본총계 발견: {pattern} = {financial_data['total_equity']}")
                                break
                            except ValueError:
                                continue
                if 'total_equity' in financial_data:
                    break
        
        logger.info(f"추출된 재무 데이터: {financial_data}")
        
        if not financial_data:
            raise ValueError("유효한 재무 데이터를 찾을 수 없습니다")
        
        return financial_data
        
    except Exception as e:
        logger.error(f"재무 데이터 조회 오류: {e}")
        raise

def search_news_perplexity(company_name: str, period: str = '3days') -> List[Dict]:
    """Perplexity API를 통해 뉴스 검색 및 요약만 반환"""
    print(f"🔍 뉴스 검색 시작: {company_name} ({period})")
    print(f"   - PERPLEXITY_API_KEY: {'설정됨' if PERPLEXITY_API_KEY else 'None'} ({PERPLEXITY_API_KEY[:20] if PERPLEXITY_API_KEY else 'N/A'}...)")
    
    if not PERPLEXITY_API_KEY:
        print(f"⚠️ Perplexity API 키 없음 - 샘플 뉴스 데이터 반환")
        # 샘플 뉴스 데이터 반환
        return [
            {
                'title': f'{company_name} 2024년 2분기 실적 발표',
                'content': f'{company_name}이 2024년 2분기 실적을 발표했습니다. 매출은 전년 동기 대비 5% 증가했으며, 영업이익은 10% 성장을 기록했습니다.',
                'summary': f'{company_name} 2분기 실적 호조, 매출 5% 증가',
                'published_date': '2024-07-15',
                'source': '경제일보',
                'url': 'https://example.com/news1'
            },
            {
                'title': f'{company_name} 신규 사업 진출 소식',
                'content': f'{company_name}이 새로운 사업 영역으로 진출한다고 발표했습니다. 투자자들은 긍정적인 반응을 보이고 있습니다.',
                'summary': f'{company_name} 신규 사업 진출, 투자자 긍정적 반응',
                'published_date': '2024-07-10',
                'source': '비즈니스뉴스',
                'url': 'https://example.com/news2'
            },
            {
                'title': f'{company_name} 주가 상승세',
                'content': f'{company_name} 주가가 최근 상승세를 보이고 있습니다. 실적 개선과 신규 사업 진출 소식이 긍정적으로 작용하고 있습니다.',
                'summary': f'{company_name} 주가 상승세, 실적 개선 기대감',
                'published_date': '2024-07-05',
                'source': '증권일보',
                'url': 'https://example.com/news3'
            }
        ]
    
    try:
        period_map = {'day': '지난 24시간', '3days': '지난 3일', 'week': '지난 7일', 'month': '지난 30일'}
        period_text = period_map.get(period, '지난 3일')
        
        url = "https://api.perplexity.ai/chat/completions"
        headers = {
            "Authorization": f"Bearer {PERPLEXITY_API_KEY}",
            "Content-Type": "application/json"
        }
        
        # 대시보드 호환성을 위한 프롬프트 (content와 summary 모두 포함)
        prompt = f"""
{company_name}의 {period_text} 재무, 실적, 투자 관련 뉴스 5건을 다음 JSON 형태로만 반환하세요:

{{
  "articles": [
    {{
      "title": "기사 제목",
      "content": "기사 전체 내용 (감성분석용)",
      "summary": "핵심 내용 3줄 요약",
      "published_date": "YYYY-MM-DD",
      "source": "언론사명",
      "url": "기사 URL"
    }},
    {{
      "title": "기사 제목",
      "content": "기사 전체 내용 (감성분석용)",
      "summary": "핵심 내용 3줄 요약",
      "published_date": "YYYY-MM-DD",
      "source": "언론사명",
      "url": "기사 URL"
    }},
    {{
      "title": "기사 제목",
      "content": "기사 전체 내용 (감성분석용)",
      "summary": "핵심 내용 3줄 요약",
      "published_date": "YYYY-MM-DD",
      "source": "언론사명",
      "url": "기사 URL"
    }},
    {{
      "title": "기사 제목",
      "content": "기사 전체 내용 (감성분석용)",
      "summary": "핵심 내용 3줄 요약",
      "published_date": "YYYY-MM-DD",
      "source": "언론사명",
      "url": "기사 URL"
    }},
    {{
      "title": "기사 제목",
      "content": "기사 전체 내용 (감성분석용)",
      "summary": "핵심 내용 3줄 요약",
      "published_date": "YYYY-MM-DD",
      "source": "언론사명",
      "url": "기사 URL"
    }}
  ]
}}

요구사항:
1. 반드시 재무/실적/투자 관련 뉴스만 선별
2. content: 기사 전체 내용 (감성분석용, 200-300자)
3. summary: 핵심 내용 3줄 요약 (100자 내외)
4. 모든 텍스트는 JSON 이스케이프 규칙 준수
"""
        
        data = {
            "model": "sonar-pro",
            "messages": [
                {"role": "system", "content": "당신은 재무 뉴스 수집 및 요약 전문가입니다. 반드시 JSON만 반환하고, summary는 정확히 3줄로 작성합니다."},
                {"role": "user", "content": prompt}
            ],
            "max_tokens": 2000,  # content 포함으로 토큰 수 증가
            "temperature": 0.2
        }
        
        # API 요청
        print(f"📡 Perplexity API 요청 전송...")
        response = requests.post(url, headers=headers, json=data, timeout=30)
        print(f"📡 Perplexity API 응답 상태: {response.status_code}")
        print(f"📡 Perplexity API 응답 길이: {len(response.text)}")
        print(f"📡 Perplexity API 응답 내용 (처음 500자): {response.text[:500]}")
        print(f"📡 Perplexity API 응답 내용 (마지막 500자): {response.text[-500:]}")
        
        if response.status_code == 200:
            result = response.json()
            
            # content 추출
            content = result['choices'][0].get('message', {}).get('content', '')
            
            # 만약 content가 없다면 에러 처리
            if not content:
                logger.error(f"Perplexity API 응답에 content가 없습니다. 응답 데이터: {json.dumps(result, ensure_ascii=False)}")
                return []
            
            try:
                # JSON 파싱
                news_data = json.loads(content)
                articles = news_data.get('articles', [])
                
                if not articles:
                    logger.error(f"Perplexity API에서 반환된 articles가 비어 있습니다.")
                    return []
                
                # 데이터 정제 (대시보드 호환성 유지)
                processed_articles = []
                for article in articles[:5]:  # 최대 5개만
                    processed_article = {
                        'title': article.get('title', '제목 없음')[:100],  # 제목 길이 제한
                        'summary': article.get('summary', '요약 없음')[:200],  # 요약 길이 제한
                        'published_date': article.get('published_date', datetime.now().strftime('%Y-%m-%d')),
                        'source': article.get('source', '출처 미상')[:50],
                        'url': article.get('url', '')[:200],
                        'content': article.get('content', article.get('summary', '내용 없음'))[:500]  # content 우선, 없으면 summary 사용
                    }
                    processed_articles.append(processed_article)
                
                print(f"✅ 뉴스 검색 성공: {len(processed_articles)}개 기사")
                return processed_articles
                
            except json.JSONDecodeError as e:
                print(f"❌ Perplexity 응답 JSON 파싱 실패: {e}")
                logger.error(f"Perplexity 응답 JSON 파싱 실패: {e}")
                
                # 폴백: MCP 뉴스 클라이언트 사용 시도
                try:
                    if _MCP_SVC is not None:
                        print(f"🔄 MCP 뉴스 클라이언트로 폴백 시도...")
                        import asyncio
                        mcp_result = asyncio.run(_MCP_SVC.get_company_news(
                            query=f"{company_name} 재무 실적 투자",
                            period=period
                        ))
                        
                        if mcp_result.get('ok'):
                            mcp_articles = mcp_result.get('data', {}).get('articles', [])
                            print(f"✅ MCP 뉴스 클라이언트 성공: {len(mcp_articles)}개 기사")
                            
                            # MCP 결과를 메인 서버 형식으로 변환
                            processed_articles = []
                            for i, article in enumerate(mcp_articles[:5]):
                                try:
                                    processed_article = {
                                        'title': str(article.get('title', '제목 없음'))[:100],
                                        'content': str(article.get('content', '내용 없음'))[:500],
                                        'summary': str(article.get('summary', '요약 없음'))[:200],
                                        'published_date': str(article.get('published_date', datetime.now().strftime('%Y-%m-%d'))),
                                        'source': str(article.get('source', '출처 미상'))[:50],
                                        'url': str(article.get('url', ''))[:200]
                                    }
                                    processed_articles.append(processed_article)
                                except Exception as e:
                                    print(f"❌ MCP 기사 {i+1} 변환 실패: {e}")
                                    continue
                            
                            return processed_articles
                        else:
                            print(f"❌ MCP 뉴스 클라이언트 실패: {mcp_result.get('error', 'Unknown error')}")
                except Exception as mcp_error:
                    print(f"❌ MCP 뉴스 클라이언트 폴백 실패: {mcp_error}")
                
                return []  # JSON 파싱 ���패시 빈 리스트 반환
                
    except Exception as e:
        print(f"❌ Perplexity API 호출 오류: {e}")
        logger.error(f"Perplexity API 호출 오류: {e}")
 
    print(f"❌ 뉴스 검색 실패, 빈 리스트 반환")
    return []

def get_corp_name_from_dart(corp_code: str, year_range: str = None) -> str:
    """DART API를 통해 corp_code로 corp_name 조회 - 연도 기반 동적 검색"""
    try:
        # 연도 범위에 따른 검색 기간 설정
        if year_range:
            try:
                start_year, end_year = year_range.split('-')
                bgn_de = f"{start_year}0101"
                end_de = f"{end_year}1231"
                print(f"📅 DART 검색 기간 설정: {year_range}년 ({bgn_de}~{end_de})")
            except Exception as e:
                print(f"⚠️ 연도 파싱 오류: {e}, 기본값 사용")
                bgn_de = '20240101'
                end_de = '20241231'
        else:
            bgn_de = '20240101'  # 기본값: 최근 1년
            end_de = '20241231'
        
        url = 'https://opendart.fss.or.kr/api/list.json'
        params = {
            'crtfc_key': DART_API_KEY,
            'corp_code': corp_code,
            'bgn_de': bgn_de,
            'end_de': end_de,
            'pblntf_ty': 'A',  # 정기공시
            'page_no': 1,
            'page_count': 1  # 1건만 조회해서 기업명 확인
        }
        
        response = requests.get(url, params=params, timeout=30)
        data = response.json()
        
        if data['status'] == '000' and data['list']:
            corp_name = data['list'][0]['corp_name']
            logger.info(f"DART에서 조회된 기업명: {corp_name} (코드: {corp_code})")
            return corp_name
        else:
            # 공시가 없으면 기업코드 XML에서 조회 (기존 방식)
            logger.warning(f"DART 공시 목록에서 {corp_code} 기업명 조회 실패, XML 방식으로 대체")
            return get_corp_name_from_xml(corp_code)
            
    except Exception as e:
        logger.error(f"DART API 기업명 조회 오류: {e}")
        # 실패 시 기존 XML 방식으로 대체
        return get_corp_name_from_xml(corp_code)

def get_corp_name_from_xml(corp_code: str) -> str:
    """기존 XML 방식으로 기업명 조회 (백업용)"""
    try:
        zip_url = f'https://opendart.fss.or.kr/api/corpCode.xml?crtfc_key={DART_API_KEY}'
        response = requests.get(zip_url, timeout=30)
        
        with zipfile.ZipFile(io.BytesIO(response.content)) as zf:
            corp_bytes = zf.read('CORPCODE.xml')
            try:
                xml_str = corp_bytes.decode('euc-kr')
            except UnicodeDecodeError:
                xml_str = corp_bytes.decode('utf-8')
        
        root = ET.fromstring(xml_str)
        
        for item in root.findall('.//list'):
            code = item.find('corp_code').text
            if code == corp_code:
                corp_name = item.find('corp_name').text
                return corp_name
                
        return f"기업_{corp_code}"  # 최후의 대체값
        
    except Exception as e:
        logger.error(f"XML에서 기업명 조회 오류: {e}")
        return f"기업_{corp_code}"

def _mcp_pick_value(rows: List[Dict], patterns: List[str]) -> float:
    for p in patterns:
        for r in rows:
            if p in r.get("계정", ""):
                v = r.get("당기")
                try:
                    return float(str(v).replace(",", "").replace("(", "-").replace(")", ""))
                except Exception:
                    pass
    return 0.0


def _mcp_extract_summary_from_statements(corp_code: str, year: str, year_range: str = None) -> Dict:
    if _MCP_SVC is None:
        # 폴백: 기존 방식 사용
        print(f"⚠️ MCP 서비스 미사용, 기존 방식으로 재무 데이터 조회")
        return get_financial_data(corp_code, year)
    
    try:
        print(f"🔍 MCP 재무제표 조회: {corp_code} ({year}년, 범위: {year_range})")
        is_res = _MCP_SVC.get_financial_statements(
            corp_code=corp_code, bsns_year=year, reprt_code="11014", fs_div="CFS", statement_type="손익계산서"
        )
        bs_res = _MCP_SVC.get_financial_statements(
            corp_code=corp_code, bsns_year=year, reprt_code="11014", fs_div="CFS", statement_type="재무상태표"
        )
        
        is_rows = is_res.get("data", []) if is_res.get("ok") else []
        bs_rows = bs_res.get("data", []) if bs_res.get("ok") else []
        
        if not is_rows and not bs_rows:
            print(f"❌ MCP 재무제표 조회 실패, 기존 방식으로 폴백")
            return get_financial_data(corp_code, year)
        
        result = {
            'revenue': _mcp_pick_value(is_rows, ['매출','매출액','영업수익','수익(매출액)']),
            'operating_profit': _mcp_pick_value(is_rows, ['영업이익','영업손익','영업이익(손실)']),
            'net_profit': _mcp_pick_value(is_rows, ['당기순이익','당기순이익(손실)','순이익']),
            'total_assets': _mcp_pick_value(bs_rows, ['자산총계','총자산','자산합계']),
            'total_debt': _mcp_pick_value(bs_rows, ['부채총계','총부채','부채합계']),
            'total_equity': _mcp_pick_value(bs_rows, ['자본총계','총자본','자본합계','자본']),
        }
        
        print(f"✅ MCP 재무제표 조회 성공: 매출 {result['revenue']:,.0f}백만원")
        return result
        
    except Exception as e:
        print(f"❌ MCP 재무제표 조회 오류: {e}, 기존 방식으로 폴백")
        return get_financial_data(corp_code, year)


def generate_dashboard_data(corp_code: str, bgn_de: str, end_de: str, user_info: Dict) -> Dict:
    """대시보드 데이터 생성 로직 - MCP 코어 사용(가능 시) + 기존 뉴스 파이프라인 유지"""
    # 연도 범위를 DART API 검색에 전달
    year_range = f"{bgn_de}-{end_de}"
    corp_name = get_corp_name_from_dart(corp_code, year_range)

    # 프론트에서 받은 연도 범위 그대로 사용
    years = list(range(int(bgn_de), int(end_de) + 1))
    print(f"📊 요청된 연도 범위: {bgn_de}-{end_de} ({len(years)}년)")

    # MCP의 시계열 분석 사용 시도
    years_sorted: List[str] = []
    revenue_trend: List[float] = []
    operating_profit_trend: List[float] = []
    net_profit_trend: List[float] = []

    if _MCP_SVC is not None:
        try:
            # MCP 시계열 분석은 고정된 로직이므로, 요청된 연도 범위로 직접 데이터 조회
            print(f"🔍 요청된 연도 범위로 직접 데이터 조회: {corp_code} ({year_range})")
            
            # 요청된 연도 범위로 직접 재무 데이터 조회
            years_sorted = []
            revenue_trend = []
            operating_profit_trend = []
            net_profit_trend = []
            
            for year in years:
                try:
                    print(f"  📊 {year}년 재무 데이터 조회 중...")
                    financial_data = _mcp_extract_summary_from_statements(corp_code, str(year), year_range)
                    
                    years_sorted.append(str(year))
                    revenue_trend.append(financial_data.get('revenue', 0.0))
                    operating_profit_trend.append(financial_data.get('operating_profit', 0.0))
                    net_profit_trend.append(financial_data.get('net_profit', 0.0))
                    
                except Exception as e:
                    print(f"  ❌ {year}년 데이터 조회 실패: {e}")
                    # 실패한 연도는 0으로 채움
                    years_sorted.append(str(year))
                    revenue_trend.append(0.0)
                    operating_profit_trend.append(0.0)
                    net_profit_trend.append(0.0)
            
            if years_sorted:
                print(f"✅ 연도별 재무 데이터 조회 성공: {len(years_sorted)}년 데이터")
            else:
                print(f"⚠️ 연도별 재무 데이터 조회 실패, 기본 연도 사용")
                years_sorted = [str(y) for y in sorted(years)]
                
        except Exception as e:
            print(f"❌ 연도별 재무 데이터 조회 실패: {e}")
            years_sorted = [str(y) for y in sorted(years)]
    else:
        print(f"⚠️ MCP 서비스 미사용, 기본 연도 사용")
        years_sorted = [str(y) for y in sorted(years)]

    # 최신년도 요약
    latest_year = years_sorted[-1] if years_sorted else end_de
    latest_financial = _mcp_extract_summary_from_statements(corp_code, str(latest_year), year_range)



    # 뉴스 데이터 (실시간 최신 뉴스 고정)
    news_articles = search_news_perplexity(corp_name, "3days")

    return {
        'company_info': {
            'corp_code': corp_code,
            'corp_name': corp_name,
            'analysis_period': f"{bgn_de}-{end_de}",
            'latest_year': latest_year
        },
        'financial_summary': {
            'revenue': latest_financial.get('revenue', 0),
            'operating_profit': latest_financial.get('operating_profit', 0),
            'net_profit': latest_financial.get('net_profit', 0),
            'total_assets': latest_financial.get('total_assets', 0),
            'total_debt': latest_financial.get('total_debt', 0),
            'total_equity': latest_financial.get('total_equity', 0)
        },

        'yearly_trends': {
            'years': years_sorted,
            'revenue': revenue_trend or [0.0]*len(years_sorted),
            'operating_profit': operating_profit_trend or [0.0]*len(years_sorted),
            'net_profit': net_profit_trend or [0.0]*len(years_sorted)
        },
        'news_data': {
            'total_articles': len(news_articles),
            'last_updated': datetime.now().strftime('%Y-%m-%d %H:%M'),
            'has_news': len(news_articles) > 0,
            'status': 'success' if len(news_articles) > 0 else 'no_news_found',
            'articles': [
                {
                    'id': idx + 1,
                    'title': article['title'],
                    'summary': article['summary'],
                    'full_content': article['content'],
                    'published_date': article['published_date'],
                    'source': article['source'],
                    'url': article.get('url', ''),
                    'relevance': 'high'
                }
                for idx, article in enumerate(news_articles[:5])
            ] if len(news_articles) > 0 else [],
            'summary_stats': {
                'positive_news': len([a for a in news_articles if any(word in a.get('content', '').lower() for word in ['증가', '상승', '호조', '개선', '성장'])]) if news_articles else 0,
                'neutral_news': len([a for a in news_articles if not any(word in a.get('content', '').lower() for word in ['증가', '상승', '호조', '개선', '성장', '감소', '하락', '부진', '악화'])]) if news_articles else 0,
                'negative_news': len([a for a in news_articles if any(word in a.get('content', '').lower() for word in ['감소', '하락', '부진', '악화'])]) if news_articles else 0
            } if len(news_articles) > 0 else {'positive_news': 0, 'neutral_news': 0, 'negative_news': 0},
            'message': '최신 뉴스를 성공적으로 가져왔습니다.' if len(news_articles) > 0 else (
                f'{corp_name}에 대한 최근 뉴스를 찾을 수 없습니다. ' + 
                ('Perplexity API 키가 설정되지 않았습니다.' if not PERPLEXITY_API_KEY else 'Perplexity API 상태를 확인해주세요.')
            )
        },
        'user_context': user_info,
        'generated_at': datetime.now().isoformat()
    }


@app.route('/api/news/<company_name>', methods=['GET'])
def get_company_news(company_name):
    """특정 기업의 뉴스 조회 - 개선된 버전"""
    try:
        period = request.args.get('period', '3days')
        limit = min(int(request.args.get('limit', 5)), 5)
        news_articles = search_news_perplexity(company_name, period)
        
        return jsonify({
            'status': 'success',
            'data': {
                'company_name': company_name,
                'period': period,
                'total_count': len(news_articles),
                'last_updated': datetime.now().strftime('%Y-%m-%d %H:%M'),
                'articles': [
                    {
                        'id': idx + 1,
                        'title': article['title'],
                        'summary': article['summary'],
                        'full_content': article['content'],
                        'published_date': article['published_date'],
                        'source': article['source'],
                        'url': article.get('url', ''),
                        'word_count': len(article['content'].split())
                    }
                    for idx, article in enumerate(news_articles[:limit])
                ],
                'sentiment_analysis': {
                    'positive': len([a for a in news_articles if any(word in a.get('content', '').lower() for word in ['증가', '상승', '호조', '개선', '성장'])]),
                    'neutral': len([a for a in news_articles if not any(word in a.get('content', '').lower() for word in ['증가', '상승', '호조', '개선', '성장', '감소', '하락', '부진', '악화'])]),
                    'negative': len([a for a in news_articles if any(word in a.get('content', '').lower() for word in ['감소', '하락', '부진', '악화'])])
                }
            }
        })
        
    except Exception as e:
        logger.error(f"뉴스 조회 오류: {e}")
        return jsonify({'error': str(e)}), 500

def save_chat_to_db(user_sno: str, message: str, response: str, chat_type: str = 'general') -> bool:
    """채팅 기록을 DB API 서버에 저장"""
    # 로컬 테스트용으로 DB 저장 비활성화
    if DB_API_BASE_URL is None:
        logger.info(f"로컬 테스트 모드: DB 저장 건너뜀 (user_sno: {user_sno}, chat_type: {chat_type})")
        return True  # 성공으로 처리
    
    try:
        # user_sno가 숫자인지 확인하고 변환
        try:
            user_sno_int = int(user_sno)
        except ValueError:
            # 숫자가 아니면 기본값 사용
            user_sno_int = 1
            logger.warning(f"user_sno '{user_sno}'를 숫자로 변환할 수 없어 기본값 1 사용")
        
        # 사용자 메시지 저장
        user_msg_response = requests.post(f'{DB_API_BASE_URL}/api/chat', 
            json={
                'user_sno': user_sno_int,
                'content': message,
                'role': 'user'
            },
            timeout=10
        )
        
        # AI 응답 저장
        ai_msg_response = requests.post(f'{DB_API_BASE_URL}/api/chat',
            json={
                'user_sno': user_sno_int,
                'content': response,
                'role': 'assistant'
            },
            timeout=10
        )
        
        return user_msg_response.ok and ai_msg_response.ok
        
    except Exception as e:
        logger.error(f"DB 저장 오류: {e}")
        return False

def validate_user_exists(user_sno: str) -> bool:
    """사용자 존재 여부 확인"""
    # 로컬 테스트용으로 사용자 검증 비활성화
    if DB_API_BASE_URL is None:
        logger.info(f"로컬 테스트 모드: 사용자 검증 건너뜀 (user_sno: {user_sno})")
        return True  # 항상 존재하는 것으로 처리
    
    try:
        # user_sno가 숫자인지 확인
        try:
            user_sno_int = int(user_sno)
        except ValueError:
            logger.warning(f"user_sno '{user_sno}'가 숫자가 아님, 사용자 검증 건너뜀")
            return True  # 테스트용으로 True 반환
        
        response = requests.get(f'{DB_API_BASE_URL}/api/users/{user_sno_int}', timeout=10)
        return response.ok
    except Exception as e:
        logger.error(f"사용자 확인 오류: {e}")
        return True  # 오류 시에도 진행하도록 True 반환

def call_llm_for_company_chat(message: str, user_info: Dict, company_data: Dict) -> str:
    """기업 분석 채팅용 LLM 호출 - MCP 동적 데이터 조회 포함"""
    if not GPT_API_KEY:
        return f"LLM API 키가 설정되지 않았습니다. '{message}' 질문에 답변하려면 GPT API 연동이 필요합니다."
    
    try:
        url = "https://api.openai.com/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {GPT_API_KEY}",
            "Content-Type": "application/json"
        }
        
        company_info = company_data.get('company_info', {})
        financial_summary = company_data.get('financial_summary', {})
        yearly_trends = company_data.get('yearly_trends', {})
        news_data = company_data.get('news_data', {})

        # MCP 재무비율 호출 (가능 시)
        ratios = {}
        try:
            if _MCP_SVC is not None:
                print(f"🔍 MCP 재무비율 조회: {company_info.get('corp_code', '')} ({company_info.get('latest_year', '')}년)")
                ratios_res = _MCP_SVC.get_financial_ratios(
                    corp_code=company_info.get('corp_code', ''),
                    bsns_year=str(company_info.get('latest_year', '')) or str(datetime.now().year - 1)
                )
                if ratios_res.get('ok'):
                    ratios = ratios_res.get('data', {})
                    print(f"✅ MCP 재무비율 조회 성공: {ratios}")
                else:
                    print(f"❌ MCP 재무비율 조회 실패: {ratios_res.get('error', 'Unknown error')}")
        except Exception as e:
            print(f"❌ MCP 재무비율 조회 오류: {e}")
            ratios = {}

        # 동적 MCP 데이터 조회 - 사용자 요청에 따른 실시간 데이터 수집
        additional_data = {}
        mcp_queries = []
        
        # 사용자 메시지에서 연도 추출 (개선된 로직)
        import re
        
        # 다양한 연도 표현 패턴 지원
        year_patterns = [
            r'(\d{4})년',           # 2024년
            r'(\d{4})년도',         # 2024년도
            r'(\d{4})',             # 2024
            r'(\d{4})년\s*(\d{4})년',  # 2022년 2024년 (범위)
        ]
        
        requested_year = str(company_info.get('latest_year', '') or datetime.now().year - 1)
        year_range = None
        
        for pattern in year_patterns:
            match = re.search(pattern, message)
            if match:
                if len(match.groups()) == 1:
                    requested_year = match.group(1)
                    print(f"🔍 사용자 요청 연도 추출: {requested_year}년")
                    break
                elif len(match.groups()) == 2:
                    year_range = f"{match.group(1)}-{match.group(2)}"
                    requested_year = match.group(2)  # 최신 연도 사용
                    print(f"🔍 사용자 요청 연도 범위 추출: {year_range}년")
                    break
        
        if not year_range:
            year_range = f"{requested_year}-{requested_year}"
        
        # 1. 재무제표 요청 감지 (확장된 키워드)
        statement_keywords = {
            '현금흐름표': ['현금흐름표', '현금흐름', 'cash flow', 'cf', '현금'],
            '손익계산서': ['손익계산서', '손익', 'income statement', 'p&l', '손익계산'],
            '재무상태표': ['재무상태표', '재무상태', 'balance sheet', 'bs', '대차대조표'],
            '자본변동표': ['자본변동표', '자본변동', '자본변화', 'equity', '자본'],
        }
        
        for statement_type, keywords in statement_keywords.items():
            if any(keyword in message.lower() for keyword in keywords):
                mcp_queries.append((statement_type, 'get_financial_statements', {
                    'corp_code': company_info.get('corp_code', ''),
                    'bsns_year': requested_year,
                    'reprt_code': '11014',
                    'fs_div': 'CFS',
                    'statement_type': statement_type
                }))
                print(f"🔍 {statement_type} 요청 감지: {requested_year}년")
        
        # 3. 공시 정보 요청 감지 (확장된 키워드)
        if any(keyword in message.lower() for keyword in ['공시', '공시정보', '공시내용', 'disclosure', '공시목록', '공시자료', '공시서류']):
            mcp_queries.append(('공시목록', 'get_disclosure_list', {
                'corp_code': company_info.get('corp_code', ''),
                'bgn_de': f"{requested_year}0101",
                'end_de': f"{requested_year}1231",
                'page_count': 10
            }))
            print(f"🔍 공시정보 요청 감지: {requested_year}년")
        
        # 4. 시계열 분석 요청 감지 (확장된 키워드)
        if any(keyword in message.lower() for keyword in ['트렌드', '추이', '변화', '성장', 'trend', '추세', '흐름', '연도별', '기간별', '성장률', '증감']):
            # 분석 기간을 요청된 연도 범위로 설정
            analysis_period = 2  # 기본값
            try:
                if year_range and '-' in year_range:
                    start_year, end_year = year_range.split('-')
                    analysis_period = int(end_year) - int(start_year) + 1
                else:
                    period_range = company_info.get('analysis_period', '')
                    if '-' in period_range:
                        start_year, end_year = period_range.split('-')
                        analysis_period = int(end_year) - int(start_year) + 1
            except:
                analysis_period = 2
            
            mcp_queries.append(('시계열분석', 'analyze_time_series', {
                'corp_code': company_info.get('corp_code', ''),
                'analysis_period': analysis_period
            }))
            print(f"🔍 시계열분석 요청 감지: {analysis_period}년")
        
        # 5. 기업 정보 요청 감지 (확장된 키워드)
        if any(keyword in message.lower() for keyword in ['기업정보', '회사정보', '기업개요', 'company info', '기업소개', '회사소개', '기업현황']):
            mcp_queries.append(('기업정보', 'get_company_info', {
                'corp_code': company_info.get('corp_code', '')
            }))
            print(f"🔍 기업정보 요청 감지")
        
        # 6. 재무비율 상세 분석 요청 감지 (확장된 키워드)
        if any(keyword in message.lower() for keyword in ['재무비율', '비율분석', 'ROE', 'ROA', '부채비율', 'financial ratio', '수익성', '안정성', '성장성', '비율']):
            # 재무비율은 이미 조회되어 있으므로 추가 조회 불필요
            print(f"🔍 재무비율 분석 요청 감지 (이미 조회됨)")
        
        # 7. 경쟁사 비교 요청 감지 (확장된 키워드)
        if any(keyword in message.lower() for keyword in ['경쟁사', '비교', 'peer', 'competitor', '동종업계', '업계비교', '경쟁업체']):
            # 경쟁사 비교는 별도 구현 필요
            print(f"🔍 경쟁사 비교 요청 감지 (미구현 기능)")
        
        # 8. 재무제표 전체 요청 감지
        if any(keyword in message.lower() for keyword in ['재무제표', '재무서류', 'financial statements', '재무보고서']):
            # 모든 재무제표 타입 조회
            for statement_type in ['손익계산서', '재무상태표', '현금흐름표', '자본변동표']:
                mcp_queries.append((f"{statement_type}_전체", 'get_financial_statements', {
                    'corp_code': company_info.get('corp_code', ''),
                    'bsns_year': requested_year,
                    'reprt_code': '11014',
                    'fs_div': 'CFS',
                    'statement_type': statement_type
                }))
            print(f"🔍 재무제표 전체 요청 감지: {requested_year}년")
        
        # 9. 기업 뉴스 요청 감지
        if any(keyword in message.lower() for keyword in ['뉴스', '기업뉴스', '최신뉴스', 'news', '기사', '언론보도']):
            mcp_queries.append(('기업뉴스', 'get_company_news', {
                'query': f"{company_info.get('corp_name', '')} 재무 실적 투자",
                'period': 'week'
            }))
            print(f"🔍 기업뉴스 요청 감지")
        
        # 10. 뉴스 감성분석 요청 감지
        if any(keyword in message.lower() for keyword in ['감성분석', '뉴스분석', '여론분석', 'sentiment', '긍정', '부정']):
            mcp_queries.append(('뉴스감성분석', 'analyze_news_sentiment', {
                'query': f"{company_info.get('corp_name', '')} 재무 실적 투자",
                'period': 'week'
            }))
            print(f"🔍 뉴스감성분석 요청 감지")
        
        # 11. 경쟁사 비교 요청 감지 (구현)
        if any(keyword in message.lower() for keyword in ['경쟁사', '비교', 'peer', 'competitor', '동종업계', '업계비교', '경쟁업체']):
            # 기본 경쟁사 코드 (실제로는 사용자가 지정하거나 업계별로 설정)
            peer_codes = ['005930', '000660', '006400']  # 삼성전자, SK하이닉스, 삼성SDI
            mcp_queries.append(('경쟁사비교', 'analyze_competitive_position', {
                'corp_code': company_info.get('corp_code', ''),
                'peer_corp_codes': peer_codes
            }))
            print(f"🔍 경쟁사비교 요청 감지")
        
        # 12. 업계 리포트 요청 감지
        if any(keyword in message.lower() for keyword in ['업계', '산업', 'industry', '섹터', 'sector']):
            mcp_queries.append(('업계리포트', 'generate_industry_report', {
                'industry': '반도체'  # 기본값, 실제로는 기업 정보에서 추출
            }))
            print(f"🔍 업계리포트 요청 감지")
        
        # 13. 포트폴리오 최적화 요청 감지
        if any(keyword in message.lower() for keyword in ['포트폴리오', '포트폴리오', 'portfolio', '자산배분', '투자비중']):
            # 기본 포트폴리오 (실제로는 사용자가 지정)
            tickers = ['005930', '000660', '006400']  # 삼성전자, SK하이닉스, 삼성SDI
            mcp_queries.append(('포트폴리오최적화', 'optimize_portfolio', {
                'tickers': tickers,
                'budget': 10000000,  # 1천만원
                'risk': '보통'
            }))
            print(f"🔍 포트폴리오최적화 요청 감지")
        
        # 14. 재무비율 상세 분석 요청 감지 (실제 MCP 호출)
        if any(keyword in message.lower() for keyword in ['재무비율', '비율분석', 'ROE', 'ROA', '부채비율', 'financial ratio', '수익성', '안정성', '성장성', '비율']):
            mcp_queries.append(('재무비율상세', 'get_financial_ratios', {
                'corp_code': company_info.get('corp_code', ''),
                'bsns_year': requested_year,
                'reprt_code': '11014',
                'fs_div': 'CFS'
            }))
            print(f"🔍 재무비율상세 분석 요청 감지: {requested_year}년")
        
        # MCP 쿼리 실행 (개선된 에러 처리)
        for query_name, query_type, params in mcp_queries:
            try:
                if _MCP_SVC is not None:
                    print(f"🔍 MCP {query_name} 조회: {params}")
                    
                    if query_type == 'get_financial_statements':
                        result = _MCP_SVC.get_financial_statements(**params)
                    elif query_type == 'get_disclosure_list':
                        result = _MCP_SVC.get_disclosure_list(**params)
                    elif query_type == 'analyze_time_series':
                        result = _MCP_SVC.analyze_time_series(**params)
                    elif query_type == 'get_company_info':
                        result = _MCP_SVC.get_company_info(**params)
                    elif query_type == 'get_financial_ratios':
                        result = _MCP_SVC.get_financial_ratios(**params)
                    elif query_type == 'get_company_news':
                        # 비동기 함수이므로 동기적으로 처리
                        import asyncio
                        try:
                            result = asyncio.run(_MCP_SVC.get_company_news(**params))
                        except Exception as e:
                            result = {"ok": False, "error": f"뉴스 조회 실패: {str(e)}"}
                    elif query_type == 'analyze_news_sentiment':
                        # 비동기 함수이므로 동기적으로 처리
                        import asyncio
                        try:
                            result = asyncio.run(_MCP_SVC.analyze_news_sentiment(**params))
                        except Exception as e:
                            result = {"ok": False, "error": f"감성분석 실패: {str(e)}"}
                    elif query_type == 'analyze_competitive_position':
                        result = _MCP_SVC.analyze_competitive_position(**params)
                    elif query_type == 'generate_industry_report':
                        result = _MCP_SVC.generate_industry_report(**params)
                    elif query_type == 'optimize_portfolio':
                        result = _MCP_SVC.optimize_portfolio(**params)
                    else:
                        print(f"⚠️ 지원하지 않는 MCP 쿼리 타입: {query_type}")
                        continue
                    
                    if result.get('ok'):
                        additional_data[query_name] = result.get('data', {})
                        print(f"✅ MCP {query_name} 조회 성공")
                    else:
                        error_msg = result.get('error', 'Unknown error')
                        additional_data[f"{query_name}_error"] = error_msg
                        print(f"❌ MCP {query_name} 조회 실패: {error_msg}")
                        
                        # 구체적인 오류 정보 제공
                        if 'no_data' in error_msg:
                            additional_data[f"{query_name}_note"] = f"{requested_year}년 데이터가 없습니다."
                        elif 'section_missing' in error_msg:
                            additional_data[f"{query_name}_note"] = f"{params.get('statement_type', '')} 섹션이 없습니다."
                        
            except Exception as e:
                error_msg = str(e)
                additional_data[f"{query_name}_error"] = error_msg
                print(f"❌ MCP {query_name} 조회 오류: {error_msg}")
                
                # 네트워크 오류 등 구체적인 안내
                if 'timeout' in error_msg.lower():
                    additional_data[f"{query_name}_note"] = "네트워크 시간 초과로 데이터를 가져올 수 없습니다."
                elif 'connection' in error_msg.lower():
                    additional_data[f"{query_name}_note"] = "네트워크 연결 오류로 데이터를 가져올 수 없습니다."
        
        # 재무제표 데이터 처리 (확장된 로직)
        financial_statements_data = {}
        
        # 현금흐름표 데이터 처리
        if '현금흐름표' in additional_data:
            cf_rows = additional_data['현금흐름표']
            cf_summary = {}
            for row in cf_rows:
                account = row.get('계정', '')
                amount = row.get('당기', 0)
                
                if '영업활동' in account and '현금흐름' in account:
                    cf_summary['영업활동현금흐름'] = amount
                elif '투자활동' in account and '현금흐름' in account:
                    cf_summary['투자활동현금흐름'] = amount
                elif '재무활동' in account and '현금흐름' in account:
                    cf_summary['재무활동현금흐름'] = amount
                elif '현금' in account and '증감' in account:
                    cf_summary['현금및현금성자산증감'] = amount
            
            financial_statements_data['현금흐름표'] = cf_summary
        
        # 손익계산서 데이터 처리
        if '손익계산서' in additional_data:
            is_rows = additional_data['손익계산서']
            is_summary = {}
            for row in is_rows:
                account = row.get('계정', '')
                amount = row.get('당기', 0)
                
                if '매출' in account:
                    is_summary['매출액'] = amount
                elif '영업이익' in account:
                    is_summary['영업이익'] = amount
                elif '당기순이익' in account:
                    is_summary['당기순이익'] = amount
            
            financial_statements_data['손익계산서'] = is_summary
        
        # 재무상태표 데이터 처리
        if '재무상태표' in additional_data:
            bs_rows = additional_data['재무상태표']
            bs_summary = {}
            for row in bs_rows:
                account = row.get('계정', '')
                amount = row.get('당기', 0)
                
                if '자산총계' in account:
                    bs_summary['총자산'] = amount
                elif '부채총계' in account:
                    bs_summary['총부채'] = amount
                elif '자본총계' in account:
                    bs_summary['총자본'] = amount
            
            financial_statements_data['재무상태표'] = bs_summary
        
        # 기존 호환성을 위한 cash_flow_data
        cash_flow_data = financial_statements_data.get('현금흐름표', {})
        
        # 동적 데이터 섹션 생성 (확장된 로직)
        additional_sections = []
        
        # 재무제표 섹션들
        for statement_type, data in financial_statements_data.items():
            if statement_type == '현금흐름표' and data:
                # 현금흐름표 데이터 포맷팅을 미리 처리 (안전한 방식)
                try:
                    cf_operating = f"{float(data.get('영업활동현금흐름', 0)):,}"
                except (ValueError, TypeError):
                    cf_operating = "0"
                
                try:
                    cf_investing = f"{float(data.get('투자활동현금흐름', 0)):,}"
                except (ValueError, TypeError):
                    cf_investing = "0"
                
                try:
                    cf_financing = f"{float(data.get('재무활동현금흐름', 0)):,}"
                except (ValueError, TypeError):
                    cf_financing = "0"
                
                try:
                    cf_change = f"{float(data.get('현금및현금성자산증감', 0)):,}"
                except (ValueError, TypeError):
                    cf_change = "0"
                
                additional_sections.append(f"""
현금흐름표 데이터 ({requested_year}년):
- 영업활동현금흐름: {cf_operating}백만원
- 투자활동현금흐름: {cf_investing}백만원
- 재무활동현금흐름: {cf_financing}백만원
- 현금및현금성자산증감: {cf_change}백만원""")
            
            elif statement_type == '손익계산서' and data:
                try:
                    revenue = f"{float(data.get('매출액', 0)):,}"
                except (ValueError, TypeError):
                    revenue = "0"
                
                try:
                    operating_profit = f"{float(data.get('영업이익', 0)):,}"
                except (ValueError, TypeError):
                    operating_profit = "0"
                
                try:
                    net_profit = f"{float(data.get('당기순이익', 0)):,}"
                except (ValueError, TypeError):
                    net_profit = "0"
                
                additional_sections.append(f"""
손익계산서 데이터 ({requested_year}년):
- 매출액: {revenue}백만원
- 영업이익: {operating_profit}백만원
- 당기순이익: {net_profit}백만원""")
            
            elif statement_type == '재무상태표' and data:
                try:
                    total_assets = f"{float(data.get('총자산', 0)):,}"
                except (ValueError, TypeError):
                    total_assets = "0"
                
                try:
                    total_debt = f"{float(data.get('총부채', 0)):,}"
                except (ValueError, TypeError):
                    total_debt = "0"
                
                try:
                    total_equity = f"{float(data.get('총자본', 0)):,}"
                except (ValueError, TypeError):
                    total_equity = "0"
                
                additional_sections.append(f"""
재무상태표 데이터 ({requested_year}년):
- 총자산: {total_assets}백만원
- 총부채: {total_debt}백만원
- 총자본: {total_equity}백만원""")
        
        # 자본변동표 섹션
        if '자본변동표' in additional_data:
            equity_data = additional_data['자본변동표']
            if equity_data:
                # 자본변동표 데이터 포맷팅을 미리 처리 (안전한 방식)
                equity_lines = []
                for row in equity_data[:5]:
                    account = row.get('계정', '')
                    try:
                        amount = f"{float(row.get('당기', 0)):,}"
                    except (ValueError, TypeError):
                        amount = "0"
                    equity_lines.append(f"- {account}: {amount}백만원")
                
                additional_sections.append(f"""
자본변동표 데이터 ({requested_year}년):
{chr(10).join(equity_lines)}""")
        
        # 공시 정보 섹션
        if '공시목록' in additional_data:
            disclosure_data = additional_data['공시목록']
            if disclosure_data:
                additional_sections.append(f"""
최근 공시 정보 ({len(disclosure_data)}건):
{chr(10).join([f"- {item.get('rcept_dt', '')}: {item.get('report_nm', '')}" for item in disclosure_data[:3]])}""")
        
        # 시계열 분석 섹션
        if '시계열분석' in additional_data:
            ts_data = additional_data['시계열분석']
            if ts_data:
                years = ts_data.get('years', [])
                series = ts_data.get('series', [])
                
                # 시계열 데이터 포맷팅을 미리 처리 (안전한 방식)
                revenue_trend = []
                operating_profit_trend = []
                net_profit_trend = []
                
                for row in series:
                    try:
                        revenue_trend.append(f"{float(row.get('매출액', 0)):,}")
                    except (ValueError, TypeError):
                        revenue_trend.append("0")
                    
                    try:
                        operating_profit_trend.append(f"{float(row.get('영업이익', 0)):,}")
                    except (ValueError, TypeError):
                        operating_profit_trend.append("0")
                    
                    try:
                        net_profit_trend.append(f"{float(row.get('순이익', 0)):,}")
                    except (ValueError, TypeError):
                        net_profit_trend.append("0")
                
                additional_sections.append(f"""
시계열 분석 ({len(years)}년):
- 분석 연도: {years}
- 매출액 추이: {revenue_trend}
- 영업이익 추이: {operating_profit_trend}
- 순이익 추이: {net_profit_trend}""")
        
        # 기업 정보 섹션
        if '기업정보' in additional_data:
            company_info_data = additional_data['기업정보']
            if company_info_data:
                additional_sections.append(f"""
기업 기본 정보:
- 기업명: {company_info_data.get('corp_name', '')}
- 종목코드: {company_info_data.get('stock_code', '')}
- 업종: {company_info_data.get('sector', '')}
- 설립일: {company_info_data.get('establish_date', '')}""")
        
        # 기업 뉴스 섹션
        if '기업뉴스' in additional_data:
            news_data = additional_data['기업뉴스']
            if news_data and news_data.get('articles'):
                articles = news_data.get('articles', [])
                news_lines = []
                for i, article in enumerate(articles[:3]):  # 최대 3개
                    title = article.get('title', '제목 없음')
                    summary = article.get('summary', '요약 없음')
                    news_lines.append(f"- {title}: {summary}")
                
                additional_sections.append(f"""
최신 기업 뉴스 ({len(articles)}건):
{chr(10).join(news_lines)}""")
        
        # 뉴스 감성분석 섹션
        if '뉴스감성분석' in additional_data:
            sentiment_data = additional_data['뉴스감성분석']
            if sentiment_data:
                total = sentiment_data.get('total', 0)
                positive = sentiment_data.get('positive', 0)
                negative = sentiment_data.get('negative', 0)
                sentiment = sentiment_data.get('sentiment', 'neutral')
                
                sentiment_kr = {'positive': '긍정', 'negative': '부정', 'neutral': '중립'}
                
                additional_sections.append(f"""
뉴스 감성분석:
- 총 뉴스: {total}건
- 긍정: {positive}건
- 부정: {negative}건
- 전체 감성: {sentiment_kr.get(sentiment, sentiment)}""")
        
        # 재무비율 상세 섹션
        if '재무비율상세' in additional_data:
            ratios_data = additional_data['재무비율상세']
            if ratios_data:
                ratio_lines = []
                for ratio_name, ratio_value in ratios_data.items():
                    ratio_lines.append(f"- {ratio_name}: {ratio_value}%")
                
                additional_sections.append(f"""
재무비율 상세 분석 ({requested_year}년):
{chr(10).join(ratio_lines)}""")
        
        # 경쟁사 비교 섹션
        if '경쟁사비교' in additional_data:
            competitive_data = additional_data['경쟁사비교']
            if competitive_data:
                corp_code = competitive_data.get('corp_code', '')
                peers = competitive_data.get('peers', [])
                summary = competitive_data.get('summary', '기본 비교')
                
                additional_sections.append(f"""
경쟁사 비교 분석:
- 대상 기업: {corp_code}
- 비교 대상: {len(peers)}개 기업
- 분석 요약: {summary}""")
        
        # 업계 리포트 섹션
        if '업계리포트' in additional_data:
            industry_data = additional_data['업계리포트']
            if industry_data:
                industry = industry_data.get('industry', '')
                highlights = industry_data.get('highlights', [])
                
                additional_sections.append(f"""
업계 리포트:
- 업계: {industry}
- 주요 특징: {', '.join(highlights)}""")
        
        # 포트폴리오 최적화 섹션
        if '포트폴리오최적화' in additional_data:
            portfolio_data = additional_data['포트폴리오최적화']
            if portfolio_data:
                weights = portfolio_data.get('weights', {})
                allocations = portfolio_data.get('allocations', {})
                risk = portfolio_data.get('risk', '보통')
                
                weight_lines = []
                for ticker, weight in weights.items():
                    allocation = allocations.get(ticker, 0)
                    weight_lines.append(f"- {ticker}: {weight*100:.1f}% ({allocation:,}원)")
                
                additional_sections.append(f"""
포트폴리오 최적화:
- 위험도: {risk}
- 자산 배분:
{chr(10).join(weight_lines)}""")
        
        # MCP 조회 실패 정보 (개선된 처리)
        mcp_errors = []
        mcp_notes = []
        
        for key, value in additional_data.items():
            if key.endswith('_error'):
                mcp_errors.append(f"- {key.replace('_error', '')}: {value}")
            elif key.endswith('_note'):
                mcp_notes.append(f"- {key.replace('_note', '')}: {value}")
        
        if mcp_errors:
            additional_sections.append(f"""
MCP 조회 실패 정보:
{chr(10).join(mcp_errors)}""")
        
        if mcp_notes:
            additional_sections.append(f"""
MCP 조회 참고사항:
{chr(10).join(mcp_notes)}""")
        
        additional_data_section = chr(10).join(additional_sections)

        # 숫자 포맷팅을 미리 처리하여 문자열 포맷팅 충돌 방지 (안전한 방식)
        try:
            revenue_formatted = f"{float(financial_summary.get('revenue', 0)):,}"
        except (ValueError, TypeError):
            revenue_formatted = "0"
        
        try:
            operating_profit_formatted = f"{float(financial_summary.get('operating_profit', 0)):,}"
        except (ValueError, TypeError):
            operating_profit_formatted = "0"
        
        try:
            net_profit_formatted = f"{float(financial_summary.get('net_profit', 0)):,}"
        except (ValueError, TypeError):
            net_profit_formatted = "0"
        
        try:
            total_assets_formatted = f"{float(financial_summary.get('total_assets', 0)):,}"
        except (ValueError, TypeError):
            total_assets_formatted = "0"
        
        try:
            total_debt_formatted = f"{float(financial_summary.get('total_debt', 0)):,}"
        except (ValueError, TypeError):
            total_debt_formatted = "0"
        
        try:
            total_equity_formatted = f"{float(financial_summary.get('total_equity', 0)):,}"
        except (ValueError, TypeError):
            total_equity_formatted = "0"
        
        system_prompt = f"""당신은 재무 분석 전문가입니다. 제공된 재무 데이터를 기반으로 정확하고 구체적인 분석을 제공하세요.

사용자: {user_info.get('nickname', '사용자')}
레벨: {user_info.get('difficulty', 'intermediate')}
관심사: {user_info.get('interest', '')}
목적: {user_info.get('purpose', '')}

분석 대상 기업: {company_info.get('corp_name', '')}
분석 기간: {company_info.get('analysis_period', '')}년

=== 기본 재무 데이터 ===
최신 재무 데이터 ({company_info.get('latest_year', '')}년):
- 매출액: {revenue_formatted}백만원
- 영업이익: {operating_profit_formatted}백만원
- 순이익: {net_profit_formatted}백만원
- 총자산: {total_assets_formatted}백만원
- 총부채: {total_debt_formatted}백만원
- 총자본: {total_equity_formatted}백만원

핵심 재무비율: {ratios}

연도별 트렌드 ({len(yearly_trends.get('years', []))}년):
- 연도: {yearly_trends.get('years', [])}
- 매출액: {yearly_trends.get('revenue', [])}
- 영업이익: {yearly_trends.get('operating_profit', [])}
- 순이익: {yearly_trends.get('net_profit', [])}

뉴스 정보: {news_data.get('total_articles', 0)}건의 최신 기사 분석됨

=== 추가 조회 데이터 ===
{additional_data_section if additional_data_section else "추가 조회된 데이터 없음"}

=== 분석 지침 ===
1. 제공된 모든 재무 데이터를 활용하여 구체적이고 전문적인 분석을 제공하세요.
2. 추가 조회된 데이터(현금흐름표, 자본변동표, 공시정보, 시계열분석 등)가 있으면 해당 데이터를 포함한 종합적인 분석을 제공하세요.
3. MCP 조회 실패 정보가 있으면 해당 내용을 명시하고, 가능한 다른 분석을 제공하세요.
4. 데이터가 0이거나 비어있으면 그 사실을 명시하고, 가능한 다른 분석을 제공하세요.
5. 재무비율을 활용한 투자 관점 분석을 포함하세요.
6. 연도별 트렌드가 있으면 성장/감소 추이를 분석하세요.
7. 분석 기간({company_info.get('analysis_period', '')}년)을 고려하여 해당 기간의 성과를 종합적으로 평가하세요.

사용자 질문에 대해 위 데이터를 기반으로 전문적이고 구체적인 답변을 제공하세요."""

        data = {
            "model": "gpt-4o",
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": message}
            ],
            "max_tokens": 800,
            "temperature": 0.7
        }
        
        response = requests.post(url, headers=headers, json=data, timeout=30)
        
        if response.status_code == 200:
            result = response.json()
            return result['choices'][0]['message']['content']
        else:
            logger.error(f"GPT API 호출 실패: {response.status_code}")
            return "죄송합니다. 현재 답변을 생성할 수 없습니다."
            
    except Exception as e:
        logger.error(f"LLM 호출 오류: {e}")
        return f"답변 생성 중 오류가 발생했습니다: {str(e)}"

def analyze_message_with_llm(message: str, user_info: Dict) -> Dict:
    """LLM을 사용하여 메시지에서 기업명 언급 및 의도 분석"""
    if not GPT_API_KEY:
        return {
            'has_company_mention': False,
            'mentioned_company': None,
            'intent': 'general',
            'confidence': 0.0
        }
    
    try:
        url = "https://api.openai.com/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {GPT_API_KEY}",
            "Content-Type": "application/json"
        }
        
        system_prompt = """당신은 메시지 분석 전문가입니다. 사용자의 메시지를 분석하여 다음 정보를 JSON 형태로 반환하세요:

{
  "has_company_mention": boolean,  // 기업명이 언급되었는지
  "mentioned_company": string or null,  // 언급된 기업명 (있는 경우)
  "intent": string,  // "company_analysis", "general_finance", "other" 중 하나
  "confidence": float  // 분석 신뢰도 (0.0 ~ 1.0)
}

기업명 언급 기준:
- 구체적인 회사명 (삼성전자, 애플, 구글 등)
- 기업/회사/주식회사 등의 일반적 언급
- 특정 산업의 기업들에 대한 질문

의도 분류:
- company_analysis: 특정 기업의 재무/투자 분석
- general_finance: 일반적인 재무/투자 상담
- other: 기타"""

        data = {
            "model": "gpt-4o",
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"분석할 메시지: '{message}'"}
            ],
            "max_tokens": 200,
            "temperature": 0.1
        }
        
        response = requests.post(url, headers=headers, json=data, timeout=30)
        
        if response.status_code == 200:
            result = response.json()
            content = result['choices'][0]['message']['content']
            
            try:
                # JSON 추출 (마크다운 코드 블록이 있을 수 있음)
                if '```json' in content:
                    content = content.split('```json')[1].split('```')[0].strip()
                elif '```' in content:
                    content = content.split('```')[1].split('```')[0].strip()
                
                analysis_result = json.loads(content)
                return analysis_result
                
            except json.JSONDecodeError as e:
                logger.error(f"LLM 분석 결과 JSON 파싱 실패: {e}")
                
    except Exception as e:
        logger.error(f"LLM 메시지 분석 오류: {e}")
    
    # 기본값 반환
    return {
        'has_company_mention': False,
        'mentioned_company': None,
        'intent': 'general',
        'confidence': 0.0
    }

def call_llm_for_general_chat(message: str, user_info: Dict) -> str:
    """일반 채팅용 LLM 호출"""
    if not GPT_API_KEY:
        return f"LLM API 키가 설정되지 않았습니다. '{message}' 질문에 답변하려면 GPT API 연동이 필요합니다."
    
    try:
        url = "https://api.openai.com/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {GPT_API_KEY}",
            "Content-Type": "application/json"
        }
        
        system_prompt = f"""당신은 재무 및 투자 상담 전문가입니다.
사용자 정보:
- 닉네임: {user_info.get('nickname', '사용자')}
- 레벨: {user_info.get('difficulty', 'intermediate')}
- 관심사: {user_info.get('interest', '')}
- 목적: {user_info.get('purpose', '')}

사용자의 레벨에 맞게 재무, 투자, 경제에 대한 전문적이고 유용한 조언을 제공하세요.
구체적인 기업 분석이 필요한 경우, 기업 검색을 통해 정확한 정보를 제공할 수 있다고 안내하세요."""

        data = {
            "model": "gpt-4o",
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": message}
            ],
            "max_tokens": 800,
            "temperature": 0.7
        }
        
        response = requests.post(url, headers=headers, json=data, timeout=30)
        
        if response.status_code == 200:
            result = response.json()
            return result['choices'][0]['message']['content']
        else:
            logger.error(f"GPT API 호출 실패: {response.status_code}")
            return "죄송합니다. 현재 답변을 생성할 수 없습니다."
            
    except Exception as e:
        logger.error(f"LLM 호출 오류: {e}")
        return f"답변 생성 중 오류가 발생했습니다: {str(e)}"

# ========== API 엔드포인트들 ==========

@app.route('/api/health', methods=['GET'])
def health_check():
    """헬스 체크"""
    return jsonify({
        'status': 'ok',
        'timestamp': datetime.now().isoformat(),
        'version': '1.0.0',
        'services': {
            'dart_api': bool(DART_API_KEY),
            'perplexity_api': bool(PERPLEXITY_API_KEY),
            'gpt_api': bool(GPT_API_KEY),
            'db_api': 'connected'  # DB API 연결 상태는 별도 체크 가능
        }
    })

@app.route('/api/dashboard', methods=['POST'])
def generate_dashboard():
    """순수 대시보드 데이터 생성 (메시지 없음)"""
    try:
        data = request.get_json()
        
        # 필수 필드 검증
        if 'corp_code' not in data:
            return jsonify({'error': '기업 고유번호(corp_code)가 필요합니다'}), 400
        
        corp_code = data['corp_code']
        bgn_de = data.get('bgn_de', '2019')
        end_de = data.get('end_de', '2023')
        
        # 사용자 정보 (선택적)
        user_info = {
            'user_sno': data.get('user_sno', ''),
            'nickname': data.get('nickname', ''),
            'difficulty': data.get('difficulty', 'intermediate'),
            'interest': data.get('interest', ''),
            'purpose': data.get('purpose', '')
        }
        
        # 대시보드 데이터 생성
        dashboard_data = generate_dashboard_data(corp_code, bgn_de, end_de, user_info)
        
        return jsonify(dashboard_data)
        
    except Exception as e:
        logger.error(f"대시보드 생성 오류: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/chat', methods=['POST'])
def chat_endpoint():
    """채팅 API - chat_type에 따라 분기 처리"""
    try:
        data = request.get_json()
        
        # 필수 필드 검증
        required_fields = ['user_sno', 'nickname', 'difficulty', 'interest', 'purpose', 'chat_type', 'message']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'필수 정보 누락: {field}'}), 400
        
        # 사용자 정보 추출
        user_info = {
            'user_sno': data['user_sno'],
            'nickname': data['nickname'],
            'difficulty': data['difficulty'],
            'interest': data['interest'],
            'purpose': data['purpose']
        }
        
        message = data['message']
        chat_type = data['chat_type']
        
        # 사용자 존재 여부 확인 (선택적)
        if not validate_user_exists(user_info['user_sno']):
            logger.warning(f"존재하지 않는 사용자: {user_info['user_sno']}")
            # 경고만 하고 계속 진행 (DB 서버 다운 시에도 동작하도록)
        
        # chat_type에 따른 분기 처리
        if chat_type == 'company_analysis':
            # 기업 분석 채팅 - 대시보드 데이터 필요
            if 'company_data' not in data:
                return jsonify({'error': '기업 분석을 위해 company_data가 필요합니다. 먼저 /api/dashboard를 호출하세요.'}), 400
            
            company_data = data['company_data']
            
            # LLM을 통한 기업 분석 답변 생성
            response_message = call_llm_for_company_chat(message, user_info, company_data)
            
            # 채팅 기록 DB에 저장
            save_success = save_chat_to_db(
                user_info['user_sno'], 
                message, 
                response_message, 
                'company_analysis'
            )
            
            return jsonify({
                'chat_type': 'company_analysis',
                'user_message': message,
                'response': response_message,
                'db_saved': save_success,
                'generated_at': datetime.now().isoformat()
            })
        
        elif chat_type == 'general_chat':
            # 일반 채팅 - LLM을 통한 메시지 분석
            analysis_result = analyze_message_with_llm(message, user_info)
            
            if analysis_result['has_company_mention'] and analysis_result['intent'] == 'company_analysis':
                # 기업 분석이 필요한 경우 팝업 유도
                response_message = "구체적인 기업 분석을 위해 정확한 기업 정보가 필요합니다. 기업을 검색하여 상세한 재무 분석을 받아보세요."
                
                # 채팅 기록 저장 (팝업 유도 메시지도 저장)
                save_success = save_chat_to_db(user_info['user_sno'], message, response_message, 'general_popup')
                
                return jsonify({
                    'chat_type': 'general_chat',
                    'user_message': message,
                    'response': response_message,
                    'analysis': analysis_result,
                    'action_required': {
                        'type': 'open_company_search',
                        'popup_url': 'http://43.203.170.37:8080/compare/compSearchPopUp',
                        'suggested_company': analysis_result['mentioned_company']
                    },
                    'db_saved': save_success,
                    'generated_at': datetime.now().isoformat()
                })
            else:
                # 일반적인 재무/투자 상담
                response_message = call_llm_for_general_chat(message, user_info)
                
                # 채팅 기록 저장
                save_success = save_chat_to_db(
                    user_info['user_sno'], 
                    message, 
                    response_message, 
                    'general_chat'
                )
                
                return jsonify({
                    'chat_type': 'general_chat',
                    'user_message': message,
                    'response': response_message,
                    'analysis': analysis_result,
                    'db_saved': save_success,
                    'generated_at': datetime.now().isoformat()
                })
        
        else:
            # 지원하지 않는 chat_type
            return jsonify({'error': f'지원하지 않는 chat_type: {chat_type}'}), 400
    
    except Exception as e:
        logger.error(f"채팅 API 오류: {e}")
        return jsonify({'error': str(e)}), 500

# ========== 추가 유틸리티 API ==========

@app.route('/api/company/search', methods=['GET'])
def search_company():
    """기업명으로 기업 코드 검색"""
    try:
        company_name = request.args.get('name')
        if not company_name:
            return jsonify({'error': '기업명(name) 파라미터가 필요합니다'}), 400
        
        corp_code = get_corp_code(company_name)
        
        return jsonify({
            'status': 'success',
            'data': {
                'company_name': company_name,
                'corp_code': corp_code
            }
        })
        
    except Exception as e:
        logger.error(f"기업 검색 오류: {e}")
        return jsonify({'error': str(e)}), 404

@app.route('/api/news/<company_name>', methods=['GET'])
def get_company_news_detailed(company_name):
    """특정 기업의 뉴스 조회 - 개선된 버전"""
    try:
        period = request.args.get('period', '3days')
        limit = min(int(request.args.get('limit', 5)), 5)  # 기본 5개, 최대 5개로 제한
        
        news_articles = search_news_perplexity(company_name, period)
        
        return jsonify({
            'status': 'success',
            'data': {
                'company_name': company_name,
                'period': period,
                'total_count': len(news_articles),
                'last_updated': datetime.now().strftime('%Y-%m-%d %H:%M'),
                'articles': [
                    {
                        'id': idx + 1,
                        'title': article['title'],
                        'summary': article['summary'],
                        'full_content': article['content'],
                        'published_date': article['published_date'],
                        'source': article['source'],
                        'url': article.get('url', ''),
                        'word_count': len(article['content'].split())
                    }
                    for idx, article in enumerate(news_articles[:limit])
                ],
                'sentiment_analysis': {
                    'positive': len([a for a in news_articles if any(word in a.get('content', '').lower() for word in ['증가', '상승', '호조', '개선', '성장'])]),
                    'neutral': len([a for a in news_articles if not any(word in a.get('content', '').lower() for word in ['증가', '상승', '호조', '개선', '성장', '감소', '하락', '부진', '악화'])]),
                    'negative': len([a for a in news_articles if any(word in a.get('content', '').lower() for word in ['감소', '하락', '부진', '악화'])])
                }
            }
        })
        
    except Exception as e:
        logger.error(f"뉴스 조회 오류: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/financial/<corp_code>/<year>', methods=['GET'])
def get_company_financial_data(corp_code, year):
    """특정 기업의 특정 연도 재무 데이터 조회"""
    try:
        financial_data = get_financial_data(corp_code, year)
        
        return jsonify({
            'status': 'success',
            'data': {
                'corp_code': corp_code,
                'year': year,
                'financial_data': financial_data
            }
        })
        
    except Exception as e:
        logger.error(f"재무 데이터 조회 오류: {e}")
        return jsonify({'error': str(e)}), 500

# ========== 에러 핸들러 ==========

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'status': 'error',
        'message': 'API 엔드포인트를 찾을 수 없습니다.',
        'available_endpoints': [
            'GET /api/health',
            'POST /api/dashboard',
            'POST /api/chat',
            'GET /api/company/search?name=기업명',
            'GET /api/news/<company_name>?period=month',
            'GET /api/financial/<corp_code>/<year>'
        ]
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        'status': 'error',
        'message': '서버 내부 오류가 발생했습니다.'
    }), 500

# ========== 기업 비교 기능 추가 ==========

def get_company_financial_indicators(corp_code: str, year: str = '2023', quarter: str = '11011') -> Dict:
    """DART API - 다중회사 주요 재무지표 조회"""
    try:
        # 지표 분류 코드
        indicator_types = {
            'profitability': 'M210000',  # 수익성지표
            'stability': 'M220000',      # 안정성지표  
            'growth': 'M230000',         # 성장성지표
            'activity': 'M240000'        # 활동성지표
        }
        
        all_indicators = {}
        
        for category, idx_cl_code in indicator_types.items():
            url = 'https://opendart.fss.or.kr/api/fnlttCmpnyIndx.json'
            params = {
                'crtfc_key': DART_API_KEY,
                'corp_code': corp_code,
                'bsns_year': year,
                'reprt_code': quarter,
                'idx_cl_code': idx_cl_code
            }
            
            print(f"재무지표 API 호출: {category} - {corp_code}")
            
            response = requests.get(url, params=params, timeout=30)
            data = response.json()
            
            if data['status'] == '000' and 'list' in data:
                category_indicators = {}
                for item in data['list']:
                    idx_nm = item.get('idx_nm', '')
                    idx_val = item.get('idx_val', '')
                    
                    # 숫자 값으로 변환 시도
                    try:
                        if idx_val and idx_val != '-':
                            category_indicators[idx_nm] = float(idx_val)
                        else:
                            category_indicators[idx_nm] = None
                    except (ValueError, TypeError):
                        category_indicators[idx_nm] = idx_val
                
                all_indicators[category] = category_indicators
            else:
                print(f"{category} 지표 조회 실패: {data.get('message', '알 수 없는 오류')}")
                all_indicators[category] = {}
        
        return all_indicators
        
    except Exception as e:
        print(f"재무지표 조회 오류: {e}")
        return {
            'profitability': {},
            'stability': {},
            'growth': {},
            'activity': {}
        }

def get_company_major_accounts(corp_code: str, year: str = '2023', quarter: str = '11011') -> Dict:
    """DART API - 다중회사 주요계정 조회"""
    try:
        url = 'https://opendart.fss.or.kr/api/fnlttMultiAcnt.json'
        params = {
            'crtfc_key': DART_API_KEY,
            'corp_code': corp_code,
            'bsns_year': year,
            'reprt_code': quarter
        }
        
        print(f"주요계정 API 호출: {corp_code}")
        
        response = requests.get(url, params=params, timeout=30)
        data = response.json()
        
        if data['status'] != '000':
            raise ValueError(f"주요계정 API 오류: {data.get('message', '알 수 없는 오류')}")
        
        if 'list' not in data or not data['list']:
            raise ValueError(f"주요계정 데이터가 없습니다: {year}년 {corp_code}")
        
        accounts_data = data['list']
        
        # CFS (연결재무제표) 우선, 없으면 OFS (개별재무제표) 사용
        cfs_data = [item for item in accounts_data if item.get('fs_div') == 'CFS']
        if not cfs_data:
            ofs_data = [item for item in accounts_data if item.get('fs_div') == 'OFS']
            if ofs_data:
                filtered_data = ofs_data
            else:
                raise ValueError("연결재무제표(CFS)와 개별재무제표(OFS) 모두 없습니다")
        else:
            filtered_data = cfs_data
        
        # 주요 계정 추출
        major_accounts = {
            'balance_sheet': {},  # 재무상태표
            'income_statement': {}  # 손익계산서
        }
        
        # 재무상태표 계정들
        bs_accounts = [item for item in filtered_data if item.get('sj_div') == 'BS']
        for item in bs_accounts:
            account_nm = item.get('account_nm', '')
            amount = item.get('thstrm_amount', '')
            
            try:
                if amount and amount != '-':
                    major_accounts['balance_sheet'][account_nm] = float(amount.replace(',', ''))
                else:
                    major_accounts['balance_sheet'][account_nm] = 0
            except (ValueError, AttributeError):
                major_accounts['balance_sheet'][account_nm] = 0
        
        # 손익계산서 계정들  
        is_accounts = [item for item in filtered_data if item.get('sj_div') == 'IS']
        for item in is_accounts:
            account_nm = item.get('account_nm', '')
            amount = item.get('thstrm_amount', '')
            
            try:
                if amount and amount != '-':
                    major_accounts['income_statement'][account_nm] = float(amount.replace(',', ''))
                else:
                    major_accounts['income_statement'][account_nm] = 0
            except (ValueError, AttributeError):
                major_accounts['income_statement'][account_nm] = 0
        
        return major_accounts
        
    except Exception as e:
        print(f"주요계정 조회 오류: {e}")
        return {
            'balance_sheet': {},
            'income_statement': {}
        }

def generate_comparison_dashboard(corp_code1: str, corp_code2: str, year: str = '2023', quarter: str = '11011') -> Dict:
    """두 기업 비교 대시보드 데이터 생성"""
    try:
        # 두 기업의 기본 정보 조회
        corp_name1 = get_corp_name_from_dart(corp_code1)
        corp_name2 = get_corp_name_from_dart(corp_code2)
        
        # 두 기업의 재무지표 조회
        indicators1 = get_company_financial_indicators(corp_code1, year, quarter)
        indicators2 = get_company_financial_indicators(corp_code2, year, quarter)
        
        # 두 기업의 주요계정 조회
        accounts1 = get_company_major_accounts(corp_code1, year, quarter)
        accounts2 = get_company_major_accounts(corp_code2, year, quarter)
        
        # 기본 재무 데이터 조회 (기존 함수 활용)
        try:
            financial1 = _mcp_extract_summary_from_statements(corp_code1, year)
        except:
            financial1 = {}
            
        try:
            financial2 = _mcp_extract_summary_from_statements(corp_code2, year)
        except:
            financial2 = {}
        
        # 비교 대시보드 JSON 구조 생성
        comparison_data = {
            'comparison_info': {
                'company1': {
                    'corp_code': corp_code1,
                    'corp_name': corp_name1
                },
                'company2': {
                    'corp_code': corp_code2,
                    'corp_name': corp_name2
                },
                'analysis_year': year,
                'report_type': quarter,
                'generated_at': datetime.now().isoformat()
            },
            
            # 기본 재무 비교 (기존 로직)
            'basic_financial_comparison': {
                'company1': {
                    'revenue': financial1.get('revenue', 0),
                    'operating_profit': financial1.get('operating_profit', 0),
                    'net_profit': financial1.get('net_profit', 0),
                    'total_assets': financial1.get('total_assets', 0),
                    'total_debt': financial1.get('total_debt', 0),
                    'total_equity': financial1.get('total_equity', 0)
                },
                'company2': {
                    'revenue': financial2.get('revenue', 0),
                    'operating_profit': financial2.get('operating_profit', 0),
                    'net_profit': financial2.get('net_profit', 0),
                    'total_assets': financial2.get('total_assets', 0),
                    'total_debt': financial2.get('total_debt', 0),
                    'total_equity': financial2.get('total_equity', 0)
                }
            },
            
            # 재무지표 비교
            'financial_indicators_comparison': {
                'profitability': {  # 수익성 지표
                    'company1': indicators1.get('profitability', {}),
                    'company2': indicators2.get('profitability', {}),
                    'key_metrics': ['영업이익률', '순이익률', 'ROE', 'ROA']  # 주요 수익성 지표
                },
                'stability': {  # 안정성 지표
                    'company1': indicators1.get('stability', {}),
                    'company2': indicators2.get('stability', {}),
                    'key_metrics': ['부채비율', '유동비율', '당좌비율', '자기자본비율']  # 주요 안정성 지표
                },
                'growth': {  # 성장성 지표
                    'company1': indicators1.get('growth', {}),
                    'company2': indicators2.get('growth', {}),
                    'key_metrics': ['매출액증가율', '영업이익증가율', '순이익증가율']  # 주요 성장성 지표
                },
                'activity': {  # 활동성 지표
                    'company1': indicators1.get('activity', {}),
                    'company2': indicators2.get('activity', {}),
                    'key_metrics': ['총자산회전율', '매출채권회전율', '재고자산회전율']  # 주요 활동성 지표
                }
            },
            
            # 주요 계정 비교
            'major_accounts_comparison': {
                'balance_sheet': {  # 재무상태표
                    'company1': accounts1.get('balance_sheet', {}),
                    'company2': accounts2.get('balance_sheet', {}),
                    'key_accounts': ['자산총계', '부채총계', '자본총계', '유동자산', '비유동자산', '유동부채', '비유동부채']
                },
                'income_statement': {  # 손익계산서
                    'company1': accounts1.get('income_statement', {}),
                    'company2': accounts2.get('income_statement', {}),
                    'key_accounts': ['매출액', '영업이익', '당기순이익', '영업비용', '판매비와관리비']
                }
            },
            
            # 비교 요약 (자동 계산)
            'comparison_summary': {
                'revenue_comparison': {
                    'winner': corp_name1 if financial1.get('revenue', 0) > financial2.get('revenue', 0) else corp_name2,
                    'difference_rate': abs(financial1.get('revenue', 0) - financial2.get('revenue', 0)) / max(financial1.get('revenue', 1), financial2.get('revenue', 1)) * 100 if max(financial1.get('revenue', 1), financial2.get('revenue', 1)) > 0 else 0
                },
                'profitability_comparison': {
                    'winner': corp_name1 if financial1.get('net_profit', 0) > financial2.get('net_profit', 0) else corp_name2,
                    'difference_rate': abs(financial1.get('net_profit', 0) - financial2.get('net_profit', 0)) / max(abs(financial1.get('net_profit', 1)), abs(financial2.get('net_profit', 1))) * 100 if max(abs(financial1.get('net_profit', 1)), abs(financial2.get('net_profit', 1))) > 0 else 0
                },
                'asset_comparison': {
                    'winner': corp_name1 if financial1.get('total_assets', 0) > financial2.get('total_assets', 0) else corp_name2,
                    'difference_rate': abs(financial1.get('total_assets', 0) - financial2.get('total_assets', 0)) / max(financial1.get('total_assets', 1), financial2.get('total_assets', 1)) * 100 if max(financial1.get('total_assets', 1), financial2.get('total_assets', 1)) > 0 else 0
                }
            },
            
            # 업계 포지션 (향후 확장 가능)
            'industry_position': {
                'company1_strengths': [],  # AI 분석으로 채울 수 있음
                'company2_strengths': [],
                'comparison_notes': f"{corp_name1}과 {corp_name2}의 {year}년 재무 비교 분석 결과입니다."
            }
        }
        
        return comparison_data
        
    except Exception as e:
        print(f"기업 비교 대시보드 생성 오류: {e}")
        raise

@app.route('/api/comparison', methods=['POST'])
def generate_comparison():
    """두 기업 비교 대시보드 API"""
    try:
        data = request.get_json()
        
        # 필수 필드 검증
        required_fields = ['corp_code1', 'corp_code2']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'필수 정보 누락: {field}'}), 400
        
        corp_code1 = data['corp_code1']
        corp_code2 = data['corp_code2']
        year = data.get('year', '2023')
        quarter = data.get('quarter', '11011')  # 기본값: 사업보고서
        
        # 동일한 기업 비교 방지
        if corp_code1 == corp_code2:
            return jsonify({'error': '동일한 기업은 비교할 수 없습니다'}), 400
        
        # 비교 대시보드 데이터 생성
        comparison_data = generate_comparison_dashboard(corp_code1, corp_code2, year, quarter)
        
        return jsonify({
            'status': 'success',
            'data': comparison_data
        })
        
    except Exception as e:
        logger.error(f"기업 비교 API 오류: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/comparison/indicators/<corp_code>', methods=['GET'])
def get_single_company_indicators(corp_code):
    """단일 기업의 재무지표 조회 (비교 전 미리보기용)"""
    try:
        year = request.args.get('year', '2023')
        quarter = request.args.get('quarter', '11011')
        
        corp_name = get_corp_name_from_dart(corp_code)
        indicators = get_company_financial_indicators(corp_code, year, quarter)
        accounts = get_company_major_accounts(corp_code, year, quarter)
        
        return jsonify({
            'status': 'success',
            'data': {
                'corp_code': corp_code,
                'corp_name': corp_name,
                'year': year,
                'quarter': quarter,
                'indicators': indicators,
                'major_accounts': accounts
            }
        })
        
    except Exception as e:
        logger.error(f"단일 기업 지표 조회 오류: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/long-term-analysis/<corp_code>', methods=['GET'])
def get_long_term_analysis(corp_code):
    """장기 재무 분석 (10년)"""
    try:
        period = int(request.args.get('period', '10'))
        
        if _MCP_SVC is None:
            return jsonify({'error': 'MCP 서비스가 초기화되지 않았습니다'}), 500
        
        # 장기 시계열 분석
        analysis_result = _MCP_SVC.analyze_time_series(corp_code, period)
        if not analysis_result.get('ok'):
            return jsonify({'error': analysis_result.get('error', '장기 분석 실패')}), 500
        
        return jsonify(analysis_result.get('data', {}))
        
    except Exception as e:
        logger.error(f"장기 재무 분석 오류: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/rim-valuation/<corp_code>', methods=['GET'])
def get_rim_valuation(corp_code):
    """RIM 기업가치 평가"""
    try:
        year = request.args.get('year', '2023')
        industry = request.args.get('industry', '제조')
        
        if _MCP_SVC is None:
            return jsonify({'error': 'MCP 서비스가 초기화되지 않았습니다'}), 500
        
        # RIM 가치 계산
        rim_result = _MCP_SVC.calculate_rim_value(corp_code, year, industry)
        if not rim_result.get('ok'):
            return jsonify({'error': rim_result.get('error', 'RIM 계산 실패')}), 500
        
        return jsonify(rim_result.get('data', {}))
        
    except Exception as e:
        logger.error(f"RIM 가치 평가 오류: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/valuation-comparison/<corp_code>', methods=['GET'])
def get_valuation_comparison(corp_code):
    """절대가치 vs 상대가치 비교"""
    try:
        year = request.args.get('year', '2023')
        
        if _MCP_SVC is None:
            return jsonify({'error': 'MCP 서비스가 초기화되지 않았습니다'}), 500
        
        # 가치평가 비교
        comparison_result = _MCP_SVC.compare_valuation_methods(corp_code, year)
        if not comparison_result.get('ok'):
            return jsonify({'error': comparison_result.get('error', '가치평가 비교 실패')}), 500
        
        return jsonify(comparison_result.get('data', {}))
        
    except Exception as e:
        logger.error(f"가치평가 비교 오류: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/advanced-charts/<corp_code>', methods=['GET'])
def get_advanced_charts(corp_code):
    """고급 차트 데이터 (워터폴, 스파이더, 히트맵)"""
    try:
        year = request.args.get('year', '2023')
        
        if _MCP_SVC is None:
            return jsonify({'error': 'MCP 서비스가 초기화되지 않았습니다'}), 500
        
        # 고급 차트 데이터 생성
        charts_result = _MCP_SVC.generate_advanced_chart_data(corp_code, year)
        if not charts_result.get('ok'):
            return jsonify({'error': charts_result.get('error', '고급 차트 데이터 생성 실패')}), 500
        
        return jsonify(charts_result.get('data', {}))
        
    except Exception as e:
        logger.error(f"고급 차트 데이터 생성 오류: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)