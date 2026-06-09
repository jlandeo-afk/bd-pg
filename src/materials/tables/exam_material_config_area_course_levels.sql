-- Table: materials.exam_material_config_area_course_levels
-- Includes constraints and indexes

--

CREATE TABLE materials.exam_material_config_area_course_levels (
    id smallint NOT NULL,
    exam_material_config_area_course_id BIGINT NOT NULL,
    level_id BIGINT NOT NULL,
    amount_question INTEGER DEFAULT 0 NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE materials.exam_material_config_area_course_levels OWNER TO postgres;

--

--

ALTER TABLE materials.exam_material_config_area_course_levels
    ADD CONSTRAINT pk_exam_material_config_area_course_levels PRIMARY KEY (id);


--

--

ALTER TABLE materials.exam_material_config_area_course_levels
    ADD CONSTRAINT fk_exam_material_config_area_course_levels_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.exam_material_config_area_course_levels
    ADD CONSTRAINT fk_exam_material_config_area_course_levels_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.exam_material_config_area_course_levels
    ADD CONSTRAINT fk_exam_material_config_area_course_levels_exam_material_config_area_course FOREIGN KEY (exam_material_config_area_course_id) REFERENCES materials.exam_material_config_area_courses(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.exam_material_config_area_course_levels
    ADD CONSTRAINT fk_exam_material_config_area_course_levels_level FOREIGN KEY (level_id) REFERENCES academic.level(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.exam_material_config_area_course_levels
    ADD CONSTRAINT fk_exam_material_config_area_course_levels_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--
