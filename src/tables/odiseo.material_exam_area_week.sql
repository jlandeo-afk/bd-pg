-- Table: odiseo.material_exam_area_week
-- Includes constraints and indexes

--

CREATE TABLE odiseo.material_exam_area_week (
    id bigint NOT NULL,
    week_type_material_id bigint NOT NULL,
    area_id smallint NOT NULL,
    url_solution character varying(255),
    url_without_solution character varying(255),
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    fl_process_status smallint DEFAULT '1'::smallint NOT NULL,
    fl_process_status_without smallint DEFAULT '1'::smallint NOT NULL,
    job_solution_id character varying(255),
    job_without_solution_id character varying(255),
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
    filename character varying(255),
    number_pages smallint,
    has_migrated boolean DEFAULT false NOT NULL
);


ALTER TABLE odiseo.material_exam_area_week OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.material_exam_area_week
    ADD CONSTRAINT material_exam_area_week_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.material_exam_area_week
    ADD CONSTRAINT uq_week_ty_mat_id_area_id UNIQUE (week_type_material_id, area_id);


--

--

ALTER TABLE ONLY odiseo.material_exam_area_week
    ADD CONSTRAINT odiseo_material_exam_area_week_area_id_foreign FOREIGN KEY (area_id) REFERENCES odiseo.exam_area(id);


--

--

ALTER TABLE ONLY odiseo.material_exam_area_week
    ADD CONSTRAINT odiseo_material_exam_area_week_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_exam_area_week
    ADD CONSTRAINT odiseo_material_exam_area_week_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_exam_area_week
    ADD CONSTRAINT odiseo_material_exam_area_week_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_exam_area_week
    ADD CONSTRAINT odiseo_material_exam_area_week_week_type_material_id_foreign FOREIGN KEY (week_type_material_id) REFERENCES odiseo.detail_week_type_mat(id);


--
