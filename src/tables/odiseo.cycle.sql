-- Table: odiseo.cycle
-- Includes constraints and indexes

--

CREATE TABLE odiseo.cycle (
    id bigint NOT NULL,
    code character varying(10) NOT NULL,
    description character varying(100) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    month smallint,
    year smallint,
    weeks smallint,
    start_date date,
    end_date date,
    active boolean DEFAULT true,
    days smallint DEFAULT '5'::smallint NOT NULL,
    cycle_type_id bigint,
    company_id integer,
    type_template_id bigint
);


ALTER TABLE odiseo.cycle OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.cycle
    ADD CONSTRAINT cycle_pkey PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX idx_cycle_unique_active ON odiseo.cycle USING btree (code, description, company_id) WHERE ((fl_status IS TRUE) AND (deleted_at IS NULL));


--

--

ALTER TABLE ONLY odiseo.cycle
    ADD CONSTRAINT cycle_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE ONLY odiseo.cycle
    ADD CONSTRAINT cycle_type_template_id_foreign FOREIGN KEY (type_template_id) REFERENCES odiseo.type_templates(id);


--

--

ALTER TABLE ONLY odiseo.cycle
    ADD CONSTRAINT odiseo_cycle_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.cycle
    ADD CONSTRAINT odiseo_cycle_cycle_type_id_foreign FOREIGN KEY (cycle_type_id) REFERENCES odiseo.cycle_types(id);


--

--

ALTER TABLE ONLY odiseo.cycle
    ADD CONSTRAINT odiseo_cycle_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.cycle
    ADD CONSTRAINT odiseo_cycle_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
