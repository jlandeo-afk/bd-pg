-- Table: audit.ON
-- Includes constraints and indexes

--

CREATE INDEX idx_ON_transaction_id ON audit.audit_log USING btree (transaction_id);


--
