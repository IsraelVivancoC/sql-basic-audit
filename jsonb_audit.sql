
-- STEP 2: DYNAMIC JSONB AUDIT
-- Description: This script implements a dynamic auditing 
-- system that stores row changes in JSONB format.

-- we create the "centralized" audit table
CREATE TABLE IF NOT EXISTS audit_log_json (
    id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    operation_type TEXT NOT NULL, -- INSERT, UPDATE, DELETE
    old_data JSONB,               -- State BEFORE the change
    new_data JSONB,               -- State AFTER the change
    changed_by TEXT DEFAULT current_user,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- then a trigger function
-- NOTE This function can be reused by ANY table in the database


CREATE OR REPLACE FUNCTION fn_audit_jsonb_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log_json (table_name, operation_type, old_data, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(OLD), to_jsonb(NEW));
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log_json (table_name, operation_type, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(NEW));
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log_json (table_name, operation_type, old_data)
        VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(OLD));
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- how to enable it for a table?
-- CREATE TRIGGER trg_audit_users
-- AFTER INSERT OR UPDATE OR DELETE ON your_table_name
-- FOR EACH ROW EXECUTE FUNCTION fn_audit_jsonb_changes();