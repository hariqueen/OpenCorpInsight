package com.corpIns.controller;

import com.corpIns.dto.User;
import com.corpIns.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import jakarta.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

@Controller
public class CommonController {
    
    @Autowired
    private UserMapper userMapper;
    @GetMapping("/")
    public String index() {
        return "index"; // /WEB-INF/views/index.jsp
    }
    
    @GetMapping("/compare")
    public String comparePage() {
        return "common/compare"; // /WEB-INF/views/common/compare.jsp
    }

    @GetMapping("/chatBot")
    public String chatBot() {
        return "chatBot"; // /WEB-INF/views/chatBot.jsp
    }

    @GetMapping("/home")
    public String homePage() {
        return "index"; // /WEB-INF/views/index.jsp
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
    public String chatBotDash() {
        return "common/chatBotDash"; // /WEB-INF/views/common/chatBotDash.jsp
    }
    
    @GetMapping("/compareDetail")
    public String compareDetail() {
        return "common/compareDetail"; // /WEB-INF/views/common/compareDetail.jsp
    }
    
    @PostMapping("/updateProfile")
    @ResponseBody
    public Map<String, Object> updateProfile(@RequestParam String nickname,
                                           HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            User loginUser = (User) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("status", "error");
                response.put("message", "로그인이 필요합니다.");
                return response;
            }
            
            // 프로필 업데이트
            Map<String, Object> updateData = new HashMap<>();
            updateData.put("userSno", loginUser.getUserSno());
            updateData.put("nickname", nickname);
            
            userMapper.updateUserProfile(updateData);
            
            // 세션의 사용자 정보도 업데이트
            loginUser.setNickname(nickname);
            session.setAttribute("loginUser", loginUser);
            
            response.put("status", "success");
            response.put("message", "프로필이 성공적으로 업데이트되었습니다.");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "프로필 업데이트 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
}
