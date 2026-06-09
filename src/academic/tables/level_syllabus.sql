-- Table: academic.level_syllabus
-- Includes constraints and indexes

--

CREATE TABLE academic.level_syllabus (
    id BIGINT NOT NULL,
    headquarter_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    course_id BIGINT,
    cycle_id BIGINT,
    university_id BIGINT,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE academic.level_syllabus OWNER TO postgres;

--

--

ALTER TABLE academic.level_syllabus
    ADD CONSTRAINT pk_level_syllabus PRIMARY KEY (id);


--

--

ALTER TABLE academic.level_syllabus
    ADD CONSTRAINT fk_level_syllabus_company FOREIGN KEY (company_id) REFERENCES organization.companies(id) ON DELETE RESTRICT;


--

--

ALTER TABLE academic.level_syllabus
    ADD CONSTRAINT fk_level_syllabus_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE academic.level_syllabus
    ADD CONSTRAINT fk_level_syllabus_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.level_syllabus
    ADD CONSTRAINT fk_level_syllabus_cycle FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id);


--

--

ALTER TABLE academic.level_syllabus
    ADD CONSTRAINT fk_level_syllabus_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.level_syllabus
    ADD CONSTRAINT fk_level_syllabus_headquarter FOREIGN KEY (headquarter_id) REFERENCES organization.headquarters(id);


--

--

ALTER TABLE academic.level_syllabus
    ADD CONSTRAINT fk_level_syllabus_university FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE academic.level_syllabus
    ADD CONSTRAINT fk_level_syllabus_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
