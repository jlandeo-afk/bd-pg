-- Table: questions.question_attributes_type
-- Includes constraints and indexes

--

CREATE TABLE questions.question_attributes_type (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_by INTEGER NOT NULL,
    updated_by INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    deleted_by INTEGER
);


ALTER TABLE questions.question_attributes_type OWNER TO postgres;

--

--

ALTER TABLE questions.question_attributes_type
    ADD CONSTRAINT pk_question_attributes_type PRIMARY KEY (id);


--
