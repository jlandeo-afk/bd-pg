-- Table: questions.question_refuzed
-- Includes constraints and indexes

--

CREATE TABLE questions.question_refuzed (
    id BIGINT NOT NULL,
    category_rejected_id smallint NOT NULL,
    importance_rejected smallint NOT NULL,
    observation TEXT NOT NULL,
    images TEXT,
    question_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    fl_active BOOLEAN DEFAULT true NOT NULL
);


ALTER TABLE questions.question_refuzed OWNER TO postgres;

--

--

ALTER TABLE questions.question_refuzed
    ADD CONSTRAINT pk_question_refuzed PRIMARY KEY (id);


--

--

ALTER TABLE questions.question_refuzed
    ADD CONSTRAINT fk_question_refuzed_category_rejected FOREIGN KEY (category_rejected_id) REFERENCES common.category_rejected(id);


--

--

ALTER TABLE questions.question_refuzed
    ADD CONSTRAINT fk_question_refuzed_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_refuzed
    ADD CONSTRAINT fk_question_refuzed_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_refuzed
    ADD CONSTRAINT fk_question_refuzed_importance_rejected FOREIGN KEY (importance_rejected) REFERENCES common.importance_rejected(id);


--

--

ALTER TABLE questions.question_refuzed
    ADD CONSTRAINT fk_question_refuzed_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE questions.question_refuzed
    ADD CONSTRAINT fk_question_refuzed_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
