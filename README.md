#  SQL Basic Audit System

A foundational PostgreSQL implementation for automated data auditing. This project utilizes **PL/pgSQL triggers** to maintain a robust history of changes in sensitive user data.

## The Quick Start (ABC)
This system acts as an automated "watcher" for your database tables.

* **The Goal**: Maintain a permanent record of "Who, What, and When."
* **The Mechanism**: A Trigger fires a Function every time an `UPDATE` or `DELETE` occurs.
* **The Result**: Full traceability required for banking or medical-grade security.

### How to Run
1.  **Initialize**: Execute `schema_setup.sql` in your database.
2.  **Test**: Update a user's email: 
    ```sql
    UPDATE users SET email = 'new@email.com' WHERE id = 1;
    ```
3.  **Verify**: Check the history:
    ```sql
    SELECT * FROM users_audit;
    ```

---

## Deep Dive: Architecture & Strategy

> **Real-world Use Case**: 
> In medical or banking applications, changing a patient's or user's access permissions cannot simply overwrite data. You must preserve the "State" before and after the modification to ensure total integrity.

###  Components
* **Audit Table**: The permanent storage for our change history.
* **Function**: The logic that captures the "snapshot" of the data.
* **Trigger**: The automatic mechanism that executes logic during data modification.

### NOTE: Performance & Scalability 
While trigger-based auditing is excellent for integrity, it can impact performance during high-volume writes. Future iterations of this project will explore:

1.  **JSONB Audit**: Moving from fixed columns to dynamic JSONB for better flexibility.
2.  **The Correct Usage of Partitions**: For tables with millions of rows, we will implement **Table Partitioning** (e.g., by month/week) to keep queries lightning-fast.
3.  **CDC (Change Data Capture)**: Using tools like Debezium for zero-impact logging in massive production environments.

---

## References & Best Practices
* [PostgreSQL Official Documentation](https://www.postgresql.org/docs/current/plpgsql-trigger.html) — Technical reference for `TG_OP` and trigger execution.
* **ACID Compliance**: This architecture ensures *Atomicity* and *Durability* by keeping the audit log within the same transaction as the data change.

## Project Roadmap
This is **Part 1** of a 3-part series on database auditing. Links will be updated as repositories go live:

1.  ✅ **Basic Audit**: Manual column tracking (cOMMING).
2.  🧪 **[JSONB Audit](https://github.com/IsraelVivancoC/sql-jsonb-audit)**: Dynamic tracking for any table (Coming Soon).
3.  🏗️ **[High-Volume Audit](https://github.com/IsraelVivancoC/sql-partition-audit)**: Implementing **Table Partitioning** for scalability (Coming Soon).