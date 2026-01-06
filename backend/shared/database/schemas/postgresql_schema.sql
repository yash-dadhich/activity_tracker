-- Enterprise Productivity Monitoring System
-- PostgreSQL Database Schema
-- Version: 1.0.0

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create custom types
CREATE TYPE user_role AS ENUM ('employee', 'manager', 'admin', 'superAdmin');
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended', 'pending');
CREATE TYPE activity_type AS ENUM ('application', 'website', 'file', 'idle', 'meeting', 'break_', 'system');
CREATE TYPE productivity_category AS ENUM ('productive', 'neutral', 'distracting', 'personal', 'unknown');
CREATE TYPE privacy_level AS ENUM ('public', 'standard', 'sensitive', 'confidential');
CREATE TYPE insight_type AS ENUM ('timeManagement', 'focusPattern', 'distractionAlert', 'productivityTip', 'behaviorChange', 'goalProgress', 'teamComparison', 'anomalyDetection');
CREATE TYPE trend_direction AS ENUM ('up', 'down', 'stable');
CREATE TYPE goal_type AS ENUM ('productivityScore', 'focusTime', 'distractionReduction', 'taskCompletion', 'timeManagement', 'custom');
CREATE TYPE goal_status AS ENUM ('draft', 'active', 'paused', 'completed', 'cancelled');

-- Organizations table (multi-tenant support)
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(255) UNIQUE NOT NULL,
    settings JSONB DEFAULT '{}',
    subscription_plan VARCHAR(50) DEFAULT 'basic',
    max_users INTEGER DEFAULT 100,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- Departments table
CREATE TABLE departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    parent_department_id UUID REFERENCES departments(id),
    manager_id UUID, -- Will be set after users table is created
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    
    UNIQUE(organization_id, name)
);

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    department_id UUID NOT NULL REFERENCES departments(id),
    manager_id UUID REFERENCES users(id),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role user_role DEFAULT 'employee',
    status user_status DEFAULT 'pending',
    profile_image_url TEXT,
    phone VARCHAR(20),
    timezone VARCHAR(50) DEFAULT 'UTC',
    language VARCHAR(10) DEFAULT 'en',
    last_login_at TIMESTAMP WITH TIME ZONE,
    password_changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP WITH TIME ZONE,
    email_verified BOOLEAN DEFAULT false,
    email_verification_token VARCHAR(255),
    password_reset_token VARCHAR(255),
    password_reset_expires TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Add foreign key constraint for department manager
ALTER TABLE departments ADD CONSTRAINT fk_department_manager 
    FOREIGN KEY (manager_id) REFERENCES users(id);

-- User preferences table
CREATE TABLE user_preferences (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    theme VARCHAR(20) DEFAULT 'system',
    enable_notifications BOOLEAN DEFAULT true,
    enable_sounds BOOLEAN DEFAULT true,
    screenshot_interval INTEGER DEFAULT 300, -- seconds
    enable_location_tracking BOOLEAN DEFAULT false,
    work_hours_start TIME DEFAULT '09:00:00',
    work_hours_end TIME DEFAULT '17:00:00',
    work_days INTEGER[] DEFAULT ARRAY[1,2,3,4,5], -- Monday to Friday
    custom_settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Privacy settings table
CREATE TABLE privacy_settings (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    consent_given BOOLEAN DEFAULT false,
    consent_date TIMESTAMP WITH TIME ZONE,
    consent_version VARCHAR(10) DEFAULT '1.0',
    allow_screenshots BOOLEAN DEFAULT false,
    allow_location_tracking BOOLEAN DEFAULT false,
    allow_app_tracking BOOLEAN DEFAULT false,
    allow_website_tracking BOOLEAN DEFAULT false,
    allow_idle_tracking BOOLEAN DEFAULT false,
    share_data_with_manager BOOLEAN DEFAULT false,
    share_data_with_hr BOOLEAN DEFAULT false,
    data_processing_purposes TEXT[] DEFAULT '{}',
    data_retention_until TIMESTAMP WITH TIME ZONE,
    anonymize_data BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Devices table
CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_name VARCHAR(255) NOT NULL,
    device_type VARCHAR(50) NOT NULL, -- desktop, laptop, mobile
    platform VARCHAR(50) NOT NULL, -- windows, macos, linux, ios, android
    platform_version VARCHAR(50),
    app_version VARCHAR(50),
    device_fingerprint VARCHAR(255) UNIQUE,
    last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, device_fingerprint)
);

