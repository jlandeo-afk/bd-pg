-- Table: materials.type_material_detail_text_subquestions
-- Includes constraints and indexes

--

CREATE TABLE materials.type_material_detail_text_subquestions (
    id bigint NOT NULL,
    type_material_detail_course_text_id bigint NOT NULL,
    subquestion_amount smallint DEFAULT '0'::smallint NOT NULL,
    "position" smallint NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE materials.type_material_detail_text_subquestions OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.type_material_detail_text_subquestions
    ADD CONSTRAINT type_material_detail_text_subquestions_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.type_material_detail_text_subquestions
    ADD CONSTRAINT type_material_detail_text_subquestions_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.type_material_detail_text_subquestions
    ADD CONSTRAINT type_material_detail_text_subquestions_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.type_material_detail_text_subquestions
    ADD CONSTRAINT type_material_detail_text_subquestions_type_material_detail_cou FOREIGN KEY (type_material_detail_course_text_id) REFERENCES materials.type_material_detail_course_texts(id);


--

--

ALTER TABLE ONLY materials.type_material_detail_text_subquestions
    ADD CONSTRAINT type_material_detail_text_subquestions_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
