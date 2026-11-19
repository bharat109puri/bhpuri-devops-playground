package com.bharat.playground;

import java.util.Map;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class Application {
  public static void main(String[] args) { SpringApplication.run(Application.class, args); }

  @RestController
  static class HealthController {
    @GetMapping("/healthz") Map<String, String> health() { return Map.of("status", "healthy"); }
    @GetMapping("/") Map<String, String> index() { return Map.of("service", "demo-spring", "status", "ok"); }
  }
}
