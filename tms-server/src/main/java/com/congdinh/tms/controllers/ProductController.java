package com.congdinh.tms.controllers;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.congdinh.tms.entities.Product;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    @GetMapping
    public ResponseEntity<?> getProduct() {
        var products = List.of(
            new Product("1", "Product A", "Description for Product A", 10.99),
            new Product("2", "Product B", "Description for Product B", 12.99),
            new Product("3", "Product C", "Description for Product C", 15.49)
        );

        return ResponseEntity.ok(products);
    }
}
