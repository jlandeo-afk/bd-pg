-- Table: odiseo.syllabus_template_topic_subtopic
-- Includes constraints and indexes

--

CREATE TABLE odiseo.syllabus_template_topic_subtopic (
    id bigint NOT NULL,
    syllabus_template_topic_id integer NOT NULL,
    subtopic_id smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    company_id integer
);


ALTER TABLE odiseo.syllabus_template_topic_subtopic OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.syllabus_template_topic_subtopic
    ADD CONSTRAINT syllabus_template_topic_subtopic_pkey PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX syllabus_tmpl_sub_topic_sub_co_unique ON odiseo.syllabus_template_topic_subtopic USING btree (syllabus_template_topic_id, subtopic_id, company_id) WHERE ((fl_status = true) AND (deleted_at IS NULL));


--

--

ALTER TABLE ONLY odiseo.syllabus_template_topic_subtopic
    ADD CONSTRAINT odiseo_syllabus_template_topic_subtopic_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_template_topic_subtopic
    ADD CONSTRAINT odiseo_syllabus_template_topic_subtopic_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_template_topic_subtopic
    ADD CONSTRAINT odiseo_syllabus_template_topic_subtopic_syllabus_template_topic FOREIGN KEY (syllabus_template_topic_id) REFERENCES odiseo.syllabus_template_topic(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_template_topic_subtopic
    ADD CONSTRAINT odiseo_syllabus_template_topic_subtopic_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_template_topic_subtopic
    ADD CONSTRAINT syllabus_template_topic_subtopic_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--
