-- Table: materials.material_ballot_stats_area_courses
-- Includes constraints and indexes

--

CREATE TABLE materials.material_ballot_stats_area_courses (
    id BIGINT NOT NULL,
    area_stats_id BIGINT NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    total_questions smallint DEFAULT 0,
    new_questions smallint DEFAULT 0,
    repeated_year smallint DEFAULT 0,
    repeated_history smallint DEFAULT 0,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE materials.material_ballot_stats_area_courses OWNER TO postgres;

--

--

ALTER TABLE materials.material_ballot_stats_area_courses
    ADD CONSTRAINT pk_material_ballot_stats_area_courses PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_ballot_stats_area_courses
    ADD CONSTRAINT fk_material_ballot_stats_area_courses_area_stats FOREIGN KEY (area_stats_id) REFERENCES materials.material_ballot_stats_areas(id) ON DELETE CASCADE;


--
