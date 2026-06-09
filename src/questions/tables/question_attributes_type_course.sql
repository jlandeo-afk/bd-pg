-- Table: questions.question_attributes_type_course
-- Includes constraints and indexes

--

CREATE TABLE questions.question_attributes_type_course (
    id bigint NOT NULL,
    question_attributes_type_id integer NOT NULL,
    course_id integer NOT NULL,
    types_questions character varying(255) NOT NULL,
    created_by integer NOT NULL,
    updated_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deleted_by integer
);


ALTER TABLE questions.question_attributes_type_course OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_attributes_type_course
    ADD CONSTRAINT question_attributes_type_course_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.question_attributes_type_course
    ADD CONSTRAINT question_attributes_type_course_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY questions.question_attributes_type_course
    ADD CONSTRAINT question_attributes_type_course_question_attributes_type_id_for FOREIGN KEY (question_attributes_type_id) REFERENCES questions.question_attributes_type(id);


--
