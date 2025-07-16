package com.congdinh.tms.mappers;

import com.congdinh.tms.dtos.ProductRequestDTO;
import com.congdinh.tms.dtos.ProductResponseDTO;
import com.congdinh.tms.entities.Product;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit test cho ProductMapper
 */
class ProductMapperTest {

    private ProductMapper productMapper;
    private Product product;
    private ProductRequestDTO requestDTO;

    @BeforeEach
    void setUp() {
        productMapper = new ProductMapper();
        
        product = new Product(1L, "Test Product", "Test Description", 99.99);
        requestDTO = new ProductRequestDTO("Test Product", "Test Description", 99.99);
    }

    @Test
    void testToEntity() {
        // When
        Product result = productMapper.toEntity(requestDTO);

        // Then
        assertNotNull(result);
        assertNull(result.getId()); // ID should be null for new entity
        assertEquals("Test Product", result.getName());
        assertEquals("Test Description", result.getDescription());
        assertEquals(99.99, result.getPrice());
    }

    @Test
    void testToEntity_WithNull() {
        // When
        Product result = productMapper.toEntity(null);

        // Then
        assertNull(result);
    }

    @Test
    void testToResponseDTO() {
        // When
        ProductResponseDTO result = productMapper.toResponseDTO(product);

        // Then
        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("Test Product", result.getName());
        assertEquals("Test Description", result.getDescription());
        assertEquals(99.99, result.getPrice());
    }

    @Test
    void testToResponseDTO_WithNull() {
        // When
        ProductResponseDTO result = productMapper.toResponseDTO(null);

        // Then
        assertNull(result);
    }

    @Test
    void testToResponseDTOList() {
        // Given
        List<Product> products = Arrays.asList(
            new Product(1L, "Product 1", "Description 1", 100.0),
            new Product(2L, "Product 2", "Description 2", 200.0)
        );

        // When
        List<ProductResponseDTO> result = productMapper.toResponseDTOList(products);

        // Then
        assertNotNull(result);
        assertEquals(2, result.size());
        assertEquals("Product 1", result.get(0).getName());
        assertEquals("Product 2", result.get(1).getName());
    }

    @Test
    void testToResponseDTOList_WithNull() {
        // When
        List<ProductResponseDTO> result = productMapper.toResponseDTOList(null);

        // Then
        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    @Test
    void testUpdateEntityFromDTO() {
        // Given
        Product existingProduct = new Product(1L, "Old Name", "Old Description", 50.0);
        ProductRequestDTO updateRequest = new ProductRequestDTO("New Name", "New Description", 150.0);

        // When
        productMapper.updateEntityFromDTO(updateRequest, existingProduct);

        // Then
        assertEquals(1L, existingProduct.getId()); // ID should remain unchanged
        assertEquals("New Name", existingProduct.getName());
        assertEquals("New Description", existingProduct.getDescription());
        assertEquals(150.0, existingProduct.getPrice());
    }

    @Test
    void testUpdateEntityFromDTO_WithNullDTO() {
        // Given
        Product existingProduct = new Product(1L, "Original Name", "Original Description", 100.0);

        // When
        productMapper.updateEntityFromDTO(null, existingProduct);

        // Then - Product should remain unchanged
        assertEquals("Original Name", existingProduct.getName());
        assertEquals("Original Description", existingProduct.getDescription());
        assertEquals(100.0, existingProduct.getPrice());
    }

    @Test
    void testUpdateEntityFromDTO_WithNullEntity() {
        // Given
        ProductRequestDTO updateRequest = new ProductRequestDTO("New Name", "New Description", 150.0);

        // When & Then - Should not throw exception
        assertDoesNotThrow(() -> {
            productMapper.updateEntityFromDTO(updateRequest, null);
        });
    }
}
