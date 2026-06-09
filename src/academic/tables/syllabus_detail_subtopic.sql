-- Table: academic.syllabus_detail_subtopic
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_detail_subtopic (
    id BIGINT NOT NULL,
    syllabus_topic_week_id BIGINT NOT NULL,
    subtopic_id smallint NOT NULL,
    questions_amount smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    is_topic_modified BOOLEAN DEFAULT false NOT NULL,
    is_subtopic_deleted BOOLEAN DEFAULT false NOT NULL,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE academic.syllabus_detail_subtopic OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus_detail_subtopic
    ADD CONSTRAINT pk_syllabus_detail_subtopic PRIMARY KEY (id);


--

--

CREATE INDEX idx_syllabus_detail_subtopic_syllabus_topic_week_id_fl_statu ON academic.syllabus_detail_subtopic USING btree (syllabus_topic_week_id, fl_status);


--

--

CREATE INDEX idx_syllabus_detail_subtopic_syllabus_topic_week_id_fl_statu ON academic.syllabus_detail_subtopic USING btree (syllabus_topic_week_id, fl_status);


--

--

ALTER TABLE academic.syllabus_detail_subtopic
    ADD CONSTRAINT fk_syllabus_detail_subtopic_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_detail_subtopic
    ADD CONSTRAINT fk_syllabus_detail_subtopic_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_detail_subtopic
    ADD CONSTRAINT fk_syllabus_detail_subtopic_subtopic FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE academic.syllabus_detail_subtopic
    ADD CONSTRAINT fk_syllabus_detail_subtopic_syllabus_topic_week FOREIGN KEY (syllabus_topic_week_id) REFERENCES academic.syllabus_topic_week(id);


--

--

ALTER TABLE academic.syllabus_detail_subtopic
    ADD CONSTRAINT fk_syllabus_detail_subtopic_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_detail_subtopic
    ADD CONSTRAINT fk_syllabus_detail_subtopic_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--