-- Refresh tokens table
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_revoked BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_refresh_tokens_user_device (user_id, device_id),
    INDEX idx_refresh_tokens_expires (expires_at)
);

-- Activity sessions table
CREATE TABLE activity_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    duration INTEGER, -- seconds
    type activity_type NOT NULL,
    category productivity_category DEFAULT 'unknown',
    title TEXT,
    description TEXT,
    application_name VARCHAR(255),
    window_title_encrypted TEXT, -- Encrypted
    website_url_encrypted TEXT, -- Encrypted
    file_path_encrypted TEXT, -- Encrypted
    is_idle BOOLEAN DEFAULT false,
    productivity_score DECIMAL(3,2) CHECK (productivity_score >= 0 AND productivity_score <= 1),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_activity_sessions_user_time (user_id, start_time),
    INDEX idx_activity_sessions_type (type),
    INDEX idx_activity_sessions_category (category),
    INDEX idx_activity_sessions_device (device_id)
);

-- Activity events table (for detailed tracking)
CREATE TABLE activity_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES activity_sessions(id) ON DELETE CASCADE,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    event_type VARCHAR(50) NOT NULL, -- keystroke, mouse_click, scroll, focus_change
    data JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_activity_events_session (session_id),
    INDEX idx_activity_events_timestamp (timestamp),
    INDEX idx_activity_events_type (event_type)
);

-- Screenshots table
CREATE TABLE screenshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES activity_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    file_path TEXT NOT NULL,
    thumbnail_path TEXT,
    file_size INTEGER NOT NULL,
    width INTEGER,
    height INTEGER,
    is_encrypted BOOLEAN DEFAULT true,
    encryption_key_id VARCHAR(255),
    privacy_level privacy_level DEFAULT 'standard',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_screenshots_user_time (user_id, timestamp),
    INDEX idx_screenshots_session (session_id),
    INDEX idx_screenshots_privacy (privacy_level)
);

-- Location data table
CREATE TABLE location_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES activity_sessions(id) ON DELETE CASCADE,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    accuracy DECIMAL(8, 2),
    address_encrypted TEXT, -- Encrypted
    city VARCHAR(100),
    country VARCHAR(100),
    timezone VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_location_data_user_time (user_id, timestamp),
    INDEX idx_location_data_session (session_id)
);

-- Productivity scores table
CREATE TABLE productivity_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    overall_score DECIMAL(3,2) NOT NULL CHECK (overall_score >= 0 AND overall_score <= 1),
    category_scores JSONB DEFAULT '{}',
    time_distribution JSONB DEFAULT '{}', -- seconds per category
    total_active_time INTEGER DEFAULT 0, -- seconds
    total_productive_time INTEGER DEFAULT 0, -- seconds
    total_distracting_time INTEGER DEFAULT 0, -- seconds
    application_usage JSONB DEFAULT '{}',
    website_usage JSONB DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, date),
    INDEX idx_productivity_scores_user_date (user_id, date),
    INDEX idx_productivity_scores_score (overall_score)
);

-- Productivity insights table
CREATE TABLE productivity_insights (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type insight_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    impact DECIMAL(3,2) CHECK (impact >= -1 AND impact <= 1),
    recommendations TEXT[] DEFAULT '{}',
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    is_dismissed BOOLEAN DEFAULT false,
    valid_until TIMESTAMP WITH TIME ZONE,
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_productivity_insights_user (user_id),
    INDEX idx_productivity_insights_type (type),
    INDEX idx_productivity_insights_generated (generated_at)
);

