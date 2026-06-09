-- Table: questions.question_attributes
-- Includes constraints and indexes

--

CREATE TABLE questions.question_attributes (
    id bigint NOT NULL,
    question_attributes_type_id integer NOT NULL,
    question_id integer NOT NULL,
    value character varying(255) NOT NULL,
    created_by integer NOT NULL,
    updated_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deleted_by integer
);


ALTER TABLE questions.question_attributes OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_attributes
    ADD CONSTRAINT question_attributes_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.question_attributes
    ADD CONSTRAINT question_attributes_question_attributes_type_id_foreign FOREIGN KEY (question_attributes_type_id) REFERENCES questions.question_attributes_type(id);


--

--

ALTER TABLE ONLY questions.question_attributes
    ADD CONSTRAINT question_attributes_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--
