-- Table: questions.history_digitalized_solution_question_pdf
-- Includes constraints and indexes

--

CREATE TABLE questions.history_digitalized_solution_question_pdf (
    id bigint NOT NULL,
    question_id bigint NOT NULL,
    status character varying(5) NOT NULL,
    url character varying(255),
    original_created_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE questions.history_digitalized_solution_question_pdf OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.history_digitalized_solution_question_pdf
    ADD CONSTRAINT history_digitalized_solution_question_pdf_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.history_digitalized_solution_question_pdf
    ADD CONSTRAINT odiseo_history_digitalized_solution_question_pdf_question_id_fo FOREIGN KEY (question_id) REFERENCES questions.question(id);


--
