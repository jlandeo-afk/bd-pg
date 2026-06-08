-- Table: odiseo.type_material_area
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_material_area (
    id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    type_material_id smallint NOT NULL,
    area_id smallint NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint
);


ALTER TABLE odiseo.type_material_area OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_material_area
    ADD CONSTRAINT type_material_area_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.type_material_area
    ADD CONSTRAINT odiseo_type_material_area_area_id_foreign FOREIGN KEY (area_id) REFERENCES odiseo.exam_area(id);


--

--

ALTER TABLE ONLY odiseo.type_material_area
    ADD CONSTRAINT odiseo_type_material_area_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_material_area
    ADD CONSTRAINT odiseo_type_material_area_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_material_area
    ADD CONSTRAINT odiseo_type_material_area_type_material_id_foreign FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE ONLY odiseo.type_material_area
    ADD CONSTRAINT odiseo_type_material_area_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
