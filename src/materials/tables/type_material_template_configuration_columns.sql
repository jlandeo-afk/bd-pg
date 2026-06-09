-- Table: materials.type_material_template_configuration_columns
-- Includes constraints and indexes

--

CREATE TABLE materials.type_material_template_configuration_columns (
    id BIGINT NOT NULL,
    type_material_template_id INTEGER NOT NULL,
    type_solution VARCHAR(255) NOT NULL,
    number_columns INTEGER NOT NULL,
    created_by INTEGER NOT NULL,
    updated_by INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    deleted_by INTEGER
);


ALTER TABLE materials.type_material_template_configuration_columns OWNER TO postgres;

--

--

ALTER TABLE materials.type_material_template_configuration_columns
    ADD CONSTRAINT pk_type_material_template_configuration_columns PRIMARY KEY (id);


--

--

ALTER TABLE materials.type_material_template_configuration_columns
    ADD CONSTRAINT fk_type_material_template_configuration_columns_type_material_template FOREIGN KEY (type_material_template_id) REFERENCES materials.type_material_template(id);


--
