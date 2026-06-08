-- Table: odiseo.subtopic_history
-- Includes constraints and indexes

--

CREATE TABLE odiseo.subtopic_history (
    id bigint NOT NULL,
    subtopic_id smallint NOT NULL,
    topic_id smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.subtopic_history OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.subtopic_history
    ADD CONSTRAINT subtopic_history_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.subtopic_history
    ADD CONSTRAINT odiseo_subtopic_history_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.subtopic_history
    ADD CONSTRAINT odiseo_subtopic_history_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.subtopic_history
    ADD CONSTRAINT odiseo_subtopic_history_subtopic_id_foreign FOREIGN KEY (subtopic_id) REFERENCES odiseo.subtopic(id);


--

--

ALTER TABLE ONLY odiseo.subtopic_history
    ADD CONSTRAINT odiseo_subtopic_history_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES odiseo.topic(id);


--

--

ALTER TABLE ONLY odiseo.subtopic_history
    ADD CONSTRAINT odiseo_subtopic_history_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
