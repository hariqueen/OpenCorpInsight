import requests
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
import json
from datetime import datetime
import boto3
from botocore.exceptions import ClientError

def get_secret():
    """AWS Secrets Manager에서 DART API 키 가져오기"""
    secret_name = "DART_API_KEY"
    region_name = "ap-northeast-2"
    
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    
    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
        secret = get_secret_value_response['SecretString']
        
        try:
            secret_dict = json.loads(secret)
            return secret_dict.get('DART_API_KEY')
        except:
            return secret
            
    except ClientError as e:
        print(f"AWS Secrets Manager 오류: {e}")
        raise e

class DartDashboard:
    def __init__(self, api_key=None):
        if api_key is None:
            self.api_key = get_secret()
        else:
            self.api_key = api_key
        self.base_url = "https://opendart.fss.or.kr/api"
        print(f"🔑 DART API 초기화 완료")
    
    def get_financial_data(self, corp_code, year="2023"):
        """재무지표 조회"""
        url = f"{self.base_url}/fnlttSinglAcntAll.json"
        params = {
            'crtfc_key': self.api_key,
            'corp_code': corp_code,
            'bsns_year': year,
            'reprt_code': '11011',
            'fs_div': 'CFS'  # 연결재무제표
        }
        
        try:
            response = requests.get(url, params=params)
            data = response.json()
            print(f"{year}년 재무지표 API 응답: {data.get('status')}")
            return data.get('list', []) if data.get('status') == '000' else []
        except Exception as e:
            print(f"API 호출 오류: {e}")
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
                'reprt_code': '11011',
                'fs_div': 'CFS'  # 연결재무제표
            }
            
            try:
                response = requests.get(url, params=params)
                data = response.json()
                all_data[year] = data.get('list', []) if data.get('status') == '000' else []
                print(f"{year}년 데이터: {len(all_data[year])}개 계정")
            except Exception as e:
                print(f"{year}년 데이터 오류: {e}")
                all_data[year] = []
        
        return all_data
    
    def extract_metrics(self, financial_data):
        """핵심 지표 추출 (실제 DART 데이터 기반)"""
        metrics = {
            'roe': 0, 'debt_ratio': 0, 'current_ratio': 0,
            'revenue': 0, 'operating_profit': 0, 'net_profit': 0
        }
        
        if not financial_data:
            print("재무데이터가 없습니다.")
            return metrics
        
        # DataFrame으로 변환
        df = pd.DataFrame(financial_data)
        print(f"🔍 총 {len(df)}개 계정 발견")
        
        try:
            # 1. 매출액 (영업수익)
            revenue_items = df[df['account_nm'].str.contains('영업수익|매출액', na=False)]
            if not revenue_items.empty:
                metrics['revenue'] = float(revenue_items.iloc[0]['thstrm_amount'])
                print(f"매출액: {metrics['revenue']:,.0f}원")
            
            # 2. 영업이익
            op_profit_items = df[df['account_nm'].str.contains('영업이익', na=False)]
            if not op_profit_items.empty:
                metrics['operating_profit'] = float(op_profit_items.iloc[0]['thstrm_amount'])
                print(f"영업이익: {metrics['operating_profit']:,.0f}원")
            
            # 3. 당기순이익
            net_profit_items = df[df['account_nm'].str.contains('당기순이익', na=False)]
            if not net_profit_items.empty:
                metrics['net_profit'] = float(net_profit_items.iloc[0]['thstrm_amount'])
                print(f"당기순이익: {metrics['net_profit']:,.0f}원")
            
            # 4. 자산총계, 부채총계로 부채비율 계산
            assets_items = df[df['account_nm'].str.contains('자산총계', na=False)]
            liabilities_items = df[df['account_nm'].str.contains('부채총계', na=False)]
            
            if not assets_items.empty and not liabilities_items.empty:
                total_assets = float(assets_items.iloc[0]['thstrm_amount'])
                total_liabilities = float(liabilities_items.iloc[0]['thstrm_amount'])
                metrics['debt_ratio'] = (total_liabilities / total_assets) * 100
                print(f"부채비율: {metrics['debt_ratio']:.1f}%")
            
            # 5. 유동자산, 유동부채로 유동비율 계산
            current_assets_items = df[df['account_nm'].str.contains('유동자산', na=False)]
            current_liabilities_items = df[df['account_nm'].str.contains('유동부채', na=False)]
            
            if not current_assets_items.empty and not current_liabilities_items.empty:
                current_assets = float(current_assets_items.iloc[0]['thstrm_amount'])
                current_liabilities = float(current_liabilities_items.iloc[0]['thstrm_amount'])
                metrics['current_ratio'] = (current_assets / current_liabilities) * 100
                print(f"유동비율: {metrics['current_ratio']:.1f}%")
            
            # 6. ROE 계산 (당기순이익 / 자본총계 * 100)
            equity_items = df[df['account_nm'].str.contains('자본총계', na=False)]
            
            if not equity_items.empty and metrics['net_profit'] > 0:
                total_equity = float(equity_items.iloc[0]['thstrm_amount'])
                metrics['roe'] = (metrics['net_profit'] / total_equity) * 100
                print(f"ROE: {metrics['roe']:.1f}%")
            
            print("\n최종 추출된 지표:")
            for key, value in metrics.items():
                if value > 0:
                    print(f"  - {key}: {value:,.1f}")
                    
        except Exception as e:
            print(f"지표 추출 중 오류: {e}")
        
        return metrics
    
    def create_health_chart(self, metrics, corp_name):
        """직관적인 재무 건전성 바 차트"""
        # 점수 계산 (0-100)
        roe_score = min(100, max(0, metrics['roe'] * 5))  # ROE 20% = 100점
        debt_score = min(100, max(0, 100 - metrics['debt_ratio']))  # 부채비율 낮을수록 좋음
        current_score = min(100, max(0, metrics['current_ratio'] / 2))  # 유동비율 200% = 100점
        
        categories = ['수익성<br>(ROE)', '안정성<br>(부채비율)', '유동성<br>(유동비율)']
        scores = [roe_score, debt_score, current_score]
        
        # 점수에 따른 색상 (좋음=초록, 보통=노랑, 나쁨=빨강)
        colors = ['#2E8B57' if s >= 70 else '#FFD700' if s >= 40 else '#FF6B6B' for s in scores]
        
        print(f"📊 건전성 점수: ROE={roe_score:.1f}, 부채={debt_score:.1f}, 유동성={current_score:.1f}")
        
        fig = go.Figure(data=[
            go.Bar(x=categories, y=scores, 
                   text=[f'{s:.0f}점' for s in scores],
                   textposition='auto',
                   marker_color=colors)
        ])
        
        fig.update_layout(
            title=f"{corp_name} 재무 건전성 점수",
            yaxis_title="점수 (0-100점)",
            yaxis=dict(range=[0, 100]),
            showlegend=False,
            height=400,
            font=dict(size=14)
        )
        
        return fig
    
    def create_growth_chart(self, multi_year_data, corp_name):
        """간단한 성장 막대 차트 (숫자 파싱 오류 수정)"""
        years, revenues, profits = [], [], []
        
        for year, data in multi_year_data.items():
            if data:
                # 숫자 파싱 오류 수정
                df = pd.DataFrame(data)
                
                try:
                    # 매출액 찾기
                    revenue_items = df[df['account_nm'].str.contains('영업수익|매출액', na=False)]
                    if not revenue_items.empty:
                        # 콤마 제거 후 숫자 변환
                        revenue_str = str(revenue_items.iloc[0]['thstrm_amount'])
                        revenue = float(revenue_str.replace(',', ''))
                        
                        # 영업이익 찾기
                        profit_items = df[df['account_nm'].str.contains('영업이익', na=False)]
                        if not profit_items.empty:
                            profit_str = str(profit_items.iloc[0]['thstrm_amount'])
                            profit = float(profit_str.replace(',', ''))
                            
                            years.append(year)
                            revenues.append(revenue / 1000000000000)  # 조원 단위
                            profits.append(profit / 1000000000000)
                            
                            print(f"{year}년: 매출 {revenue/1000000000000:.1f}조, 영업이익 {profit/1000000000000:.1f}조")
                            
                except Exception as e:
                    print(f"{year}년 데이터 파싱 오류: {e}")
        
        print(f"📈 성장 데이터: {len(years)}개년 ({years})")
        
        # 막대 차트로 변경 (더 직관적)
        fig = go.Figure()
        
        # 매출액 막대
        fig.add_trace(go.Bar(
            name='매출액',
            x=years,
            y=revenues,
            marker_color='lightblue',
            text=[f'{r:.1f}조' for r in revenues],
            textposition='auto'
        ))
        
        # 영업이익 막대  
        fig.add_trace(go.Bar(
            name='영업이익',
            x=years,
            y=profits,
            marker_color='orange',
            text=[f'{p:.1f}조' for p in profits],
            textposition='auto'
        ))
        
        fig.update_layout(
            title=f"{corp_name} 3년 성장 추이 (막대 차트)",
            xaxis_title="연도",
            yaxis_title="금액 (조원)",
            barmode='group',
            height=400,
            hovermode='x unified'
        )
        
        return fig
    
    def generate_dashboard(self, corp_code, corp_name="기업"):
        """대시보드 데이터 생성 (실제 API 데이터)"""
        print(f"\n🏢 {corp_name} 재무 분석 시작...")
        print("=" * 50)
        
        # 최신 재무지표 조회
        print("2023년 재무지표 조회 중...")
        current_data = self.get_financial_data(corp_code)
        current_metrics = self.extract_metrics(current_data)
        
        # 3개년 데이터 조회
        print("3개년 트렌드 데이터 조회 중...")
        multi_year = self.get_multi_year_data(corp_code)
        
        # 차트 생성
        print("차트 생성 중...")
        health_chart = self.create_health_chart(current_metrics, corp_name)
        growth_chart = self.create_growth_chart(multi_year, corp_name)
        
        # 핵심 지표 요약
        print("\n💡 핵심 지표 요약:")
        print(f"   ROE: {current_metrics['roe']:.1f}%")
        print(f"   부채비율: {current_metrics['debt_ratio']:.1f}%")
        print(f"   유동비율: {current_metrics['current_ratio']:.1f}%")
        print(f"   매출액: {current_metrics['revenue']/1000000000000:.1f}조원")
        print(f"   영업이익: {current_metrics['operating_profit']/1000000000000:.1f}조원")
        
        # 차트를 한 화면에 표시
        print(" 통합 대시보드 표시 중...")
        
        # 서브플롯으로 두 차트를 한 화면에 표시
        from plotly.subplots import make_subplots
        
        # 2행 1열 구성
        combined_fig = make_subplots(
            rows=2, cols=1,
            subplot_titles=(f'{corp_name} 재무 건전성 점수', f'{corp_name} 3년 성장 추이'),
            vertical_spacing=0.12,
            specs=[[{"type": "bar"}], [{"type": "bar"}]]
        )
        
        # 건전성 차트 데이터 추가 (상단)
        roe_score = min(100, max(0, current_metrics['roe'] * 5))
        debt_score = min(100, max(0, 100 - current_metrics['debt_ratio']))
        current_score = min(100, max(0, current_metrics['current_ratio'] / 2))
        
        categories = ['수익성<br>(ROE)', '안정성<br>(부채비율)', '유동성<br>(유동비율)']
        scores = [roe_score, debt_score, current_score]
        colors = ['#2E8B57' if s >= 70 else '#FFD700' if s >= 40 else '#FF6B6B' for s in scores]
        
        combined_fig.add_trace(
            go.Bar(x=categories, y=scores, 
                   text=[f'{s:.0f}점' for s in scores],
                   textposition='auto',
                   marker_color=colors,
                   showlegend=False),
            row=1, col=1
        )
        
        # 성장 차트 데이터 추가 (하단)
        years, revenues, profits = [], [], []
        
        for year, data in multi_year.items():
            if data:
                df = pd.DataFrame(data)
                try:
                    revenue_items = df[df['account_nm'].str.contains('영업수익|매출액', na=False)]
                    profit_items = df[df['account_nm'].str.contains('영업이익', na=False)]
                    
                    if not revenue_items.empty and not profit_items.empty:
                        revenue_str = str(revenue_items.iloc[0]['thstrm_amount'])
                        profit_str = str(profit_items.iloc[0]['thstrm_amount'])
                        
                        revenue = float(revenue_str.replace(',', ''))
                        profit = float(profit_str.replace(',', ''))
                        
                        years.append(year)
                        revenues.append(revenue / 1000000000000)  # 조원 단위
                        profits.append(profit / 1000000000000)
                except:
                    pass
        
        # 매출액 막대 (하단)
        combined_fig.add_trace(
            go.Bar(x=years, y=revenues, 
                   name='매출액',
                   marker_color='lightblue',
                   text=[f'{r:.1f}조' for r in revenues],
                   textposition='auto'),
            row=2, col=1
        )
        
        # 영업이익 막대 (하단)
        combined_fig.add_trace(
            go.Bar(x=years, y=profits,
                   name='영업이익', 
                   marker_color='orange',
                   text=[f'{p:.1f}조' for p in profits],
                   textposition='auto'),
            row=2, col=1
        )
        
        # 레이아웃 업데이트
        combined_fig.update_layout(
            height=800,
            title_text=f"📊 {corp_name} 종합 재무 대시보드",
            title_x=0.5,
            showlegend=True
        )
        
        # y축 설정
        combined_fig.update_yaxes(title_text="점수 (0-100점)", range=[0, 100], row=1, col=1)
        combined_fig.update_yaxes(title_text="금액 (조원)", row=2, col=1)
        combined_fig.update_xaxes(title_text="재무지표", row=1, col=1)
        combined_fig.update_xaxes(title_text="연도", row=2, col=1)
        
        # 통합 차트 표시
        combined_fig.show()
        
        return current_metrics

# 사용 예시
if __name__ == "__main__":
    try:
        print("🚀 OpenCorpInsight 대시보드 시작")
        print("AWS Secrets Manager에서 API 키 로드 중...")
        
        # AWS에서 API 키 자동으로 가져와서 대시보드 생성
        dashboard = DartDashboard()
        
        # 삼성전자 분석 (실제 DART API 데이터)
        result = dashboard.generate_dashboard("00126380", "삼성전자")
        
        print("대시보드 생성 완료!")
        print(f"ROE: {result['roe']:.1f}%, 부채비율: {result['debt_ratio']:.1f}%, 유동비율: {result['current_ratio']:.1f}%")
        
    except Exception as e:
        print(f"오류 발생: {e}")
        print("\n🔧 해결 방법:")
        print("1. AWS 자격 증명 확인: aws sts get-caller-identity")
        print("2. DART API 키가 AWS Secrets Manager에 제대로 저장되었는지 확인")
        print("3. 네트워크 연결 상태 확인")