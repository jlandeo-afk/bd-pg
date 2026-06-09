-- Table: materials.material_ballot_stats_area_courses
-- Includes constraints and indexes

--

CREATE TABLE materials.material_ballot_stats_area_courses (
    id bigint NOT NULL,
    area_stats_id bigint NOT NULL,
    course_name character varying(100) NOT NULL,
    total_questions smallint DEFAULT 0,
    new_questions smallint DEFAULT 0,
    repeated_year smallint DEFAULT 0,
    repeated_history smallint DEFAULT 0,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE materials.material_ballot_stats_area_courses OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_ballot_stats_area_courses
    ADD CONSTRAINT material_ballot_stats_area_courses_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_ballot_stats_area_courses
    ADD CONSTRAINT fk_stats_courses_area FOREIGN KEY (area_stats_id) REFERENCES materials.material_ballot_stats_areas(id) ON DELETE CASCADE;


--
