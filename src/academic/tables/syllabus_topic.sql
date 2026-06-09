-- Table: academic.syllabus_topic
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_topic (
    id BIGINT NOT NULL,
    syllabus_id BIGINT NOT NULL,
    topic_id smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    is_topic_deleted BOOLEAN DEFAULT false NOT NULL,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE academic.syllabus_topic OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus_topic
    ADD CONSTRAINT pk_syllabus_topic PRIMARY KEY (id);


--

--

CREATE INDEX idx_syllabus_topic_syllabus_id ON academic.syllabus_topic USING btree (syllabus_id);


--

--

ALTER TABLE academic.syllabus_topic
    ADD CONSTRAINT fk_syllabus_topic_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_topic
    ADD CONSTRAINT fk_syllabus_topic_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_topic
    ADD CONSTRAINT fk_syllabus_topic_syllabus FOREIGN KEY (syllabus_id) REFERENCES academic.syllabus(id);


--

--

ALTER TABLE academic.syllabus_topic
    ADD CONSTRAINT fk_syllabus_topic_topic FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--

--

ALTER TABLE academic.syllabus_topic
    ADD CONSTRAINT fk_syllabus_topic_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_topic
    ADD CONSTRAINT fk_syllabus_topic_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--
