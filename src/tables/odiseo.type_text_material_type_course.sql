-- Table: odiseo.type_text_material_type_course
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_text_material_type_course (
    id bigint NOT NULL,
    type_material_id smallint NOT NULL,
    course_id smallint NOT NULL,
    subquestion_amount smallint DEFAULT '0'::smallint NOT NULL,
    "position" smallint NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.type_text_material_type_course OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_text_material_type_course
    ADD CONSTRAINT type_text_material_type_course_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.type_text_material_type_course
    ADD CONSTRAINT unique_type_material_course_pos UNIQUE (type_material_id, course_id, "position");


--

--

ALTER TABLE ONLY odiseo.type_text_material_type_course
    ADD CONSTRAINT type_text_material_type_course_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.type_text_material_type_course
    ADD CONSTRAINT type_text_material_type_course_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_text_material_type_course
    ADD CONSTRAINT type_text_material_type_course_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_text_material_type_course
    ADD CONSTRAINT type_text_material_type_course_type_material_id_foreign FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE ONLY odiseo.type_text_material_type_course
    ADD CONSTRAINT type_text_material_type_course_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
