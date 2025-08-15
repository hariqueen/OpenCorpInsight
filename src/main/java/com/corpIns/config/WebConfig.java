package com.corpIns.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**") // 모든 URL 패턴 허용
                .allowedOrigins("*") // 모든 Origin 허용 (localhost:8080 포함)
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS") // 허용할 메서드
                .allowedHeaders("*") // 모든 요청 헤더 허용
                .allowCredentials(false); // 쿠키 허용 여부 (false면 * 가능)
    }
}