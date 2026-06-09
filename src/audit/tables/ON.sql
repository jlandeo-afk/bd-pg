-- Table: audit.ON
-- Includes constraints and indexes

--

CREATE INDEX idx_audit_transaction ON audit.audit_log USING btree (transaction_id);


--
