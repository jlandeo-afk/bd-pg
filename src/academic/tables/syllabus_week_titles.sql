-- Table: academic.syllabus_week_titles
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_week_titles (
    id BIGINT NOT NULL,
    syllabus_id BIGINT NOT NULL,
    title VARCHAR(255),
    week smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE academic.syllabus_week_titles OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus_week_titles
    ADD CONSTRAINT pk_syllabus_week_titles PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX uq_syllabus_week_titles_syllabus_id_week ON academic.syllabus_week_titles USING btree (syllabus_id, week) WHERE (fl_status IS TRUE);


--

--

ALTER TABLE academic.syllabus_week_titles
    ADD CONSTRAINT fk_syllabus_week_titles_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_week_titles
    ADD CONSTRAINT fk_syllabus_week_titles_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_week_titles
    ADD CONSTRAINT fk_syllabus_week_titles_syllabus FOREIGN KEY (syllabus_id) REFERENCES academic.syllabus(id);


--

--

ALTER TABLE academic.syllabus_week_titles
    ADD CONSTRAINT fk_syllabus_week_titles_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_week_titles
    ADD CONSTRAINT fk_syllabus_week_titles_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--
