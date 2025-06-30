-- Initialize EcommerceAI PostgreSQL Database (Node.js + Prisma)
-- This script runs automatically when PostgreSQL container starts

-- Create database extensions if they don't exist
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Log initialization
SELECT 'PostgreSQL database initialization completed successfully for Node.js platform' as message;
