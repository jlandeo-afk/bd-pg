-- Table: materials.material_exam_area_week
-- Includes constraints and indexes

--

CREATE TABLE materials.material_exam_area_week (
    id BIGINT NOT NULL,
    week_type_material_id BIGINT NOT NULL,
    area_id smallint NOT NULL,
    url_solution VARCHAR(255),
    url_without_solution VARCHAR(255),
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    fl_process_status smallint DEFAULT '1'::smallint NOT NULL,
    fl_process_status_without smallint DEFAULT '1'::smallint NOT NULL,
    job_solution_id VARCHAR(255),
    job_without_solution_id VARCHAR(255),
    fl_process_quality smallint DEFAULT '1'::smallint NOT NULL,
    url_quality VARCHAR(255),
    job_quality_id VARCHAR(255),
    fl_process_without_quality smallint DEFAULT '1'::smallint NOT NULL,
    url_without_quality VARCHAR(255),
    job_without_quality_id VARCHAR(255),
    fl_complete_questions BOOLEAN DEFAULT true NOT NULL,
    data_incomplete_questions VARCHAR(255),
    fl_config_type BOOLEAN DEFAULT false NOT NULL,
    limit_lower_question smallint,
    limit_upper_question smallint,
    missing_config_message VARCHAR(255),
    data_missing_course_config VARCHAR(255),
    filename VARCHAR(255),
    number_pages smallint,
    has_migrated BOOLEAN DEFAULT false NOT NULL
);


ALTER TABLE materials.material_exam_area_week OWNER TO postgres;

--

--

ALTER TABLE materials.material_exam_area_week
    ADD CONSTRAINT pk_material_exam_area_week PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_exam_area_week
    ADD CONSTRAINT uq_week_ty_mat_id_area_id UNIQUE (week_type_material_id, area_id);


--

--

ALTER TABLE materials.material_exam_area_week
    ADD CONSTRAINT fk_material_exam_area_week_area FOREIGN KEY (area_id) REFERENCES odiseo.exam_area(id);


--

--

ALTER TABLE materials.material_exam_area_week
    ADD CONSTRAINT fk_material_exam_area_week_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_exam_area_week
    ADD CONSTRAINT fk_material_exam_area_week_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_exam_area_week
    ADD CONSTRAINT fk_material_exam_area_week_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_exam_area_week
    ADD CONSTRAINT fk_material_exam_area_week_week_type_material FOREIGN KEY (week_type_material_id) REFERENCES academic.detail_week_type_mat(id);


--
