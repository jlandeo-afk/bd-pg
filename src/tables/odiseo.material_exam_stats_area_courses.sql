-- Table: odiseo.material_exam_stats_area_courses
-- Includes constraints and indexes

--

CREATE TABLE odiseo.material_exam_stats_area_courses (
    id bigint NOT NULL,
    area_stats_id bigint NOT NULL,
    course_name character varying(100) NOT NULL,
    total_questions smallint DEFAULT '0'::smallint NOT NULL,
    new_questions smallint DEFAULT '0'::smallint NOT NULL,
    repeated_year smallint DEFAULT '0'::smallint NOT NULL,
    repeated_history smallint DEFAULT '0'::smallint NOT NULL,
    repeated_area smallint DEFAULT '0'::smallint NOT NULL,
    question_details jsonb DEFAULT '{}'::jsonb,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    course_id bigint NOT NULL
);


ALTER TABLE odiseo.material_exam_stats_area_courses OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.material_exam_stats_area_courses
    ADD CONSTRAINT material_exam_stats_area_courses_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.material_exam_stats_area_courses
    ADD CONSTRAINT material_exam_stats_area_courses_area_stats_id_foreign FOREIGN KEY (area_stats_id) REFERENCES odiseo.material_exam_stats_areas(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY odiseo.material_exam_stats_area_courses
    ADD CONSTRAINT material_exam_stats_area_courses_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--
