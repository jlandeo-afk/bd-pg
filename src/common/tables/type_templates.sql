-- Table: common.type_templates
-- Includes constraints and indexes

--

CREATE TABLE common.type_templates (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    "DEFAULT" BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    company_id INTEGER
);


ALTER TABLE common.type_templates OWNER TO postgres;

--

--

ALTER TABLE common.type_templates
    ADD CONSTRAINT odiseo_type_templates_name_unique UNIQUE (name);


--

--

ALTER TABLE common.type_templates
    ADD CONSTRAINT pk_type_templates PRIMARY KEY (id);


--

--

ALTER TABLE common.type_templates
    ADD CONSTRAINT fk_type_templates_company FOREIGN KEY (company_id) REFERENCES organization.companies(id);


--
