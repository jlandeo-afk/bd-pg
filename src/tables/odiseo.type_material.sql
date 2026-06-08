-- Table: odiseo.type_material
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_material (
    id smallint NOT NULL,
    description character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    code character varying(4),
    amount_question integer DEFAULT 0 NOT NULL,
    fl_exam boolean DEFAULT false NOT NULL,
    type_material_template_id bigint,
    fl_class_material boolean DEFAULT false NOT NULL,
    thread smallint DEFAULT '1'::smallint NOT NULL,
    percentage numeric(5,2) DEFAULT '30'::numeric NOT NULL,
    parent_id bigint,
    level_order boolean DEFAULT false NOT NULL,
    company_id bigint DEFAULT '1'::bigint NOT NULL,
    "position" smallint DEFAULT '0'::smallint NOT NULL,
    order_date timestamp(0) without time zone,
    cycle_id bigint
);


ALTER TABLE odiseo.type_material OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_material
    ADD CONSTRAINT type_material_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.type_material
    ADD CONSTRAINT odiseo_type_material_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_material
    ADD CONSTRAINT odiseo_type_material_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_material
    ADD CONSTRAINT odiseo_type_material_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE ONLY odiseo.type_material
    ADD CONSTRAINT odiseo_type_material_type_material_template_id_foreign FOREIGN KEY (type_material_template_id) REFERENCES odiseo.type_material_template(id);


--

--

ALTER TABLE ONLY odiseo.type_material
    ADD CONSTRAINT odiseo_type_material_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_material
    ADD CONSTRAINT type_material_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE ONLY odiseo.type_material
    ADD CONSTRAINT type_material_cycle_id_foreign FOREIGN KEY (cycle_id) REFERENCES odiseo.cycle(id);


--
