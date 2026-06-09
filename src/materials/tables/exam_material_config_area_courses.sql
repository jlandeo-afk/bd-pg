-- Table: materials.exam_material_config_area_courses
-- Includes constraints and indexes

--

CREATE TABLE materials.exam_material_config_area_courses (
    id smallint NOT NULL,
    exam_material_config_id bigint NOT NULL,
    course_id bigint NOT NULL,
    exam_area_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    amount_type_d integer
);


ALTER TABLE materials.exam_material_config_area_courses OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.exam_material_config_area_courses
    ADD CONSTRAINT exam_material_config_area_courses_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.exam_material_config_area_courses
    ADD CONSTRAINT odiseo_exam_material_config_area_courses_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY materials.exam_material_config_area_courses
    ADD CONSTRAINT odiseo_exam_material_config_area_courses_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY materials.exam_material_config_area_courses
    ADD CONSTRAINT odiseo_exam_material_config_area_courses_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY materials.exam_material_config_area_courses
    ADD CONSTRAINT odiseo_exam_material_config_area_courses_exam_area_id_foreign FOREIGN KEY (exam_area_id) REFERENCES odiseo.exam_area(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY materials.exam_material_config_area_courses
    ADD CONSTRAINT odiseo_exam_material_config_area_courses_exam_material_config_i FOREIGN KEY (exam_material_config_id) REFERENCES materials.exam_material_configurations(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY materials.exam_material_config_area_courses
    ADD CONSTRAINT odiseo_exam_material_config_area_courses_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--
