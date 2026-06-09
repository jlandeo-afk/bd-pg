-- Table: materials.material_configuration_detail_value
-- Includes constraints and indexes

--

CREATE TABLE materials.material_configuration_detail_value (
    id BIGINT NOT NULL,
    material_configuration_detail_id BIGINT NOT NULL,
    template_type_material_configuration_id BIGINT,
    value TEXT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE materials.material_configuration_detail_value OWNER TO postgres;

--

--

ALTER TABLE materials.material_configuration_detail_value
    ADD CONSTRAINT pk_material_configuration_detail_value PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_configuration_detail_value
    ADD CONSTRAINT fk_material_configuration_detail_value_material_configuration_detail FOREIGN KEY (material_configuration_detail_id) REFERENCES materials.material_configuration_details(id);


--

--

ALTER TABLE materials.material_configuration_detail_value
    ADD CONSTRAINT fk_material_configuration_detail_value_template_type_material_configuration FOREIGN KEY (template_type_material_configuration_id) REFERENCES materials.template_type_material_configurations(id);


--
