-- Table: questions.history_digitalized_solution_question_pdf
-- Includes constraints and indexes

--

CREATE TABLE questions.history_digitalized_solution_question_pdf (
    id BIGINT NOT NULL,
    question_id BIGINT NOT NULL,
    status VARCHAR(5) NOT NULL,
    url VARCHAR(255),
    original_created_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE questions.history_digitalized_solution_question_pdf OWNER TO postgres;

--

--

ALTER TABLE questions.history_digitalized_solution_question_pdf
    ADD CONSTRAINT pk_history_digitalized_solution_question_pdf PRIMARY KEY (id);


--

--

ALTER TABLE questions.history_digitalized_solution_question_pdf
    ADD CONSTRAINT fk_history_digitalized_solution_question_pdf_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--
