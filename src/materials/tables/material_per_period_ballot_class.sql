-- Table: materials.material_per_period_ballot_class
-- Includes constraints and indexes

--

CREATE TABLE materials.material_per_period_ballot_class (
    id bigint NOT NULL,
    material_per_period_ballot_url_id bigint NOT NULL,
    course_id smallint NOT NULL,
    file_name character varying(255),
    fl_job_process character varying(255) DEFAULT 'unprocessed'::character varying NOT NULL,
    job_url character varying(255),
    job_id character varying(255),
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    CONSTRAINT material_per_period_ballot_class_fl_job_process_check CHECK (((fl_job_process)::text = ANY (ARRAY[('unprocessed'::character varying)::text, ('pending'::character varying)::text, ('processing'::character varying)::text, ('completed'::character varying)::text, ('failed'::character varying)::text, ('canceled'::character varying)::text])))
);


ALTER TABLE materials.material_per_period_ballot_class OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_per_period_ballot_class
    ADD CONSTRAINT material_per_period_ballot_class_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_per_period_ballot_class
    ADD CONSTRAINT material_per_period_ballot_class_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY materials.material_per_period_ballot_class
    ADD CONSTRAINT material_per_period_ballot_class_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_per_period_ballot_class
    ADD CONSTRAINT material_per_period_ballot_class_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_per_period_ballot_class
    ADD CONSTRAINT material_per_period_ballot_class_material_per_period_ballot_url FOREIGN KEY (material_per_period_ballot_url_id) REFERENCES materials.material_per_period_ballot_url(id);


--

--

ALTER TABLE ONLY materials.material_per_period_ballot_class
    ADD CONSTRAINT material_per_period_ballot_class_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
