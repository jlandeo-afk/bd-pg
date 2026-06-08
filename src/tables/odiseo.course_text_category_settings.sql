-- Table: odiseo.course_text_category_settings
-- Includes constraints and indexes

--

CREATE TABLE odiseo.course_text_category_settings (
    id bigint NOT NULL,
    course_id smallint NOT NULL,
    type_text_id smallint NOT NULL,
    fl_show_in_material_without_solution boolean DEFAULT false NOT NULL,
    fl_show_in_material_with_solution boolean DEFAULT false NOT NULL,
    created_by bigint,
    updated_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.course_text_category_settings OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.course_text_category_settings
    ADD CONSTRAINT course_text_category_settings_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.course_text_category_settings
    ADD CONSTRAINT course_type_text_unique UNIQUE (course_id, type_text_id);


--

--

ALTER TABLE ONLY odiseo.course_text_category_settings
    ADD CONSTRAINT course_text_category_settings_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.course_text_category_settings
    ADD CONSTRAINT course_text_category_settings_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.course_text_category_settings
    ADD CONSTRAINT course_text_category_settings_type_text_id_foreign FOREIGN KEY (type_text_id) REFERENCES odiseo.type_text(id);


--

--

ALTER TABLE ONLY odiseo.course_text_category_settings
    ADD CONSTRAINT course_text_category_settings_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
