-- Table: questions.question_attributes_type_course
-- Includes constraints and indexes

--

CREATE TABLE questions.question_attributes_type_course (
    id BIGINT NOT NULL,
    question_attributes_type_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    types_questions VARCHAR(255) NOT NULL,
    created_by INTEGER NOT NULL,
    updated_by INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    deleted_by INTEGER
);


ALTER TABLE questions.question_attributes_type_course OWNER TO postgres;

--

--

ALTER TABLE questions.question_attributes_type_course
    ADD CONSTRAINT pk_question_attributes_type_course PRIMARY KEY (id);


--

--

ALTER TABLE questions.question_attributes_type_course
    ADD CONSTRAINT fk_question_attributes_type_course_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE questions.question_attributes_type_course
    ADD CONSTRAINT fk_question_attributes_type_course_question_attributes_type FOREIGN KEY (question_attributes_type_id) REFERENCES questions.question_attributes_type(id);


--
