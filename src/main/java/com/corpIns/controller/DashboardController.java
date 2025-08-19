package com.corpIns.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    @GetMapping("/{corpCode}")
    public ResponseEntity<?> getDashboardData(
            @PathVariable String corpCode,
            @RequestParam("start_year") int startYear,
            @RequestParam("end_year") int endYear
    ) {
        // 👉 서비스에서 corpCode, startYear, endYear로 데이터 조회
        Map<String, Object> dashboardData = new HashMap<>();
        dashboardData.put("corpCode", corpCode);
        dashboardData.put("startYear", startYear);
        dashboardData.put("endYear", endYear);
        dashboardData.put("message", "데이터 정상 조회됨!");

        return ResponseEntity.ok(dashboardData);
    }
}
