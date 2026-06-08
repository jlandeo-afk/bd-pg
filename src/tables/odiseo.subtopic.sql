-- Table: odiseo.subtopic
-- Includes constraints and indexes

--

CREATE TABLE odiseo.subtopic (
    id smallint NOT NULL,
    code character varying(3) NOT NULL,
    name character varying(300) NOT NULL,
    topic_id smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.subtopic OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.subtopic
    ADD CONSTRAINT subtopic_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.subtopic
    ADD CONSTRAINT odiseo_subtopic_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.subtopic
    ADD CONSTRAINT odiseo_subtopic_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.subtopic
    ADD CONSTRAINT odiseo_subtopic_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES odiseo.topic(id);


--

--

ALTER TABLE ONLY odiseo.subtopic
    ADD CONSTRAINT odiseo_subtopic_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
