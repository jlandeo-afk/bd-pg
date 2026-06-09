-- Table: materials.material_exam_stats_global
-- Includes constraints and indexes

--

CREATE TABLE materials.material_exam_stats_global (
    id BIGINT NOT NULL,
    detail_week_type_mat_id BIGINT NOT NULL,
    number_pages smallint DEFAULT '0'::smallint NOT NULL,
    total_questions smallint DEFAULT '0'::smallint NOT NULL,
    new_questions smallint DEFAULT '0'::smallint NOT NULL,
    repeated_year smallint DEFAULT '0'::smallint NOT NULL,
    repeated_history smallint DEFAULT '0'::smallint NOT NULL,
    repeated_area smallint DEFAULT '0'::smallint NOT NULL,
    created_by INTEGER NOT NULL,
    updated_by INTEGER NOT NULL,
    deleted_by INTEGER,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    pages_details JSONB DEFAULT '[]'::JSONB NOT NULL
);


ALTER TABLE materials.material_exam_stats_global OWNER TO postgres;

--

--

ALTER TABLE materials.material_exam_stats_global
    ADD CONSTRAINT pk_material_exam_stats_global PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_exam_stats_global
    ADD CONSTRAINT fk_material_exam_stats_global_detail_week_type_mat FOREIGN KEY (detail_week_type_mat_id) REFERENCES academic.detail_week_type_mat(id);


--
