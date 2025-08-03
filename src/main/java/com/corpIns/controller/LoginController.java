package com.corpIns.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class LoginController {
    @GetMapping("/login")
    public String comparePage() {
        return "login/login"; // /WEB-INF/views/login/login.jsp
    }

    @GetMapping("/join")
    public String chatBot() {
        return "login/join"; // /WEB-INF/views/login/join.jsp
    }

}
