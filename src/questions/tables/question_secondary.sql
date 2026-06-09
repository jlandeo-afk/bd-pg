-- Table: questions.question_secondary
-- Includes constraints and indexes

--

CREATE TABLE questions.question_secondary (
    id BIGINT NOT NULL,
    code VARCHAR(25) NOT NULL,
    question_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    updated_by INTEGER,
    created_by INTEGER,
    deleted_by INTEGER
);


ALTER TABLE questions.question_secondary OWNER TO postgres;

--

--

ALTER TABLE questions.question_secondary
    ADD CONSTRAINT pk_question_secondary PRIMARY KEY (id);


--

--

ALTER TABLE questions.question_secondary
    ADD CONSTRAINT fk_question_secondary_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE questions.question_secondary
    ADD CONSTRAINT fk_question_secondary_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--