-- Productivity trends table
CREATE TABLE productivity_trends (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    direction trend_direction NOT NULL,
    change_percentage DECIMAL(5,2) NOT NULL,
    data_points JSONB NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_productivity_trends_user_period (user_id, period_start, period_end)
);

-- Productivity goals table
CREATE TABLE productivity_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type goal_type NOT NULL,
    target_value DECIMAL(10,2) NOT NULL,
    current_value DECIMAL(10,2) DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status goal_status DEFAULT 'draft',
    milestones TEXT[] DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_productivity_goals_user (user_id),
    INDEX idx_productivity_goals_status (status),
    INDEX idx_productivity_goals_dates (start_date, end_date)
);

-- Audit logs table
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_audit_logs_user (user_id),
    INDEX idx_audit_logs_action (action),
    INDEX idx_audit_logs_timestamp (timestamp),
    INDEX idx_audit_logs_resource (resource_type, resource_id)
);

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_notifications_user (user_id),
    INDEX idx_notifications_unread (user_id, is_read),
    INDEX idx_notifications_created (created_at)
);

-- Application categories table (for productivity classification)
CREATE TABLE application_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    application_name VARCHAR(255) NOT NULL,
    category productivity_category NOT NULL,
    confidence_score DECIMAL(3,2) DEFAULT 1.0,
    is_custom BOOLEAN DEFAULT false,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(organization_id, application_name),
    INDEX idx_application_categories_org (organization_id),
    INDEX idx_application_categories_category (category)
);

-- Website categories table (for productivity classification)
CREATE TABLE website_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    domain VARCHAR(255) NOT NULL,
    category productivity_category NOT NULL,
    confidence_score DECIMAL(3,2) DEFAULT 1.0,
    is_custom BOOLEAN DEFAULT false,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(organization_id, domain),
    INDEX idx_website_categories_org (organization_id),
    INDEX idx_website_categories_category (category)
);

-- Data retention policies table
CREATE TABLE data_retention_policies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    data_type VARCHAR(50) NOT NULL, -- screenshots, activities, locations, etc.
    retention_days INTEGER NOT NULL,
    auto_delete BOOLEAN DEFAULT true,
    anonymize_after_days INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(organization_id, data_type)
);

-- Create indexes for performance
CREATE INDEX idx_users_organization ON users(organization_id);
CREATE INDEX idx_users_department ON users(department_id);
CREATE INDEX idx_users_manager ON users(manager_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_role ON users(role);

-- Full-text search indexes
CREATE INDEX idx_activity_sessions_title_search ON activity_sessions USING gin(to_tsvector('english', title));
CREATE INDEX idx_activity_sessions_app_search ON activity_sessions USING gin(to_tsvector('english', application_name));

-- Partitioning for large tables (activity_sessions by month)
-- This would be implemented based on actual usage patterns

-- Row Level Security (RLS) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE screenshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE productivity_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE productivity_insights ENABLE ROW LEVEL SECURITY;

-- RLS policies for users table
CREATE POLICY user_own_data ON users
    FOR ALL TO authenticated_user
    USING (id = current_user_id());

CREATE POLICY manager_team_data ON users
    FOR SELECT TO authenticated_user
    USING (
        manager_id = current_user_id() OR
        current_user_role() IN ('admin', 'superAdmin')
    );

-- RLS policies for activity_sessions table
CREATE POLICY activity_own_data ON activity_sessions
    FOR ALL TO authenticated_user
    USING (user_id = current_user_id());

CREATE POLICY activity_manager_data ON activity_sessions
    FOR SELECT TO authenticated_user
    USING (
        user_id IN (
            SELECT id FROM users 
            WHERE manager_id = current_user_id()
        ) OR
        current_user_role() IN ('admin', 'superAdmin')
    );

-- Functions for RLS
CREATE OR REPLACE FUNCTION current_user_id() RETURNS UUID AS $$
    SELECT COALESCE(current_setting('app.current_user_id', true)::UUID, '00000000-0000-0000-0000-000000000000'::UUID);
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION current_user_role() RETURNS user_role AS $$
    SELECT COALESCE(current_setting('app.current_user_role', true)::user_role, 'employee'::user_role);
$$ LANGUAGE SQL STABLE;

-- Triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers to relevant tables
CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_departments_updated_at BEFORE UPDATE ON departments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_privacy_settings_updated_at BEFORE UPDATE ON privacy_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_devices_updated_at BEFORE UPDATE ON devices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_activity_sessions_updated_at BEFORE UPDATE ON activity_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_productivity_scores_updated_at BEFORE UPDATE ON productivity_scores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_productivity_goals_updated_at BEFORE UPDATE ON productivity_goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Data cleanup functions
CREATE OR REPLACE FUNCTION cleanup_expired_tokens()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM refresh_tokens 
    WHERE expires_at < NOW() OR is_revoked = true;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cleanup_old_audit_logs(retention_days INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM audit_logs 
    WHERE timestamp < NOW() - INTERVAL '1 day' * retention_days;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Scheduled cleanup (requires pg_cron extension)
-- SELECT cron.schedule('cleanup-tokens', '0 2 * * *', 'SELECT cleanup_expired_tokens();');
-- SELECT cron.schedule('cleanup-audit-logs', '0 3 * * 0', 'SELECT cleanup_old_audit_logs(90);');

-- Insert default data
INSERT INTO organizations (id, name, domain, settings) VALUES 
    ('00000000-0000-0000-0000-000000000001', 'Default Organization', 'default.local', '{}');

INSERT INTO departments (id, organization_id, name, description) VALUES 
    ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'IT Department', 'Information Technology'),
    ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'HR Department', 'Human Resources'),
    ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'Sales Department', 'Sales and Marketing');

