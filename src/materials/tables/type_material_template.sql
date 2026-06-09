-- Table: materials.type_material_template
-- Includes constraints and indexes

--

CREATE TABLE materials.type_material_template (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    fl_exam BOOLEAN DEFAULT false NOT NULL,
    type_exam_id BIGINT,
    fl_use_syllabus_exam BOOLEAN DEFAULT true NOT NULL,
    fl_revision BOOLEAN DEFAULT false NOT NULL,
    has_config_column BOOLEAN DEFAULT false NOT NULL
);


ALTER TABLE materials.type_material_template OWNER TO postgres;

--

--

ALTER TABLE materials.type_material_template
    ADD CONSTRAINT pk_type_material_template PRIMARY KEY (id);


--

--

ALTER TABLE materials.type_material_template
    ADD CONSTRAINT fk_type_material_template_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--

--

ALTER TABLE materials.type_material_template
    ADD CONSTRAINT fk_type_material_template_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--

--

ALTER TABLE materials.type_material_template
    ADD CONSTRAINT fk_type_material_template_type_exam FOREIGN KEY (type_exam_id) REFERENCES odiseo.type_exams(id);


--

--

ALTER TABLE materials.type_material_template
    ADD CONSTRAINT fk_type_material_template_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--
