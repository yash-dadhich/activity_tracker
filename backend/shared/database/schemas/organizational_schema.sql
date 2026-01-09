-- Organizational Hierarchy Schema
-- This schema supports multi-tenant architecture with organizations, companies, and departments

-- Organizations Table (Top Level)
CREATE TABLE organizations (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    logo_url VARCHAR(500),
    website VARCHAR(255),
    industry VARCHAR(100),
    size VARCHAR(50), -- small, medium, large, enterprise
    subscription_plan VARCHAR(50) DEFAULT 'free', -- free, basic, professional, enterprise
    subscription_status VARCHAR(50) DEFAULT 'active', -- active, suspended, cancelled
    subscription_expires_at TIMESTAMP,
    max_users INTEGER DEFAULT 10,
    max_companies INTEGER DEFAULT 1,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'
);

-- Companies Table (Under Organizations)
CREATE TABLE companies (
    id VARCHAR(50) PRIMARY KEY,
    organization_id VARCHAR(50) NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    email VARCHAR(255),
    industry VARCHAR(100),
    size VARCHAR(50),
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'
);

-- Departments Table (Under Companies)
CREATE TABLE departments (
    id VARCHAR(50) PRIMARY KEY,
    company_id VARCHAR(50) NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    organization_id VARCHAR(50) NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    manager_id VARCHAR(50), -- References users table
    parent_department_id VARCHAR(50) REFERENCES departments(id), -- For sub-departments
    cost_center VARCHAR(50),
    budget DECIMAL(15, 2),
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'
);

-- Extended Users Table
CREATE TABLE users (
    id VARCHAR(50) PRIMARY KEY,
    organization_id VARCHAR(50) REFERENCES organizations(id) ON DELETE CASCADE,
    company_id VARCHAR(50) REFERENCES companies(id) ON DELETE SET NULL,
    department_id VARCHAR(50) REFERENCES departments(id) ON DELETE SET NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL, -- super_admin, admin, manager, team_lead, employee, tester, approver
    manager_id VARCHAR(50) REFERENCES users(id) ON DELETE SET NULL,
    employee_id VARCHAR(50) UNIQUE,
    phone VARCHAR(50),
    avatar_url VARCHAR(500),
    job_title VARCHAR(100),
    employment_type VARCHAR(50), -- full_time, part_time, contract, intern
    hire_date DATE,
    termination_date DATE,
    status VARCHAR(50) DEFAULT 'active', -- active, inactive, suspended, terminated
    last_login_at TIMESTAMP,
    last_activity_at TIMESTAMP,
    preferences JSONB DEFAULT '{}',
    privacy_settings JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50),
    metadata JSONB DEFAULT '{}'
);

