-- Table: questions.essential_knowledges
-- Includes constraints and indexes

--

CREATE TABLE questions.essential_knowledges (
    id BIGINT NOT NULL,
    code VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    course_id BIGINT NOT NULL,
    topic_id BIGINT NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    editor_content TEXT NOT NULL,
    thumbnail TEXT NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE questions.essential_knowledges OWNER TO postgres;

--

--

ALTER TABLE questions.essential_knowledges
    ADD CONSTRAINT essential_knowledges_code_unique UNIQUE (code);


--

--

ALTER TABLE questions.essential_knowledges
    ADD CONSTRAINT pk_essential_knowledges PRIMARY KEY (id);


--

--

ALTER TABLE questions.essential_knowledges
    ADD CONSTRAINT fk_essential_knowledges_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE questions.essential_knowledges
    ADD CONSTRAINT fk_essential_knowledges_topic FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--
