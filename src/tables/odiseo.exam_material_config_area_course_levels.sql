-- Table: odiseo.exam_material_config_area_course_levels
-- Includes constraints and indexes

--

CREATE TABLE odiseo.exam_material_config_area_course_levels (
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


ALTER TABLE odiseo.exam_material_config_area_course_levels OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.exam_material_config_area_course_levels
    ADD CONSTRAINT exam_material_config_area_course_levels_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.exam_material_config_area_course_levels
    ADD CONSTRAINT odiseo_exam_material_config_area_course_levels_created_by_forei FOREIGN KEY (created_by) REFERENCES odiseo.users(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY odiseo.exam_material_config_area_course_levels
    ADD CONSTRAINT odiseo_exam_material_config_area_course_levels_deleted_by_forei FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY odiseo.exam_material_config_area_course_levels
    ADD CONSTRAINT odiseo_exam_material_config_area_course_levels_exam_material_co FOREIGN KEY (exam_material_config_area_course_id) REFERENCES odiseo.exam_material_config_area_courses(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY odiseo.exam_material_config_area_course_levels
    ADD CONSTRAINT odiseo_exam_material_config_area_course_levels_level_id_foreign FOREIGN KEY (level_id) REFERENCES odiseo.level(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY odiseo.exam_material_config_area_course_levels
    ADD CONSTRAINT odiseo_exam_material_config_area_course_levels_updated_by_forei FOREIGN KEY (updated_by) REFERENCES odiseo.users(id) ON DELETE CASCADE;


--
