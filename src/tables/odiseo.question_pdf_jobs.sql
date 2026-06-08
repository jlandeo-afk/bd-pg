-- Table: odiseo.question_pdf_jobs
-- Includes constraints and indexes

--

CREATE TABLE odiseo.question_pdf_jobs (
    id bigint NOT NULL,
    question_id bigint NOT NULL,
    process_type character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    job_id character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.question_pdf_jobs OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.question_pdf_jobs
    ADD CONSTRAINT question_pdf_jobs_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_question_jobs_on_id_and_date ON odiseo.question_pdf_jobs USING btree (question_id, updated_at DESC);


--

--

ALTER TABLE ONLY odiseo.question_pdf_jobs
    ADD CONSTRAINT odiseo_question_pdf_jobs_question_id_foreign FOREIGN KEY (question_id) REFERENCES odiseo.question(id);


--
