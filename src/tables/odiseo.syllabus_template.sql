-- Table: odiseo.syllabus_template
-- Includes constraints and indexes

--

CREATE TABLE odiseo.syllabus_template (
    id smallint NOT NULL,
    university_id smallint NOT NULL,
    course_id bigint,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    pseudo_course_id bigint,
    company_id integer,
    CONSTRAINT chk_course_or_pseudo_syllabus_template CHECK ((((course_id IS NULL) AND (pseudo_course_id IS NOT NULL)) OR ((course_id IS NOT NULL) AND (pseudo_course_id IS NULL))))
);


ALTER TABLE odiseo.syllabus_template OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.syllabus_template
    ADD CONSTRAINT syllabus_template_pkey PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX syllabus_tmpl_uni_course_co_unique ON odiseo.syllabus_template USING btree (university_id, course_id, company_id) WHERE ((fl_status = true) AND (deleted_at IS NULL));


--

--

ALTER TABLE ONLY odiseo.syllabus_template
    ADD CONSTRAINT odiseo_syllabus_template_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_template
    ADD CONSTRAINT odiseo_syllabus_template_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_template
    ADD CONSTRAINT odiseo_syllabus_template_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_template
    ADD CONSTRAINT odiseo_syllabus_template_pseudo_course_id_foreign FOREIGN KEY (pseudo_course_id) REFERENCES odiseo.pseudo_course(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_template
    ADD CONSTRAINT odiseo_syllabus_template_university_id_foreign FOREIGN KEY (university_id) REFERENCES odiseo.origin_university(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_template
    ADD CONSTRAINT odiseo_syllabus_template_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_template
    ADD CONSTRAINT syllabus_template_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--
