-- Table: odiseo.type_text_exam_material_configuration
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_text_exam_material_configuration (
    id bigint NOT NULL,
    exam_material_config_id bigint NOT NULL,
    course_id bigint NOT NULL,
    area_id smallint,
    type_text_level_id smallint NOT NULL,
    text_amount smallint NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.type_text_exam_material_configuration OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_text_exam_material_configuration
    ADD CONSTRAINT type_text_exam_material_configuration_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.type_text_exam_material_configuration
    ADD CONSTRAINT unique_exam_course_area_level UNIQUE (exam_material_config_id, course_id, area_id, type_text_level_id);


--

--

ALTER TABLE ONLY odiseo.type_text_exam_material_configuration
    ADD CONSTRAINT type_text_exam_material_configuration_area_id_foreign FOREIGN KEY (area_id) REFERENCES odiseo.exam_area(id);


--

--

ALTER TABLE ONLY odiseo.type_text_exam_material_configuration
    ADD CONSTRAINT type_text_exam_material_configuration_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.type_text_exam_material_configuration
    ADD CONSTRAINT type_text_exam_material_configuration_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_text_exam_material_configuration
    ADD CONSTRAINT type_text_exam_material_configuration_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_text_exam_material_configuration
    ADD CONSTRAINT type_text_exam_material_configuration_exam_material_config_id_f FOREIGN KEY (exam_material_config_id) REFERENCES odiseo.exam_material_configurations(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY odiseo.type_text_exam_material_configuration
    ADD CONSTRAINT type_text_exam_material_configuration_type_text_level_id_foreig FOREIGN KEY (type_text_level_id) REFERENCES odiseo.type_text_level(id);


--

--

ALTER TABLE ONLY odiseo.type_text_exam_material_configuration
    ADD CONSTRAINT type_text_exam_material_configuration_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
