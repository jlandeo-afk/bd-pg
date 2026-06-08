-- Table: odiseo.syllabus_text_content
-- Includes constraints and indexes

--

CREATE TABLE odiseo.syllabus_text_content (
    id bigint NOT NULL,
    syllabus_text_id bigint NOT NULL,
    subtopic_id bigint NOT NULL,
    quantity smallint NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    fl_status boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE odiseo.syllabus_text_content OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.syllabus_text_content
    ADD CONSTRAINT syllabus_text_content_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.syllabus_text_content
    ADD CONSTRAINT syllabus_text_content_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY odiseo.syllabus_text_content
    ADD CONSTRAINT syllabus_text_content_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_text_content
    ADD CONSTRAINT syllabus_text_content_subtopic_id_foreign FOREIGN KEY (subtopic_id) REFERENCES odiseo.subtopic(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_text_content
    ADD CONSTRAINT syllabus_text_content_syllabus_text_id_foreign FOREIGN KEY (syllabus_text_id) REFERENCES odiseo.syllabus_texts(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_text_content
    ADD CONSTRAINT syllabus_text_content_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
