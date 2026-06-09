-- Table: academic.syllabus_topic_week
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_topic_week (
    id bigint NOT NULL,
    syllabus_topic_id bigint NOT NULL,
    week smallint NOT NULL,
    total_questions_amount smallint DEFAULT '0'::smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE academic.syllabus_topic_week OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.syllabus_topic_week
    ADD CONSTRAINT syllabus_topic_week_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_stw_topic_week_lookup ON academic.syllabus_topic_week USING btree (week, syllabus_topic_id) WHERE ((fl_status = true) AND (total_questions_amount > 0));


--

--

CREATE INDEX syllabus_topic_week_syllabus_topic_id_fl_status_idx ON academic.syllabus_topic_week USING btree (syllabus_topic_id, fl_status);


--

--

CREATE INDEX syllabus_topic_week_syllabus_topic_id_fl_status_idx1 ON academic.syllabus_topic_week USING btree (syllabus_topic_id, fl_status);


--

--

ALTER TABLE ONLY academic.syllabus_topic_week
    ADD CONSTRAINT odiseo_syllabus_topic_week_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.syllabus_topic_week
    ADD CONSTRAINT odiseo_syllabus_topic_week_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.syllabus_topic_week
    ADD CONSTRAINT odiseo_syllabus_topic_week_syllabus_topic_id_foreign FOREIGN KEY (syllabus_topic_id) REFERENCES academic.syllabus_topic(id);


--

--

ALTER TABLE ONLY academic.syllabus_topic_week
    ADD CONSTRAINT odiseo_syllabus_topic_week_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.syllabus_topic_week
    ADD CONSTRAINT syllabus_topic_week_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--
