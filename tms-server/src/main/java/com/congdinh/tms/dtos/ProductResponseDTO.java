package com.congdinh.tms.dtos;

/**
 * ProductResponseDTO - Data Transfer Object cho việc trả về thông tin Product
 * Chỉ bao gồm các thông tin cần thiết để hiển thị
 */
public class ProductResponseDTO {

    private Long id;
    private String name;
    private String description;
    private double price;

    // Default constructor
    public ProductResponseDTO() {
    }

    // Constructor with all fields
    public ProductResponseDTO(Long id, String name, String description, double price) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.price = price;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    @Override
    public String toString() {
        return "ProductResponseDTO{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", price=" + price +
                '}';
    }
}
