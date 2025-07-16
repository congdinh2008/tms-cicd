package com.congdinh.tms.services;

import com.congdinh.tms.dtos.ProductRequestDTO;
import com.congdinh.tms.dtos.ProductResponseDTO;
import com.congdinh.tms.entities.Product;
import com.congdinh.tms.exceptions.ResourceNotFoundException;
import com.congdinh.tms.mappers.ProductMapper;
import com.congdinh.tms.repositories.ProductRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.context.ActiveProfiles;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit test cho ProductService
 * Sử dụng Mockito để mock repository layer
 * Test với DTOs thay vì Entity
 */
@ExtendWith(MockitoExtension.class)
@ActiveProfiles("test")
class ProductServiceTest {

    @Mock
    private ProductRepository productRepository;

    @Mock
    private ProductMapper productMapper;

    @InjectMocks
    private ProductService productService;

    private Product mockProduct;
    private ProductRequestDTO mockRequestDTO;
    private ProductResponseDTO mockResponseDTO;

    @BeforeEach
    void setUp() {
        mockProduct = new Product(1L, "Test Product", "Test Description", 99.99);
        mockRequestDTO = new ProductRequestDTO("Test Product", "Test Description", 99.99);
        mockResponseDTO = new ProductResponseDTO(1L, "Test Product", "Test Description", 99.99);
    }

    @Test
    void testGetAllProducts() {
        // Given
        List<Product> mockProducts = Arrays.asList(
            new Product(1L, "Product 1", "Description 1", 100.0),
            new Product(2L, "Product 2", "Description 2", 200.0)
        );
        List<ProductResponseDTO> mockResponseDTOs = Arrays.asList(
            new ProductResponseDTO(1L, "Product 1", "Description 1", 100.0),
            new ProductResponseDTO(2L, "Product 2", "Description 2", 200.0)
        );
        
        when(productRepository.findAll()).thenReturn(mockProducts);
        when(productMapper.toResponseDTOList(mockProducts)).thenReturn(mockResponseDTOs);

        // When
        List<ProductResponseDTO> result = productService.getAllProducts();

        // Then
        assertEquals(2, result.size());
        assertEquals("Product 1", result.get(0).getName());
        verify(productRepository).findAll();
        verify(productMapper).toResponseDTOList(mockProducts);
    }

    @Test
    void testGetProductById_Success() {
        // Given
        when(productRepository.findById(1L)).thenReturn(Optional.of(mockProduct));
        when(productMapper.toResponseDTO(mockProduct)).thenReturn(mockResponseDTO);

        // When
        ProductResponseDTO result = productService.getProductById(1L);

        // Then
        assertNotNull(result);
        assertEquals("Test Product", result.getName());
        assertEquals(1L, result.getId());
        verify(productRepository).findById(1L);
        verify(productMapper).toResponseDTO(mockProduct);
    }

    @Test
    void testGetProductById_NotFound() {
        // Given
        when(productRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
            productService.getProductById(1L);
        });
        
        assertTrue(exception.getMessage().contains("Product"));
        assertTrue(exception.getMessage().contains("id"));
        assertTrue(exception.getMessage().contains("1"));
        
