package com.corpIns.mapper;

import com.corpIns.dto.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.Map;

@Mapper
public interface UserMapper {
    User selectUserByEmail(@Param("email") String email);

    void insertUser(Map<String, Object> userData);
    
    void updateUserProfile(Map<String, Object> userData);
    
    Map<String, Object> getUserProfile(int userSno);
}
