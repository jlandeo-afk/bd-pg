-- Table: odiseo.type_material_detail_courses
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_material_detail_courses (
    id bigint NOT NULL,
    type_material_detail_template_id bigint NOT NULL,
    type_material_course_id bigint NOT NULL,
    course_id bigint NOT NULL,
    amount_question integer NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.type_material_detail_courses OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_material_detail_courses
    ADD CONSTRAINT type_material_detail_courses_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.type_material_detail_courses
    ADD CONSTRAINT type_material_detail_courses_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.type_material_detail_courses
    ADD CONSTRAINT type_material_detail_courses_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_material_detail_courses
    ADD CONSTRAINT type_material_detail_courses_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_material_detail_courses
    ADD CONSTRAINT type_material_detail_courses_type_material_course_id_foreign FOREIGN KEY (type_material_course_id) REFERENCES odiseo.type_material_course(id);


--

--

ALTER TABLE ONLY odiseo.type_material_detail_courses
    ADD CONSTRAINT type_material_detail_courses_type_material_detail_template_id_f FOREIGN KEY (type_material_detail_template_id) REFERENCES odiseo.type_material_detail_template(id);


--

--

ALTER TABLE ONLY odiseo.type_material_detail_courses
    ADD CONSTRAINT type_material_detail_courses_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
