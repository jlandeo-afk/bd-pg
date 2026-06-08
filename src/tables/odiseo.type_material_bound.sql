-- Table: odiseo.type_material_bound
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_material_bound (
    id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    type_material_template_id bigint,
    type_material_template_extra_id bigint
);


ALTER TABLE odiseo.type_material_bound OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_material_bound
    ADD CONSTRAINT type_material_bound_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.type_material_bound
    ADD CONSTRAINT type_material_bound_unique_pair UNIQUE (type_material_template_id, type_material_template_extra_id);


--

--

ALTER TABLE ONLY odiseo.type_material_bound
    ADD CONSTRAINT odiseo_type_material_bound_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_material_bound
    ADD CONSTRAINT odiseo_type_material_bound_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_material_bound
    ADD CONSTRAINT odiseo_type_material_bound_type_material_template_extra_id_fore FOREIGN KEY (type_material_template_extra_id) REFERENCES odiseo.type_material_template(id);


--

--

ALTER TABLE ONLY odiseo.type_material_bound
    ADD CONSTRAINT odiseo_type_material_bound_type_material_template_id_foreign FOREIGN KEY (type_material_template_id) REFERENCES odiseo.type_material_template(id);


--

--

ALTER TABLE ONLY odiseo.type_material_bound
    ADD CONSTRAINT odiseo_type_material_bound_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
