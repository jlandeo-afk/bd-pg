-- Table: odiseo.type_texts_subtopics
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_texts_subtopics (
    id bigint NOT NULL,
    subtopic_id bigint NOT NULL,
    type_text_id bigint NOT NULL,
    probability_percentage smallint DEFAULT '0'::smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.type_texts_subtopics OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_texts_subtopics
    ADD CONSTRAINT type_texts_subtopics_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.type_texts_subtopics
    ADD CONSTRAINT type_texts_subtopics_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_texts_subtopics
    ADD CONSTRAINT type_texts_subtopics_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_texts_subtopics
    ADD CONSTRAINT type_texts_subtopics_subtopic_id_foreign FOREIGN KEY (subtopic_id) REFERENCES odiseo.subtopic(id);


--

--

ALTER TABLE ONLY odiseo.type_texts_subtopics
    ADD CONSTRAINT type_texts_subtopics_type_text_id_foreign FOREIGN KEY (type_text_id) REFERENCES odiseo.type_text(id);


--

--

ALTER TABLE ONLY odiseo.type_texts_subtopics
    ADD CONSTRAINT type_texts_subtopics_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
