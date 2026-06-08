-- Table: odiseo.type_texts_topics
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_texts_topics (
    id bigint NOT NULL,
    topic_id bigint NOT NULL,
    type_text_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    probability_percentage smallint DEFAULT '0'::smallint NOT NULL
);


ALTER TABLE odiseo.type_texts_topics OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_texts_topics
    ADD CONSTRAINT type_texts_topics_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.type_texts_topics
    ADD CONSTRAINT type_texts_topics_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_texts_topics
    ADD CONSTRAINT type_texts_topics_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_texts_topics
    ADD CONSTRAINT type_texts_topics_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES odiseo.topic(id);


--

--

ALTER TABLE ONLY odiseo.type_texts_topics
    ADD CONSTRAINT type_texts_topics_type_text_id_foreign FOREIGN KEY (type_text_id) REFERENCES odiseo.type_text(id);


--

--

ALTER TABLE ONLY odiseo.type_texts_topics
    ADD CONSTRAINT type_texts_topics_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
