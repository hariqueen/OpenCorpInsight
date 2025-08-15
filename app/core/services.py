from typing import Any, Dict, List
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
        assets = pick('재무상태표', ['자산총계'])
        equity = pick('재무상태표', ['자본총계'])
        liab = pick('재무상태표', ['부채총계'])
        rev = pick('손익계산서', ['매출액','수익\\(매출액\\)','영업수익'])
        op = pick('손익계산서', ['영업이익'])
        net = pick('손익계산서', ['당기순이익','당기순이익\\(손실\\)'])
        ratios = {}
        if equity>0 and net!=0: ratios['ROE']=round(net/equity*100,2)
        if assets>0 and net!=0: ratios['ROA']=round(net/assets*100,2)
        if equity>0: ratios['부채비율']=round(liab/equity*100,2)
        if rev>0: ratios['영업이익률']=round(op/rev*100,2)
        return {"ok": True, "data": ratios}

    def compare_financials(self, corp_codes: List[str], bsns_year: str, reprt_code: str = "11014", fs_div: str = "CFS", metrics: List[str] | None = None) -> Dict[str, Any]:
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

    def analyze_time_series(self, corp_code: str, analysis_period: int = 5, metrics: List[str] | None = None, reprt_code: str = "11014", fs_div: str = "CFS") -> Dict[str, Any]:
        metrics = metrics or ["매출액","영업이익","순이익"]
        years = []
        data_rows = []
        # 최근 analysis_period년 역산
        import datetime as dt
        end_year = dt.datetime.now().year - 1
        for y in range(end_year - analysis_period + 1, end_year + 1):
            j = self.dart.singl_acnt_all(corp_code=corp_code, bsns_year=str(y), reprt_code=reprt_code, fs_div=fs_div)
            if j.get('status') != '000':
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
            rev = pick('손익계산서', ['매출액','수익\\(매출액\\)','영업수익'])
            op = pick('손익계산서', ['영업이익'])
            net = pick('손익계산서', ['당기순이익','당기순이익\\(손실\\)'])
            years.append(y)
            data_rows.append({"year": y, "매출액": rev, "영업이익": op, "순이익": net})
        return {"ok": True, "data": {"years": years, "series": data_rows}}

    def generate_summary_report(self, title: str, content: str) -> Dict[str, Any]:
        return {"ok": True, "data": {"title": title, "content": content}}

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
