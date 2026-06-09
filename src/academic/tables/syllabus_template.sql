-- Table: academic.syllabus_template
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_template (
    id smallint NOT NULL,
    university_id smallint NOT NULL,
    course_id BIGINT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    pseudo_course_id BIGINT,
    company_id INTEGER,
    CONSTRAINT chk_course_or_pseudo_syllabus_template CHECK ((((course_id IS NULL) AND (pseudo_course_id IS NOT NULL)) OR ((course_id IS NOT NULL) AND (pseudo_course_id IS NULL))))
);


ALTER TABLE academic.syllabus_template OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus_template
    ADD CONSTRAINT pk_syllabus_template PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX uq_syllabus_template_university_id_course_id_company_id ON academic.syllabus_template USING btree (university_id, course_id, company_id) WHERE ((fl_status = true) AND (deleted_at IS NULL));


--

--

ALTER TABLE academic.syllabus_template
    ADD CONSTRAINT fk_syllabus_template_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE academic.syllabus_template
    ADD CONSTRAINT fk_syllabus_template_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_template
    ADD CONSTRAINT fk_syllabus_template_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_template
    ADD CONSTRAINT fk_syllabus_template_pseudo_course FOREIGN KEY (pseudo_course_id) REFERENCES academic.pseudo_course(id);


--

--

ALTER TABLE academic.syllabus_template
    ADD CONSTRAINT fk_syllabus_template_university FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE academic.syllabus_template
    ADD CONSTRAINT fk_syllabus_template_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_template
    ADD CONSTRAINT fk_syllabus_template_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--
