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
        // 👉 실제로는 서비스에서 DB 조회 결과를 내려야 함
        Map<String, Object> dashboardData = new HashMap<>();
        dashboardData.put("corpCode", corpCode);
        dashboardData.put("startYear", startYear);
        dashboardData.put("endYear", endYear);

        // 프론트에서 data.data 구조로 꺼내니까 "data" 키 안에 감싸서 내려주는 게 맞음
        Map<String, Object> response = new HashMap<>();
        response.put("data", dashboardData);

        return ResponseEntity.ok(response);
    }
}

