-- Table: academic.detail_week_type_mat
-- Includes constraints and indexes

--

CREATE TABLE academic.detail_week_type_mat (
    id BIGINT NOT NULL,
    material_id BIGINT NOT NULL,
    week smallint NOT NULL,
    type_material_id smallint NOT NULL,
    url_solution VARCHAR(255),
    url_without_solution VARCHAR(255),
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    parent_type_material_id smallint,
    fl_process_status smallint DEFAULT '1'::smallint NOT NULL,
    fl_process_status_without smallint DEFAULT '1'::smallint NOT NULL,
    job_solution_id VARCHAR(255),
    job_without_solution_id VARCHAR(255),
    fl_process_class_mat smallint DEFAULT '0'::smallint NOT NULL,
    url_zip_class_mat VARCHAR(255),
    fl_config_level BOOLEAN DEFAULT true NOT NULL,
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
    locked BOOLEAN DEFAULT false NOT NULL,
    locked_by BIGINT,
    locked_at TIMESTAMPTZ,
    questions_generation_process VARCHAR(255) DEFAULT 'not_started'::VARCHAR NOT NULL,
    data_missing_text JSON,
    UUID UUID DEFAULT gen_random_uuid(),
    CONSTRAINT detail_week_type_mat_questions_generation_process_check CHECK (((questions_generation_process)::TEXT = ANY (ARRAY[('not_started'::VARCHAR)::TEXT, ('in_progress'::VARCHAR)::TEXT, ('canceled'::VARCHAR)::TEXT, ('done'::VARCHAR)::TEXT, ('failed'::VARCHAR)::TEXT])))
);


ALTER TABLE academic.detail_week_type_mat OWNER TO postgres;

--

--

ALTER TABLE academic.detail_week_type_mat
    ADD CONSTRAINT pk_detail_week_type_mat PRIMARY KEY (id);


--

--

ALTER TABLE academic.detail_week_type_mat
    ADD CONSTRAINT ux_detail_week_type_mat UNIQUE (material_id, week, type_material_id);


--

--

CREATE INDEX idx_detail_week_type_mat_material_id_id ON academic.detail_week_type_mat USING btree (material_id, id);


--

--

ALTER TABLE academic.detail_week_type_mat
    ADD CONSTRAINT fk_detail_week_type_mat_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.detail_week_type_mat
    ADD CONSTRAINT fk_detail_week_type_mat_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.detail_week_type_mat
    ADD CONSTRAINT fk_detail_week_type_mat_locked_by FOREIGN KEY (locked_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.detail_week_type_mat
    ADD CONSTRAINT fk_detail_week_type_mat_material FOREIGN KEY (material_id) REFERENCES materials.material(id);


--

--

ALTER TABLE academic.detail_week_type_mat
    ADD CONSTRAINT fk_detail_week_type_mat_parent_type_material FOREIGN KEY (parent_type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE academic.detail_week_type_mat
    ADD CONSTRAINT fk_detail_week_type_mat_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE academic.detail_week_type_mat
    ADD CONSTRAINT fk_detail_week_type_mat_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
