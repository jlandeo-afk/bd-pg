-- Table: academic.network_course_topic_subtopic
-- Includes constraints and indexes

--

CREATE TABLE academic.network_course_topic_subtopic (
    id bigint NOT NULL,
    uuid uuid,
    course_id integer,
    topic_id integer,
    subtopic_id integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    created_by integer,
    updated_by integer,
    deleted_by integer,
    deleted_at timestamp(0) without time zone,
    new_name_topic character varying(255) NOT NULL,
    last_name_topic character varying(255) NOT NULL,
    new_name_subtopic character varying(255) NOT NULL,
    last_name_subtopic character varying(255) NOT NULL
);


ALTER TABLE academic.network_course_topic_subtopic OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.network_course_topic_subtopic
    ADD CONSTRAINT network_course_topic_subtopic_pkey PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX idx_unique_uuid_course_topic_subtopic ON academic.network_course_topic_subtopic USING btree (uuid, course_id, topic_id, subtopic_id) WHERE (deleted_at IS NULL);


--

--

ALTER TABLE ONLY academic.network_course_topic_subtopic
    ADD CONSTRAINT network_course_topic_subtopic_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY academic.network_course_topic_subtopic
    ADD CONSTRAINT network_course_topic_subtopic_subtopic_id_foreign FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE ONLY academic.network_course_topic_subtopic
    ADD CONSTRAINT network_course_topic_subtopic_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--
