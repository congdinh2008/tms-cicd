-- Initialization script for TMS database
-- This script runs automatically when PostgreSQL container starts for the first time

-- Create extension if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set timezone
SET timezone = 'Asia/Ho_Chi_Minh';

-- Create indexes for better performance (will be created when tables exist)
-- Example: CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_product_name ON products(name);

-- Insert initial data if needed
-- Example data will be inserted by Spring Boot when application starts
