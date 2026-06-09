-- Table: materials.template_type_material_courses_order
-- Includes constraints and indexes

--

CREATE TABLE materials.template_type_material_courses_order (
    id bigint NOT NULL,
    template_type_material_id bigint NOT NULL,
    course_id bigint NOT NULL,
    "position" smallint NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    university_id integer
);


ALTER TABLE materials.template_type_material_courses_order OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.template_type_material_courses_order
    ADD CONSTRAINT template_type_material_courses_order_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.template_type_material_courses_order
    ADD CONSTRAINT odiseo_template_type_material_courses_order_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY materials.template_type_material_courses_order
    ADD CONSTRAINT odiseo_template_type_material_courses_order_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.template_type_material_courses_order
    ADD CONSTRAINT odiseo_template_type_material_courses_order_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.template_type_material_courses_order
    ADD CONSTRAINT odiseo_template_type_material_courses_order_template_type_mater FOREIGN KEY (template_type_material_id) REFERENCES materials.type_material_template(id);


--

--

ALTER TABLE ONLY materials.template_type_material_courses_order
    ADD CONSTRAINT odiseo_template_type_material_courses_order_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.template_type_material_courses_order
    ADD CONSTRAINT template_type_material_courses_order_university_id_foreign FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--
