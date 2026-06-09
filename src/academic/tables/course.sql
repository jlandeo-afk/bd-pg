-- Table: academic.course
-- Includes constraints and indexes

--

CREATE TABLE academic.course (
    id smallint NOT NULL,
    code VARCHAR(3) NOT NULL,
    name VARCHAR(30) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    area_id BIGINT,
    fl_pseudo_course BOOLEAN DEFAULT false NOT NULL,
    apply_text BOOLEAN DEFAULT false NOT NULL,
    alias_nq VARCHAR(255),
    agreement_url VARCHAR(255),
    agreement_file_name VARCHAR(255),
    type_text_template_id smallint,
    show_context_nq BOOLEAN DEFAULT true NOT NULL
);


ALTER TABLE academic.course OWNER TO postgres;

--

--

ALTER TABLE academic.course
    ADD CONSTRAINT pk_course PRIMARY KEY (id);


--

--

ALTER TABLE academic.course
    ADD CONSTRAINT odiseo_course_code_unique UNIQUE (code);


--

--

ALTER TABLE academic.course
    ADD CONSTRAINT fk_course_type_text_template FOREIGN KEY (type_text_template_id) REFERENCES common.type_text_templates(id);


--

--

ALTER TABLE academic.course
    ADD CONSTRAINT fk_course_area FOREIGN KEY (area_id) REFERENCES odiseo.area(id);


--

--

ALTER TABLE academic.course
    ADD CONSTRAINT fk_course_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.course
    ADD CONSTRAINT fk_course_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.course
    ADD CONSTRAINT fk_course_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
