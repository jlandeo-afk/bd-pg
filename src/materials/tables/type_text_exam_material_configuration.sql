-- Table: materials.type_text_exam_material_configuration
-- Includes constraints and indexes

--

CREATE TABLE materials.type_text_exam_material_configuration (
    id BIGINT NOT NULL,
    exam_material_config_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    area_id smallint,
    type_text_level_id smallint NOT NULL,
    text_amount smallint NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE materials.type_text_exam_material_configuration OWNER TO postgres;

--

--

ALTER TABLE materials.type_text_exam_material_configuration
    ADD CONSTRAINT pk_type_text_exam_material_configuration PRIMARY KEY (id);


--

--

ALTER TABLE materials.type_text_exam_material_configuration
    ADD CONSTRAINT unique_exam_course_area_level UNIQUE (exam_material_config_id, course_id, area_id, type_text_level_id);


--

--

ALTER TABLE materials.type_text_exam_material_configuration
    ADD CONSTRAINT fk_type_text_exam_material_configuration_area FOREIGN KEY (area_id) REFERENCES odiseo.exam_area(id);


--

--

ALTER TABLE materials.type_text_exam_material_configuration
    ADD CONSTRAINT fk_type_text_exam_material_configuration_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.type_text_exam_material_configuration
    ADD CONSTRAINT fk_type_text_exam_material_configuration_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_text_exam_material_configuration
    ADD CONSTRAINT fk_type_text_exam_material_configuration_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_text_exam_material_configuration
    ADD CONSTRAINT fk_type_text_exam_material_configuration_exam_material_config FOREIGN KEY (exam_material_config_id) REFERENCES materials.exam_material_configurations(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.type_text_exam_material_configuration
    ADD CONSTRAINT fk_type_text_exam_material_configuration_type_text_level FOREIGN KEY (type_text_level_id) REFERENCES common.type_text_level(id);


--

--

ALTER TABLE materials.type_text_exam_material_configuration
    ADD CONSTRAINT fk_type_text_exam_material_configuration_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
