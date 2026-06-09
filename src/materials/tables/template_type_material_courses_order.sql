-- Table: materials.template_type_material_courses_order
-- Includes constraints and indexes

--

CREATE TABLE materials.template_type_material_courses_order (
    id BIGINT NOT NULL,
    template_type_material_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    "position" smallint NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    university_id INTEGER
);


ALTER TABLE materials.template_type_material_courses_order OWNER TO postgres;

--

--

ALTER TABLE materials.template_type_material_courses_order
    ADD CONSTRAINT pk_template_type_material_courses_order PRIMARY KEY (id);


--

--

ALTER TABLE materials.template_type_material_courses_order
    ADD CONSTRAINT fk_template_type_material_courses_order_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.template_type_material_courses_order
    ADD CONSTRAINT fk_template_type_material_courses_order_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.template_type_material_courses_order
    ADD CONSTRAINT fk_template_type_material_courses_order_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.template_type_material_courses_order
    ADD CONSTRAINT fk_template_type_material_courses_order_template_type_material FOREIGN KEY (template_type_material_id) REFERENCES materials.type_material_template(id);


--

--

ALTER TABLE materials.template_type_material_courses_order
    ADD CONSTRAINT fk_template_type_material_courses_order_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.template_type_material_courses_order
    ADD CONSTRAINT fk_template_type_material_courses_order_university FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--
