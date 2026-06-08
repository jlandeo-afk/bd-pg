-- Table: odiseo.setting_diagrammed_courses
-- Includes constraints and indexes

--

CREATE TABLE odiseo.setting_diagrammed_courses (
    id bigint NOT NULL,
    course_id bigint NOT NULL,
    "position" smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    field_diagram_id bigint,
    category_text_id bigint,
    fl_active boolean DEFAULT true NOT NULL,
    fl_optional boolean DEFAULT false NOT NULL
);


ALTER TABLE odiseo.setting_diagrammed_courses OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.setting_diagrammed_courses
    ADD CONSTRAINT setting_diagrammed_courses_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.setting_diagrammed_courses
    ADD CONSTRAINT odiseo_setting_diagrammed_courses_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.setting_diagrammed_courses
    ADD CONSTRAINT odiseo_setting_diagrammed_courses_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.setting_diagrammed_courses
    ADD CONSTRAINT odiseo_setting_diagrammed_courses_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.setting_diagrammed_courses
    ADD CONSTRAINT odiseo_setting_diagrammed_courses_field_diagram_id_foreign FOREIGN KEY (field_diagram_id) REFERENCES odiseo.field_diagrammed(id);


--

--

ALTER TABLE ONLY odiseo.setting_diagrammed_courses
    ADD CONSTRAINT odiseo_setting_diagrammed_courses_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
