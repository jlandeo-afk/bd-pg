-- Table: questions.question_attributes_types_values
-- Includes constraints and indexes

--

CREATE TABLE questions.question_attributes_types_values (
    id BIGINT NOT NULL,
    question_attributes_type_id INTEGER NOT NULL,
    value VARCHAR(255) NOT NULL,
    label VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    created_by INTEGER NOT NULL,
    updated_by INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    deleted_by INTEGER
);


ALTER TABLE questions.question_attributes_types_values OWNER TO postgres;

--

--

ALTER TABLE questions.question_attributes_types_values
    ADD CONSTRAINT pk_question_attributes_types_values PRIMARY KEY (id);


--

--

ALTER TABLE questions.question_attributes_types_values
    ADD CONSTRAINT fk_question_attributes_types_values_question_attributes_type FOREIGN KEY (question_attributes_type_id) REFERENCES questions.question_attributes_type(id) ON DELETE CASCADE;


--
