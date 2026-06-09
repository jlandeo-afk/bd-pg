-- Table: materials.material_exam_stats_areas
-- Includes constraints and indexes

--

CREATE TABLE materials.material_exam_stats_areas (
    id BIGINT NOT NULL,
    material_exam_stats_global_id BIGINT NOT NULL,
    area_name VARCHAR(100) NOT NULL,
    total_questions smallint DEFAULT '0'::smallint NOT NULL,
    new_questions smallint DEFAULT '0'::smallint NOT NULL,
    repeated_year smallint DEFAULT '0'::smallint NOT NULL,
    repeated_history smallint DEFAULT '0'::smallint NOT NULL,
    repeated_area smallint DEFAULT '0'::smallint NOT NULL,
    question_details JSONB DEFAULT '{}'::JSONB NOT NULL,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    area_id BIGINT NOT NULL
);


ALTER TABLE materials.material_exam_stats_areas OWNER TO postgres;

--

--

ALTER TABLE materials.material_exam_stats_areas
    ADD CONSTRAINT pk_material_exam_stats_areas PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_exam_stats_areas
    ADD CONSTRAINT fk_material_exam_stats_areas_area FOREIGN KEY (area_id) REFERENCES odiseo.area(id);


--

--

ALTER TABLE materials.material_exam_stats_areas
    ADD CONSTRAINT fk_material_exam_stats_areas_material_exam_stats_global FOREIGN KEY (material_exam_stats_global_id) REFERENCES materials.material_exam_stats_global(id) ON DELETE CASCADE;


--
