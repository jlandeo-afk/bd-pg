-- Table: academic.syllabus_subtopic_type_material
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_subtopic_type_material (
    id BIGINT NOT NULL,
    syllabus_detail_subtopic_id BIGINT NOT NULL,
    type_material_id smallint NOT NULL,
    questions_amount smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE academic.syllabus_subtopic_type_material OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus_subtopic_type_material
    ADD CONSTRAINT pk_syllabus_subtopic_type_material PRIMARY KEY (id);


--

--

CREATE INDEX idx_syllabus_subtopic_type_material_syllabus_detail_subtopic ON academic.syllabus_subtopic_type_material USING btree (syllabus_detail_subtopic_id, fl_status);


--

--

CREATE INDEX idx_syllabus_subtopic_type_material_syllabus_detail_subtopic ON academic.syllabus_subtopic_type_material USING btree (syllabus_detail_subtopic_id, fl_status);


--

--

ALTER TABLE academic.syllabus_subtopic_type_material
    ADD CONSTRAINT fk_syllabus_subtopic_type_material_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_subtopic_type_material
    ADD CONSTRAINT fk_syllabus_subtopic_type_material_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_subtopic_type_material
    ADD CONSTRAINT fk_syllabus_subtopic_type_material_syllabus_detail_subtopic FOREIGN KEY (syllabus_detail_subtopic_id) REFERENCES academic.syllabus_detail_subtopic(id);


--

--

ALTER TABLE academic.syllabus_subtopic_type_material
    ADD CONSTRAINT fk_syllabus_subtopic_type_material_type_material FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE academic.syllabus_subtopic_type_material
    ADD CONSTRAINT fk_syllabus_subtopic_type_material_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_subtopic_type_material
    ADD CONSTRAINT fk_syllabus_subtopic_type_material_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--
