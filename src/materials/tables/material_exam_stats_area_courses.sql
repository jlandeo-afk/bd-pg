-- Table: materials.material_exam_stats_area_courses
-- Includes constraints and indexes

--

CREATE TABLE materials.material_exam_stats_area_courses (
    id BIGINT NOT NULL,
    area_stats_id BIGINT NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    total_questions smallint DEFAULT '0'::smallint NOT NULL,
    new_questions smallint DEFAULT '0'::smallint NOT NULL,
    repeated_year smallint DEFAULT '0'::smallint NOT NULL,
    repeated_history smallint DEFAULT '0'::smallint NOT NULL,
    repeated_area smallint DEFAULT '0'::smallint NOT NULL,
    question_details JSONB DEFAULT '{}'::JSONB,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    course_id BIGINT NOT NULL
);


ALTER TABLE materials.material_exam_stats_area_courses OWNER TO postgres;

--

--

ALTER TABLE materials.material_exam_stats_area_courses
    ADD CONSTRAINT pk_material_exam_stats_area_courses PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_exam_stats_area_courses
    ADD CONSTRAINT fk_material_exam_stats_area_courses_area_stats FOREIGN KEY (area_stats_id) REFERENCES materials.material_exam_stats_areas(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.material_exam_stats_area_courses
    ADD CONSTRAINT fk_material_exam_stats_area_courses_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--
