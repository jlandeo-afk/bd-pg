-- Table: odiseo.syllabus_detail_subtopic
-- Includes constraints and indexes

--

CREATE TABLE odiseo.syllabus_detail_subtopic (
    id bigint NOT NULL,
    syllabus_topic_week_id bigint NOT NULL,
    subtopic_id smallint NOT NULL,
    questions_amount smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    is_topic_modified boolean DEFAULT false NOT NULL,
    is_subtopic_deleted boolean DEFAULT false NOT NULL,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE odiseo.syllabus_detail_subtopic OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.syllabus_detail_subtopic
    ADD CONSTRAINT syllabus_detail_subtopic_pkey PRIMARY KEY (id);


--

--

CREATE INDEX syllabus_detail_subtopic_syllabus_topic_week_id_fl_status_idx ON odiseo.syllabus_detail_subtopic USING btree (syllabus_topic_week_id, fl_status);


--

--

CREATE INDEX syllabus_detail_subtopic_syllabus_topic_week_id_fl_status_idx1 ON odiseo.syllabus_detail_subtopic USING btree (syllabus_topic_week_id, fl_status);


--

--

ALTER TABLE ONLY odiseo.syllabus_detail_subtopic
    ADD CONSTRAINT odiseo_syllabus_detail_subtopic_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_detail_subtopic
    ADD CONSTRAINT odiseo_syllabus_detail_subtopic_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_detail_subtopic
    ADD CONSTRAINT odiseo_syllabus_detail_subtopic_subtopic_id_foreign FOREIGN KEY (subtopic_id) REFERENCES odiseo.subtopic(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_detail_subtopic
    ADD CONSTRAINT odiseo_syllabus_detail_subtopic_syllabus_topic_week_id_foreign FOREIGN KEY (syllabus_topic_week_id) REFERENCES odiseo.syllabus_topic_week(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_detail_subtopic
    ADD CONSTRAINT odiseo_syllabus_detail_subtopic_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_detail_subtopic
    ADD CONSTRAINT syllabus_detail_subtopic_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--
