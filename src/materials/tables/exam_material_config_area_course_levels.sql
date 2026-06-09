-- Table: materials.exam_material_config_area_course_levels
-- Includes constraints and indexes

--

CREATE TABLE materials.exam_material_config_area_course_levels (
    id smallint NOT NULL,
    exam_material_config_area_course_id bigint NOT NULL,
    level_id bigint NOT NULL,
    amount_question integer DEFAULT 0 NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE materials.exam_material_config_area_course_levels OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.exam_material_config_area_course_levels
    ADD CONSTRAINT exam_material_config_area_course_levels_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.exam_material_config_area_course_levels
    ADD CONSTRAINT odiseo_exam_material_config_area_course_levels_created_by_forei FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY materials.exam_material_config_area_course_levels
    ADD CONSTRAINT odiseo_exam_material_config_area_course_levels_deleted_by_forei FOREIGN KEY (deleted_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY materials.exam_material_config_area_course_levels
    ADD CONSTRAINT odiseo_exam_material_config_area_course_levels_exam_material_co FOREIGN KEY (exam_material_config_area_course_id) REFERENCES materials.exam_material_config_area_courses(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY materials.exam_material_config_area_course_levels
    ADD CONSTRAINT odiseo_exam_material_config_area_course_levels_level_id_foreign FOREIGN KEY (level_id) REFERENCES academic.level(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY materials.exam_material_config_area_course_levels
    ADD CONSTRAINT odiseo_exam_material_config_area_course_levels_updated_by_forei FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--
