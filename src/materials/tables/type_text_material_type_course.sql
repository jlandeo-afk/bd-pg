-- Table: materials.type_text_material_type_course
-- Includes constraints and indexes

--

CREATE TABLE materials.type_text_material_type_course (
    id BIGINT NOT NULL,
    type_material_id smallint NOT NULL,
    course_id smallint NOT NULL,
    subquestion_amount smallint DEFAULT '0'::smallint NOT NULL,
    "position" smallint NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE materials.type_text_material_type_course OWNER TO postgres;

--

--

ALTER TABLE materials.type_text_material_type_course
    ADD CONSTRAINT pk_type_text_material_type_course PRIMARY KEY (id);


--

--

ALTER TABLE materials.type_text_material_type_course
    ADD CONSTRAINT unique_type_material_course_pos UNIQUE (type_material_id, course_id, "position");


--

--

ALTER TABLE materials.type_text_material_type_course
    ADD CONSTRAINT fk_type_text_material_type_course_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.type_text_material_type_course
    ADD CONSTRAINT fk_type_text_material_type_course_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_text_material_type_course
    ADD CONSTRAINT fk_type_text_material_type_course_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_text_material_type_course
    ADD CONSTRAINT fk_type_text_material_type_course_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE materials.type_text_material_type_course
    ADD CONSTRAINT fk_type_text_material_type_course_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
