-- Table: questions.question_field_diagrammed_nq
-- Includes constraints and indexes

--

CREATE TABLE questions.question_field_diagrammed_nq (
    id BIGINT NOT NULL,
    question_teacher_ia_id BIGINT NOT NULL,
    field_diagrammed_id BIGINT NOT NULL,
    content TEXT,
    "position" smallint,
    course_id smallint,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE questions.question_field_diagrammed_nq OWNER TO postgres;

--

--

ALTER TABLE questions.question_field_diagrammed_nq
    ADD CONSTRAINT pk_question_field_diagrammed_nq PRIMARY KEY (id);


--

--

ALTER TABLE questions.question_field_diagrammed_nq
    ADD CONSTRAINT fk_question_field_diagrammed_nq_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE questions.question_field_diagrammed_nq
    ADD CONSTRAINT fk_question_field_diagrammed_nq_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_field_diagrammed_nq
    ADD CONSTRAINT fk_question_field_diagrammed_nq_field_diagrammed FOREIGN KEY (field_diagrammed_id) REFERENCES questions.field_diagrammed(id);


--

--

ALTER TABLE questions.question_field_diagrammed_nq
    ADD CONSTRAINT fk_question_field_diagrammed_nq_question_teacher_ia FOREIGN KEY (question_teacher_ia_id) REFERENCES questions.question_teacher_ia(id);


--
