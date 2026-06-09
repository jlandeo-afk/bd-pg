-- Table: academic.detail_level_syllabus_weeks_parents
-- Includes constraints and indexes

--

CREATE TABLE academic.detail_level_syllabus_weeks_parents (
    id bigint NOT NULL,
    level_syllabus_weeks_id bigint NOT NULL,
    level_id bigint NOT NULL,
    number_of_passages integer NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    type_material_id bigint,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE academic.detail_level_syllabus_weeks_parents OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT detail_level_syllabus_weeks_parents_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_dtl_lvl_syl_wks_parents_id ON academic.detail_level_syllabus_weeks_parents USING btree (level_syllabus_weeks_id);


--

--

ALTER TABLE ONLY academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT detail_level_syllabus_weeks_parents_company_id_foreign FOREIGN KEY (company_id) REFERENCES organization.companies(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--

--

ALTER TABLE ONLY academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT detail_level_syllabus_weeks_parents_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT detail_level_syllabus_weeks_parents_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT detail_level_syllabus_weeks_parents_level_id_foreign FOREIGN KEY (level_id) REFERENCES academic.level(id);


--

--

ALTER TABLE ONLY academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT detail_level_syllabus_weeks_parents_level_syllabus_weeks_id_for FOREIGN KEY (level_syllabus_weeks_id) REFERENCES academic.level_syllabus_weeks(id);


--

--

ALTER TABLE ONLY academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT detail_level_syllabus_weeks_parents_type_material_id_foreign FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE ONLY academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT detail_level_syllabus_weeks_parents_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
