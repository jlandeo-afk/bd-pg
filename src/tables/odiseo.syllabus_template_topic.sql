-- Table: odiseo.syllabus_template_topic
-- Includes constraints and indexes

--

CREATE TABLE odiseo.syllabus_template_topic (
    id integer NOT NULL,
    syllabus_template_id smallint NOT NULL,
    topic_id smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    company_id integer
);


ALTER TABLE odiseo.syllabus_template_topic OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.syllabus_template_topic
    ADD CONSTRAINT syllabus_template_topic_pkey PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX syllabus_tmpl_topic_tmpl_topic_co_unique ON odiseo.syllabus_template_topic USING btree (syllabus_template_id, topic_id, company_id) WHERE ((fl_status = true) AND (deleted_at IS NULL));


--

--

ALTER TABLE ONLY odiseo.syllabus_template_topic
    ADD CONSTRAINT odiseo_syllabus_template_topic_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_template_topic
    ADD CONSTRAINT odiseo_syllabus_template_topic_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_template_topic
    ADD CONSTRAINT odiseo_syllabus_template_topic_syllabus_template_id_foreign FOREIGN KEY (syllabus_template_id) REFERENCES odiseo.syllabus_template(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_template_topic
    ADD CONSTRAINT odiseo_syllabus_template_topic_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_template_topic
    ADD CONSTRAINT syllabus_template_topic_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--
