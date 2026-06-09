-- Table: questions.essential_knowledge_questions
-- Includes constraints and indexes

--

CREATE TABLE questions.essential_knowledge_questions (
    id bigint NOT NULL,
    essential_knowledge_id integer NOT NULL,
    question_id integer NOT NULL,
    created_by integer NOT NULL,
    updated_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deleted_by integer
);


ALTER TABLE questions.essential_knowledge_questions OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.essential_knowledge_questions
    ADD CONSTRAINT essential_knowledge_questions_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.essential_knowledge_questions
    ADD CONSTRAINT essential_knowledge_questions_essential_knowledge_id_foreign FOREIGN KEY (essential_knowledge_id) REFERENCES questions.essential_knowledges(id);


--

--

ALTER TABLE ONLY questions.essential_knowledge_questions
    ADD CONSTRAINT essential_knowledge_questions_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--
