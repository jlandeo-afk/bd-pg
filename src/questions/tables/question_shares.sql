-- Table: questions.question_shares
-- Includes constraints and indexes

--

CREATE TABLE questions.question_shares (
    id bigint NOT NULL,
    question_id bigint NOT NULL,
    code character varying(255) NOT NULL,
    topic_id smallint NOT NULL,
    subtopic_id smallint NOT NULL,
    created_by integer NOT NULL,
    updated_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deleted_by integer,
    course_id integer
);


ALTER TABLE questions.question_shares OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_shares
    ADD CONSTRAINT question_shares_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.question_shares
    ADD CONSTRAINT question_shares_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY questions.question_shares
    ADD CONSTRAINT question_shares_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE ONLY questions.question_shares
    ADD CONSTRAINT question_shares_subtopic_id_foreign FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE ONLY questions.question_shares
    ADD CONSTRAINT question_shares_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--
