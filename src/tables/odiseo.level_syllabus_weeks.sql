-- Table: odiseo.level_syllabus_weeks
-- Includes constraints and indexes

--

CREATE TABLE odiseo.level_syllabus_weeks (
    id bigint NOT NULL,
    level_syllabus_id bigint NOT NULL,
    week smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE odiseo.level_syllabus_weeks OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.level_syllabus_weeks
    ADD CONSTRAINT level_syllabus_weeks_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.level_syllabus_weeks
    ADD CONSTRAINT level_syllabus_weeks_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--

--

ALTER TABLE ONLY odiseo.level_syllabus_weeks
    ADD CONSTRAINT odiseo_level_syllabus_weeks_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.level_syllabus_weeks
    ADD CONSTRAINT odiseo_level_syllabus_weeks_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.level_syllabus_weeks
    ADD CONSTRAINT odiseo_level_syllabus_weeks_level_syllabus_id_foreign FOREIGN KEY (level_syllabus_id) REFERENCES odiseo.level_syllabus(id);


--

--

ALTER TABLE ONLY odiseo.level_syllabus_weeks
    ADD CONSTRAINT odiseo_level_syllabus_weeks_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
