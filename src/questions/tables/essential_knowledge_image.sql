-- Table: questions.essential_knowledge_image
-- Includes constraints and indexes

--

CREATE TABLE questions.essential_knowledge_image (
    id bigint NOT NULL,
    essential_knowledge_id bigint NOT NULL,
    image text NOT NULL,
    extension text NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE questions.essential_knowledge_image OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.essential_knowledge_image
    ADD CONSTRAINT essential_knowledge_image_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.essential_knowledge_image
    ADD CONSTRAINT essential_knowledge_image_essential_knowledge_id_foreign FOREIGN KEY (essential_knowledge_id) REFERENCES questions.essential_knowledges(id);


--
