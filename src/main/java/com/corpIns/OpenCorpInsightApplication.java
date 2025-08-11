package com.corpIns;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@MapperScan("com.corpIns.mapper")
@SpringBootApplication
public class OpenCorpInsightApplication {
    public static void main(String[] args) {
        SpringApplication.run(OpenCorpInsightApplication.class, args);
    }
}
