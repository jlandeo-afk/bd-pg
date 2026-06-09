-- Table: materials.material_per_period_ballot_url
-- Includes constraints and indexes

--

CREATE TABLE materials.material_per_period_ballot_url (
    id bigint NOT NULL,
    material_per_period_ballot_id bigint NOT NULL,
    type_url character varying(255) NOT NULL,
    job_url character varying(255),
    job_id character varying(255),
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    file_name character varying(255),
    fl_job_process character varying(255) DEFAULT 'unprocessed'::character varying NOT NULL,
    retries smallint DEFAULT '0'::smallint NOT NULL,
    number_pages smallint,
    CONSTRAINT material_per_period_ballot_url_fl_job_process_check CHECK (((fl_job_process)::text = ANY (ARRAY[('unprocessed'::character varying)::text, ('pending'::character varying)::text, ('processing'::character varying)::text, ('completed'::character varying)::text, ('failed'::character varying)::text, ('canceled'::character varying)::text]))),
    CONSTRAINT material_per_period_ballot_url_type_url_check CHECK (((type_url)::text = ANY (ARRAY[('solution'::character varying)::text, ('without_solution'::character varying)::text, ('review_solution'::character varying)::text, ('review_without_solution'::character varying)::text, ('material_class'::character varying)::text])))
);


ALTER TABLE materials.material_per_period_ballot_url OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_per_period_ballot_url
    ADD CONSTRAINT material_per_period_ballot_url_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_per_period_ballot_url
    ADD CONSTRAINT material_per_period_ballot_url_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_per_period_ballot_url
    ADD CONSTRAINT material_per_period_ballot_url_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_per_period_ballot_url
    ADD CONSTRAINT material_per_period_ballot_url_material_per_period_ballot_id_fo FOREIGN KEY (material_per_period_ballot_id) REFERENCES materials.material_per_period_ballot(id);


--

--

ALTER TABLE ONLY materials.material_per_period_ballot_url
    ADD CONSTRAINT material_per_period_ballot_url_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
