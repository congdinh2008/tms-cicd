package com.congdinh.tms.config;

import com.congdinh.tms.entities.Product;
import com.congdinh.tms.repositories.ProductRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * DataInitializer - Khởi tạo dữ liệu mẫu khi ứng dụng start
 * Chỉ chạy một lần khi database còn trống
 */
@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner initDatabase(ProductRepository repository) {
        return args -> {
            // Chỉ khởi tạo dữ liệu nếu database trống
            if (repository.count() == 0) {
                repository.save(new Product("Laptop Dell XPS 13", 
                    "Laptop cao cấp với màn hình 13 inch, CPU Intel Core i7, RAM 16GB", 
                    25999000.0));
                
                repository.save(new Product("iPhone 15 Pro", 
                    "Smartphone flagship của Apple với chip A17 Pro, camera 48MP", 
                    28999000.0));
                
                repository.save(new Product("Samsung Galaxy Watch 6", 
                    "Smartwatch với GPS, theo dõi sức khỏe và thể thao", 
                    6990000.0));
                
                repository.save(new Product("Sony WH-1000XM5", 
                    "Tai nghe chống ồn cao cấp với chất lượng âm thanh tuyệt vời", 
                    8990000.0));
                
                repository.save(new Product("MacBook Air M3", 
                    "Laptop Apple với chip M3, màn hình Retina 13 inch, hiệu năng mạnh mẽ", 
                    32990000.0));
                
                System.out.println("Đã khởi tạo dữ liệu mẫu cho Product!");
            }
        };
    }
}
