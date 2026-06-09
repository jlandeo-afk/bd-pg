-- Table: questions.essential_knowledge_questions
-- Includes constraints and indexes

--

CREATE TABLE questions.essential_knowledge_questions (
    id BIGINT NOT NULL,
    essential_knowledge_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    created_by INTEGER NOT NULL,
    updated_by INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    deleted_by INTEGER
);


ALTER TABLE questions.essential_knowledge_questions OWNER TO postgres;

--

--

ALTER TABLE questions.essential_knowledge_questions
    ADD CONSTRAINT pk_essential_knowledge_questions PRIMARY KEY (id);


--

--

ALTER TABLE questions.essential_knowledge_questions
    ADD CONSTRAINT fk_essential_knowledge_questions_essential_knowledge FOREIGN KEY (essential_knowledge_id) REFERENCES questions.essential_knowledges(id);


--

--

ALTER TABLE questions.essential_knowledge_questions
    ADD CONSTRAINT fk_essential_knowledge_questions_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--
