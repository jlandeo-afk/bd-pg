-- Table: common.type_texts_subtopics
-- Includes constraints and indexes

--

CREATE TABLE common.type_texts_subtopics (
    id BIGINT NOT NULL,
    subtopic_id BIGINT NOT NULL,
    type_text_id BIGINT NOT NULL,
    probability_percentage smallint DEFAULT '0'::smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE common.type_texts_subtopics OWNER TO postgres;

--

--

ALTER TABLE common.type_texts_subtopics
    ADD CONSTRAINT pk_type_texts_subtopics PRIMARY KEY (id);


--

--

ALTER TABLE common.type_texts_subtopics
    ADD CONSTRAINT fk_type_texts_subtopics_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.type_texts_subtopics
    ADD CONSTRAINT fk_type_texts_subtopics_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.type_texts_subtopics
    ADD CONSTRAINT fk_type_texts_subtopics_subtopic FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE common.type_texts_subtopics
    ADD CONSTRAINT fk_type_texts_subtopics_type_text FOREIGN KEY (type_text_id) REFERENCES common.type_text(id);


--

--

ALTER TABLE common.type_texts_subtopics
    ADD CONSTRAINT fk_type_texts_subtopics_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
