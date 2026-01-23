# SQL Dynamic JSONB Audit System

A high-flexibility PostgreSQL implementation for automated data auditing. This project evolves from fixed-column logging (Part 1) to **schema-agnostic auditing** using the **JSONB** data type.

## Prerequisites

- PostgreSQL 12+ (Full JSONB support)
- Superuser or `CREATE` privileges on the target schema

## The Evolution: Why JSONB?
In **Part 1**, we tracked specific columns manually. While secure, it required constant maintenance. **Part 2** introduces a system that captures the entire row state. This allows the audit logic to automatically adapt when you add, rename, or remove columns from your business tables.

* **The Goal**: Zero-maintenance auditing for dynamic schemas.
* **The Mechanism**: A Generic Trigger Function converts `OLD` and `NEW` records into JSONB objects.
* **The Result**: A centralized, searchable history of every change across your entire database.

---

## Deep Dive: Architecture & Strategy

> **Real-world Use Case**: 
> In modern SaaS platforms, table structures evolve rapidly. By using JSONB, your audit trail never breaks when a developer adds a new feature or column. You gain **Total Traceability** without the technical debt of updating audit schemas.

### Components
* **Centralized Audit Table**: One table (`audit_log_json`) that stores logs for the entire database.
* **Generic Function**: A single piece of logic (`fn_audit_jsonb_changes`) that handles any table regardless of its structure.
* **JSONB Operators**: Leverages PostgreSQL's power to query inside the audit logs as if they were standard columns.

### Implementation (The "ABC")

1.  **Initialize**: Execute the `jsonb_audit_setup.sql` script.
2.  **Attach**: Link the generic function to your target table:
    ```sql
    CREATE TRIGGER trg_audit_any_table
    AFTER INSERT OR UPDATE OR DELETE ON your_table_name
    FOR EACH ROW EXECUTE FUNCTION fn_audit_jsonb_changes();
    ```
3.  **Search**: Query specific changes using JSON syntax:
    ```sql
    -- Find changes where the 'price' was updated to a value greater than 100
    SELECT * FROM audit_log_json 
    WHERE (new_data->>'price')::numeric > 100;
    ```

---

## Performance & Scalability 
While JSONB is highly flexible, storing large JSON objects for every change can increase storage requirements. To handle massive production environments, we will explore:

1.  **Index Optimization**: Using GIN indexes on JSONB columns for lightning-fast history searches.
2.  **Part 3: Table Partitioning**: Splitting the audit table by date (e.g., `audit_log_2024_01`) to maintain performance as the log grows into millions of rows.

---

## Project Roadmap
This is **Part 2** of a 3-part series on database auditing.

1.  **Basic Audit**: Manual column tracking (Completed).
2.  **JSONB Audit**: Dynamic tracking for any table (**Current Version**).
3.  **[High-Volume Audit]**: Implementing **Table Partitioning** for multi-million row scalability (Coming Soon).

---

## References & Best Practices
* [PostgreSQL JSON Types](https://www.postgresql.org/docs/current/datatype-json.html) — Understanding the power of JSONB.
* **Schema-Agnostic Design**: Best practices for building systems that adapt to data changes.