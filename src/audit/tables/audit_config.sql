-- Table: audit.audit_config
-- Includes constraints and indexes

--

CREATE TABLE audit.audit_config (
    id INTEGER NOT NULL,
    table_name VARCHAR NOT NULL,
    fl_active BOOLEAN DEFAULT true NOT NULL,
    updated_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT now()
);


ALTER TABLE audit.audit_config OWNER TO postgres;

--

--

ALTER TABLE audit.audit_config
    ADD CONSTRAINT pk_audit_config PRIMARY KEY (id);


--

--

ALTER TABLE audit.audit_config
    ADD CONSTRAINT audit_config_table_name_key UNIQUE (table_name);


--
