-- Table: academic.syllabus_subtopic_type_material
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_subtopic_type_material (
    id bigint NOT NULL,
    syllabus_detail_subtopic_id bigint NOT NULL,
    type_material_id smallint NOT NULL,
    questions_amount smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE academic.syllabus_subtopic_type_material OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.syllabus_subtopic_type_material
    ADD CONSTRAINT syllabus_subtopic_type_material_pkey PRIMARY KEY (id);


--

--

CREATE INDEX syllabus_subtopic_type_materi_syllabus_detail_subtopic_id__idx1 ON academic.syllabus_subtopic_type_material USING btree (syllabus_detail_subtopic_id, fl_status);


--

--

CREATE INDEX syllabus_subtopic_type_materi_syllabus_detail_subtopic_id_f_idx ON academic.syllabus_subtopic_type_material USING btree (syllabus_detail_subtopic_id, fl_status);


--

--

ALTER TABLE ONLY academic.syllabus_subtopic_type_material
    ADD CONSTRAINT odiseo_syllabus_subtopic_type_material_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.syllabus_subtopic_type_material
    ADD CONSTRAINT odiseo_syllabus_subtopic_type_material_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.syllabus_subtopic_type_material
    ADD CONSTRAINT odiseo_syllabus_subtopic_type_material_syllabus_detail_subtopic FOREIGN KEY (syllabus_detail_subtopic_id) REFERENCES academic.syllabus_detail_subtopic(id);


--

--

ALTER TABLE ONLY academic.syllabus_subtopic_type_material
    ADD CONSTRAINT odiseo_syllabus_subtopic_type_material_type_material_id_foreign FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE ONLY academic.syllabus_subtopic_type_material
    ADD CONSTRAINT odiseo_syllabus_subtopic_type_material_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.syllabus_subtopic_type_material
    ADD CONSTRAINT syllabus_subtopic_type_material_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--
