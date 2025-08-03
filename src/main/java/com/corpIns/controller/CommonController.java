package com.corpIns.controller;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CommonController {
    @GetMapping("/compare")
    public String comparePage() {
        return "compare"; // /WEB-INF/views/compare.jsp
    }

    @GetMapping("/chatBot")
    public String chatBot() {
        return "chatBot"; // /WEB-INF/views/chatBot.jsp
    }


    @GetMapping("/home")
    public String homePage() {
        return "main"; // 예: main.jsp
    }

}
