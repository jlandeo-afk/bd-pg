-- Table: academic.course_text_category_settings
-- Includes constraints and indexes

--

CREATE TABLE academic.course_text_category_settings (
    id BIGINT NOT NULL,
    course_id smallint NOT NULL,
    type_text_id smallint NOT NULL,
    fl_show_in_material_without_solution BOOLEAN DEFAULT false NOT NULL,
    fl_show_in_material_with_solution BOOLEAN DEFAULT false NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE academic.course_text_category_settings OWNER TO postgres;

--

--

ALTER TABLE academic.course_text_category_settings
    ADD CONSTRAINT pk_course_text_category_settings PRIMARY KEY (id);


--

--

ALTER TABLE academic.course_text_category_settings
    ADD CONSTRAINT course_type_text_unique UNIQUE (course_id, type_text_id);


--

--

ALTER TABLE academic.course_text_category_settings
    ADD CONSTRAINT fk_course_text_category_settings_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE academic.course_text_category_settings
    ADD CONSTRAINT fk_course_text_category_settings_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.course_text_category_settings
    ADD CONSTRAINT fk_course_text_category_settings_type_text FOREIGN KEY (type_text_id) REFERENCES common.type_text(id);


--

--

ALTER TABLE academic.course_text_category_settings
    ADD CONSTRAINT fk_course_text_category_settings_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