-- Roles Table
CREATE TABLE roles (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    level INTEGER NOT NULL, -- 1=super_admin, 2=admin, 3=manager, 4=team_lead, 5=employee
    is_system_role BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Permissions Table
CREATE TABLE permissions (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    resource VARCHAR(100) NOT NULL, -- organizations, companies, departments, users, activities, etc.
    action VARCHAR(50) NOT NULL, -- create, read, update, delete, manage
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Role Permissions Mapping
CREATE TABLE role_permissions (
    id VARCHAR(50) PRIMARY KEY,
    role_id VARCHAR(50) NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id VARCHAR(50) NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(role_id, permission_id)
);

-- User Roles Mapping (for multiple roles per user)
CREATE TABLE user_roles (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id VARCHAR(50) NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    organization_id VARCHAR(50) REFERENCES organizations(id) ON DELETE CASCADE,
    company_id VARCHAR(50) REFERENCES companies(id) ON DELETE CASCADE,
    department_id VARCHAR(50) REFERENCES departments(id) ON DELETE CASCADE,
    assigned_by VARCHAR(50) REFERENCES users(id),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(user_id, role_id, organization_id, company_id, department_id)
);

-- Team Members Mapping
CREATE TABLE team_members (
    id VARCHAR(50) PRIMARY KEY,
    team_lead_id VARCHAR(50) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    member_id VARCHAR(50) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    department_id VARCHAR(50) REFERENCES departments(id) ON DELETE CASCADE,
    role_in_team VARCHAR(50), -- developer, tester, designer, etc.
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by VARCHAR(50) REFERENCES users(id),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(team_lead_id, member_id)
);

-- Audit Log for Administrative Actions
CREATE TABLE admin_audit_log (
    id VARCHAR(50) PRIMARY KEY,
    organization_id VARCHAR(50) REFERENCES organizations(id) ON DELETE CASCADE,
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL, -- create_organization, add_user, change_role, etc.
    resource_type VARCHAR(50) NOT NULL, -- organization, company, department, user
    resource_id VARCHAR(50),
    old_value JSONB,
    new_value JSONB,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- Indexes for Performance
CREATE INDEX idx_companies_org ON companies(organization_id);
CREATE INDEX idx_departments_company ON departments(company_id);
CREATE INDEX idx_departments_org ON departments(organization_id);
CREATE INDEX idx_users_org ON users(organization_id);
CREATE INDEX idx_users_company ON users(company_id);
CREATE INDEX idx_users_department ON users(department_id);
CREATE INDEX idx_users_manager ON users(manager_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role_id);
CREATE INDEX idx_team_members_lead ON team_members(team_lead_id);
CREATE INDEX idx_team_members_member ON team_members(member_id);
CREATE INDEX idx_audit_log_org ON admin_audit_log(organization_id);
CREATE INDEX idx_audit_log_user ON admin_audit_log(user_id);
CREATE INDEX idx_audit_log_created ON admin_audit_log(created_at);

-- Insert Default Roles
INSERT INTO roles (id, name, display_name, description, level, is_system_role) VALUES
('role-super-admin', 'super_admin', 'Super Administrator', 'Full system access across all organizations', 1, true),
('role-admin', 'admin', 'Administrator', 'Organization-level administrator', 2, true),
('role-manager', 'manager', 'Manager', 'Department or team manager', 3, true),
('role-team-lead', 'team_lead', 'Team Lead', 'Team leader with limited management capabilities', 4, true),
('role-employee', 'employee', 'Employee', 'Regular employee', 5, true),
('role-tester', 'tester', 'Tester', 'Quality assurance tester', 5, true),
('role-approver', 'approver', 'Approver', 'Task approver', 4, true);

-- Insert Default Permissions
INSERT INTO permissions (id, name, display_name, description, resource, action) VALUES
-- Organization permissions
('perm-org-create', 'organizations.create', 'Create Organizations', 'Create new organizations', 'organizations', 'create'),
('perm-org-read', 'organizations.read', 'View Organizations', 'View organization details', 'organizations', 'read'),
('perm-org-update', 'organizations.update', 'Update Organizations', 'Update organization details', 'organizations', 'update'),
('perm-org-delete', 'organizations.delete', 'Delete Organizations', 'Delete organizations', 'organizations', 'delete'),
('perm-org-manage', 'organizations.manage', 'Manage Organizations', 'Full organization management', 'organizations', 'manage'),

-- Company permissions
('perm-company-create', 'companies.create', 'Create Companies', 'Create new companies', 'companies', 'create'),
('perm-company-read', 'companies.read', 'View Companies', 'View company details', 'companies', 'read'),
('perm-company-update', 'companies.update', 'Update Companies', 'Update company details', 'companies', 'update'),
('perm-company-delete', 'companies.delete', 'Delete Companies', 'Delete companies', 'companies', 'delete'),

-- Department permissions
('perm-dept-create', 'departments.create', 'Create Departments', 'Create new departments', 'departments', 'create'),
('perm-dept-read', 'departments.read', 'View Departments', 'View department details', 'departments', 'read'),
('perm-dept-update', 'departments.update', 'Update Departments', 'Update department details', 'departments', 'update'),
('perm-dept-delete', 'departments.delete', 'Delete Departments', 'Delete departments', 'departments', 'delete'),

-- User permissions
('perm-user-create', 'users.create', 'Create Users', 'Create new users', 'users', 'create'),
('perm-user-read', 'users.read', 'View Users', 'View user details', 'users', 'read'),
('perm-user-update', 'users.update', 'Update Users', 'Update user details', 'users', 'update'),
('perm-user-delete', 'users.delete', 'Delete Users', 'Delete users', 'users', 'delete'),
('perm-user-manage-roles', 'users.manage_roles', 'Manage User Roles', 'Assign and revoke user roles', 'users', 'manage'),

-- Activity permissions
('perm-activity-read-own', 'activities.read_own', 'View Own Activities', 'View own activity logs', 'activities', 'read'),
('perm-activity-read-team', 'activities.read_team', 'View Team Activities', 'View team member activities', 'activities', 'read'),
('perm-activity-read-all', 'activities.read_all', 'View All Activities', 'View all activities in organization', 'activities', 'read'),

-- Report permissions
('perm-report-generate', 'reports.generate', 'Generate Reports', 'Generate activity reports', 'reports', 'create'),
('perm-report-export', 'reports.export', 'Export Reports', 'Export reports to various formats', 'reports', 'create'),

-- System permissions
('perm-system-settings', 'system.settings', 'System Settings', 'Manage system-wide settings', 'system', 'manage'),
('perm-system-analytics', 'system.analytics', 'System Analytics', 'View system-wide analytics', 'system', 'read');

-- Assign Permissions to Roles

-- Super Admin gets all permissions
INSERT INTO role_permissions (id, role_id, permission_id)
SELECT 
    'rp-super-' || permissions.id,
    'role-super-admin',
    permissions.id
FROM permissions;

-- Admin gets organization-level permissions
INSERT INTO role_permissions (id, role_id, permission_id)
SELECT 
    'rp-admin-' || permissions.id,
    'role-admin',
    permissions.id
FROM permissions
WHERE permissions.name IN (
    'companies.create', 'companies.read', 'companies.update', 'companies.delete',
    'departments.create', 'departments.read', 'departments.update', 'departments.delete',
    'users.create', 'users.read', 'users.update', 'users.delete', 'users.manage_roles',
    'activities.read_all', 'reports.generate', 'reports.export'
);

-- Manager gets team-level permissions
INSERT INTO role_permissions (id, role_id, permission_id)
SELECT 
    'rp-manager-' || permissions.id,
    'role-manager',
    permissions.id
FROM permissions
WHERE permissions.name IN (
    'departments.read', 'users.read', 'activities.read_team', 'reports.generate'
);

-- Team Lead gets limited team permissions
INSERT INTO role_permissions (id, role_id, permission_id)
SELECT 
    'rp-lead-' || permissions.id,
    'role-team-lead',
    permissions.id
FROM permissions
WHERE permissions.name IN (
    'users.read', 'activities.read_team', 'reports.generate'
);

-- Employee gets own data permissions
INSERT INTO role_permissions (id, role_id, permission_id)
SELECT 
    'rp-employee-' || permissions.id,
    'role-employee',
    permissions.id
FROM permissions
WHERE permissions.name IN (
    'activities.read_own'
);
