package com.congdinh.tms.controllers;

import com.congdinh.tms.dtos.ProductRequestDTO;
import com.congdinh.tms.dtos.ProductResponseDTO;
import com.congdinh.tms.services.ProductService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * ProductController - REST API endpoints cho Product
 * Theo REST conventions với HTTP methods và status codes
 * Sử dụng DTOs thay vì expose Entity trực tiếp
 */
@RestController
@RequestMapping("/api/products")
@CrossOrigin(origins = "http://localhost:2025") // Cho phép CORS từ React app
public class ProductController {

    private final ProductService productService;

    // Constructor injection (không cần @Autowired từ Spring 4.3+)
    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    /**
     * GET /api/products - Lấy tất cả products
     */
    @GetMapping
    public ResponseEntity<List<ProductResponseDTO>> getAllProducts() {
        List<ProductResponseDTO> products = productService.getAllProducts();
        return ResponseEntity.ok(products);
    }

    /**
     * GET /api/products/{id} - Lấy product theo ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<ProductResponseDTO> getProductById(@PathVariable Long id) {
        ProductResponseDTO product = productService.getProductById(id);
        return ResponseEntity.ok(product);
    }

    /**
     * POST /api/products - Tạo mới product
     */
    @PostMapping
    public ResponseEntity<ProductResponseDTO> createProduct(@Valid @RequestBody ProductRequestDTO productRequestDTO) {
        ProductResponseDTO createdProduct = productService.createProduct(productRequestDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdProduct);
    }

    /**
     * PUT /api/products/{id} - Cập nhật product
     */
    @PutMapping("/{id}")
    public ResponseEntity<ProductResponseDTO> updateProduct(
            @PathVariable Long id, 
            @Valid @RequestBody ProductRequestDTO productRequestDTO) {
        ProductResponseDTO updatedProduct = productService.updateProduct(id, productRequestDTO);
        return ResponseEntity.ok(updatedProduct);
    }

    /**
     * DELETE /api/products/{id} - Xóa product
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * GET /api/products/search?name=keyword - Tìm kiếm theo tên
     */
    @GetMapping("/search")
    public ResponseEntity<List<ProductResponseDTO>> searchProductsByName(@RequestParam String name) {
        List<ProductResponseDTO> products = productService.searchProductsByName(name);
        return ResponseEntity.ok(products);
    }

    /**
     * GET /api/products/search/keyword?q=keyword - Tìm kiếm theo keyword
     */
    @GetMapping("/search/keyword")
    public ResponseEntity<List<ProductResponseDTO>> searchProductsByKeyword(@RequestParam String q) {
        List<ProductResponseDTO> products = productService.searchProductsByKeyword(q);
        return ResponseEntity.ok(products);
    }

    /**
     * GET /api/products/price-range?min=0&max=100 - Tìm kiếm theo khoảng giá
     */
    @GetMapping("/price-range")
    public ResponseEntity<List<ProductResponseDTO>> findProductsByPriceRange(
            @RequestParam double min, 
            @RequestParam double max) {
        List<ProductResponseDTO> products = productService.findProductsByPriceRange(min, max);
        return ResponseEntity.ok(products);
    }
}
