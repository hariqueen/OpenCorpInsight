package com.corpIns.mapper;

import com.corpIns.dto.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserMapper {
    User selectUserByEmailAndPasswordHash(@Param("email") String email, @Param("password_hash") String password_hash);
}