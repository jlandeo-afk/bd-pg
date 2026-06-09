-- Table: materials.exam_material_config_area_courses
-- Includes constraints and indexes

--

CREATE TABLE materials.exam_material_config_area_courses (
    id smallint NOT NULL,
    exam_material_config_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    exam_area_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    amount_type_d INTEGER
);


ALTER TABLE materials.exam_material_config_area_courses OWNER TO postgres;

--

--

ALTER TABLE materials.exam_material_config_area_courses
    ADD CONSTRAINT pk_exam_material_config_area_courses PRIMARY KEY (id);


--

--

ALTER TABLE materials.exam_material_config_area_courses
    ADD CONSTRAINT fk_exam_material_config_area_courses_course FOREIGN KEY (course_id) REFERENCES academic.course(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.exam_material_config_area_courses
    ADD CONSTRAINT fk_exam_material_config_area_courses_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.exam_material_config_area_courses
    ADD CONSTRAINT fk_exam_material_config_area_courses_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.exam_material_config_area_courses
    ADD CONSTRAINT fk_exam_material_config_area_courses_exam_area FOREIGN KEY (exam_area_id) REFERENCES odiseo.exam_area(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.exam_material_config_area_courses
    ADD CONSTRAINT fk_exam_material_config_area_courses_exam_material_config FOREIGN KEY (exam_material_config_id) REFERENCES materials.exam_material_configurations(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.exam_material_config_area_courses
    ADD CONSTRAINT fk_exam_material_config_area_courses_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--
