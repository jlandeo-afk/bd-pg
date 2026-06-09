-- Table: questions.question_secondary
-- Includes constraints and indexes

--

CREATE TABLE questions.question_secondary (
    id bigint NOT NULL,
    code character varying(25) NOT NULL,
    question_id integer NOT NULL,
    course_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    updated_by integer,
    created_by integer,
    deleted_by integer
);


ALTER TABLE questions.question_secondary OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_secondary
    ADD CONSTRAINT question_secondary_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.question_secondary
    ADD CONSTRAINT question_secondary_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY questions.question_secondary
    ADD CONSTRAINT question_secondary_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--
