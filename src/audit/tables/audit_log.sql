-- Table: audit.audit_log
-- Includes constraints and indexes

--

CREATE TABLE audit.audit_log (
    id bigint NOT NULL,
    transaction_id uuid,
    table_name character varying(70) NOT NULL,
    record_id character varying NOT NULL,
    action character varying(6) NOT NULL,
    old_data jsonb,
    new_data jsonb,
    changed_by bigint,
    changed_at timestamp with time zone DEFAULT now(),
    company_id integer
);


ALTER TABLE audit.audit_log OWNER TO postgres;

--

--

ALTER TABLE ONLY audit.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_audit_changed_at ON audit.audit_log USING btree (changed_at);


--

--

CREATE INDEX idx_audit_changed_by ON audit.audit_log USING btree (changed_by);


--

--

CREATE INDEX idx_audit_table_record ON audit.audit_log USING btree (table_name, record_id);


--
