-- Table: academic.detail_week_type_mat
-- Includes constraints and indexes

--

CREATE TABLE academic.detail_week_type_mat (
    id bigint NOT NULL,
    material_id bigint NOT NULL,
    week smallint NOT NULL,
    type_material_id smallint NOT NULL,
    url_solution character varying(255),
    url_without_solution character varying(255),
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    parent_type_material_id smallint,
    fl_process_status smallint DEFAULT '1'::smallint NOT NULL,
    fl_process_status_without smallint DEFAULT '1'::smallint NOT NULL,
    job_solution_id character varying(255),
    job_without_solution_id character varying(255),
    fl_process_class_mat smallint DEFAULT '0'::smallint NOT NULL,
    url_zip_class_mat character varying(255),
    fl_config_level boolean DEFAULT true NOT NULL,
    fl_process_quality smallint DEFAULT '1'::smallint NOT NULL,
    url_quality character varying(255),
    job_quality_id character varying(255),
    fl_process_without_quality smallint DEFAULT '1'::smallint NOT NULL,
    url_without_quality character varying(255),
    job_without_quality_id character varying(255),
    fl_complete_questions boolean DEFAULT true NOT NULL,
    data_incomplete_questions character varying(255),
    fl_config_type boolean DEFAULT false NOT NULL,
    limit_lower_question smallint,
    limit_upper_question smallint,
    missing_config_message character varying(255),
    data_missing_course_config character varying(255),
    locked boolean DEFAULT false NOT NULL,
    locked_by bigint,
    locked_at timestamp(0) without time zone,
    questions_generation_process character varying(255) DEFAULT 'not_started'::character varying NOT NULL,
    data_missing_text json,
    uuid uuid DEFAULT gen_random_uuid(),
    CONSTRAINT detail_week_type_mat_questions_generation_process_check CHECK (((questions_generation_process)::text = ANY (ARRAY[('not_started'::character varying)::text, ('in_progress'::character varying)::text, ('canceled'::character varying)::text, ('done'::character varying)::text, ('failed'::character varying)::text])))
);


ALTER TABLE academic.detail_week_type_mat OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.detail_week_type_mat
    ADD CONSTRAINT detail_week_type_mat_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.detail_week_type_mat
    ADD CONSTRAINT ux_detail_week_type_mat UNIQUE (material_id, week, type_material_id);


--

--

CREATE INDEX idx_dwtm_material_id_id ON academic.detail_week_type_mat USING btree (material_id, id);


--

--

ALTER TABLE ONLY academic.detail_week_type_mat
    ADD CONSTRAINT odiseo_detail_week_type_mat_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.detail_week_type_mat
    ADD CONSTRAINT odiseo_detail_week_type_mat_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.detail_week_type_mat
    ADD CONSTRAINT odiseo_detail_week_type_mat_locked_by_foreign FOREIGN KEY (locked_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.detail_week_type_mat
    ADD CONSTRAINT odiseo_detail_week_type_mat_material_id_foreign FOREIGN KEY (material_id) REFERENCES materials.material(id);


--

--

ALTER TABLE ONLY academic.detail_week_type_mat
    ADD CONSTRAINT odiseo_detail_week_type_mat_parent_type_material_id_foreign FOREIGN KEY (parent_type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE ONLY academic.detail_week_type_mat
    ADD CONSTRAINT odiseo_detail_week_type_mat_type_material_id_foreign FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE ONLY academic.detail_week_type_mat
    ADD CONSTRAINT odiseo_detail_week_type_mat_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
