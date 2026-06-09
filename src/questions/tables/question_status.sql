-- Table: questions.question_status
-- Includes constraints and indexes

--

CREATE TABLE questions.question_status (
    id BIGINT NOT NULL,
    question_id BIGINT NOT NULL,
    status VARCHAR(5) NOT NULL,
    process VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    fl_active BOOLEAN DEFAULT true NOT NULL
);


ALTER TABLE questions.question_status OWNER TO postgres;

--

--

ALTER TABLE questions.question_status
    ADD CONSTRAINT pk_question_status PRIMARY KEY (id);


--

--

CREATE INDEX idx_question_status_question_id_status_created_at ON questions.question_status USING btree (question_id, status, created_at);


--

--

CREATE INDEX idx_question_status_question_id_status ON questions.question_status USING btree (question_id, status) WHERE (fl_active = true);


--

--

ALTER TABLE questions.question_status
    ADD CONSTRAINT fk_question_status_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_status
    ADD CONSTRAINT fk_question_status_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--
