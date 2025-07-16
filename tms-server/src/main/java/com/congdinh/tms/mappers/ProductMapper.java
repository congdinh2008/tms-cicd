package com.congdinh.tms.mappers;

import com.congdinh.tms.dtos.ProductRequestDTO;
import com.congdinh.tms.dtos.ProductResponseDTO;
import com.congdinh.tms.entities.Product;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * ProductMapper - Mapper để chuyển đổi giữa Product Entity và DTOs
 * Tách biệt logic mapping ra khỏi Service layer
 */
@Component
public class ProductMapper {

    /**
     * Chuyển đổi từ ProductRequestDTO sang Product Entity
     */
    public Product toEntity(ProductRequestDTO requestDTO) {
        if (requestDTO == null) {
            return null;
        }

        Product product = new Product();
        product.setName(requestDTO.getName());
        product.setDescription(requestDTO.getDescription());
        product.setPrice(requestDTO.getPrice());
        return product;
    }

    /**
     * Chuyển đổi từ Product Entity sang ProductResponseDTO
     */
    public ProductResponseDTO toResponseDTO(Product product) {
        if (product == null) {
            return null;
        }

        return new ProductResponseDTO(
                product.getId(),
                product.getName(),
                product.getDescription(),
                product.getPrice()
        );
    }

    /**
     * Chuyển đổi danh sách Product Entity sang danh sách ProductResponseDTO
     */
    public List<ProductResponseDTO> toResponseDTOList(List<Product> products) {
        if (products == null) {
            return List.of(); // Return empty list instead of null
        }

        return products.stream()
                .map(this::toResponseDTO)
                .toList(); // Use toList() instead of collect(Collectors.toList())
    }

    /**
     * Cập nhật Product Entity từ ProductRequestDTO (cho update operation)
     */
    public void updateEntityFromDTO(ProductRequestDTO requestDTO, Product product) {
        if (requestDTO == null || product == null) {
            return;
        }

        product.setName(requestDTO.getName());
        product.setDescription(requestDTO.getDescription());
        product.setPrice(requestDTO.getPrice());
    }
}
