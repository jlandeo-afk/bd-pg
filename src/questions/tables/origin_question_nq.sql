-- Table: questions.origin_question_nq
-- Includes constraints and indexes

--

CREATE TABLE questions.origin_question_nq (
    id bigint NOT NULL,
    question_ia_id bigint NOT NULL,
    question_id bigint NOT NULL,
    date_revised timestamp(0) without time zone NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE questions.origin_question_nq OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.origin_question_nq
    ADD CONSTRAINT origin_question_nq_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.origin_question_nq
    ADD CONSTRAINT origin_question_nq_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.origin_question_nq
    ADD CONSTRAINT origin_question_nq_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.origin_question_nq
    ADD CONSTRAINT origin_question_nq_question_ia_id_foreign FOREIGN KEY (question_ia_id) REFERENCES questions.question_teacher_ia(id);


--

--

ALTER TABLE ONLY questions.origin_question_nq
    ADD CONSTRAINT origin_question_nq_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE ONLY questions.origin_question_nq
    ADD CONSTRAINT origin_question_nq_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
