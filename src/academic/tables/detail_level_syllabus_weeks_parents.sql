-- Table: academic.detail_level_syllabus_weeks_parents
-- Includes constraints and indexes

--

CREATE TABLE academic.detail_level_syllabus_weeks_parents (
    id BIGINT NOT NULL,
    level_syllabus_weeks_id BIGINT NOT NULL,
    level_id BIGINT NOT NULL,
    number_of_passages INTEGER NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    type_material_id BIGINT,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE academic.detail_level_syllabus_weeks_parents OWNER TO postgres;

--

--

ALTER TABLE academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT pk_detail_level_syllabus_weeks_parents PRIMARY KEY (id);


--

--

CREATE INDEX idx_detail_level_syllabus_weeks_parents_level_syllabus_weeks ON academic.detail_level_syllabus_weeks_parents USING btree (level_syllabus_weeks_id);


--

--

ALTER TABLE academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT fk_detail_level_syllabus_weeks_parents_company FOREIGN KEY (company_id) REFERENCES organization.companies(id) ON DELETE RESTRICT;


--

--

ALTER TABLE academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT fk_detail_level_syllabus_weeks_parents_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT fk_detail_level_syllabus_weeks_parents_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT fk_detail_level_syllabus_weeks_parents_level FOREIGN KEY (level_id) REFERENCES academic.level(id);


--

--

ALTER TABLE academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT fk_detail_level_syllabus_weeks_parents_level_syllabus_weeks FOREIGN KEY (level_syllabus_weeks_id) REFERENCES academic.level_syllabus_weeks(id);


--

--

ALTER TABLE academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT fk_detail_level_syllabus_weeks_parents_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE academic.detail_level_syllabus_weeks_parents
    ADD CONSTRAINT fk_detail_level_syllabus_weeks_parents_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
