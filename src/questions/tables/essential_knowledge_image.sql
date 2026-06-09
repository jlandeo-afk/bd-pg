-- Table: questions.essential_knowledge_image
-- Includes constraints and indexes

--

CREATE TABLE questions.essential_knowledge_image (
    id BIGINT NOT NULL,
    essential_knowledge_id BIGINT NOT NULL,
    image TEXT NOT NULL,
    extension TEXT NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE questions.essential_knowledge_image OWNER TO postgres;

--

--

ALTER TABLE questions.essential_knowledge_image
    ADD CONSTRAINT pk_essential_knowledge_image PRIMARY KEY (id);


--

--

ALTER TABLE questions.essential_knowledge_image
    ADD CONSTRAINT fk_essential_knowledge_image_essential_knowledge FOREIGN KEY (essential_knowledge_id) REFERENCES questions.essential_knowledges(id);


--
