-- Table: materials.template_type_material_configurations
-- Includes constraints and indexes

--

CREATE TABLE materials.template_type_material_configurations (
    id BIGINT NOT NULL,
    type_material_template_id BIGINT NOT NULL,
    exam_area_id BIGINT,
    company_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    type_template_id BIGINT
);


ALTER TABLE materials.template_type_material_configurations OWNER TO postgres;

--

--

ALTER TABLE materials.template_type_material_configurations
    ADD CONSTRAINT pk_template_type_material_configurations PRIMARY KEY (id);


--

--

ALTER TABLE materials.template_type_material_configurations
    ADD CONSTRAINT fk_template_type_material_configurations_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE materials.template_type_material_configurations
    ADD CONSTRAINT fk_template_type_material_configurations_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.template_type_material_configurations
    ADD CONSTRAINT fk_template_type_material_configurations_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.template_type_material_configurations
    ADD CONSTRAINT fk_template_type_material_configurations_exam_area FOREIGN KEY (exam_area_id) REFERENCES odiseo.exam_area(id);


--

--

ALTER TABLE materials.template_type_material_configurations
    ADD CONSTRAINT fk_template_type_material_configurations_type_material_template FOREIGN KEY (type_material_template_id) REFERENCES materials.type_material_template(id);


--

--

ALTER TABLE materials.template_type_material_configurations
    ADD CONSTRAINT fk_template_type_material_configurations_type_template FOREIGN KEY (type_template_id) REFERENCES common.type_templates(id);


--

--

ALTER TABLE materials.template_type_material_configurations
    ADD CONSTRAINT fk_template_type_material_configurations_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
