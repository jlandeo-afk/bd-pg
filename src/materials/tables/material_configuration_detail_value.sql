-- Table: materials.material_configuration_detail_value
-- Includes constraints and indexes

--

CREATE TABLE materials.material_configuration_detail_value (
    id bigint NOT NULL,
    material_configuration_detail_id bigint NOT NULL,
    template_type_material_configuration_id bigint,
    value text,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE materials.material_configuration_detail_value OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_configuration_detail_value
    ADD CONSTRAINT material_configuration_detail_value_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_configuration_detail_value
    ADD CONSTRAINT odiseo_material_configuration_detail_value_material_configurati FOREIGN KEY (material_configuration_detail_id) REFERENCES materials.material_configuration_details(id);


--

--

ALTER TABLE ONLY materials.material_configuration_detail_value
    ADD CONSTRAINT odiseo_material_configuration_detail_value_template_type_materi FOREIGN KEY (template_type_material_configuration_id) REFERENCES materials.template_type_material_configurations(id);


--
