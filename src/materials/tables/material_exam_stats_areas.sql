-- Table: materials.material_exam_stats_areas
-- Includes constraints and indexes

--

CREATE TABLE materials.material_exam_stats_areas (
    id bigint NOT NULL,
    material_exam_stats_global_id bigint NOT NULL,
    area_name character varying(100) NOT NULL,
    total_questions smallint DEFAULT '0'::smallint NOT NULL,
    new_questions smallint DEFAULT '0'::smallint NOT NULL,
    repeated_year smallint DEFAULT '0'::smallint NOT NULL,
    repeated_history smallint DEFAULT '0'::smallint NOT NULL,
    repeated_area smallint DEFAULT '0'::smallint NOT NULL,
    question_details jsonb DEFAULT '{}'::jsonb NOT NULL,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    area_id bigint NOT NULL
);


ALTER TABLE materials.material_exam_stats_areas OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_exam_stats_areas
    ADD CONSTRAINT material_exam_stats_areas_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_exam_stats_areas
    ADD CONSTRAINT material_exam_stats_areas_area_id_foreign FOREIGN KEY (area_id) REFERENCES odiseo.area(id);


--

--

ALTER TABLE ONLY materials.material_exam_stats_areas
    ADD CONSTRAINT material_exam_stats_areas_material_exam_stats_global_id_foreign FOREIGN KEY (material_exam_stats_global_id) REFERENCES materials.material_exam_stats_global(id) ON DELETE CASCADE;


--
