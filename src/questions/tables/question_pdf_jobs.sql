-- Table: questions.question_pdf_jobs
-- Includes constraints and indexes

--

CREATE TABLE questions.question_pdf_jobs (
    id BIGINT NOT NULL,
    question_id BIGINT NOT NULL,
    process_type VARCHAR(255) NOT NULL,
    status VARCHAR(255) DEFAULT 'pending'::VARCHAR NOT NULL,
    job_id VARCHAR(255),
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE questions.question_pdf_jobs OWNER TO postgres;

--

--

ALTER TABLE questions.question_pdf_jobs
    ADD CONSTRAINT pk_question_pdf_jobs PRIMARY KEY (id);


--

--

CREATE INDEX idx_question_pdf_jobs_question_id_updated_atDESC ON questions.question_pdf_jobs USING btree (question_id, updated_at DESC);


--

--

ALTER TABLE questions.question_pdf_jobs
    ADD CONSTRAINT fk_question_pdf_jobs_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--
