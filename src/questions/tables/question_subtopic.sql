-- Table: questions.question_subtopic
-- Includes constraints and indexes

--

CREATE TABLE questions.question_subtopic (
    id bigint NOT NULL,
    question_id integer NOT NULL,
    subtopic_id integer NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE questions.question_subtopic OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_subtopic
    ADD CONSTRAINT question_subtopic_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_question_subtopic_question_id ON questions.question_subtopic USING btree (question_id);


--

--

ALTER TABLE ONLY questions.question_subtopic
    ADD CONSTRAINT odiseo_question_subtopic_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_subtopic
    ADD CONSTRAINT odiseo_question_subtopic_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_subtopic
    ADD CONSTRAINT odiseo_question_subtopic_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE ONLY questions.question_subtopic
    ADD CONSTRAINT odiseo_question_subtopic_subtopic_id_foreign FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE ONLY questions.question_subtopic
    ADD CONSTRAINT odiseo_question_subtopic_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
