package com.example.GtnTechAssesment.exceptions;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity handleNotFound(ResourceNotFoundException ex){
        Map<String,Object> error=new HashMap<>();
        error.put("timestamp", LocalDateTime.now().toString());
        error.put("status", HttpStatus.NOT_FOUND.value());
        error.put("error","Not Found");
        error.put("message",ex.getMessage());
        return new ResponseEntity<>(error,HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity handleValidationErrors(MethodArgumentNotValidException ex){
        Map<String , Object> error=new HashMap<>();
        Map<String,String> fieldErrors=new HashMap<>();

        ex.getBindingResult().getFieldErrors().forEach(err->
                fieldErrors.put(err.getField(),err.getDefaultMessage()));

        error.put("timestamp",LocalDateTime.now().toString());
        error.put("status",HttpStatus.BAD_REQUEST.value());
        error.put("error","Validation Failed");
        return new ResponseEntity(error,HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity handleGenericException(Exception ex){
        Map<String,Object> error=new HashMap<>();
        error.put("timestamp",LocalDateTime.now().toString());
        error.put("status",HttpStatus.INTERNAL_SERVER_ERROR.value());
        error.put("error","Internal Server Error");
        error.put("message",ex.getMessage());
        return new ResponseEntity(error,HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
