-- Table: academic.network_course_topic_subtopic
-- Includes constraints and indexes

--

CREATE TABLE academic.network_course_topic_subtopic (
    id BIGINT NOT NULL,
    UUID UUID,
    course_id INTEGER,
    topic_id INTEGER,
    subtopic_id INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    created_by INTEGER,
    updated_by INTEGER,
    deleted_by INTEGER,
    deleted_at TIMESTAMPTZ,
    new_name_topic VARCHAR(255) NOT NULL,
    last_name_topic VARCHAR(255) NOT NULL,
    new_name_subtopic VARCHAR(255) NOT NULL,
    last_name_subtopic VARCHAR(255) NOT NULL
);


ALTER TABLE academic.network_course_topic_subtopic OWNER TO postgres;

--

--

ALTER TABLE academic.network_course_topic_subtopic
    ADD CONSTRAINT pk_network_course_topic_subtopic PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX uq_network_course_topic_subtopic_UUID_course_id_topic_id_sub ON academic.network_course_topic_subtopic USING btree (UUID, course_id, topic_id, subtopic_id) WHERE (deleted_at IS NULL);


--

--

ALTER TABLE academic.network_course_topic_subtopic
    ADD CONSTRAINT fk_network_course_topic_subtopic_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE academic.network_course_topic_subtopic
    ADD CONSTRAINT fk_network_course_topic_subtopic_subtopic FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE academic.network_course_topic_subtopic
    ADD CONSTRAINT fk_network_course_topic_subtopic_topic FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--
