package com.congdinh.tms.integration;

import com.congdinh.tms.dtos.ProductRequestDTO;
import com.congdinh.tms.dtos.ProductResponseDTO;
import com.congdinh.tms.repositories.ProductRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Integration Test cho TMS Application với Testcontainers
 * Sử dụng PostgreSQL container thực tế để test toàn bộ flow
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
@Testcontainers
@ActiveProfiles("integration-test")
@Transactional
class ProductIntegrationTest {

    @Container
    @ServiceConnection
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16.0-alpine")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        // Clean database before each test
        productRepository.deleteAll();
    }

    @Test
    void testCreateAndRetrieveProduct() throws Exception {
        // Given
        ProductRequestDTO requestDTO = new ProductRequestDTO(
            "Integration Test Product", 
            "This is a test product for integration testing", 
            299.99
        );

        // When - Create product
        String response = mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(requestDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("Integration Test Product"))
                .andExpect(jsonPath("$.description").value("This is a test product for integration testing"))
                .andExpect(jsonPath("$.price").value(299.99))
                .andReturn().getResponse().getContentAsString();

        ProductResponseDTO createdProduct = objectMapper.readValue(response, ProductResponseDTO.class);

        // Then - Retrieve the created product
        mockMvc.perform(get("/api/products/" + createdProduct.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(createdProduct.getId()))
                .andExpect(jsonPath("$.name").value("Integration Test Product"))
                .andExpect(jsonPath("$.description").value("This is a test product for integration testing"))
                .andExpect(jsonPath("$.price").value(299.99));
    }

    @Test
    void testGetAllProducts() throws Exception {
        // Given - Create multiple products
        ProductRequestDTO product1 = new ProductRequestDTO("Product 1", "Description 1", 100.0);
        ProductRequestDTO product2 = new ProductRequestDTO("Product 2", "Description 2", 200.0);

        // Create products
        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(product1)))
                .andExpect(status().isCreated());

        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(product2)))
                .andExpect(status().isCreated());

        // When & Then - Get all products
        mockMvc.perform(get("/api/products"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(2));
    }

    @Test
    void testUpdateProduct() throws Exception {
        // Given - Create a product first
        ProductRequestDTO createRequest = new ProductRequestDTO("Original Product", "Original Description", 150.0);
        
        String createResponse = mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(createRequest)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();

        ProductResponseDTO createdProduct = objectMapper.readValue(createResponse, ProductResponseDTO.class);

        // When - Update the product
        ProductRequestDTO updateRequest = new ProductRequestDTO("Updated Product", "Updated Description", 250.0);

        mockMvc.perform(put("/api/products/" + createdProduct.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(createdProduct.getId()))
                .andExpect(jsonPath("$.name").value("Updated Product"))
                .andExpect(jsonPath("$.description").value("Updated Description"))
                .andExpect(jsonPath("$.price").value(250.0));
    }

    @Test
    void testDeleteProduct() throws Exception {
        // Given - Create a product first
        ProductRequestDTO createRequest = new ProductRequestDTO("Product to Delete", "Will be deleted", 100.0);
        
        String createResponse = mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(createRequest)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();

        ProductResponseDTO createdProduct = objectMapper.readValue(createResponse, ProductResponseDTO.class);

        // When - Delete the product
        mockMvc.perform(delete("/api/products/" + createdProduct.getId()))
                .andExpect(status().isNoContent());

        // Then - Verify product is deleted
        mockMvc.perform(get("/api/products/" + createdProduct.getId()))
                .andExpect(status().isNotFound());
    }

    @Test
    void testSearchProductsByName() throws Exception {
        // Given - Create products with different names
        ProductRequestDTO laptop = new ProductRequestDTO("Laptop Dell", "High performance laptop", 1500.0);
        ProductRequestDTO phone = new ProductRequestDTO("iPhone 15", "Latest smartphone", 1000.0);

        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(laptop)))
                .andExpect(status().isCreated());

        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(phone)))
                .andExpect(status().isCreated());

        // When & Then - Search by name
        mockMvc.perform(get("/api/products/search")
                .param("name", "Laptop"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].name").value("Laptop Dell"));
    }

    @Test
    void testFindProductsByPriceRange() throws Exception {
        // Given - Create products with different prices
        ProductRequestDTO cheapProduct = new ProductRequestDTO("Cheap Product", "Budget option", 50.0);
        ProductRequestDTO expensiveProduct = new ProductRequestDTO("Expensive Product", "Premium option", 500.0);
        ProductRequestDTO midRangeProduct = new ProductRequestDTO("Mid Range Product", "Good value", 150.0);

        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(cheapProduct)))
                .andExpect(status().isCreated());

        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(expensiveProduct)))
                .andExpect(status().isCreated());

        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(midRangeProduct)))
                .andExpect(status().isCreated());

        // When & Then - Search by price range
        mockMvc.perform(get("/api/products/price-range")
                .param("min", "100.0")
                .param("max", "200.0"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].name").value("Mid Range Product"));
    }

    @Test
    void testCreateProductWithInvalidData() throws Exception {
        // Given - Invalid product with null name
        ProductRequestDTO invalidProduct = new ProductRequestDTO(null, "Description", 100.0);

        // When & Then
        mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidProduct)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testGetNonExistentProduct() throws Exception {
        // When & Then
        mockMvc.perform(get("/api/products/999999"))
                .andExpect(status().isNotFound());
    }
}
