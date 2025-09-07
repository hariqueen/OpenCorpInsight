# ========== app.py (메인 Flask 애플리케이션) ==========
from flask import Flask, jsonify, request
from flask_cors import CORS
import sqlite3
import os
from datetime import datetime
import hashlib

app = Flask(__name__)
CORS(app)  # 모든 도메인에서 접근 허용

# 데이터베이스 파일 경로
DB_PATH = os.path.join(os.path.dirname(__file__), 'chatbot.db')  # 현재 디렉토리의 chatbot.db

def get_db_connection():
    """SQLite 데이터베이스 연결"""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row  # 딕셔너리 형태로 결과 반환
    return conn

def dict_from_row(row):
    """SQLite Row 객체를 딕셔너리로 변환"""
    return dict(row) if row else None

# ========== 테스트 API ==========

@app.route('/api/test', methods=['GET'])
def test_connection():
    """API 연결 테스트"""
    return jsonify({
        'status': 'success',
        'message': 'API 연결 성공!',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/test/db', methods=['GET'])
def test_database():
    """데이터베이스 연결 테스트"""
    try:
        conn = get_db_connection()
        
        # 각 테이블의 레코드 수 조회
        users_count = conn.execute('SELECT COUNT(*) as count FROM users').fetchone()['count']
        user_details_count = conn.execute('SELECT COUNT(*) as count FROM user_details').fetchone()['count']
        chat_messages_count = conn.execute('SELECT COUNT(*) as count FROM chat_messages').fetchone()['count']
        
        conn.close()
        
        return jsonify({
            'status': 'success',
            'message': 'DB 연결 성공!',
            'data': {
                'users_count': users_count,
                'user_details_count': user_details_count,
                'chat_messages_count': chat_messages_count
            }
        })
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'DB 연결 실패: {str(e)}'
        }), 500

# ========== 사용자 관련 API ==========

@app.route('/api/users', methods=['GET'])
def get_all_users():
    """모든 사용자 조회"""
    try:
        conn = get_db_connection()
        users = conn.execute('''
            SELECT u.*, ud.nickname, ud.difficulty, ud.interest, ud.purpose 
            FROM users u 
            LEFT JOIN user_details ud ON u.user_sno = ud.user_sno
            WHERE u.is_active = 'Y'
            ORDER BY u.created_at DESC
        ''').fetchall()
        conn.close()
        
        users_list = [dict_from_row(user) for user in users]
        
        return jsonify({
            'status': 'success',
            'data': users_list,
            'count': len(users_list)
        })
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/users/<int:user_sno>', methods=['GET'])
def get_user_by_id(user_sno):
    """특정 사용자 조회"""
    try:
        conn = get_db_connection()
        user = conn.execute('''
            SELECT u.*, ud.nickname, ud.difficulty, ud.interest, ud.purpose 
            FROM users u 
            LEFT JOIN user_details ud ON u.user_sno = ud.user_sno 
            WHERE u.user_sno = ? AND u.is_active = 'Y'
        ''', (user_sno,)).fetchone()
        conn.close()
        
        if user:
            return jsonify({
                'status': 'success',
                'data': dict_from_row(user)
            })
        else:
            return jsonify({
                'status': 'error',
                'message': '사용자를 찾을 수 없습니다.'
            }), 404
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/users', methods=['POST'])
def create_user():
    """새 사용자 생성"""
    try:
        data = request.get_json()
        
        # 필수 필드 검증
        if not data.get('email'):
            return jsonify({
                'status': 'error',
                'message': '이메일은 필수입니다.'
            }), 400
        
        conn = get_db_connection()
        
        # 사용자 생성
        cursor = conn.execute('''
            INSERT INTO users (provider, provider_id, name, email, password_hash)
            VALUES (?, ?, ?, ?, ?)
        ''', (
            data.get('provider', 'local'),
            data.get('provider_id'),
            data.get('name'),
            data.get('email'),
            data.get('password_hash')
        ))
        
        user_sno = cursor.lastrowid
        
        # 사용자 상세 정보가 있으면 추가
        if any(key in data for key in ['nickname', 'difficulty', 'interest', 'purpose']):
            conn.execute('''
                INSERT INTO user_details (user_sno, nickname, difficulty, interest, purpose)
                VALUES (?, ?, ?, ?, ?)
            ''', (
                user_sno,
                data.get('nickname'),
                data.get('difficulty'),
                data.get('interest'),
                data.get('purpose')
            ))
        
        conn.commit()
        conn.close()
        
        return jsonify({
            'status': 'success',
            'message': '사용자가 생성되었습니다.',
            'data': {'user_sno': user_sno}
        }), 201
        
    except sqlite3.IntegrityError as e:
        return jsonify({
            'status': 'error',
            'message': '이미 존재하는 이메일입니다.'
        }), 400
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

# ========== 채팅 메시지 관련 API ==========

