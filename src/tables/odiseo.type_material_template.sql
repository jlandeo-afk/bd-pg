-- Table: odiseo.type_material_template
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_material_template (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    fl_exam boolean DEFAULT false NOT NULL,
    type_exam_id bigint,
    fl_use_syllabus_exam boolean DEFAULT true NOT NULL,
    fl_revision boolean DEFAULT false NOT NULL,
    has_config_column boolean DEFAULT false NOT NULL
);


ALTER TABLE odiseo.type_material_template OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_material_template
    ADD CONSTRAINT type_material_template_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.type_material_template
    ADD CONSTRAINT odiseo_type_material_template_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id) ON DELETE SET NULL;


--

--

ALTER TABLE ONLY odiseo.type_material_template
    ADD CONSTRAINT odiseo_type_material_template_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id) ON DELETE SET NULL;


--

--

ALTER TABLE ONLY odiseo.type_material_template
    ADD CONSTRAINT odiseo_type_material_template_type_exam_id_foreign FOREIGN KEY (type_exam_id) REFERENCES odiseo.type_exams(id);


--

--

ALTER TABLE ONLY odiseo.type_material_template
    ADD CONSTRAINT odiseo_type_material_template_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id) ON DELETE SET NULL;


--
