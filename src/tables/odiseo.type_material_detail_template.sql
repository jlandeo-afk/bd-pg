-- Table: odiseo.type_material_detail_template
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_material_detail_template (
    id bigint NOT NULL,
    type_material_id smallint NOT NULL,
    week smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.type_material_detail_template OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_material_detail_template
    ADD CONSTRAINT type_material_detail_template_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.type_material_detail_template
    ADD CONSTRAINT odiseo_type_material_detail_template_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_material_detail_template
    ADD CONSTRAINT odiseo_type_material_detail_template_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_material_detail_template
    ADD CONSTRAINT odiseo_type_material_detail_template_type_material_id_foreign FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE ONLY odiseo.type_material_detail_template
    ADD CONSTRAINT odiseo_type_material_detail_template_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
