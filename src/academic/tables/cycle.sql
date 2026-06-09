-- Table: academic.cycle
-- Includes constraints and indexes

--

CREATE TABLE academic.cycle (
    id BIGINT NOT NULL,
    code VARCHAR(10) NOT NULL,
    description VARCHAR(100) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    month smallint,
    year smallint,
    weeks smallint,
    start_date DATE,
    end_date DATE,
    active BOOLEAN DEFAULT true,
    days smallint DEFAULT '5'::smallint NOT NULL,
    cycle_type_id BIGINT,
    company_id INTEGER,
    type_template_id BIGINT
);


ALTER TABLE academic.cycle OWNER TO postgres;

--

--

ALTER TABLE academic.cycle
    ADD CONSTRAINT pk_cycle PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX uq_cycle_code_description_company_id ON academic.cycle USING btree (code, description, company_id) WHERE ((fl_status IS TRUE) AND (deleted_at IS NULL));


--

--

ALTER TABLE academic.cycle
    ADD CONSTRAINT fk_cycle_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE academic.cycle
    ADD CONSTRAINT fk_cycle_type_template FOREIGN KEY (type_template_id) REFERENCES common.type_templates(id);


--

--

ALTER TABLE academic.cycle
    ADD CONSTRAINT fk_cycle_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.cycle
    ADD CONSTRAINT fk_cycle_cycle_type FOREIGN KEY (cycle_type_id) REFERENCES academic.cycle_types(id);


--

--

ALTER TABLE academic.cycle
    ADD CONSTRAINT fk_cycle_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.cycle
    ADD CONSTRAINT fk_cycle_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
