-- Table: odiseo.type_templates
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_templates (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    "default" boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    company_id integer
);


ALTER TABLE odiseo.type_templates OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_templates
    ADD CONSTRAINT odiseo_type_templates_name_unique UNIQUE (name);


--

--

ALTER TABLE ONLY odiseo.type_templates
    ADD CONSTRAINT type_templates_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.type_templates
    ADD CONSTRAINT type_templates_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--
