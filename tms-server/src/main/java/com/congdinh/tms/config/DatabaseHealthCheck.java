package com.congdinh.tms.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.EventListener;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * DatabaseHealthCheck - Kiểm tra kết nối database khi ứng dụng start
 * Giúp debug các vấn đề kết nối database
 */
@Configuration
public class DatabaseHealthCheck {

    private final DataSource dataSource;

    @Value("${spring.datasource.url}")
    private String databaseUrl;

    @Value("${spring.datasource.username}")
    private String databaseUser;

    public DatabaseHealthCheck(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @EventListener
    public void handleContextRefresh(ContextRefreshedEvent event) {
        System.out.println("=== DATABASE CONNECTION CHECK ===");
        System.out.println("Database URL: " + databaseUrl);
        System.out.println("Database User: " + databaseUser);
        
        try (Connection connection = dataSource.getConnection()) {
            System.out.println("✅ Database connection successful!");
            System.out.println("Database Product Name: " + connection.getMetaData().getDatabaseProductName());
            System.out.println("Database Version: " + connection.getMetaData().getDatabaseProductVersion());
        } catch (SQLException e) {
            System.err.println("❌ Database connection failed: " + e.getMessage());
            throw new RuntimeException("Failed to connect to database", e);
        }
        System.out.println("==================================");
    }
}
