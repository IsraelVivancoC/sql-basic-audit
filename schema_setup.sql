/* Main user table. 
   We keep this table lightweight and simple to ensure a clear understanding of the 
   basics and fast lookups during authentication and profile queries, 
   even under stress testing.
*/
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL
);

/* AUDIT LOG STRATEGY:
   This table captures every change. 
   NOTE: This table could grow exponentially in a production environment. 
   We will address TABLE PARTITIONING in another repository to handle 
   long-term storage and performance properly.
*/
CREATE TABLE users_audit (
    audit_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    old_username VARCHAR(50),
    new_username VARCHAR(50),
    old_email VARCHAR(255),
    new_email VARCHAR(255),
    operation_type CHAR(6), 
    changed_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

/*
   TRIGGER LOGIC:
   We use the TG_OP variable to determine the database action.
   For further reference, check the official documentation 
   mentioned in the README.md.
   
   - UPDATES: Only logged if the username or email actually changes.
   - DELETES: Captures the final state of the user before removal.
*/
CREATE OR REPLACE FUNCTION process_user_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        IF (OLD.username <> NEW.username OR OLD.email <> NEW.email) THEN
            INSERT INTO users_audit (user_id, old_username, new_username, old_email, new_email, operation_type)
            VALUES (OLD.id, OLD.username, NEW.username, OLD.email, NEW.email, 'UPDATE');
        END IF;
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO users_audit (user_id, old_username, old_email, operation_type)
        VALUES (OLD.id, OLD.username, OLD.email, 'DELETE');
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

--Finally, we create the trigger which will call the function 
--Fire the trigger after the row is modified/deleted

CREATE TRIGGER trg_user_audit
AFTER UPDATE OR DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION process_user_audit();