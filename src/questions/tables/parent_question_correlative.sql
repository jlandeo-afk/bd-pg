-- Table: questions.parent_question_correlative
-- Includes constraints and indexes

--

CREATE TABLE questions.parent_question_correlative (
    id BIGINT NOT NULL,
    course_id INTEGER NOT NULL,
    correlative INTEGER NOT NULL,
    created_by INTEGER NOT NULL,
    updated_by INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_by INTEGER,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE questions.parent_question_correlative OWNER TO postgres;

--

--

ALTER TABLE questions.parent_question_correlative
    ADD CONSTRAINT pk_parent_question_correlative PRIMARY KEY (id);


--

--

ALTER TABLE questions.parent_question_correlative
    ADD CONSTRAINT fk_parent_question_correlative_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--
