-- Table: questions.question_history_course
-- Includes constraints and indexes

--

CREATE TABLE questions.question_history_course (
    id BIGINT NOT NULL,
    question_id BIGINT NOT NULL,
    code VARCHAR(25),
    number VARCHAR(25),
    course_id BIGINT,
    updated_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE questions.question_history_course OWNER TO postgres;

--

--

ALTER TABLE questions.question_history_course
    ADD CONSTRAINT pk_question_history_course PRIMARY KEY (id);


--

--

ALTER TABLE questions.question_history_course
    ADD CONSTRAINT fk_question_history_course_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE questions.question_history_course
    ADD CONSTRAINT fk_question_history_course_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE questions.question_history_course
    ADD CONSTRAINT fk_question_history_course_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
