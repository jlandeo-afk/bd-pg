-- Table: academic.syllabus_topic_week
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_topic_week (
    id BIGINT NOT NULL,
    syllabus_topic_id BIGINT NOT NULL,
    week smallint NOT NULL,
    total_questions_amount smallint DEFAULT '0'::smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE academic.syllabus_topic_week OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus_topic_week
    ADD CONSTRAINT pk_syllabus_topic_week PRIMARY KEY (id);


--

--

CREATE INDEX idx_syllabus_topic_week_week_syllabus_topic_id ON academic.syllabus_topic_week USING btree (week, syllabus_topic_id) WHERE ((fl_status = true) AND (total_questions_amount > 0));


--

--

CREATE INDEX idx_syllabus_topic_week_syllabus_topic_id_fl_status ON academic.syllabus_topic_week USING btree (syllabus_topic_id, fl_status);


--

--

CREATE INDEX idx_syllabus_topic_week_syllabus_topic_id_fl_status ON academic.syllabus_topic_week USING btree (syllabus_topic_id, fl_status);


--

--

ALTER TABLE academic.syllabus_topic_week
    ADD CONSTRAINT fk_syllabus_topic_week_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_topic_week
    ADD CONSTRAINT fk_syllabus_topic_week_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_topic_week
    ADD CONSTRAINT fk_syllabus_topic_week_syllabus_topic FOREIGN KEY (syllabus_topic_id) REFERENCES academic.syllabus_topic(id);


--

--

ALTER TABLE academic.syllabus_topic_week
    ADD CONSTRAINT fk_syllabus_topic_week_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_topic_week
    ADD CONSTRAINT fk_syllabus_topic_week_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--
