-- Table: questions.parent_observation
-- Includes constraints and indexes

--

CREATE TABLE questions.parent_observation (
    id BIGINT NOT NULL,
    description TEXT NOT NULL,
    similitaries TEXT DEFAULT '[]'::TEXT NOT NULL,
    parent_id BIGINT NOT NULL,
    type VARCHAR(5) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE questions.parent_observation OWNER TO postgres;

--

--

ALTER TABLE questions.parent_observation
    ADD CONSTRAINT pk_parent_observation PRIMARY KEY (id);


--

--

ALTER TABLE questions.parent_observation
    ADD CONSTRAINT fk_parent_observation_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.parent_observation
    ADD CONSTRAINT fk_parent_observation_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.parent_observation
    ADD CONSTRAINT fk_parent_observation_parent FOREIGN KEY (parent_id) REFERENCES questions.parent_question(id);


--

--

ALTER TABLE questions.parent_observation
    ADD CONSTRAINT fk_parent_observation_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
