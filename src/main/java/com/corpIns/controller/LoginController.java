package com.corpIns.controller;

import com.corpIns.dto.User;
import com.corpIns.service.UserService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.Map;

@Controller
public class LoginController {
    private final UserService userService;
    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    public LoginController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/login")
    public String comparePage() {
        return "login/login"; // /WEB-INF/views/login/login.jsp
    }

    @GetMapping("/join")
    public String chatBot() {
        return "login/join"; // /WEB-INF/views/login/join.jsp
    }

    @GetMapping("/setProfile")
    public String setProfile() {
        return "login/setProfile"; // /WEB-INF/views/login/setProfile.jsp
    }

    @GetMapping("/joinAction")
    public String joinAction() {
        return "login/joinAction"; // /WEB-INF/views/login/joinAction.jsp
    }

    @PostMapping("/joinAction")
    @ResponseBody
    public Map<String, Object> joinAction(
            @RequestParam String email,
            @RequestParam String password,
            @RequestParam String confirmPassword) {

        Map<String, Object> result = new HashMap<>();

        try {
            if (password == null || password.isEmpty()) {
                throw new IllegalArgumentException("비밀번호를 입력하세요.");
            }
            if (!password.equals(confirmPassword)) {
                throw new IllegalArgumentException("비밀번호가 일치하지 않습니다.");
            }

            // 비밀번호 암호화
            String passwordHash = passwordEncoder.encode(password);

            // DB 저장 파라미터
            Map<String, Object> param = new HashMap<>();
            param.put("email", email);
            param.put("password_hash", passwordHash);

            // 유저 저장
            userService.insertUser(param);

            result.put("status", "success");
        } catch (Exception e) {
            result.put("status", "fail");
            result.put("message", e.getMessage());
        }
        return result;
    }



    @PostMapping("/loginAction")
    @ResponseBody
    public Map<String, Object> loginAction(@RequestParam String email,
                                           @RequestParam String password,
                                           HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = userService.findByEmail(email);

        if (user != null && passwordEncoder.matches(password, user.getPasswordHash())) {
            session.setAttribute("loginUser", user);
            result.put("status", "success");
        } else {
            result.put("status", "fail");
            result.put("message", "아이디 또는 비밀번호가 올바르지 않습니다.");
        }
        return result;
    }


    @PostMapping("/logout")
    @ResponseBody
    public Map<String, String> logout(HttpSession session) {
        session.invalidate();
        Map<String, String> result = new HashMap<>();
        result.put("status", "ok");
        return result;
    }



}
