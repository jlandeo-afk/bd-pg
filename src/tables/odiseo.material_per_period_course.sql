-- Table: odiseo.material_per_period_course
-- Includes constraints and indexes

--

CREATE TABLE odiseo.material_per_period_course (
    id bigint NOT NULL,
    material_per_period_ballot_id bigint NOT NULL,
    course_id smallint NOT NULL,
    type character varying(255) NOT NULL,
    url character varying(255),
    job_id character varying(255),
    job_status character varying(255) DEFAULT 'unprocessed'::character varying NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    pages smallint DEFAULT '0'::smallint NOT NULL,
    retries smallint DEFAULT '0'::smallint NOT NULL,
    CONSTRAINT material_per_period_course_job_status_check CHECK (((job_status)::text = ANY (ARRAY[('unprocessed'::character varying)::text, ('pending'::character varying)::text, ('processing'::character varying)::text, ('completed'::character varying)::text, ('failed'::character varying)::text, ('canceled'::character varying)::text]))),
    CONSTRAINT material_per_period_course_type_check CHECK (((type)::text = ANY (ARRAY[('solution'::character varying)::text, ('without_solution'::character varying)::text, ('review_solution'::character varying)::text, ('review_without_solution'::character varying)::text, ('material_class'::character varying)::text])))
);


ALTER TABLE odiseo.material_per_period_course OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.material_per_period_course
    ADD CONSTRAINT material_per_period_course_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.material_per_period_course
    ADD CONSTRAINT period_id_course_type UNIQUE (material_per_period_ballot_id, course_id, type);


--

--

ALTER TABLE ONLY odiseo.material_per_period_course
    ADD CONSTRAINT material_per_period_course_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.material_per_period_course
    ADD CONSTRAINT material_per_period_course_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_per_period_course
    ADD CONSTRAINT material_per_period_course_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_per_period_course
    ADD CONSTRAINT material_per_period_course_material_per_period_ballot_id_foreig FOREIGN KEY (material_per_period_ballot_id) REFERENCES odiseo.material_per_period_ballot(id);


--

--

ALTER TABLE ONLY odiseo.material_per_period_course
    ADD CONSTRAINT material_per_period_course_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
