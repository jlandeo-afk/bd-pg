-- Table: academic.syllabus
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus (
    id bigint NOT NULL,
    university_id smallint NOT NULL,
    course_id bigint,
    cycle_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    pseudo_course_id bigint,
    is_disabled boolean DEFAULT false NOT NULL,
    is_deleteable boolean DEFAULT true NOT NULL,
    company_id bigint DEFAULT '1'::bigint NOT NULL,
    CONSTRAINT chk_course_or_pseudo_syllabus CHECK ((((course_id IS NULL) AND (pseudo_course_id IS NOT NULL)) OR ((course_id IS NOT NULL) AND (pseudo_course_id IS NULL))))
);


ALTER TABLE academic.syllabus OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.syllabus
    ADD CONSTRAINT syllabus_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.syllabus
    ADD CONSTRAINT odiseo_syllabus_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY academic.syllabus
    ADD CONSTRAINT odiseo_syllabus_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.syllabus
    ADD CONSTRAINT odiseo_syllabus_cycle_id_foreign FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id);


--

--

ALTER TABLE ONLY academic.syllabus
    ADD CONSTRAINT odiseo_syllabus_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.syllabus
    ADD CONSTRAINT odiseo_syllabus_pseudo_course_id_foreign FOREIGN KEY (pseudo_course_id) REFERENCES academic.pseudo_course(id);


--

--

ALTER TABLE ONLY academic.syllabus
    ADD CONSTRAINT odiseo_syllabus_university_id_foreign FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE ONLY academic.syllabus
    ADD CONSTRAINT odiseo_syllabus_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.syllabus
    ADD CONSTRAINT syllabus_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--
