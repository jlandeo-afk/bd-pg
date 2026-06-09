-- Table: questions.question_attributes
-- Includes constraints and indexes

--

CREATE TABLE questions.question_attributes (
    id BIGINT NOT NULL,
    question_attributes_type_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    value VARCHAR(255) NOT NULL,
    created_by INTEGER NOT NULL,
    updated_by INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    deleted_by INTEGER
);


ALTER TABLE questions.question_attributes OWNER TO postgres;

--

--

ALTER TABLE questions.question_attributes
    ADD CONSTRAINT pk_question_attributes PRIMARY KEY (id);


--

--

ALTER TABLE questions.question_attributes
    ADD CONSTRAINT fk_question_attributes_question_attributes_type FOREIGN KEY (question_attributes_type_id) REFERENCES questions.question_attributes_type(id);


--

--

ALTER TABLE questions.question_attributes
    ADD CONSTRAINT fk_question_attributes_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--
