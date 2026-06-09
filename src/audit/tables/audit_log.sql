-- Table: audit.audit_log
-- Includes constraints and indexes

--

CREATE TABLE audit.audit_log (
    id BIGINT NOT NULL,
    transaction_id UUID,
    table_name VARCHAR(70) NOT NULL,
    record_id VARCHAR NOT NULL,
    action VARCHAR(6) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    changed_by BIGINT,
    changed_at TIMESTAMPTZ DEFAULT now(),
    company_id INTEGER
);


ALTER TABLE audit.audit_log OWNER TO postgres;

--

--

ALTER TABLE audit.audit_log
    ADD CONSTRAINT pk_audit_log PRIMARY KEY (id);


--

--

CREATE INDEX idx_audit_log_changed_at ON audit.audit_log USING btree (changed_at);


--

--

CREATE INDEX idx_audit_log_changed_by ON audit.audit_log USING btree (changed_by);


--

--

CREATE INDEX idx_audit_log_table_name_record_id ON audit.audit_log USING btree (table_name, record_id);


--
