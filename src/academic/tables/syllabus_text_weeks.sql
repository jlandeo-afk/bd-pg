-- Table: academic.syllabus_text_weeks
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_text_weeks (
    id bigint NOT NULL,
    syllabus_id bigint NOT NULL,
    week smallint NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    fl_status boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE academic.syllabus_text_weeks OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.syllabus_text_weeks
    ADD CONSTRAINT syllabus_text_weeks_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.syllabus_text_weeks
    ADD CONSTRAINT syllabus_text_weeks_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY academic.syllabus_text_weeks
    ADD CONSTRAINT syllabus_text_weeks_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.syllabus_text_weeks
    ADD CONSTRAINT syllabus_text_weeks_syllabus_id_foreign FOREIGN KEY (syllabus_id) REFERENCES academic.syllabus(id);


--

--

ALTER TABLE ONLY academic.syllabus_text_weeks
    ADD CONSTRAINT syllabus_text_weeks_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
