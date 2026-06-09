-- Table: academic.syllabus_text_weeks
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_text_weeks (
    id BIGINT NOT NULL,
    syllabus_id BIGINT NOT NULL,
    week smallint NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE academic.syllabus_text_weeks OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus_text_weeks
    ADD CONSTRAINT pk_syllabus_text_weeks PRIMARY KEY (id);


--

--

ALTER TABLE academic.syllabus_text_weeks
    ADD CONSTRAINT fk_syllabus_text_weeks_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--

--

ALTER TABLE academic.syllabus_text_weeks
    ADD CONSTRAINT fk_syllabus_text_weeks_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_text_weeks
    ADD CONSTRAINT fk_syllabus_text_weeks_syllabus FOREIGN KEY (syllabus_id) REFERENCES academic.syllabus(id);


--

--

ALTER TABLE academic.syllabus_text_weeks
    ADD CONSTRAINT fk_syllabus_text_weeks_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
