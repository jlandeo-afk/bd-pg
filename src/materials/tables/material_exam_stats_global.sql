-- Table: materials.material_exam_stats_global
-- Includes constraints and indexes

--

CREATE TABLE materials.material_exam_stats_global (
    id bigint NOT NULL,
    detail_week_type_mat_id bigint NOT NULL,
    number_pages smallint DEFAULT '0'::smallint NOT NULL,
    total_questions smallint DEFAULT '0'::smallint NOT NULL,
    new_questions smallint DEFAULT '0'::smallint NOT NULL,
    repeated_year smallint DEFAULT '0'::smallint NOT NULL,
    repeated_history smallint DEFAULT '0'::smallint NOT NULL,
    repeated_area smallint DEFAULT '0'::smallint NOT NULL,
    created_by integer NOT NULL,
    updated_by integer NOT NULL,
    deleted_by integer,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    pages_details jsonb DEFAULT '[]'::jsonb NOT NULL
);


ALTER TABLE materials.material_exam_stats_global OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_exam_stats_global
    ADD CONSTRAINT material_exam_stats_global_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_exam_stats_global
    ADD CONSTRAINT material_exam_stats_global_detail_week_type_mat_id_foreign FOREIGN KEY (detail_week_type_mat_id) REFERENCES academic.detail_week_type_mat(id);


--
