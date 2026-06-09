-- Table: materials.type_material_detail_text_subquestions
-- Includes constraints and indexes

--

CREATE TABLE materials.type_material_detail_text_subquestions (
    id BIGINT NOT NULL,
    type_material_detail_course_text_id BIGINT NOT NULL,
    subquestion_amount smallint DEFAULT '0'::smallint NOT NULL,
    "position" smallint NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE materials.type_material_detail_text_subquestions OWNER TO postgres;

--

--

ALTER TABLE materials.type_material_detail_text_subquestions
    ADD CONSTRAINT pk_type_material_detail_text_subquestions PRIMARY KEY (id);


--

--

ALTER TABLE materials.type_material_detail_text_subquestions
    ADD CONSTRAINT fk_type_material_detail_text_subquestions_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_detail_text_subquestions
    ADD CONSTRAINT fk_type_material_detail_text_subquestions_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_detail_text_subquestions
    ADD CONSTRAINT fk_type_material_detail_text_subquestions_type_material_detail_course_text FOREIGN KEY (type_material_detail_course_text_id) REFERENCES materials.type_material_detail_course_texts(id);


--

--

ALTER TABLE materials.type_material_detail_text_subquestions
    ADD CONSTRAINT fk_type_material_detail_text_subquestions_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
