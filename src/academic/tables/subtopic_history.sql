-- Table: academic.subtopic_history
-- Includes constraints and indexes

--

CREATE TABLE academic.subtopic_history (
    id BIGINT NOT NULL,
    subtopic_id smallint NOT NULL,
    topic_id smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE academic.subtopic_history OWNER TO postgres;

--

--

ALTER TABLE academic.subtopic_history
    ADD CONSTRAINT pk_subtopic_history PRIMARY KEY (id);


--

--

ALTER TABLE academic.subtopic_history
    ADD CONSTRAINT fk_subtopic_history_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.subtopic_history
    ADD CONSTRAINT fk_subtopic_history_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.subtopic_history
    ADD CONSTRAINT fk_subtopic_history_subtopic FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE academic.subtopic_history
    ADD CONSTRAINT fk_subtopic_history_topic FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--

--

ALTER TABLE academic.subtopic_history
    ADD CONSTRAINT fk_subtopic_history_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
