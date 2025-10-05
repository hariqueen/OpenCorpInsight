package com.corpIns.controller;

import com.corpIns.dto.User;
import com.corpIns.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

@Controller
public class CommonController {
    
    private static final Logger logger = LoggerFactory.getLogger(CommonController.class);
    
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
        System.out.println("DEBUG: chatBotDash 호출됨");
        return "common/chatBotDash"; // /WEB-INF/views/common/chatBotDash.jsp
    }
    
    @GetMapping("/compareDetail")
    public String compareDetail() {
        return "common/compareDetail"; // /WEB-INF/views/common/compareDetail.jsp
    }
    
    @GetMapping("/getProfile")
    @ResponseBody
    public Map<String, Object> getProfile(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            User loginUser = (User) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("status", "error");
                response.put("message", "로그인이 필요합니다.");
                return response;
            }
            
            Map<String, Object> profile = userMapper.getUserProfile(loginUser.getUserSno());
            if (profile == null) {
                profile = new HashMap<>();
                profile.put("nickname", "");
                profile.put("difficulty", "");
                profile.put("interest", "");
                profile.put("purpose", "");
            }
            
            response.put("status", "success");
            response.put("data", profile);
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "프로필 조회 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    @PostMapping("/updateProfile")
    @ResponseBody
    public Map<String, Object> updateProfile(@RequestParam String nickname,
                                           @RequestParam(required = false) String difficulty,
                                           @RequestParam(required = false) String interest,
                                           @RequestParam(required = false) String purpose,
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
            updateData.put("difficulty", difficulty);
            updateData.put("interest", interest);
            updateData.put("purpose", purpose);
            
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
    
    @PostMapping("/api/log")
    @ResponseBody
    public Map<String, Object> logMessage(@RequestBody Map<String, Object> logData) {
        String message = (String) logData.get("message");
        String company = (String) logData.get("company");
        Object statusObj = logData.get("status");
        String status = statusObj != null ? statusObj.toString() : null;
        String error = (String) logData.get("error");
        String url = (String) logData.get("url");
        Object modeObj = logData.get("mode");
        String mode = modeObj != null ? modeObj.toString() : null;
        
        StringBuilder logMsg = new StringBuilder("[프론트엔드 로그] ");
        logMsg.append(message);
        
        if (company != null) logMsg.append(" - 회사: ").append(company);
        if (mode != null) logMsg.append(" - 모드: ").append(mode);
        if (status != null) logMsg.append(" - 상태: ").append(status);
        if (error != null) logMsg.append(" - 오류: ").append(error);
        if (url != null) logMsg.append(" - URL: ").append(url);
        
        logger.info(logMsg.toString());
        
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        return response;
    }
}