-- Insert default application categories
INSERT INTO application_categories (organization_id, application_name, category, confidence_score) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Visual Studio Code', 'productive', 1.0),
    ('00000000-0000-0000-0000-000000000001', 'Microsoft Word', 'productive', 1.0),
    ('00000000-0000-0000-0000-000000000001', 'Slack', 'productive', 0.8),
    ('00000000-0000-0000-0000-000000000001', 'Chrome', 'neutral', 0.6),
    ('00000000-0000-0000-0000-000000000001', 'Spotify', 'distracting', 0.9),
    ('00000000-0000-0000-0000-000000000001', 'Steam', 'distracting', 1.0);

-- Insert default website categories
INSERT INTO website_categories (organization_id, domain, category, confidence_score) VALUES
    ('00000000-0000-0000-0000-000000000001', 'github.com', 'productive', 1.0),
    ('00000000-0000-0000-0000-000000000001', 'stackoverflow.com', 'productive', 1.0),
    ('00000000-0000-0000-0000-000000000001', 'google.com', 'neutral', 0.7),
    ('00000000-0000-0000-0000-000000000001', 'youtube.com', 'distracting', 0.8),
    ('00000000-0000-0000-0000-000000000001', 'facebook.com', 'distracting', 1.0),
    ('00000000-0000-0000-0000-000000000001', 'twitter.com', 'distracting', 0.9);

-- Insert default data retention policies
INSERT INTO data_retention_policies (organization_id, data_type, retention_days, auto_delete, anonymize_after_days) VALUES
    ('00000000-0000-0000-0000-000000000001', 'screenshots', 90, true, 30),
    ('00000000-0000-0000-0000-000000000001', 'activities', 365, false, 90),
    ('00000000-0000-0000-0000-000000000001', 'locations', 30, true, 7),
    ('00000000-0000-0000-0000-000000000001', 'audit_logs', 2555, true, null); -- 7 years

COMMENT ON DATABASE current_database() IS 'Enterprise Productivity Monitoring System Database';
COMMENT ON TABLE users IS 'User accounts with role-based access control';
COMMENT ON TABLE activity_sessions IS 'User activity sessions with productivity categorization';
COMMENT ON TABLE screenshots IS 'Encrypted screenshot storage with privacy controls';
COMMENT ON TABLE productivity_scores IS 'Daily productivity scores and metrics';
COMMENT ON TABLE audit_logs IS 'Comprehensive audit trail for compliance';