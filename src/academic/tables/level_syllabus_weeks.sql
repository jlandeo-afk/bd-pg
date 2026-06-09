-- Table: academic.level_syllabus_weeks
-- Includes constraints and indexes

--

CREATE TABLE academic.level_syllabus_weeks (
    id BIGINT NOT NULL,
    level_syllabus_id BIGINT NOT NULL,
    week smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE academic.level_syllabus_weeks OWNER TO postgres;

--

--

ALTER TABLE academic.level_syllabus_weeks
    ADD CONSTRAINT pk_level_syllabus_weeks PRIMARY KEY (id);


--

--

ALTER TABLE academic.level_syllabus_weeks
    ADD CONSTRAINT fk_level_syllabus_weeks_company FOREIGN KEY (company_id) REFERENCES organization.companies(id) ON DELETE RESTRICT;


--

--

ALTER TABLE academic.level_syllabus_weeks
    ADD CONSTRAINT fk_level_syllabus_weeks_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.level_syllabus_weeks
    ADD CONSTRAINT fk_level_syllabus_weeks_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.level_syllabus_weeks
    ADD CONSTRAINT fk_level_syllabus_weeks_level_syllabus FOREIGN KEY (level_syllabus_id) REFERENCES academic.level_syllabus(id);


--

--

ALTER TABLE academic.level_syllabus_weeks
    ADD CONSTRAINT fk_level_syllabus_weeks_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
