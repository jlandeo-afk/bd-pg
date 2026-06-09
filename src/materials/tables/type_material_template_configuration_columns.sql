-- Table: materials.type_material_template_configuration_columns
-- Includes constraints and indexes

--

CREATE TABLE materials.type_material_template_configuration_columns (
    id bigint NOT NULL,
    type_material_template_id integer NOT NULL,
    type_solution character varying(255) NOT NULL,
    number_columns integer NOT NULL,
    created_by integer NOT NULL,
    updated_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deleted_by integer
);


ALTER TABLE materials.type_material_template_configuration_columns OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.type_material_template_configuration_columns
    ADD CONSTRAINT type_material_template_configuration_columns_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.type_material_template_configuration_columns
    ADD CONSTRAINT type_material_template_configuration_columns_type_material_temp FOREIGN KEY (type_material_template_id) REFERENCES materials.type_material_template(id);


--
