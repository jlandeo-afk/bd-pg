-- Table: materials.template_type_material_configurations
-- Includes constraints and indexes

--

CREATE TABLE materials.template_type_material_configurations (
    id bigint NOT NULL,
    type_material_template_id bigint NOT NULL,
    exam_area_id bigint,
    company_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    type_template_id bigint
);


ALTER TABLE materials.template_type_material_configurations OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.template_type_material_configurations
    ADD CONSTRAINT template_type_material_configurations_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.template_type_material_configurations
    ADD CONSTRAINT odiseo_template_type_material_configurations_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE ONLY materials.template_type_material_configurations
    ADD CONSTRAINT odiseo_template_type_material_configurations_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.template_type_material_configurations
    ADD CONSTRAINT odiseo_template_type_material_configurations_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.template_type_material_configurations
    ADD CONSTRAINT odiseo_template_type_material_configurations_exam_area_id_forei FOREIGN KEY (exam_area_id) REFERENCES odiseo.exam_area(id);


--

--

ALTER TABLE ONLY materials.template_type_material_configurations
    ADD CONSTRAINT odiseo_template_type_material_configurations_type_material_temp FOREIGN KEY (type_material_template_id) REFERENCES materials.type_material_template(id);


--

--

ALTER TABLE ONLY materials.template_type_material_configurations
    ADD CONSTRAINT odiseo_template_type_material_configurations_type_template_id_f FOREIGN KEY (type_template_id) REFERENCES common.type_templates(id);


--

--

ALTER TABLE ONLY materials.template_type_material_configurations
    ADD CONSTRAINT odiseo_template_type_material_configurations_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
