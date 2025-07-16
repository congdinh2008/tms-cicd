package com.congdinh.tms.exceptions;

/**
 * ResourceNotFoundException - Custom exception cho trường hợp không tìm thấy resource
 */
public class ResourceNotFoundException extends RuntimeException {
    
    public ResourceNotFoundException(String message) {
        super(message);
    }
    
    public ResourceNotFoundException(String resourceName, String fieldName, Object fieldValue) {
        super(String.format("Không tìm thấy %s với %s: %s", resourceName, fieldName, fieldValue));
    }
}
