package com.corpIns.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@RestController
@RequestMapping("/api")
public class CorpSearchController {

    private static final String API_URL = "https://xp5bdl3ftqldheyokoroxvcocm0eorbe.lambda-url.ap-northeast-2.on.aws/";

    @GetMapping("/search")
    public ResponseEntity<String> search(
            @RequestParam String q,
            @RequestParam(defaultValue = "10") String limit,
            @RequestParam String bgn_de,
            @RequestParam String end_de
    ) {
        try {
            // URL 인코딩
            String query = String.format("q=%s&limit=%s&bgn_de=%s&end_de=%s",
                    URLEncoder.encode(q, StandardCharsets.UTF_8),
                    URLEncoder.encode(limit, StandardCharsets.UTF_8),
                    URLEncoder.encode(bgn_de, StandardCharsets.UTF_8),
                    URLEncoder.encode(end_de, StandardCharsets.UTF_8)
            );

            URI uri = new URI(API_URL + "?" + query);

            RestTemplate restTemplate = new RestTemplate();
            String result = restTemplate.getForObject(uri, String.class);

            return ResponseEntity.ok(result);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}
