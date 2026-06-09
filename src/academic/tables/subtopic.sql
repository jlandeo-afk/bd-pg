-- Table: academic.subtopic
-- Includes constraints and indexes

--

CREATE TABLE academic.subtopic (
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


ALTER TABLE academic.subtopic OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.subtopic
    ADD CONSTRAINT subtopic_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.subtopic
    ADD CONSTRAINT odiseo_subtopic_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.subtopic
    ADD CONSTRAINT odiseo_subtopic_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.subtopic
    ADD CONSTRAINT odiseo_subtopic_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--

--

ALTER TABLE ONLY academic.subtopic
    ADD CONSTRAINT odiseo_subtopic_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
