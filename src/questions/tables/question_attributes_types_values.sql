-- Table: questions.question_attributes_types_values
-- Includes constraints and indexes

--

CREATE TABLE questions.question_attributes_types_values (
    id bigint NOT NULL,
    question_attributes_type_id integer NOT NULL,
    value character varying(255) NOT NULL,
    label character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    created_by integer NOT NULL,
    updated_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deleted_by integer
);


ALTER TABLE questions.question_attributes_types_values OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_attributes_types_values
    ADD CONSTRAINT question_attributes_types_values_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.question_attributes_types_values
    ADD CONSTRAINT question_attributes_types_values_question_attributes_type_id_fo FOREIGN KEY (question_attributes_type_id) REFERENCES questions.question_attributes_type(id) ON DELETE CASCADE;


--
