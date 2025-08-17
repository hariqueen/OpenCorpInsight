package com.corpIns.service;

import com.corpIns.dto.User;
import com.corpIns.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class UserService {

    private final UserMapper userMapper;

    @Autowired
    public UserService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public User findByEmail(String email) {
        return userMapper.selectUserByEmail(email);
    }

    public void insertUser(Map<String, Object> userData) {
        userMapper.insertUser(userData);
    }
}
