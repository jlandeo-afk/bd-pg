-- Table: academic.syllabus_template_topic
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_template_topic (
    id INTEGER NOT NULL,
    syllabus_template_id smallint NOT NULL,
    topic_id smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    company_id INTEGER
);


ALTER TABLE academic.syllabus_template_topic OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus_template_topic
    ADD CONSTRAINT pk_syllabus_template_topic PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX uq_syllabus_template_topic_syllabus_template_id_topic_id_com ON academic.syllabus_template_topic USING btree (syllabus_template_id, topic_id, company_id) WHERE ((fl_status = true) AND (deleted_at IS NULL));


--

--

ALTER TABLE academic.syllabus_template_topic
    ADD CONSTRAINT fk_syllabus_template_topic_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_template_topic
    ADD CONSTRAINT fk_syllabus_template_topic_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_template_topic
    ADD CONSTRAINT fk_syllabus_template_topic_syllabus_template FOREIGN KEY (syllabus_template_id) REFERENCES academic.syllabus_template(id);


--

--

ALTER TABLE academic.syllabus_template_topic
    ADD CONSTRAINT fk_syllabus_template_topic_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_template_topic
    ADD CONSTRAINT fk_syllabus_template_topic_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--
