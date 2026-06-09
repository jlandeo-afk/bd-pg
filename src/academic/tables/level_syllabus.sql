-- Table: academic.level_syllabus
-- Includes constraints and indexes

--

CREATE TABLE academic.level_syllabus (
    id bigint NOT NULL,
    headquarter_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    course_id bigint,
    cycle_id bigint,
    university_id bigint,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE academic.level_syllabus OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.level_syllabus
    ADD CONSTRAINT level_syllabus_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.level_syllabus
    ADD CONSTRAINT level_syllabus_company_id_foreign FOREIGN KEY (company_id) REFERENCES organization.companies(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--

--

ALTER TABLE ONLY academic.level_syllabus
    ADD CONSTRAINT odiseo_level_syllabus_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY academic.level_syllabus
    ADD CONSTRAINT odiseo_level_syllabus_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.level_syllabus
    ADD CONSTRAINT odiseo_level_syllabus_cycle_id_foreign FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id);


--

--

ALTER TABLE ONLY academic.level_syllabus
    ADD CONSTRAINT odiseo_level_syllabus_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.level_syllabus
    ADD CONSTRAINT odiseo_level_syllabus_headquarter_id_foreign FOREIGN KEY (headquarter_id) REFERENCES organization.headquarters(id);


--

--

ALTER TABLE ONLY academic.level_syllabus
    ADD CONSTRAINT odiseo_level_syllabus_university_id_foreign FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE ONLY academic.level_syllabus
    ADD CONSTRAINT odiseo_level_syllabus_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
