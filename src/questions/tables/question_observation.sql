-- Table: questions.question_observation
-- Includes constraints and indexes

--

CREATE TABLE questions.question_observation (
    id BIGINT NOT NULL,
    description TEXT NOT NULL,
    similitaries TEXT DEFAULT '[]'::TEXT NOT NULL,
    question_id BIGINT NOT NULL,
    type VARCHAR(5) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    boards_observation TEXT DEFAULT '[]'::TEXT NOT NULL
);


ALTER TABLE questions.question_observation OWNER TO postgres;

--

--

ALTER TABLE questions.question_observation
    ADD CONSTRAINT pk_question_observation PRIMARY KEY (id);


--

--

ALTER TABLE questions.question_observation
    ADD CONSTRAINT fk_question_observation_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_observation
    ADD CONSTRAINT fk_question_observation_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_observation
    ADD CONSTRAINT fk_question_observation_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE questions.question_observation
    ADD CONSTRAINT fk_question_observation_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