        verify(productRepository).findById(1L);
        verify(productMapper, never()).toResponseDTO(any());
    }

    @Test
    void testCreateProduct() {
        // Given
        when(productMapper.toEntity(mockRequestDTO)).thenReturn(mockProduct);
        when(productRepository.save(mockProduct)).thenReturn(mockProduct);
        when(productMapper.toResponseDTO(mockProduct)).thenReturn(mockResponseDTO);

        // When
        ProductResponseDTO result = productService.createProduct(mockRequestDTO);

        // Then
        assertNotNull(result);
        assertEquals("Test Product", result.getName());
        assertEquals(1L, result.getId());
        verify(productMapper).toEntity(mockRequestDTO);
        verify(productRepository).save(mockProduct);
        verify(productMapper).toResponseDTO(mockProduct);
    }

    @Test
    void testUpdateProduct_Success() {
        // Given
        when(productRepository.findById(1L)).thenReturn(Optional.of(mockProduct));
        when(productRepository.save(mockProduct)).thenReturn(mockProduct);
        when(productMapper.toResponseDTO(mockProduct)).thenReturn(mockResponseDTO);

        // When
        ProductResponseDTO result = productService.updateProduct(1L, mockRequestDTO);

        // Then
        assertNotNull(result);
        assertEquals("Test Product", result.getName());
        verify(productRepository).findById(1L);
        verify(productMapper).updateEntityFromDTO(mockRequestDTO, mockProduct);
        verify(productRepository).save(mockProduct);
        verify(productMapper).toResponseDTO(mockProduct);
    }

    @Test
    void testUpdateProduct_NotFound() {
        // Given
        when(productRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
            productService.updateProduct(1L, mockRequestDTO);
        });
        
        assertTrue(exception.getMessage().contains("Product"));
        verify(productRepository).findById(1L);
        verify(productRepository, never()).save(any());
    }

    @Test
    void testDeleteProduct_Success() {
        // Given
        when(productRepository.findById(1L)).thenReturn(Optional.of(mockProduct));

        // When
        productService.deleteProduct(1L);

        // Then
        verify(productRepository).findById(1L);
        verify(productRepository).delete(mockProduct);
    }

    @Test
    void testDeleteProduct_NotFound() {
        // Given
        when(productRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        ResourceNotFoundException exception = assertThrows(ResourceNotFoundException.class, () -> {
            productService.deleteProduct(1L);
        });
        
        assertTrue(exception.getMessage().contains("Product"));
        verify(productRepository).findById(1L);
        verify(productRepository, never()).delete(any());
    }

    @Test
    void testSearchProductsByName() {
        // Given
        String searchName = "Test";
        List<Product> mockProducts = List.of(mockProduct);
        List<ProductResponseDTO> mockResponseDTOs = List.of(mockResponseDTO);
        
        when(productRepository.findByNameContainingIgnoreCase(searchName)).thenReturn(mockProducts);
        when(productMapper.toResponseDTOList(mockProducts)).thenReturn(mockResponseDTOs);

        // When
        List<ProductResponseDTO> result = productService.searchProductsByName(searchName);

        // Then
        assertEquals(1, result.size());
        assertEquals("Test Product", result.get(0).getName());
        verify(productRepository).findByNameContainingIgnoreCase(searchName);
        verify(productMapper).toResponseDTOList(mockProducts);
    }

    @Test
    void testFindProductsByPriceRange_Success() {
        // Given
        double minPrice = 50.0;
        double maxPrice = 150.0;
        List<Product> mockProducts = List.of(mockProduct);
        List<ProductResponseDTO> mockResponseDTOs = List.of(mockResponseDTO);
        
        when(productRepository.findByPriceBetween(minPrice, maxPrice)).thenReturn(mockProducts);
        when(productMapper.toResponseDTOList(mockProducts)).thenReturn(mockResponseDTOs);

        // When
        List<ProductResponseDTO> result = productService.findProductsByPriceRange(minPrice, maxPrice);

        // Then
        assertEquals(1, result.size());
        verify(productRepository).findByPriceBetween(minPrice, maxPrice);
        verify(productMapper).toResponseDTOList(mockProducts);
    }

    @Test
    void testFindProductsByPriceRange_InvalidMinPrice() {
        // When & Then
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            productService.findProductsByPriceRange(-10.0, 100.0);
        });
        
        assertEquals("Giá không được âm", exception.getMessage());
        verify(productRepository, never()).findByPriceBetween(any(Double.class), any(Double.class));
    }

    @Test
    void testFindProductsByPriceRange_InvalidMaxPrice() {
        // When & Then
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            productService.findProductsByPriceRange(10.0, -100.0);
        });
        
        assertEquals("Giá không được âm", exception.getMessage());
        verify(productRepository, never()).findByPriceBetween(any(Double.class), any(Double.class));
    }

    @Test
    void testFindProductsByPriceRange_MinGreaterThanMax() {
        // When & Then
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            productService.findProductsByPriceRange(150.0, 100.0);
        });
        
        assertEquals("Giá tối thiểu không được lớn hơn giá tối đa", exception.getMessage());
        verify(productRepository, never()).findByPriceBetween(any(Double.class), any(Double.class));
    }
}
