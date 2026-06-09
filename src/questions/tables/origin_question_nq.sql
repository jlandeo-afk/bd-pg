-- Table: questions.origin_question_nq
-- Includes constraints and indexes

--

CREATE TABLE questions.origin_question_nq (
    id BIGINT NOT NULL,
    question_ia_id BIGINT NOT NULL,
    question_id BIGINT NOT NULL,
    date_revised TIMESTAMPTZ NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE questions.origin_question_nq OWNER TO postgres;

--

--

ALTER TABLE questions.origin_question_nq
    ADD CONSTRAINT pk_origin_question_nq PRIMARY KEY (id);


--

--

ALTER TABLE questions.origin_question_nq
    ADD CONSTRAINT fk_origin_question_nq_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.origin_question_nq
    ADD CONSTRAINT fk_origin_question_nq_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.origin_question_nq
    ADD CONSTRAINT fk_origin_question_nq_question_ia FOREIGN KEY (question_ia_id) REFERENCES questions.question_teacher_ia(id);


--

--

ALTER TABLE questions.origin_question_nq
    ADD CONSTRAINT fk_origin_question_nq_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE questions.origin_question_nq
    ADD CONSTRAINT fk_origin_question_nq_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
