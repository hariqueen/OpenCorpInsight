package com.corpIns.service;

import com.corpIns.dto.User;
import com.corpIns.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserMapper userMapper;

    @Autowired
    public UserService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }
    public User findByEmailAndPassword(String email, String password_hash) {
        return userMapper.selectUserByEmailAndPasswordHash(email, password_hash);
    }
}
