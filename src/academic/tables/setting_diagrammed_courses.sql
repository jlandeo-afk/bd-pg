-- Table: academic.setting_diagrammed_courses
-- Includes constraints and indexes

--

CREATE TABLE academic.setting_diagrammed_courses (
    id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    "position" smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    field_diagram_id BIGINT,
    category_text_id BIGINT,
    fl_active BOOLEAN DEFAULT true NOT NULL,
    fl_optional BOOLEAN DEFAULT false NOT NULL
);


ALTER TABLE academic.setting_diagrammed_courses OWNER TO postgres;

--

--

ALTER TABLE academic.setting_diagrammed_courses
    ADD CONSTRAINT pk_setting_diagrammed_courses PRIMARY KEY (id);


--

--

ALTER TABLE academic.setting_diagrammed_courses
    ADD CONSTRAINT fk_setting_diagrammed_courses_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE academic.setting_diagrammed_courses
    ADD CONSTRAINT fk_setting_diagrammed_courses_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.setting_diagrammed_courses
    ADD CONSTRAINT fk_setting_diagrammed_courses_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.setting_diagrammed_courses
    ADD CONSTRAINT fk_setting_diagrammed_courses_field_diagram FOREIGN KEY (field_diagram_id) REFERENCES questions.field_diagrammed(id);


--

--

ALTER TABLE academic.setting_diagrammed_courses
    ADD CONSTRAINT fk_setting_diagrammed_courses_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
