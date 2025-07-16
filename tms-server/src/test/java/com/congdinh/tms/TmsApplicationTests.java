package com.congdinh.tms;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

/**
 * Integration test cho TMS Application
 * Sử dụng profile 'test' để chạy với H2 in-memory database
 */
@SpringBootTest
@ActiveProfiles("test")  // Sử dụng application-test.properties
class TmsApplicationTests {

	@Test
	void contextLoads() {
		// Test này kiểm tra Spring Context có load được không
		// Với H2 database, test sẽ không cần PostgreSQL
	}

}
