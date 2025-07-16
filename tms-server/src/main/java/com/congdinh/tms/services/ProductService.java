package com.congdinh.tms.services;

import com.congdinh.tms.dtos.ProductRequestDTO;
import com.congdinh.tms.dtos.ProductResponseDTO;
import com.congdinh.tms.entities.Product;
import com.congdinh.tms.exceptions.ResourceNotFoundException;
import com.congdinh.tms.mappers.ProductMapper;
import com.congdinh.tms.repositories.ProductRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * ProductService - Business logic layer
 * Xử lý các logic nghiệp vụ liên quan đến Product với DTOs
 */
@Service
@Transactional
public class ProductService {
    
    private static final String RESOURCE_NAME = "Product";
    
    private final ProductRepository productRepository;
    private final ProductMapper productMapper;
    
    // Constructor injection (best practice)
    public ProductService(ProductRepository productRepository, ProductMapper productMapper) {
        this.productRepository = productRepository;
        this.productMapper = productMapper;
    }
    
    /**
     * Lấy tất cả products
     */
    @Transactional(readOnly = true)
    public List<ProductResponseDTO> getAllProducts() {
        List<Product> products = productRepository.findAll();
        return productMapper.toResponseDTOList(products);
    }
    
    /**
     * Lấy product theo ID
     */
    @Transactional(readOnly = true)
    public ProductResponseDTO getProductById(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(RESOURCE_NAME, "id", id));
        return productMapper.toResponseDTO(product);
    }
    
    /**
     * Tạo mới product
     */
    public ProductResponseDTO createProduct(ProductRequestDTO productRequestDTO) {
        // Validation sẽ được xử lý bởi @Valid annotation trong Controller
        Product product = productMapper.toEntity(productRequestDTO);
        Product savedProduct = productRepository.save(product);
        return productMapper.toResponseDTO(savedProduct);
    }
    
    /**
     * Cập nhật product
     */
    public ProductResponseDTO updateProduct(Long id, ProductRequestDTO productRequestDTO) {
        Product existingProduct = productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(RESOURCE_NAME, "id", id));
        
        productMapper.updateEntityFromDTO(productRequestDTO, existingProduct);
        Product updatedProduct = productRepository.save(existingProduct);
        return productMapper.toResponseDTO(updatedProduct);
    }
    
    /**
     * Xóa product
     */
    public void deleteProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(RESOURCE_NAME, "id", id));
        productRepository.delete(product);
    }
    
    /**
     * Tìm kiếm product theo tên
     */
    @Transactional(readOnly = true)
    public List<ProductResponseDTO> searchProductsByName(String name) {
        List<Product> products = productRepository.findByNameContainingIgnoreCase(name);
        return productMapper.toResponseDTOList(products);
    }
    
    /**
     * Tìm kiếm product theo keyword
     */
    @Transactional(readOnly = true)
    public List<ProductResponseDTO> searchProductsByKeyword(String keyword) {
        List<Product> products = productRepository.searchByKeyword(keyword);
        return productMapper.toResponseDTOList(products);
    }
    
    /**
     * Tìm kiếm product theo khoảng giá
     */
    @Transactional(readOnly = true)
    public List<ProductResponseDTO> findProductsByPriceRange(double minPrice, double maxPrice) {
        if (minPrice < 0 || maxPrice < 0) {
            throw new IllegalArgumentException("Giá không được âm");
        }
        if (minPrice > maxPrice) {
            throw new IllegalArgumentException("Giá tối thiểu không được lớn hơn giá tối đa");
        }
        
        List<Product> products = productRepository.findByPriceBetween(minPrice, maxPrice);
        return productMapper.toResponseDTOList(products);
    }
}
