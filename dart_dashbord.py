import requests
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
import json
from datetime import datetime

class DartDashboard:
    def __init__(self, api_key):
        self.api_key = api_key
        self.base_url = "https://opendart.fss.or.kr/api"
    
    def get_financial_data(self, corp_code, year="2023"):
        """재무지표 조회"""
        url = f"{self.base_url}/fnlttSinglAcntAll.json"
        params = {
            'crtfc_key': self.api_key,
            'corp_code': corp_code,
            'bsns_year': year,
            'reprt_code': '11011'
        }
        
        try:
            response = requests.get(url, params=params)
            data = response.json()
            return data.get('list', []) if data.get('status') == '000' else []
        except:
            return []
    
    def get_multi_year_data(self, corp_code, years=[2021, 2022, 2023]):
        """3개년 데이터 조회"""
        url = f"{self.base_url}/fnlttSinglAcnt.json"
        all_data = {}
        
        for year in years:
            params = {
                'crtfc_key': self.api_key,
                'corp_code': corp_code,
                'bsns_year': str(year),
                'reprt_code': '11011'
            }
            
            try:
                response = requests.get(url, params=params)
                data = response.json()
                all_data[year] = data.get('list', []) if data.get('status') == '000' else []
            except:
                all_data[year] = []
        
        return all_data
    
    def extract_metrics(self, financial_data):
        """핵심 지표 추출"""
        metrics = {
            'roe': 0, 'debt_ratio': 0, 'current_ratio': 0,
            'revenue': 0, 'operating_profit': 0, 'net_profit': 0
        }
        
        if not financial_data:
            return metrics
        
        df = pd.DataFrame(financial_data)
        
        try:
            # ROE
            roe = df[df['account_nm'].str.contains('자기자본이익률', na=False)]
            if not roe.empty:
                metrics['roe'] = float(roe.iloc[0]['thstrm_amount'])
            
            # 부채비율
            debt = df[df['account_nm'].str.contains('부채비율', na=False)]
            if not debt.empty:
                metrics['debt_ratio'] = float(debt.iloc[0]['thstrm_amount'])
            
            # 유동비율
            current = df[df['account_nm'].str.contains('유동비율', na=False)]
            if not current.empty:
                metrics['current_ratio'] = float(current.iloc[0]['thstrm_amount'])
            
            # 매출액
            revenue = df[df['account_nm'].str.contains('매출액', na=False)]
            if not revenue.empty:
                metrics['revenue'] = float(revenue.iloc[0]['thstrm_amount'])
            
            # 영업이익
            op_profit = df[df['account_nm'].str.contains('영업이익', na=False)]
            if not op_profit.empty:
                metrics['operating_profit'] = float(op_profit.iloc[0]['thstrm_amount'])
        except:
            pass
        
        return metrics
    
    def create_health_chart(self, metrics, corp_name):
        """재무 건전성 레이더 차트"""
        roe_score = min(100, max(0, metrics['roe'] * 5))
        debt_score = min(100, max(0, 100 - metrics['debt_ratio']))
        current_score = min(100, max(0, metrics['current_ratio'] / 2))
        
        fig = go.Figure()
        fig.add_trace(go.Scatterpolar(
            r=[roe_score, debt_score, current_score],
            theta=['수익성(ROE)', '안정성(부채비율)', '유동성(유동비율)'],
            fill='toself',
            name=corp_name,
            line_color='rgb(0, 123, 255)'
        ))
        
        fig.update_layout(
            polar=dict(radialaxis=dict(visible=True, range=[0, 100])),
            title=f"{corp_name} 재무 건전성",
            showlegend=False
        )
        
        return fig
    
    def create_growth_chart(self, multi_year_data, corp_name):
        """성장 트렌드 차트"""
        years, revenues, profits = [], [], []
        
        for year, data in multi_year_data.items():
            if data:
                metrics = self.extract_metrics(data)
                years.append(year)
                revenues.append(metrics['revenue'] / 100000000)  # 억원
                profits.append(metrics['operating_profit'] / 100000000)
        
        fig = make_subplots(specs=[[{"secondary_y": True}]])
        
        fig.add_trace(
            go.Scatter(x=years, y=revenues, name="매출액", 
                      line=dict(color='blue', width=3)),
            secondary_y=False
        )
        
        fig.add_trace(
            go.Scatter(x=years, y=profits, name="영업이익",
                      line=dict(color='red', width=3)),
            secondary_y=True
        )
        
        fig.update_layout(title=f"{corp_name} 3년 성장 트렌드")
        fig.update_yaxes(title_text="매출액 (억원)", secondary_y=False)
        fig.update_yaxes(title_text="영업이익 (억원)", secondary_y=True)
        
        return fig
    
    def generate_dashboard(self, corp_code, corp_name="기업"):
        """대시보드 데이터 생성"""
        print(f" {corp_name} 분석 시작...")
        
        current_data = self.get_financial_data(corp_code)
        multi_year = self.get_multi_year_data(corp_code)
        current_metrics = self.extract_metrics(current_data)
        health_chart = self.create_health_chart(current_metrics, corp_name)
        growth_chart = self.create_growth_chart(multi_year, corp_name)
        
        print(f"ROE: {current_metrics['roe']:.1f}%")
        print(f"부채비율: {current_metrics['debt_ratio']:.1f}%")
        print(f"유동비율: {current_metrics['current_ratio']:.1f}%")
        
        # 차트 표시
        health_chart.show()
        growth_chart.show()
        
        # JSON 데이터 반환 (Cloudflare용)
        dashboard_data = {
            "company": corp_name,
            "metrics": current_metrics,
            "health_chart": health_chart.to_json(),
            "growth_chart": growth_chart.to_json(),
            "updated": datetime.now().isoformat()
        }
        
        return dashboard_data
if __name__ == "__main__":
    API_KEY = "YOUR_DART_API_KEY_HERE"
    dashboard = DartDashboard(API_KEY)
    result = dashboard.generate_dashboard("00126380", "삼성전자")
    
    # JSON 저장 (Cloudflare에서 사용)
    with open('dashboard_output.json', 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)