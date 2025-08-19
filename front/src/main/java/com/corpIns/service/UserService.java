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
    private final Map<String, User> mockUsers = new HashMap<>();

    @Autowired
    public UserService(UserMapper userMapper, PasswordEncoder passwordEncoder) {
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
        
        // Mock 데이터 초기화
        initializeMockUsers();
    }

    private void initializeMockUsers() {
        // 테스트용 사용자 생성
        User testUser1 = new User();
        testUser1.setEmail("test@test.com");
        testUser1.setPasswordHash(passwordEncoder.encode("1234"));
        mockUsers.put("test@test.com", testUser1);

        User testUser2 = new User();
        testUser2.setEmail("admin@admin.com");
        testUser2.setPasswordHash(passwordEncoder.encode("admin"));
        mockUsers.put("admin@admin.com", testUser2);

        System.out.println("🔐 Mock 사용자 데이터 초기화 완료");
        System.out.println("📧 test@test.com / 1234");
        System.out.println("📧 admin@admin.com / admin");
    }

    public User findByEmail(String email) {
        // Mock 데이터에서 사용자 찾기
        User mockUser = mockUsers.get(email);
        if (mockUser != null) {
            System.out.println("🔍 Mock 사용자 찾음: " + email);
            return mockUser;
        }
        
        // DB에서도 찾기 (실제 DB가 있는 경우)
        try {
            return userMapper.selectUserByEmail(email);
        } catch (Exception e) {
            System.out.println("⚠️ DB 조회 실패, Mock 데이터만 사용: " + e.getMessage());
            return null;
        }
    }

    public void insertUser(Map<String, Object> userData) {
        String email = (String) userData.get("email");
        String passwordHash = (String) userData.get("password_hash");
        
        // Mock 데이터에 사용자 추가
        User newUser = new User();
        newUser.setEmail(email);
        newUser.setPasswordHash(passwordHash);
        mockUsers.put(email, newUser);
        
        System.out.println("✅ Mock 사용자 등록 완료: " + email);
        
        // DB에도 저장 시도 (실제 DB가 있는 경우)
        try {
            userMapper.insertUser(userData);
            System.out.println("💾 DB 저장도 완료: " + email);
        } catch (Exception e) {
            System.out.println("⚠️ DB 저장 실패, Mock 데이터만 사용: " + e.getMessage());
        }
    }

    // Mock 데이터 조회 메서드 (디버깅용)
    public void printMockUsers() {
        System.out.println("📋 현재 Mock 사용자 목록:");
        for (String email : mockUsers.keySet()) {
            System.out.println("  - " + email);
        }
    }
}
