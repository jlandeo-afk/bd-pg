-- Table: odiseo.material_class_week
-- Includes constraints and indexes

--

CREATE TABLE odiseo.material_class_week (
    id bigint NOT NULL,
    material_id bigint NOT NULL,
    type_material_id smallint NOT NULL,
    week_type_material_ids character varying(255),
    week smallint NOT NULL,
    course_id smallint NOT NULL,
    fl_process_status smallint DEFAULT '1'::smallint NOT NULL,
    url_material_class character varying(255),
    job_id character varying(255),
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    url_material_class_solution character varying(255),
    fl_course_active boolean DEFAULT true NOT NULL
);


ALTER TABLE odiseo.material_class_week OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.material_class_week
    ADD CONSTRAINT material_class_week_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.material_class_week
    ADD CONSTRAINT odiseo_material_class_week_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.material_class_week
    ADD CONSTRAINT odiseo_material_class_week_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_class_week
    ADD CONSTRAINT odiseo_material_class_week_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_class_week
    ADD CONSTRAINT odiseo_material_class_week_material_id_foreign FOREIGN KEY (material_id) REFERENCES odiseo.material(id);


--

--

ALTER TABLE ONLY odiseo.material_class_week
    ADD CONSTRAINT odiseo_material_class_week_type_material_id_foreign FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE ONLY odiseo.material_class_week
    ADD CONSTRAINT odiseo_material_class_week_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
