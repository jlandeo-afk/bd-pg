-- Table: academic.syllabus_text_content
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_text_content (
    id BIGINT NOT NULL,
    syllabus_text_id BIGINT NOT NULL,
    subtopic_id BIGINT NOT NULL,
    quantity smallint NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE academic.syllabus_text_content OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus_text_content
    ADD CONSTRAINT pk_syllabus_text_content PRIMARY KEY (id);


--

--

ALTER TABLE academic.syllabus_text_content
    ADD CONSTRAINT fk_syllabus_text_content_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--

--

ALTER TABLE academic.syllabus_text_content
    ADD CONSTRAINT fk_syllabus_text_content_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_text_content
    ADD CONSTRAINT fk_syllabus_text_content_subtopic FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE academic.syllabus_text_content
    ADD CONSTRAINT fk_syllabus_text_content_syllabus_text FOREIGN KEY (syllabus_text_id) REFERENCES academic.syllabus_texts(id);


--

--

ALTER TABLE academic.syllabus_text_content
    ADD CONSTRAINT fk_syllabus_text_content_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
