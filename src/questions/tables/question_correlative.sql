-- Table: questions.question_correlative
-- Includes constraints and indexes

--

CREATE TABLE questions.question_correlative (
    id BIGINT NOT NULL,
    course_id INTEGER NOT NULL,
    correlative INTEGER NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    apply_text BOOLEAN DEFAULT false NOT NULL
);


ALTER TABLE questions.question_correlative OWNER TO postgres;

--

--

ALTER TABLE questions.question_correlative
    ADD CONSTRAINT pk_question_correlative PRIMARY KEY (id);


--
