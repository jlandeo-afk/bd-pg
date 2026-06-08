-- Table: odiseo.type_material_course
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_material_course (
    id bigint NOT NULL,
    course_id smallint NOT NULL,
    type_material_id smallint NOT NULL,
    amount_question integer DEFAULT 0 NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    amount_text integer DEFAULT 0 NOT NULL,
    amount_subquestion integer DEFAULT 0,
    is_generic boolean DEFAULT true NOT NULL,
    is_generic_text boolean DEFAULT true NOT NULL
);


ALTER TABLE odiseo.type_material_course OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_material_course
    ADD CONSTRAINT type_material_course_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.type_material_course
    ADD CONSTRAINT odiseo_type_material_course_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.type_material_course
    ADD CONSTRAINT odiseo_type_material_course_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_material_course
    ADD CONSTRAINT odiseo_type_material_course_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_material_course
    ADD CONSTRAINT odiseo_type_material_course_type_material_id_foreign FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE ONLY odiseo.type_material_course
    ADD CONSTRAINT odiseo_type_material_course_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
