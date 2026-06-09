-- Table: materials.type_material_detail_course_texts
-- Includes constraints and indexes

--

CREATE TABLE materials.type_material_detail_course_texts (
    id BIGINT NOT NULL,
    type_material_detail_template_id BIGINT NOT NULL,
    type_material_course_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    amount_text INTEGER NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE materials.type_material_detail_course_texts OWNER TO postgres;

--

--

ALTER TABLE materials.type_material_detail_course_texts
    ADD CONSTRAINT pk_type_material_detail_course_texts PRIMARY KEY (id);


--

--

ALTER TABLE materials.type_material_detail_course_texts
    ADD CONSTRAINT fk_type_material_detail_course_texts_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.type_material_detail_course_texts
    ADD CONSTRAINT fk_type_material_detail_course_texts_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_detail_course_texts
    ADD CONSTRAINT fk_type_material_detail_course_texts_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_detail_course_texts
    ADD CONSTRAINT fk_type_material_detail_course_texts_type_material_course FOREIGN KEY (type_material_course_id) REFERENCES materials.type_material_course(id);


--

--

ALTER TABLE materials.type_material_detail_course_texts
    ADD CONSTRAINT fk_type_material_detail_course_texts_type_material_detail_template FOREIGN KEY (type_material_detail_template_id) REFERENCES materials.type_material_detail_template(id);


--

--

ALTER TABLE materials.type_material_detail_course_texts
    ADD CONSTRAINT fk_type_material_detail_course_texts_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
