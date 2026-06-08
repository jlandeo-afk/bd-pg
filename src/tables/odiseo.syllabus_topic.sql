-- Table: odiseo.syllabus_topic
-- Includes constraints and indexes

--

CREATE TABLE odiseo.syllabus_topic (
    id bigint NOT NULL,
    syllabus_id bigint NOT NULL,
    topic_id smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    is_topic_deleted boolean DEFAULT false NOT NULL,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE odiseo.syllabus_topic OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.syllabus_topic
    ADD CONSTRAINT syllabus_topic_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_st_syllabus ON odiseo.syllabus_topic USING btree (syllabus_id);


--

--

ALTER TABLE ONLY odiseo.syllabus_topic
    ADD CONSTRAINT odiseo_syllabus_topic_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_topic
    ADD CONSTRAINT odiseo_syllabus_topic_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_topic
    ADD CONSTRAINT odiseo_syllabus_topic_syllabus_id_foreign FOREIGN KEY (syllabus_id) REFERENCES odiseo.syllabus(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_topic
    ADD CONSTRAINT odiseo_syllabus_topic_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES odiseo.topic(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_topic
    ADD CONSTRAINT odiseo_syllabus_topic_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_topic
    ADD CONSTRAINT syllabus_topic_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--
