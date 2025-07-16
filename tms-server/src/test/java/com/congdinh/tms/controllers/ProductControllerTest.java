package com.congdinh.tms.controllers;

import com.congdinh.tms.dtos.ProductRequestDTO;
import com.congdinh.tms.dtos.ProductResponseDTO;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import com.congdinh.tms.services.ProductService;

import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Unit test cho ProductController sử dụng @WebMvcTest
 * Test các endpoint REST API với mock service layer
 */
@WebMvcTest(ProductController.class)
@ActiveProfiles("test")
class ProductControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private ProductService productService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void testGetAllProducts() throws Exception {
        // Given
        List<ProductResponseDTO> mockProducts = Arrays.asList(
            new ProductResponseDTO(1L, "Product 1", "Description 1", 100.0),
            new ProductResponseDTO(2L, "Product 2", "Description 2", 200.0)
        );
        when(productService.getAllProducts()).thenReturn(mockProducts);

        // When & Then
        mockMvc.perform(get("/api/products"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].name").value("Product 1"))
                .andExpect(jsonPath("$[1].id").value(2))
                .andExpect(jsonPath("$[1].name").value("Product 2"));
    }

    @Test
    void testGetProductById() throws Exception {
        // Given
        ProductResponseDTO mockProduct = new ProductResponseDTO(1L, "Test Product", "Test Description", 99.99);
        when(productService.getProductById(1L)).thenReturn(mockProduct);

        // When & Then
        mockMvc.perform(get("/api/products/1"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.name").value("Test Product"))
                .andExpect(jsonPath("$.description").value("Test Description"))
                .andExpect(jsonPath("$.price").value(99.99));
    }

    @Test
    void testCreateProduct() throws Exception {
        // Given
        ProductRequestDTO requestDTO = new ProductRequestDTO("New Product", "New Description", 150.0);
        ProductResponseDTO responseDTO = new ProductResponseDTO(1L, "New Product", "New Description", 150.0);
        
        when(productService.createProduct(any(ProductRequestDTO.class))).thenReturn(responseDTO);

        // When & Then
        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestDTO)))
                .andExpect(status().isCreated())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.name").value("New Product"))
                .andExpect(jsonPath("$.description").value("New Description"))
                .andExpect(jsonPath("$.price").value(150.0));
    }

    @Test
    void testCreateProduct_InvalidData() throws Exception {
        // Given - invalid product with null name
        ProductRequestDTO invalidRequestDTO = new ProductRequestDTO(null, "Description", 100.0);

        // When & Then
        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidRequestDTO)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testCreateProduct_NegativePrice() throws Exception {
        // Given - invalid product with negative price
        ProductRequestDTO invalidRequestDTO = new ProductRequestDTO("Product", "Description", -50.0);

        // When & Then
        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidRequestDTO)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testUpdateProduct() throws Exception {
        // Given
        ProductRequestDTO requestDTO = new ProductRequestDTO("Updated Product", "Updated Description", 200.0);
        ProductResponseDTO responseDTO = new ProductResponseDTO(1L, "Updated Product", "Updated Description", 200.0);
        
        when(productService.updateProduct(eq(1L), any(ProductRequestDTO.class))).thenReturn(responseDTO);

        // When & Then
        mockMvc.perform(put("/api/products/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestDTO)))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.name").value("Updated Product"))
                .andExpect(jsonPath("$.description").value("Updated Description"))
                .andExpect(jsonPath("$.price").value(200.0));
    }

    @Test
    void testDeleteProduct() throws Exception {
        // When & Then
        mockMvc.perform(delete("/api/products/1"))
                .andExpect(status().isNoContent());
    }

    @Test
    void testSearchProductsByName() throws Exception {
        // Given
        List<ProductResponseDTO> mockProducts = List.of(
            new ProductResponseDTO(1L, "Test Product", "Test Description", 99.99)
        );
        when(productService.searchProductsByName("Test")).thenReturn(mockProducts);

        // When & Then
        mockMvc.perform(get("/api/products/search")
                .param("name", "Test"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].name").value("Test Product"));
    }

    @Test
    void testFindProductsByPriceRange() throws Exception {
        // Given
        List<ProductResponseDTO> mockProducts = List.of(
            new ProductResponseDTO(1L, "Test Product", "Test Description", 99.99)
        );
        when(productService.findProductsByPriceRange(50.0, 150.0)).thenReturn(mockProducts);

        // When & Then
        mockMvc.perform(get("/api/products/price-range")
                .param("min", "50.0")
                .param("max", "150.0"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].price").value(99.99));
    }
}
