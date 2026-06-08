-- Table: odiseo.syllabus_week_titles
-- Includes constraints and indexes

--

CREATE TABLE odiseo.syllabus_week_titles (
    id bigint NOT NULL,
    syllabus_id bigint NOT NULL,
    title character varying(255),
    week smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE odiseo.syllabus_week_titles OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.syllabus_week_titles
    ADD CONSTRAINT syllabus_week_titles_pkey PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX idx_syllabus_week_titles_syllabus_id_week_active ON odiseo.syllabus_week_titles USING btree (syllabus_id, week) WHERE (fl_status IS TRUE);


--

--

ALTER TABLE ONLY odiseo.syllabus_week_titles
    ADD CONSTRAINT odiseo_syllabus_week_titles_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_week_titles
    ADD CONSTRAINT odiseo_syllabus_week_titles_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_week_titles
    ADD CONSTRAINT odiseo_syllabus_week_titles_syllabus_id_foreign FOREIGN KEY (syllabus_id) REFERENCES odiseo.syllabus(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_week_titles
    ADD CONSTRAINT odiseo_syllabus_week_titles_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_week_titles
    ADD CONSTRAINT syllabus_week_titles_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--
