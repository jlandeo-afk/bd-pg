-- Table: materials.material_configuration_details
-- Includes constraints and indexes

--

CREATE TABLE materials.material_configuration_details (
    id BIGINT NOT NULL,
    material_configuration_id BIGINT NOT NULL,
    name VARCHAR(150) NOT NULL,
    value VARCHAR(255),
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE materials.material_configuration_details OWNER TO postgres;

--

--

ALTER TABLE materials.material_configuration_details
    ADD CONSTRAINT pk_material_configuration_details PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_configuration_details
    ADD CONSTRAINT fk_material_configuration_details_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_configuration_details
    ADD CONSTRAINT fk_material_configuration_details_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_configuration_details
    ADD CONSTRAINT fk_material_configuration_details_material_configuration FOREIGN KEY (material_configuration_id) REFERENCES materials.material_configurations(id);


--

--

ALTER TABLE materials.material_configuration_details
    ADD CONSTRAINT fk_material_configuration_details_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
