-- Table: audit.audit_config
-- Includes constraints and indexes

--

CREATE TABLE audit.audit_config (
    id integer NOT NULL,
    table_name character varying NOT NULL,
    fl_active boolean DEFAULT true NOT NULL,
    updated_by bigint,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE audit.audit_config OWNER TO postgres;

--

--

ALTER TABLE ONLY audit.audit_config
    ADD CONSTRAINT audit_config_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY audit.audit_config
    ADD CONSTRAINT audit_config_table_name_key UNIQUE (table_name);


--
