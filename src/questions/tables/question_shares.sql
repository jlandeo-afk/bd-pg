-- Table: questions.question_shares
-- Includes constraints and indexes

--

CREATE TABLE questions.question_shares (
    id BIGINT NOT NULL,
    question_id BIGINT NOT NULL,
    code VARCHAR(255) NOT NULL,
    topic_id smallint NOT NULL,
    subtopic_id smallint NOT NULL,
    created_by INTEGER NOT NULL,
    updated_by INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    deleted_by INTEGER,
    course_id INTEGER
);


ALTER TABLE questions.question_shares OWNER TO postgres;

--

--

ALTER TABLE questions.question_shares
    ADD CONSTRAINT pk_question_shares PRIMARY KEY (id);


--

--

ALTER TABLE questions.question_shares
    ADD CONSTRAINT fk_question_shares_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE questions.question_shares
    ADD CONSTRAINT fk_question_shares_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE questions.question_shares
    ADD CONSTRAINT fk_question_shares_subtopic FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE questions.question_shares
    ADD CONSTRAINT fk_question_shares_topic FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--
