-- Table: odiseo.template_type_material_courses_order
-- Includes constraints and indexes

--

CREATE TABLE odiseo.template_type_material_courses_order (
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


ALTER TABLE odiseo.template_type_material_courses_order OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.template_type_material_courses_order
    ADD CONSTRAINT template_type_material_courses_order_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.template_type_material_courses_order
    ADD CONSTRAINT odiseo_template_type_material_courses_order_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.template_type_material_courses_order
    ADD CONSTRAINT odiseo_template_type_material_courses_order_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.template_type_material_courses_order
    ADD CONSTRAINT odiseo_template_type_material_courses_order_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.template_type_material_courses_order
    ADD CONSTRAINT odiseo_template_type_material_courses_order_template_type_mater FOREIGN KEY (template_type_material_id) REFERENCES odiseo.type_material_template(id);


--

--

ALTER TABLE ONLY odiseo.template_type_material_courses_order
    ADD CONSTRAINT odiseo_template_type_material_courses_order_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.template_type_material_courses_order
    ADD CONSTRAINT template_type_material_courses_order_university_id_foreign FOREIGN KEY (university_id) REFERENCES odiseo.origin_university(id);


--
