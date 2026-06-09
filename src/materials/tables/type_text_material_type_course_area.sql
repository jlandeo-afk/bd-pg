-- Table: materials.type_text_material_type_course_area
-- Includes constraints and indexes

--

CREATE TABLE materials.type_text_material_type_course_area (
    id BIGINT NOT NULL,
    type_material_id smallint NOT NULL,
    course_id smallint NOT NULL,
    exam_area_id smallint NOT NULL,
    subquestion_amount smallint DEFAULT '0'::smallint NOT NULL,
    "position" smallint NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE materials.type_text_material_type_course_area OWNER TO postgres;

--

--

ALTER TABLE materials.type_text_material_type_course_area
    ADD CONSTRAINT pk_type_text_material_type_course_area PRIMARY KEY (id);


--

--

ALTER TABLE materials.type_text_material_type_course_area
    ADD CONSTRAINT unique_type_material_course_are_pos UNIQUE (type_material_id, course_id, exam_area_id, "position");


--

--

ALTER TABLE materials.type_text_material_type_course_area
    ADD CONSTRAINT fk_type_text_material_type_course_area_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.type_text_material_type_course_area
    ADD CONSTRAINT fk_type_text_material_type_course_area_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_text_material_type_course_area
    ADD CONSTRAINT fk_type_text_material_type_course_area_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_text_material_type_course_area
    ADD CONSTRAINT fk_type_text_material_type_course_area_exam_area FOREIGN KEY (exam_area_id) REFERENCES odiseo.exam_area(id);


--

--

ALTER TABLE materials.type_text_material_type_course_area
    ADD CONSTRAINT fk_type_text_material_type_course_area_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE materials.type_text_material_type_course_area
    ADD CONSTRAINT fk_type_text_material_type_course_area_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
