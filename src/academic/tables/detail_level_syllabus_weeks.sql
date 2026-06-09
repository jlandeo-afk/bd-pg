-- Table: academic.detail_level_syllabus_weeks
-- Includes constraints and indexes

--

CREATE TABLE academic.detail_level_syllabus_weeks (
    id BIGINT NOT NULL,
    level_syllabus_weeks_id BIGINT NOT NULL,
    type_material_id BIGINT NOT NULL,
    level_id BIGINT NOT NULL,
    type_question VARCHAR(255) NOT NULL,
    number_questions INTEGER NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE academic.detail_level_syllabus_weeks OWNER TO postgres;

--

--

ALTER TABLE academic.detail_level_syllabus_weeks
    ADD CONSTRAINT pk_detail_level_syllabus_weeks PRIMARY KEY (id);


--

--

CREATE INDEX idx_detail_level_syllabus_weeks_level_syllabus_weeks_id ON academic.detail_level_syllabus_weeks USING btree (level_syllabus_weeks_id);


--

--

ALTER TABLE academic.detail_level_syllabus_weeks
    ADD CONSTRAINT fk_detail_level_syllabus_weeks_company FOREIGN KEY (company_id) REFERENCES organization.companies(id) ON DELETE RESTRICT;


--

--

ALTER TABLE academic.detail_level_syllabus_weeks
    ADD CONSTRAINT fk_detail_level_syllabus_weeks_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.detail_level_syllabus_weeks
    ADD CONSTRAINT fk_detail_level_syllabus_weeks_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.detail_level_syllabus_weeks
    ADD CONSTRAINT fk_detail_level_syllabus_weeks_level FOREIGN KEY (level_id) REFERENCES academic.level(id);


--

--

ALTER TABLE academic.detail_level_syllabus_weeks
    ADD CONSTRAINT fk_detail_level_syllabus_weeks_level_syllabus_weeks FOREIGN KEY (level_syllabus_weeks_id) REFERENCES academic.level_syllabus_weeks(id);


--

--

ALTER TABLE academic.detail_level_syllabus_weeks
    ADD CONSTRAINT fk_detail_level_syllabus_weeks_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE academic.detail_level_syllabus_weeks
    ADD CONSTRAINT fk_detail_level_syllabus_weeks_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
