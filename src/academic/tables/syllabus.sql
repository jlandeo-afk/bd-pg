-- Table: academic.syllabus
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus (
    id BIGINT NOT NULL,
    university_id smallint NOT NULL,
    course_id BIGINT,
    cycle_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    pseudo_course_id BIGINT,
    is_disabled BOOLEAN DEFAULT false NOT NULL,
    is_deleteable BOOLEAN DEFAULT true NOT NULL,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL,
    CONSTRAINT chk_course_or_pseudo_syllabus CHECK ((((course_id IS NULL) AND (pseudo_course_id IS NOT NULL)) OR ((course_id IS NOT NULL) AND (pseudo_course_id IS NULL))))
);


ALTER TABLE academic.syllabus OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus
    ADD CONSTRAINT pk_syllabus PRIMARY KEY (id);


--

--

ALTER TABLE academic.syllabus
    ADD CONSTRAINT fk_syllabus_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE academic.syllabus
    ADD CONSTRAINT fk_syllabus_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus
    ADD CONSTRAINT fk_syllabus_cycle FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id);


--

--

ALTER TABLE academic.syllabus
    ADD CONSTRAINT fk_syllabus_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus
    ADD CONSTRAINT fk_syllabus_pseudo_course FOREIGN KEY (pseudo_course_id) REFERENCES academic.pseudo_course(id);


--

--

ALTER TABLE academic.syllabus
    ADD CONSTRAINT fk_syllabus_university FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE academic.syllabus
    ADD CONSTRAINT fk_syllabus_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus
    ADD CONSTRAINT fk_syllabus_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--
