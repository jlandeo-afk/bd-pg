-- Table: academic.subtopic
-- Includes constraints and indexes

--

CREATE TABLE academic.subtopic (
    id smallint NOT NULL,
    code VARCHAR(3) NOT NULL,
    name VARCHAR(300) NOT NULL,
    topic_id smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE academic.subtopic OWNER TO postgres;

--

--

ALTER TABLE academic.subtopic
    ADD CONSTRAINT pk_subtopic PRIMARY KEY (id);


--

--

ALTER TABLE academic.subtopic
    ADD CONSTRAINT fk_subtopic_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.subtopic
    ADD CONSTRAINT fk_subtopic_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.subtopic
    ADD CONSTRAINT fk_subtopic_topic FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--

--

ALTER TABLE academic.subtopic
    ADD CONSTRAINT fk_subtopic_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
