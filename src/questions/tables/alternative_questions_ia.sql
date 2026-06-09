-- Table: questions.alternative_questions_ia
-- Includes constraints and indexes

--

CREATE TABLE questions.alternative_questions_ia (
    id BIGINT NOT NULL,
    description TEXT NOT NULL,
    option VARCHAR(255) NOT NULL,
    question_ia_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE questions.alternative_questions_ia OWNER TO postgres;

--

--

ALTER TABLE questions.alternative_questions_ia
    ADD CONSTRAINT pk_alternative_questions_ia PRIMARY KEY (id);


--

--

ALTER TABLE questions.alternative_questions_ia
    ADD CONSTRAINT fk_alternative_questions_ia_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.alternative_questions_ia
    ADD CONSTRAINT fk_alternative_questions_ia_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.alternative_questions_ia
    ADD CONSTRAINT fk_alternative_questions_ia_question_ia FOREIGN KEY (question_ia_id) REFERENCES questions.question_teacher_ia(id);


--

--

ALTER TABLE questions.alternative_questions_ia
    ADD CONSTRAINT fk_alternative_questions_ia_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
