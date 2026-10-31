package com.example.GtnTechAssesment.Controllers;


import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@Tag(name = "Health Check", description = "Endpoint for ALB Target Group and ECS Container Health Checks")
public class HealthCheckController {
    @GetMapping("/health")
    @Operation(summary = "Application Health Check Endpoint")
    public ResponseEntity health(){
        return ResponseEntity.ok(Map.of("status","UP"));
    }
}