@app.route('/api/chat', methods=['GET'])
def get_all_chat_messages():
    """모든 채팅 메시지 조회"""
    try:
        conn = get_db_connection()
        
        # 페이지네이션 파라미터
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 50, type=int)
        offset = (page - 1) * per_page
        
        messages = conn.execute('''
            SELECT cm.*, u.name, u.email 
            FROM chat_messages cm
            LEFT JOIN users u ON cm.user_sno = u.user_sno
            ORDER BY cm.created_at DESC
            LIMIT ? OFFSET ?
        ''', (per_page, offset)).fetchall()
        
        total_count = conn.execute('SELECT COUNT(*) as count FROM chat_messages').fetchone()['count']
        conn.close()
        
        messages_list = [dict_from_row(msg) for msg in messages]
        
        return jsonify({
            'status': 'success',
            'data': messages_list,
            'pagination': {
                'page': page,
                'per_page': per_page,
                'total': total_count,
                'pages': (total_count + per_page - 1) // per_page
            }
        })
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/chat/user/<int:user_sno>', methods=['GET'])
def get_user_chat_history(user_sno):
    """특정 사용자의 채팅 기록 조회"""
    try:
        conn = get_db_connection()
        messages = conn.execute('''
            SELECT * FROM chat_messages 
            WHERE user_sno = ? 
            ORDER BY created_at ASC
        ''', (user_sno,)).fetchall()
        conn.close()
        
        messages_list = [dict_from_row(msg) for msg in messages]
        
        return jsonify({
            'status': 'success',
            'data': messages_list,
            'count': len(messages_list)
        })
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/chat', methods=['POST'])
def save_chat_message():
    """새 채팅 메시지 저장"""
    try:
        data = request.get_json()
        
        # 필수 필드 검증
        required_fields = ['user_sno', 'content', 'role']
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'status': 'error',
                    'message': f'{field}는 필수입니다.'
                }), 400
        
        # role 검증
        if data['role'] not in ['user', 'assistant']:
            return jsonify({
                'status': 'error',
                'message': 'role은 user 또는 assistant여야 합니다.'
            }), 400
        
        conn = get_db_connection()
        cursor = conn.execute('''
            INSERT INTO chat_messages (user_sno, content, role)
            VALUES (?, ?, ?)
        ''', (data['user_sno'], data['content'], data['role']))
        
        message_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return jsonify({
            'status': 'success',
            'message': '채팅 메시지가 저장되었습니다.',
            'data': {'message_id': message_id}
        }), 201
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/chat/conversation/<int:user_sno>', methods=['GET'])
def get_conversation_format(user_sno):
    """대화 형태로 포맷된 채팅 기록 조회"""
    try:
        conn = get_db_connection()
        messages = conn.execute('''
            SELECT content, role, created_at 
            FROM chat_messages 
            WHERE user_sno = ? 
            ORDER BY created_at ASC
        ''', (user_sno,)).fetchall()
        conn.close()
        
        conversation = []
        for msg in messages:
            conversation.append({
                'content': msg['content'],
                'role': msg['role'],
                'timestamp': msg['created_at']
            })
        
        return jsonify({
            'status': 'success',
            'data': {
                'user_sno': user_sno,
                'conversation': conversation
            },
            'count': len(conversation)
        })
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/chat/<int:message_id>', methods=['DELETE'])
def delete_chat_message(message_id):
    """채팅 메시지 삭제"""
    try:
        conn = get_db_connection()
        cursor = conn.execute('DELETE FROM chat_messages WHERE message_id = ?', (message_id,))
        conn.commit()
        
        if cursor.rowcount > 0:
            conn.close()
            return jsonify({
                'status': 'success',
                'message': '메시지가 삭제되었습니다.'
            })
        else:
            conn.close()
            return jsonify({
                'status': 'error',
                'message': '메시지를 찾을 수 없습니다.'
            }), 404
            
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

# ========== 통계 API ==========

@app.route('/api/stats', methods=['GET'])
def get_statistics():
    """전체 통계 조회"""
    try:
        conn = get_db_connection()
        
        # 사용자 통계
        total_users = conn.execute('SELECT COUNT(*) as count FROM users WHERE is_active = "Y"').fetchone()['count']
        total_messages = conn.execute('SELECT COUNT(*) as count FROM chat_messages').fetchone()['count']
        
        # 최근 7일 신규 사용자
        recent_users = conn.execute('''
            SELECT COUNT(*) as count FROM users 
            WHERE is_active = "Y" AND created_at >= datetime('now', '-7 days')
        ''').fetchone()['count']
        
        # 최근 7일 메시지
        recent_messages = conn.execute('''
            SELECT COUNT(*) as count FROM chat_messages 
            WHERE created_at >= datetime('now', '-7 days')
        ''').fetchone()['count']
        
        conn.close()
        
        return jsonify({
            'status': 'success',
            'data': {
                'total_users': total_users,
                'total_messages': total_messages,
                'recent_users': recent_users,
                'recent_messages': recent_messages
            }
        })
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

# ========== 에러 핸들러 ==========

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'status': 'error',
        'message': 'API 엔드포인트를 찾을 수 없습니다.'
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        'status': 'error',
        'message': '서버 내부 오류가 발생했습니다.'
    }), 500


if __name__ == '__main__':
    print("데이터베이스 파일 확인:", DB_PATH)
    print("   - http://localhost:5002/api/test")
    print("   - http://localhost:5002/api/test/db") 
    print("   - http://localhost:5002/api/users")
    print("   - http://localhost:5002/api/chat")
    print("   - http://localhost:5002/api/chat/conversation/<user_sno>")
    
    app.run(host='0.0.0.0', port=5002, debug=False)
