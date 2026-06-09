-- Table: questions.question_subtopic
-- Includes constraints and indexes

--

CREATE TABLE questions.question_subtopic (
    id BIGINT NOT NULL,
    question_id INTEGER NOT NULL,
    subtopic_id INTEGER NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE questions.question_subtopic OWNER TO postgres;

--

--

ALTER TABLE questions.question_subtopic
    ADD CONSTRAINT pk_question_subtopic PRIMARY KEY (id);


--

--

CREATE INDEX idx_question_subtopic_question_id ON questions.question_subtopic USING btree (question_id);


--

--

ALTER TABLE questions.question_subtopic
    ADD CONSTRAINT fk_question_subtopic_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_subtopic
    ADD CONSTRAINT fk_question_subtopic_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_subtopic
    ADD CONSTRAINT fk_question_subtopic_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE questions.question_subtopic
    ADD CONSTRAINT fk_question_subtopic_subtopic FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE questions.question_subtopic
    ADD CONSTRAINT fk_question_subtopic_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
