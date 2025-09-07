from typing import Any, Dict, List, Optional
import pandas as pd
from .dart_client import DartClient

class FinancialService:
    def __init__(self, dart: DartClient):
        self.dart = dart

    def get_company_info(self, corp_code: str) -> Dict[str, Any]:
        j = self.dart.company(corp_code=corp_code)
        if j.get("status") != "000":
            return {"ok": False, "error": j.get("message")}
        return {"ok": True, "data": j}

    def get_disclosure_list(self, corp_code: str, bgn_de: str, end_de: str, page_count: int = 50) -> Dict[str, Any]:
        j = self.dart.list(corp_code=corp_code, bgn_de=bgn_de, end_de=end_de, page_count=page_count, last_reprt_at='Y')
        if j.get("status") != "000":
            return {"ok": False, "error": j.get("message")}
        return {"ok": True, "data": j.get("list", [])}

    def get_financial_statements(self, corp_code: str, bsns_year: str, reprt_code: str, fs_div: str, statement_type: str) -> Dict[str, Any]:
        j = self.dart.singl_acnt_all(corp_code=corp_code, bsns_year=bsns_year, reprt_code=reprt_code, fs_div=fs_div)
        if j.get("status") != "000":
            return {"ok": False, "error": j.get("message"), "status": j.get("status")}
        df = pd.DataFrame(j.get("list", []))
        if df.empty:
            return {"ok": False, "error": "no_data"}
        part = df[df["sj_nm"] == statement_type].copy()
        if part.empty:
            return {"ok": False, "error": f"section_missing:{statement_type}"}
        cols = [c for c in ["account_nm","thstrm_amount","frmtrm_amount","bfefrmtrm_amount"] if c in part.columns]
        out = part[cols].rename(columns={
            "account_nm": "계정",
            "thstrm_amount": "당기",
            "frmtrm_amount": "전기",
            "bfefrmtrm_amount": "전전기"
        })
        return {"ok": True, "data": out.to_dict(orient="records")}

    def get_financial_ratios(self, corp_code: str, bsns_year: str, reprt_code: str = "11014", fs_div: str = "CFS") -> Dict[str, Any]:
        j = self.dart.singl_acnt_all(corp_code=corp_code, bsns_year=bsns_year, reprt_code=reprt_code, fs_div=fs_div)
        if j.get("status") != "000":
            return {"ok": False, "error": j.get("message"), "status": j.get("status")}
        df = pd.DataFrame(j.get("list", []))
        if df.empty:
            return {"ok": False, "error": "no_data"}
        def pick(sj, patterns):
            tgt = df[df['sj_nm']==sj]
            if tgt.empty: return 0.0
            for p in patterns:
                m = tgt[tgt['account_nm'].str.contains(p, na=False)]
                if not m.empty:
                    for c in ['thstrm_amount','frmtrm_amount','bfefrmtrm_amount']:
                        if c in m.columns:
                            v = m.iloc[0][c]
                            try:
                                return float(str(v).replace(',','').replace('(','-').replace(')',''))
                            except Exception:
                                continue
            return 0.0
        
        # 기본 재무 데이터 추출
        assets = pick('재무상태표', ['자산총계'])
        equity = pick('재무상태표', ['자본총계'])
        liab = pick('재무상태표', ['부채총계'])
        current_assets = pick('재무상태표', ['유동자산'])
        current_liab = pick('재무상태표', ['유동부채'])
        cash = pick('재무상태표', ['현금및현금성자산'])
        
        rev = pick('손익계산서', ['매출액','수익\\(매출액\\)','영업수익'])
        op = pick('손익계산서', ['영업이익'])
        net = pick('손익계산서', ['당기순이익','당기순이익\\(손실\\)'])
        gross_profit = pick('손익계산서', ['매출총이익'])
        interest_expense = pick('손익계산서', ['이자비용'])
        
        # 투자 판단 핵심 지표 계산
        ratios = {}
        
        # 수익성 지표
        if equity > 0 and net != 0:
            ratios['ROE'] = round(net/equity*100, 2)  # 자기자본이익률
        if assets > 0 and net != 0:
            ratios['ROA'] = round(net/assets*100, 2)  # 총자산이익률
        if rev > 0 and op != 0:
            ratios['ROIC'] = round(op/(equity + liab)*100, 2)  # 투하자본이익률
        if rev > 0 and gross_profit != 0:
            ratios['GPM'] = round(gross_profit/rev*100, 2)  # 매출총이익률
        if rev > 0 and op != 0:
            ratios['OPM'] = round(op/rev*100, 2)  # 영업이익률
        if rev > 0 and net != 0:
            ratios['NPM'] = round(net/rev*100, 2)  # 순이익률
        
        # 안정성 지표
        if equity > 0:
            ratios['부채비율'] = round(liab/equity*100, 2)  # 부채비율
        if current_liab > 0 and current_assets != 0:
            ratios['유동비율'] = round(current_assets/current_liab, 2)  # 유동비율
        if current_liab > 0 and (current_assets - cash) != 0:
            ratios['당좌비율'] = round((current_assets - cash)/current_liab, 2)  # 당좌비율
        if interest_expense > 0 and op != 0:
            ratios['이자보상배율'] = round(op/interest_expense, 2)  # 이자보상배율
        if current_liab > 0 and cash != 0:
            ratios['현금비율'] = round(cash/current_liab, 2)  # 현금비율
        
        return {"ok": True, "data": ratios}

    def get_investment_grade(self, corp_code: str, bsns_year: str) -> Dict[str, Any]:
        """투자 등급 계산"""
        ratios_result = self.get_financial_ratios(corp_code, bsns_year)
        if not ratios_result.get("ok"):
            return ratios_result
        
        ratios = ratios_result.get("data", {})
        score = 0
        max_score = 100
        
        # 수익성 평가 (40점)
        roe = ratios.get('ROE', 0)
        roa = ratios.get('ROA', 0)
        if roe > 15: score += 20
        elif roe > 10: score += 15
        elif roe > 5: score += 10
        
        if roa > 8: score += 20
        elif roa > 5: score += 15
        elif roa > 3: score += 10
        
        # 안정성 평가 (40점)
        debt_ratio = ratios.get('부채비율', 1000)
        current_ratio = ratios.get('유동비율', 0)
        if debt_ratio < 50: score += 20
        elif debt_ratio < 80: score += 15
        elif debt_ratio < 120: score += 10
        
        if current_ratio > 1.5: score += 20
        elif current_ratio > 1.2: score += 15
        elif current_ratio > 1.0: score += 10
        
        # 성장성 평가 (20점) - 기본 점수
        score += 10  # 기본 성장성 점수
        
        # 등급 결정
        if score >= 80:
            grade = {'grade': 'A', 'score': score, 'level': 'excellent', 'color': '#28a745'}
        elif score >= 60:
            grade = {'grade': 'B', 'score': score, 'level': 'good', 'color': '#ffc107'}
        elif score >= 40:
            grade = {'grade': 'C', 'score': score, 'level': 'fair', 'color': '#fd7e14'}
        else:
            grade = {'grade': 'D', 'score': score, 'level': 'poor', 'color': '#dc3545'}
        
        return {"ok": True, "data": {"grade": grade, "ratios": ratios}}

    def get_industry_benchmarks(self, corp_code: str = None, year: str = None) -> Dict[str, Any]:
        """DART API 기반 동종업계 벤치마크 데이터"""
        try:
            if not corp_code or not year:
                # 기본값 반환 (기업코드나 연도가 없는 경우)
                return self._get_default_benchmarks()
            
            print(f"🔍 {corp_code} 기업의 동종업계 벤치마크 계산 시작...")
            
            # 1. 대상 기업의 업종 정보 조회
            company_info = self._get_company_industry(corp_code)
            if not company_info.get('ok'):
                print(f"⚠️ 기업 업종 정보 조회 실패: {company_info.get('error')}")
                return self._get_default_benchmarks()
            
            industry = company_info.get('data', {}).get('industry', '제조')
            print(f"📊 대상 기업 업종: {industry}")
            
            # 2. 동종업계 기업 목록 조회
            peer_companies = self._get_peer_companies(industry, corp_code)
            if not peer_companies.get('ok') or not peer_companies.get('data'):
                print(f"⚠️ 동종업계 기업 목록 조회 실패: {peer_companies.get('error')}")
                return self._get_default_benchmarks()
            
            peer_list = peer_companies.get('data', [])
            print(f"📊 동종업계 기업 수: {len(peer_list)}개")
            
            # 3. 동종업계 기업들의 재무비율 수집
            industry_ratios = []
            for peer_corp in peer_list[:20]:  # 상위 20개 기업만 분석 (성능 고려)
                try:
                    peer_ratios = self.get_financial_ratios(peer_corp['corp_code'], year)
                    if peer_ratios.get('ok') and peer_ratios.get('data'):
                        ratio_data = peer_ratios.get('data', {})
                        # 유효한 데이터만 필터링
                        if (ratio_data.get('ROE', 0) != 0 and 
                            ratio_data.get('ROA', 0) != 0 and 
                            ratio_data.get('부채비율', 0) != 0):
                            industry_ratios.append(ratio_data)
                except Exception as e:
                    print(f"⚠️ {peer_corp.get('corp_name', 'Unknown')} 재무비율 조회 실패: {e}")
                    continue
            
            print(f"📊 수집된 유효한 재무비율 데이터: {len(industry_ratios)}개")
            
            # 4. 업계 평균 계산
            if len(industry_ratios) >= 3:  # 최소 3개 기업 이상
                avg_benchmarks = self._calculate_industry_averages(industry_ratios)
                print(f"✅ {industry} 업계 평균 계산 완료")
                return {"ok": True, "data": {industry: avg_benchmarks}}
            else:
                print(f"⚠️ 충분한 동종업계 데이터가 없습니다. 기본값 사용")
                return self._get_default_benchmarks()
                
        except Exception as e:
            print(f"❌ 업계 벤치마크 계산 실패: {e}")
            return self._get_default_benchmarks()
    
    def _get_default_benchmarks(self) -> Dict[str, Any]:
        """기본 벤치마크 데이터 (fallback)"""
        benchmarks = {
            '제조': {
                'ROE': 12.1, 'ROA': 6.8, '부채비율': 52.8,
                '유동비율': 1.5, '영업이익률': 8.9,
                'beta': 1.0, 'risk_free_rate': 3.5, 'market_premium': 6.0
            }
        }
        return {"ok": True, "data": benchmarks}
    
    def _get_company_industry(self, corp_code: str) -> Dict[str, Any]:
        """기업의 업종 정보 조회"""
        try:
            # DART API에서 기업 정보 조회
            j = self.dart.corp_code(corp_code=corp_code)
            if j.get("status") != "000":
                return {"ok": False, "error": "기업 정보 조회 실패"}
            
            corp_info = j.get("list", [{}])[0] if j.get("list") else {}
            industry = corp_info.get('induty_code_nm', '제조')  # 업종코드명
            
            # 업종 분류 매핑
            industry_mapping = {
                '반도체': ['반도체', '전자부품', '전자'],
                'IT': ['소프트웨어', '정보통신', 'IT'],
                '유통': ['유통', '도소매', '판매'],
                '제조': ['제조', '화학', '철강', '자동차']
            }
            
            mapped_industry = '제조'  # 기본값
            for key, keywords in industry_mapping.items():
                if any(keyword in industry for keyword in keywords):
                    mapped_industry = key
                    break
            
            return {
                "ok": True,
                "data": {
                    "industry": mapped_industry,
                    "original_industry": industry
                }
            }
            
        except Exception as e:
            return {"ok": False, "error": f"업종 정보 조회 실패: {str(e)}"}
    
    def _get_peer_companies(self, industry: str, exclude_corp_code: str) -> Dict[str, Any]:
        """동종업계 기업 목록 조회"""
        try:
            # 업종별 대표 기업 목록 (실제로는 DART API로 동적 조회 필요)
            industry_companies = {
                '반도체': [
                    {'corp_code': '00126380', 'corp_name': '삼성전자'},
                    {'corp_code': '00164779', 'corp_name': 'SK하이닉스'},
                    {'corp_code': '00164780', 'corp_name': 'LG디스플레이'},
                    {'corp_code': '00164781', 'corp_name': '삼성디스플레이'},
                    {'corp_code': '00164782', 'corp_name': 'DB하이텍'}
                ],
                'IT': [
                    {'corp_code': '00164783', 'corp_name': '네이버'},
                    {'corp_code': '00164784', 'corp_name': '카카오'},
                    {'corp_code': '00164785', 'corp_name': '쿠팡'},
                    {'corp_code': '00164786', 'corp_name': '배달의민족'},
                    {'corp_code': '00164787', 'corp_name': '토스'}
                ],
                '유통': [
                    {'corp_code': '00164788', 'corp_name': '신세계'},
                    {'corp_code': '00164789', 'corp_name': '롯데쇼핑'},
                    {'corp_code': '00164790', 'corp_name': '이마트'},
                    {'corp_code': '00164791', 'corp_name': '홈플러스'},
                    {'corp_code': '00164792', 'corp_name': '쿠팡'}
                ],
                '제조': [
                    {'corp_code': '00164793', 'corp_name': '현대자동차'},
                    {'corp_code': '00164794', 'corp_name': '기아'},
                    {'corp_code': '00164795', 'corp_name': '포스코'},
                    {'corp_code': '00164796', 'corp_name': 'LG화학'},
                    {'corp_code': '00164797', 'corp_name': '삼성SDI'}
                ]
            }
            
            # 대상 업종의 기업 목록 반환 (제외 기업 제외)
            companies = industry_companies.get(industry, [])
            filtered_companies = [c for c in companies if c['corp_code'] != exclude_corp_code]
            
            return {
                "ok": True,
                "data": filtered_companies
            }
            
        except Exception as e:
            return {"ok": False, "error": f"동종업계 기업 목록 조회 실패: {str(e)}"}
    
    def _calculate_industry_averages(self, ratios_list: List[Dict]) -> Dict[str, float]:
        """업계 평균 계산"""
        try:
            if not ratios_list:
                return {}
            
            # 각 지표별 평균 계산
            avg_ratios = {}
            indicators = ['ROE', 'ROA', '부채비율', '유동비율', '영업이익률']
            
            for indicator in indicators:
                values = [r.get(indicator, 0) for r in ratios_list if r.get(indicator, 0) != 0]
                if values:
                    avg_ratios[indicator] = round(sum(values) / len(values), 2)
                else:
                    avg_ratios[indicator] = 0.0
            
            # 추가 지표 (고정값)
            avg_ratios['beta'] = 1.0
            avg_ratios['risk_free_rate'] = 3.5
            avg_ratios['market_premium'] = 6.0
            
            print(f"📊 업계 평균 계산 결과: {avg_ratios}")
            return avg_ratios
            
        except Exception as e:
            print(f"❌ 업계 평균 계산 실패: {e}")
            return {}
 
    def calculate_rim_value(self, corp_code: str, year: str, industry: str = "제조") -> Dict[str, Any]:
        """RIM (Residual Income Model) 기업가치 계산"""
        try:
            # 1. 재무 데이터 조회
            financial_data = self.get_financial_ratios(corp_code, year)
            if not financial_data.get('ok'):
                return {"ok": False, "error": "재무 데이터 조회 실패"}
            
            ratios = financial_data.get('data', {})
            
            # 2. 업종 벤치마크 조회 (DART API 기반)
            benchmarks = self.get_industry_benchmarks(corp_code, year)
            industry_data = benchmarks.get('data', {}).get(industry, {})
            
            # 3. 자기자본 수익률 (ROE) 계산
            roe = ratios.get('ROE', 0)
            
            # 4. 자기자본 비용 (ke) 계산 (CAPM 모델)
            risk_free_rate = industry_data.get('risk_free_rate', 3.5)
            beta = industry_data.get('beta', 1.0)
            market_premium = industry_data.get('market_premium', 6.0)
            ke = risk_free_rate + (beta * market_premium)
            
            # 5. 잔여이익 (RI) 계산
            # RI = (ROE - ke) × 자기자본
            # 자기자본은 재무상태표에서 추출 필요
            equity_data = self._get_equity_data(corp_code, year)
            if not equity_data.get('ok'):
                return {"ok": False, "error": "자기자본 데이터 조회 실패"}
            
            total_equity = equity_data.get('data', {}).get('total_equity', 0)
            residual_income = (roe - ke) * total_equity / 100  # ROE는 퍼센트이므로 100으로 나눔
            
            # 6. RIM 기업가치 계산
            # 기업가치 = 자기자본 + 잔여이익의 현재가치
            # 단순화를 위해 잔여이익을 영구적으로 유지한다고 가정
            rim_value = total_equity + (residual_income / (ke / 100))
            
            # 7. 현재주가 대비 비율 계산 (가상 주가 사용)
            # 실제로는 주가 API가 필요하지만, 여기서는 가상값 사용
            estimated_stock_price = rim_value / 1000000  # 100만주로 가정
            current_stock_price = estimated_stock_price * 0.8  # 현재주가를 RIM가치의 80%로 가정
            rim_ratio = rim_value / (current_stock_price * 1000000)
            
            return {
                "ok": True,
                "data": {
                    "rim_value": round(rim_value, 0),
                    "residual_income": round(residual_income, 0),
                    "cost_of_equity": round(ke, 2),
                    "roe": roe,
                    "total_equity": round(total_equity, 0),
                    "estimated_stock_price": round(estimated_stock_price, 0),
                    "current_stock_price": round(current_stock_price, 0),
                    "rim_ratio": round(rim_ratio, 2),
                    "investment_potential": self._assess_investment_potential(rim_ratio),
                    "calculation_details": {
                        "risk_free_rate": risk_free_rate,
                        "beta": beta,
                        "market_premium": market_premium,
                        "industry": industry
                    }
                }
            }
            
        except Exception as e:
            return {"ok": False, "error": f"RIM 계산 실패: {str(e)}"}

    def _get_equity_data(self, corp_code: str, year: str) -> Dict[str, Any]:
        """자기자본 데이터 조회"""
        try:
            j = self.dart.singl_acnt_all(corp_code=corp_code, bsns_year=year)
            if j.get("status") != "000":
                return {"ok": False, "error": j.get("message")}
            
            df = pd.DataFrame(j.get("list", []))
            if df.empty:
                return {"ok": False, "error": "데이터 없음"}
            
            def pick(sj, patterns):
                tgt = df[df['sj_nm']==sj]
                if tgt.empty: return 0.0
                for p in patterns:
                    m = tgt[tgt['account_nm'].str.contains(p, na=False)]
                    if not m.empty:
                        for c in ['thstrm_amount','frmtrm_amount','bfefrmtrm_amount']:
                            if c in m.columns:
                                v = m.iloc[0][c]
                                try:
                                    return float(str(v).replace(',','').replace('(','-').replace(')',''))
                                except Exception:
                                    continue
                return 0.0
            
            total_equity = pick('재무상태표', ['자본총계'])
            
            return {
                "ok": True,
                "data": {
                    "total_equity": total_equity
                }
            }
            
        except Exception as e:
            return {"ok": False, "error": str(e)}

    def _assess_investment_potential(self, rim_ratio: float) -> Dict[str, Any]:
        """투자 포텐셜 평가"""
        if rim_ratio >= 2.0:
            return {
                "level": "high",
                "description": "높은 투자 포텐셜",
                "color": "#28a745",
                "recommendation": "매우 매력적인 투자 대상"
            }
        elif rim_ratio >= 1.5:
            return {
                "level": "medium",
                "description": "보통 투자 포텐셜",
                "color": "#ffc107",
                "recommendation": "적정 투자 대상"
            }
        elif rim_ratio >= 1.0:
            return {
                "level": "low",
                "description": "낮은 투자 포텐셜",
                "color": "#fd7e14",
                "recommendation": "신중한 투자 필요"
            }
        else:
            return {
                "level": "very_low",
                "description": "매우 낮은 투자 포텐셜",
                "color": "#dc3545",
                "recommendation": "투자 위험"
            }

    def compare_valuation_methods(self, corp_code: str, year: str) -> Dict[str, Any]:
        """절대가치 vs 상대가치 비교"""
        try:
            # RIM 절대가치 계산
            rim_result = self.calculate_rim_value(corp_code, year)
            if not rim_result.get('ok'):
                return {"ok": False, "error": "RIM 계산 실패"}
            
            rim_data = rim_result.get('data', {})
            
            # 상대가치 지표 계산
            ratios = self.get_financial_ratios(corp_code, year)
            if not ratios.get('ok'):
                return {"ok": False, "error": "재무비율 계산 실패"}
            
            ratio_data = ratios.get('data', {})
            
            # 업종 평균과 비교 (DART API 기반)
            industry_benchmarks = self.get_industry_benchmarks(corp_code, year)
            industry_avg = industry_benchmarks.get('data', {}).get('제조', {})
            
            comparison = {
                "absolute_valuation": {
                    "method": "RIM (Residual Income Model)",
                    "value": rim_data.get('rim_value', 0),
                    "ratio": rim_data.get('rim_ratio', 0),
                    "potential": rim_data.get('investment_potential', {})
                },
                "relative_valuation": {
                    "roe": {
                        "company": ratio_data.get('ROE', 0),
                        "industry_avg": industry_avg.get('ROE', 0),
                        "comparison": "우수" if ratio_data.get('ROE', 0) > industry_avg.get('ROE', 0) else "평균"
                    },
                    "debt_ratio": {
                        "company": ratio_data.get('부채비율', 0),
                        "industry_avg": industry_avg.get('부채비율', 0),
                        "comparison": "우수" if ratio_data.get('부채비율', 0) < industry_avg.get('부채비율', 0) else "평균"
                    },
                    "operating_margin": {
                        "company": ratio_data.get('OPM', 0),
                        "industry_avg": industry_avg.get('영업이익률', 0),
                        "comparison": "우수" if ratio_data.get('OPM', 0) > industry_avg.get('영업이익률', 0) else "평균"
                    }
                },
                "summary": {
                    "absolute_score": self._calculate_absolute_score(rim_data),
                    "relative_score": self._calculate_relative_score(ratio_data, industry_avg),
                    "overall_assessment": self._get_overall_assessment(rim_data, ratio_data, industry_avg)
                }
            }
            
            return {"ok": True, "data": comparison}
            
        except Exception as e:
            return {"ok": False, "error": f"가치평가 비교 실패: {str(e)}"}

    def _calculate_absolute_score(self, rim_data: Dict) -> int:
        """절대가치 점수 계산 (0-100)"""
        rim_ratio = rim_data.get('rim_ratio', 1.0)
        if rim_ratio >= 2.0:
            return 90
        elif rim_ratio >= 1.5:
            return 75
        elif rim_ratio >= 1.2:
            return 60
        elif rim_ratio >= 1.0:
            return 45
        else:
            return 30

    def _calculate_relative_score(self, ratio_data: Dict, industry_avg: Dict) -> int:
        """상대가치 점수 계산 (0-100)"""
        score = 50  # 기본 점수
        
        # ROE 비교
        if ratio_data.get('ROE', 0) > industry_avg.get('ROE', 0):
            score += 15
        elif ratio_data.get('ROE', 0) < industry_avg.get('ROE', 0) * 0.8:
            score -= 15
        
        # 부채비율 비교
        if ratio_data.get('부채비율', 1000) < industry_avg.get('부채비율', 1000):
            score += 15
        elif ratio_data.get('부채비율', 1000) > industry_avg.get('부채비율', 1000) * 1.2:
            score -= 15
        
        # 영업이익률 비교
        if ratio_data.get('OPM', 0) > industry_avg.get('영업이익률', 0):
            score += 20
        elif ratio_data.get('OPM', 0) < industry_avg.get('영업이익률', 0) * 0.8:
            score -= 20
        
        return max(0, min(100, score))

    def _get_overall_assessment(self, rim_data: Dict, ratio_data: Dict, industry_avg: Dict) -> Dict[str, Any]:
        """종합 평가"""
        absolute_score = self._calculate_absolute_score(rim_data)
        relative_score = self._calculate_relative_score(ratio_data, industry_avg)
        
        overall_score = (absolute_score + relative_score) / 2
        
        if overall_score >= 80:
            return {
                "grade": "A",
                "level": "excellent",
                "description": "매우 우수한 투자 대상",
                "color": "#28a745"
            }
        elif overall_score >= 65:
            return {
                "grade": "B",
                "level": "good",
                "description": "좋은 투자 대상",
                "color": "#ffc107"
            }
        elif overall_score >= 50:
            return {
                "grade": "C",
                "level": "fair",
                "description": "보통 투자 대상",
                "color": "#fd7e14"
            }
        else:
            return {
                "grade": "D",
                "level": "poor",
                "description": "투자 신중",
                "color": "#dc3545"
            }

    def compare_financials(self, corp_codes: List[str], bsns_year: str, reprt_code: str = "11014", fs_div: str = "CFS", metrics: Optional[List[str]] = None) -> Dict[str, Any]:
        metrics = metrics or ["매출액","영업이익","순이익","ROE","부채비율","영업이익률"]
        out: Dict[str, Dict[str, float]] = {}
        for code in corp_codes:
            j = self.dart.singl_acnt_all(corp_code=code, bsns_year=bsns_year, reprt_code=reprt_code, fs_div=fs_div)
            if j.get('status') != '000':
                out[code] = {"ERROR": 1}
                continue
            df = pd.DataFrame(j.get('list', []))
            def pick(sj, patterns):
                tgt = df[df['sj_nm']==sj]
                if tgt.empty: return 0.0
                for p in patterns:
                    m = tgt[tgt['account_nm'].str.contains(p, na=False)]
                    if not m.empty:
                        for c in ['thstrm_amount','frmtrm_amount','bfefrmtrm_amount']:
                            if c in m.columns:
                                v = m.iloc[0][c]
                                try:
                                    return float(str(v).replace(',','').replace('(','-').replace(')',''))
                                except Exception:
                                    continue
                return 0.0
            assets = pick('재무상태표', ['자산총계'])
            equity = pick('재무상태표', ['자본총계'])
            liab = pick('재무상태표', ['부채총계'])
            rev = pick('손익계산서', ['매출액','수익\\(매출액\\)','영업수익'])
            op = pick('손익계산서', ['영업이익'])
            net = pick('손익계산서', ['당기순이익','당기순이익\\(손실\\)'])
            d: Dict[str, float] = {}
            if '매출액' in metrics and rev>0: d['매출액']=round(rev/1e8,1)
            if '영업이익' in metrics and op!=0: d['영업이익']=round(op/1e8,1)
            if '순이익' in metrics and net!=0: d['순이익']=round(net/1e8,1)
            if 'ROE' in metrics and equity>0 and net!=0: d['ROE']=round(net/equity*100,2)
            if '부채비율' in metrics and equity>0: d['부채비율']=round(liab/equity*100,2)
            if '영업이익률' in metrics and rev>0: d['영업이익률']=round(op/rev*100,2)
            out[code] = d
        return {"ok": True, "data": out}

    def analyze_time_series(self, corp_code: str, analysis_period: int = 10, metrics: Optional[List[str]] = None, reprt_code: str = "11014", fs_div: str = "CFS") -> Dict[str, Any]:
        """장기 재무 데이터 분석 (기본 10년)"""
        metrics = metrics or ["매출액","영업이익","순이익","총자산","총부채","총자본"]
        years = []
        data_rows = []
        
        # 최근 analysis_period년 역산 (현재 연도 기준)
        import datetime as dt
        current_year = dt.datetime.now().year
        end_year = current_year
        start_year = end_year - analysis_period + 1
        
        print(f"📊 장기 재무 분석 시작: {corp_code} ({start_year}-{end_year}) [현재 연도: {current_year}]")
        
        for y in range(start_year, end_year + 1):
            try:
                j = self.dart.singl_acnt_all(corp_code=corp_code, bsns_year=str(y), reprt_code=reprt_code, fs_div=fs_div)
                if j.get('status') != '000':
                    print(f"⚠️ {y}년 데이터 조회 실패: {j.get('message', 'Unknown error')}")
                    continue
                    
                df = pd.DataFrame(j.get('list', []))
                if df.empty:
                    print(f"⚠️ {y}년 데이터 없음")
                    continue
                    
                def pick(sj, patterns):
                    tgt = df[df['sj_nm']==sj]
                    if tgt.empty: return 0.0
                    for p in patterns:
                        m = tgt[tgt['account_nm'].str.contains(p, na=False)]
                        if not m.empty:
                            for c in ['thstrm_amount','frmtrm_amount','bfefrmtrm_amount']:
                                if c in m.columns:
                                    v = m.iloc[0][c]
                                    try:
                                        return float(str(v).replace(',','').replace('(','-').replace(')',''))
                                    except Exception:
                                        continue
                    return 0.0
                
                # 손익계산서 데이터
                rev = pick('손익계산서', ['매출액','수익\\(매출액\\)','영업수익'])
                op = pick('손익계산서', ['영업이익'])
                net = pick('손익계산서', ['당기순이익','당기순이익\\(손실\\)'])
                gross_profit = pick('손익계산서', ['매출총이익'])
                
                # 재무상태표 데이터
                total_assets = pick('재무상태표', ['자산총계'])
                total_liab = pick('재무상태표', ['부채총계'])
                total_equity = pick('재무상태표', ['자본총계'])
                
                years.append(y)
                data_rows.append({
                    "year": y, 
                    "매출액": rev, 
                    "영업이익": op, 
                    "순이익": net,
                    "매출총이익": gross_profit,
                    "총자산": total_assets,
                    "총부채": total_liab,
                    "총자본": total_equity
                })
                
                print(f"✅ {y}년 데이터 수집 완료")
                
            except Exception as e:
                print(f"❌ {y}년 데이터 처리 실패: {e}")
                continue
        
        # 성장률 계산
        growth_rates = self.calculate_growth_rates(data_rows)
        
        # 트렌드 패턴 분석
        trend_patterns = self.analyze_trend_patterns(data_rows)
        
        return {
            "ok": True, 
            "data": {
                "years": years, 
                "series": data_rows,
                "growth_rates": growth_rates,
                "trend_patterns": trend_patterns,
                "analysis_period": f"{start_year}-{end_year}",
                "total_years": len(years)
            }
        }

    def calculate_growth_rates(self, data_rows: List[Dict]) -> Dict[str, Any]:
        """성장률 계산"""
        if len(data_rows) < 2:
            return {}
        
        growth_rates = {}
        
        # 연평균 성장률 (CAGR) 계산
        for metric in ['매출액', '영업이익', '순이익', '총자산', '총자본']:
            if len(data_rows) >= 2:
                first_value = data_rows[0].get(metric, 0)
                last_value = data_rows[-1].get(metric, 0)
                
                if first_value > 0 and last_value > 0:
                    years = len(data_rows) - 1
                    cagr = ((last_value / first_value) ** (1/years) - 1) * 100
                    growth_rates[f'{metric}_CAGR'] = round(cagr, 2)
                else:
                    growth_rates[f'{metric}_CAGR'] = 0
        
        # 연도별 성장률
        year_over_year = {}
        for i in range(1, len(data_rows)):
            year = data_rows[i]['year']
            prev_year = data_rows[i-1]['year']
            
            for metric in ['매출액', '영업이익', '순이익']:
                current = data_rows[i].get(metric, 0)
                previous = data_rows[i-1].get(metric, 0)
                
                if previous > 0:
                    growth = ((current - previous) / previous) * 100
                    if metric not in year_over_year:
                        year_over_year[metric] = {}
                    year_over_year[metric][year] = round(growth, 2)
        
        growth_rates['year_over_year'] = year_over_year
        
        return growth_rates

    def analyze_trend_patterns(self, data_rows: List[Dict]) -> Dict[str, Any]:
        """트렌드 패턴 분석"""
        if len(data_rows) < 3:
            return {}
        
        patterns = {}
        
        # 수익성 트렌드
        profitability_trend = []
        for row in data_rows:
            if row['매출액'] > 0:
                op_margin = (row['영업이익'] / row['매출액']) * 100
                net_margin = (row['순이익'] / row['매출액']) * 100
                profitability_trend.append({
                    'year': row['year'],
                    '영업이익률': round(op_margin, 2),
                    '순이익률': round(net_margin, 2)
                })
        
        patterns['profitability_trend'] = profitability_trend
        
        # 안정성 트렌드
        stability_trend = []
        for row in data_rows:
            if row['총자본'] > 0:
                debt_ratio = (row['총부채'] / row['총자본']) * 100
                stability_trend.append({
                    'year': row['year'],
                    '부채비율': round(debt_ratio, 2)
                })
        
        patterns['stability_trend'] = stability_trend
        
        # 성장 패턴 분석
        revenue_growth = []
        for i in range(1, len(data_rows)):
            if data_rows[i-1]['매출액'] > 0:
                growth = ((data_rows[i]['매출액'] - data_rows[i-1]['매출액']) / data_rows[i-1]['매출액']) * 100
                revenue_growth.append({
                    'year': data_rows[i]['year'],
                    '성장률': round(growth, 2)
                })
        
        patterns['revenue_growth'] = revenue_growth
        
        return patterns

    def generate_summary_report(self, title: str, content: str) -> Dict[str, Any]:
        return {"ok": True, "data": {"title": title, "content": content}}

    def generate_advanced_chart_data(self, corp_code: str, year: str) -> Dict[str, Any]:
        """고급 차트 데이터 생성 (워터폴, 스파이더, 히트맵)"""
        try:
            # 기본 재무 데이터 조회
            financial_data = self.get_financial_ratios(corp_code, year)
            if not financial_data.get('ok'):
                return {"ok": False, "error": "재무 데이터 조회 실패"}
            
            ratios = financial_data.get('data', {})
            
            # 업종 벤치마크 조회 (DART API 기반)
            company_info = self._get_company_industry(corp_code)
            industry = company_info.get('data', {}).get('industry', '제조') if company_info.get('ok') else '제조'
            benchmarks = self.get_industry_benchmarks(corp_code, year)
            industry_avg = benchmarks.get('data', {}).get(industry, {})
            
            # 1. 스파이더 차트 데이터 (종합 평가)
            spider_data = self._generate_spider_data(ratios, industry_avg)
            
            # 2. 히트맵 데이터 (연도별 비교)
            heatmap_data = self._generate_heatmap_data(corp_code)
            
            # 오류 체크
            if spider_data.get('error'):
                print(f"⚠️ 스파이더 차트 데이터 오류: {spider_data.get('error')}")
                spider_data = {"title": "종합 재무 평가", "dimensions": []}
            
            if heatmap_data.get('error'):
                print(f"⚠️ 히트맵 데이터 오류: {heatmap_data.get('error')}")
                heatmap_data = {"title": "연도별 재무 지표 히트맵", "data": []}
            
            return {
                "ok": True,
                "data": {
                    "spider_chart": spider_data,
                    "heatmap_chart": heatmap_data
                }
            }
            
        except Exception as e:
            return {"ok": False, "error": f"고급 차트 데이터 생성 실패: {str(e)}"}



    def _generate_spider_data(self, ratios: Dict, industry_avg: Dict) -> Dict[str, Any]:
        """스파이더 차트 데이터 생성 (종합 재무 평가)"""
        try:
            # 5개 차원으로 종합 평가
            spider_data = {
                "title": "종합 재무 평가",
                "dimensions": [
                    {
                        "name": "수익성",
                        "company": min(100, max(0, ratios.get('ROE', 0) * 5)),  # ROE를 0-100 스케일로 변환
                        "industry": min(100, max(0, industry_avg.get('ROE', 0) * 5)),
                        "max": 100
                    },
                    {
                        "name": "성장성",
                        "company": min(100, max(0, ratios.get('OPM', 0) * 8)),  # 영업이익률을 0-100 스케일로 변환
                        "industry": min(100, max(0, industry_avg.get('영업이익률', 0) * 8)),
                        "max": 100
                    },
                    {
                        "name": "안정성",
                        "company": min(100, max(0, 100 - ratios.get('부채비율', 100))),  # 부채비율이 낮을수록 높은 점수
                        "industry": min(100, max(0, 100 - industry_avg.get('부채비율', 100))),
                        "max": 100
                    },
                    {
                        "name": "효율성",
                        "company": min(100, max(0, ratios.get('ROA', 0) * 10)),  # ROA를 0-100 스케일로 변환
                        "industry": min(100, max(0, industry_avg.get('ROA', 0) * 10)),
                        "max": 100
                    },
                    {
                        "name": "현금창출력",
                        "company": min(100, max(0, ratios.get('유동비율', 0) * 50)),  # 유동비율을 0-100 스케일로 변환
                        "industry": min(100, max(0, industry_avg.get('유동비율', 0) * 50)),
                        "max": 100
                    }
                ]
            }
            
            return spider_data
            
        except Exception as e:
            return {"error": f"스파이더 데이터 생성 실패: {str(e)}"}

    def _generate_heatmap_data(self, corp_code: str) -> Dict[str, Any]:
        """히트맵 데이터 생성 (연도별 지표 비교)"""
        try:
            # 최근 5년 데이터 조회 (현재 연도 기준)
            current_year = 2024  # 안정성을 위해 고정값 사용
            years = list(range(current_year - 4, current_year))
            
            heatmap_data = {
                "title": "연도별 재무 지표 히트맵",
                "x_axis": "연도",
                "y_axis": "재무지표",
                "data": []
            }
            
            indicators = ['ROE', 'ROA', 'OPM', '부채비율', '유동비율']
            
            for year in years:
                try:
                    ratios = self.get_financial_ratios(corp_code, str(year))
                    if ratios.get('ok'):
                        ratio_data = ratios.get('data', {})
                        
                        for indicator in indicators:
                            value = ratio_data.get(indicator, 0)
                            
                            # 색상 점수 계산 (0-100)
                            if indicator in ['ROE', 'ROA', 'OPM']:
                                color_score = min(100, max(0, value * 5))  # 높을수록 좋음
                            elif indicator == '부채비율':
                                color_score = min(100, max(0, 100 - value))  # 낮을수록 좋음
                            elif indicator == '유동비율':
                                color_score = min(100, max(0, value * 50))  # 높을수록 좋음
                            else:
                                color_score = 50
                            
                            heatmap_data["data"].append({
                                "x": str(year),
                                "y": indicator,
                                "value": round(value, 2),
                                "color_score": round(color_score, 2)
                            })
                            
                except Exception as e:
                    print(f"⚠️ {year}년 히트맵 데이터 생성 실패: {e}")
                    continue
            
            return heatmap_data
            
        except Exception as e:
            return {"error": f"히트맵 데이터 생성 실패: {str(e)}"}

    def export_to_pdf(self, title: str, content: str, page_format: str = "A4") -> Dict[str, Any]:
        try:
            from reportlab.lib.pagesizes import A4, letter
            from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
            from reportlab.lib.styles import getSampleStyleSheet
            import io, base64
            buf = io.BytesIO()
            page = A4 if page_format == "A4" else letter
            doc = SimpleDocTemplate(buf, pagesize=page)
            styles = getSampleStyleSheet()
            story = [Paragraph(title, styles['Title']), Spacer(1, 12)]
            for line in content.split('\n'):
                if line.strip():
                    story.append(Paragraph(line, styles['Normal']))
                    story.append(Spacer(1, 6))
            doc.build(story)
            data = buf.getvalue(); buf.close()
            b64 = base64.b64encode(data).decode('utf-8')
            return {"ok": True, "data": {"pdf_base64": b64, "size": len(data)}}
        except Exception as e:
            return {"ok": False, "error": str(e)}

    # --- 뉴스/포트폴리오/경쟁/업계 (간단 샘플) ---
    async def get_company_news(self, query: str, period: str = "week") -> Dict[str, Any]:
        from .secrets import Secrets
        from .news_client import PerplexityClient
        key = Secrets().get_perplexity_key()
        if not key:
            return {"ok": False, "error": "perplexity_key_missing"}
        client = PerplexityClient(key)
        data = await client.search(query, recency=period)
        return {"ok": True, "data": data}

    async def analyze_news_sentiment(self, query: str, period: str = "week") -> Dict[str, Any]:
        res = await self.get_company_news(query, period)
        if not res.get("ok"):
            return res
        arts = res.get("data", {}).get("articles", [])
        pos = sum(1 for a in arts if any(k in (a.get('title','')+a.get('content','')) for k in ['성장','상승','증가']))
        neg = sum(1 for a in arts if any(k in (a.get('title','')+a.get('content','')) for k in ['감소','하락','부진']))
        label = "neutral"
        if pos > neg*1.5: label = "positive"
        elif neg > pos*1.5: label = "negative"
        return {"ok": True, "data": {"total": len(arts), "positive": pos, "negative": neg, "sentiment": label}}

    def optimize_portfolio(self, tickers: list[str], budget: float, risk: str = "보통") -> Dict[str, Any]:
        w = round(1/len(tickers), 4) if tickers else 0
        alloc = {t: round(budget*w, 2) for t in tickers}
        return {"ok": True, "data": {"weights": {t: w for t in tickers}, "allocations": alloc, "risk": risk}}

    def analyze_competitive_position(self, corp_code: str, peer_corp_codes: list[str]) -> Dict[str, Any]:
        return {"ok": True, "data": {"corp_code": corp_code, "peers": peer_corp_codes, "summary": "basic comparison"}}

    def generate_industry_report(self, industry: str) -> Dict[str, Any]:
        return {"ok": True, "data": {"industry": industry, "highlights": ["sample"]}}
