-- Table: materials.type_material_course
-- Includes constraints and indexes

--

CREATE TABLE materials.type_material_course (
    id BIGINT NOT NULL,
    course_id smallint NOT NULL,
    type_material_id smallint NOT NULL,
    amount_question INTEGER DEFAULT 0 NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    amount_text INTEGER DEFAULT 0 NOT NULL,
    amount_subquestion INTEGER DEFAULT 0,
    is_generic BOOLEAN DEFAULT true NOT NULL,
    is_generic_text BOOLEAN DEFAULT true NOT NULL
);


ALTER TABLE materials.type_material_course OWNER TO postgres;

--

--

ALTER TABLE materials.type_material_course
    ADD CONSTRAINT pk_type_material_course PRIMARY KEY (id);


--

--

ALTER TABLE materials.type_material_course
    ADD CONSTRAINT fk_type_material_course_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.type_material_course
    ADD CONSTRAINT fk_type_material_course_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_course
    ADD CONSTRAINT fk_type_material_course_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_course
    ADD CONSTRAINT fk_type_material_course_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE materials.type_material_course
    ADD CONSTRAINT fk_type_material_course_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
