package com.corpIns.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class CommonController {
    @GetMapping("/compare")
    public String comparePage() {
        return "common/compare"; // /WEB-INF/views/common/compare.jsp
    }

    @GetMapping("/chatBot")
    public String chatBot() {
        return "common/chatBot"; // /WEB-INF/views/common/chatBot.jsp
    }

    @GetMapping("/home")
    public String homePage() {
        return "main"; //  /WEB-INF/views/index.jsp
    }

    @GetMapping("/myPage")
    public String myPage() {
        return "common/myPage"; // /WEB-INF/views/common/myPage.jsp
    }

    @GetMapping("/compare/compSearchPopUp")
    public String compSearchPopUp() {
        return "common/modal/compSearchPopUp"; // /WEB-INF/views/common/modal/compSearchPopup.jsp
    }

    @GetMapping("/chatBotDash")
    public String chatBotDash(@RequestParam(value = "corpCode", required = false) String corpCode, Model model) {
        model.addAttribute("corpCode", corpCode);
        return "common/chatBotDash";
    } // /WEB-INF/views/common/chatBotDash.jsp

    @GetMapping("/compareDetail")
    public String compareDetail() {
        return "common/compareDetail"; // /WEB-INF/views/common/compareDetail.jsp
    }

}
