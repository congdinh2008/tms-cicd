package com.congdinh.tms.repositories;

import com.congdinh.tms.entities.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * ProductRepository - Interface để thao tác với database
 * Spring Data JPA sẽ tự động implement các method cơ bản
 */
@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    
    // Tìm kiếm product theo tên (case-insensitive)
    List<Product> findByNameContainingIgnoreCase(String name);
    
    // Tìm kiếm product có giá trong khoảng min-max
    List<Product> findByPriceBetween(double minPrice, double maxPrice);
    
    // Tìm kiếm product có giá lớn hơn một giá trị
    List<Product> findByPriceGreaterThan(double price);
    
    // Custom query sử dụng JPQL
    @Query("SELECT p FROM Product p WHERE p.name LIKE %:keyword% OR p.description LIKE %:keyword%")
    List<Product> searchByKeyword(@Param("keyword") String keyword);
    
    // Custom query sử dụng native SQL
    @Query(value = "SELECT * FROM products WHERE price = (SELECT MAX(price) FROM products)", nativeQuery = true)
    List<Product> findMostExpensiveProducts();
}
