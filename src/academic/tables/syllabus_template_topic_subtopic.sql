-- Table: academic.syllabus_template_topic_subtopic
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_template_topic_subtopic (
    id BIGINT NOT NULL,
    syllabus_template_topic_id INTEGER NOT NULL,
    subtopic_id smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    company_id INTEGER
);


ALTER TABLE academic.syllabus_template_topic_subtopic OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus_template_topic_subtopic
    ADD CONSTRAINT pk_syllabus_template_topic_subtopic PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX uq_syllabus_template_topic_subtopic_syllabus_template_topic_ ON academic.syllabus_template_topic_subtopic USING btree (syllabus_template_topic_id, subtopic_id, company_id) WHERE ((fl_status = true) AND (deleted_at IS NULL));


--

--

ALTER TABLE academic.syllabus_template_topic_subtopic
    ADD CONSTRAINT fk_syllabus_template_topic_subtopic_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_template_topic_subtopic
    ADD CONSTRAINT fk_syllabus_template_topic_subtopic_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_template_topic_subtopic
    ADD CONSTRAINT fk_syllabus_template_topic_subtopic_syllabus_template_topic FOREIGN KEY (syllabus_template_topic_id) REFERENCES academic.syllabus_template_topic(id);


--

--

ALTER TABLE academic.syllabus_template_topic_subtopic
    ADD CONSTRAINT fk_syllabus_template_topic_subtopic_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_template_topic_subtopic
    ADD CONSTRAINT fk_syllabus_template_topic_subtopic_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--
