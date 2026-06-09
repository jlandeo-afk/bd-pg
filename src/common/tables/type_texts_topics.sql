-- Table: common.type_texts_topics
-- Includes constraints and indexes

--

CREATE TABLE common.type_texts_topics (
    id BIGINT NOT NULL,
    topic_id BIGINT NOT NULL,
    type_text_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    probability_percentage smallint DEFAULT '0'::smallint NOT NULL
);


ALTER TABLE common.type_texts_topics OWNER TO postgres;

--

--

ALTER TABLE common.type_texts_topics
    ADD CONSTRAINT pk_type_texts_topics PRIMARY KEY (id);


--

--

ALTER TABLE common.type_texts_topics
    ADD CONSTRAINT fk_type_texts_topics_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.type_texts_topics
    ADD CONSTRAINT fk_type_texts_topics_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.type_texts_topics
    ADD CONSTRAINT fk_type_texts_topics_topic FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--

--

ALTER TABLE common.type_texts_topics
    ADD CONSTRAINT fk_type_texts_topics_type_text FOREIGN KEY (type_text_id) REFERENCES common.type_text(id);


--

--

ALTER TABLE common.type_texts_topics
    ADD CONSTRAINT fk_type_texts_topics_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
