package com.corpIns.service;

import com.corpIns.dto.User;
import com.corpIns.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class UserService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    // Mock 데이터 - 테스트용 사용자
    @Autowired
    public UserService(UserMapper userMapper, PasswordEncoder passwordEncoder) {
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
    }

    public User findByEmail(String email) {
        // DB에서 사용자 찾기
        try {
            User user = userMapper.selectUserByEmail(email);
            if (user != null) {
                System.out.println("🔍 DB에서 사용자 찾음: " + email);
            }
            return user;
        } catch (Exception e) {
            System.out.println("⚠️ DB 조회 실패: " + e.getMessage());
            return null;
        }
    }

    public void insertUser(Map<String, Object> userData) {
        String email = (String) userData.get("email");
        String passwordHash = (String) userData.get("password_hash");
        
        // DB에 사용자 저장
        try {
            userMapper.insertUser(userData);
            System.out.println("💾 DB 저장 완료: " + email);
        } catch (Exception e) {
            System.out.println("⚠️ DB 저장 실패: " + e.getMessage());
        }
    }
}
