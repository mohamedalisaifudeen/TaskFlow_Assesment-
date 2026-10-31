package com.example.GtnTechAssesment.exceptions;

public class ResourceNotFoundException extends RuntimeException{
    public ResourceNotFoundException (String message){
        super(message);
    }
}
