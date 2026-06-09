-- Table: materials.material_configurations
-- Includes constraints and indexes

--

CREATE TABLE materials.material_configurations (
    id BIGINT NOT NULL,
    company_id BIGINT NOT NULL,
    category VARCHAR(150) NOT NULL,
    element VARCHAR(150) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    is_global BOOLEAN DEFAULT true NOT NULL
);


ALTER TABLE materials.material_configurations OWNER TO postgres;

--

--

ALTER TABLE materials.material_configurations
    ADD CONSTRAINT pk_material_configurations PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_configurations
    ADD CONSTRAINT fk_material_configurations_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE materials.material_configurations
    ADD CONSTRAINT fk_material_configurations_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_configurations
    ADD CONSTRAINT fk_material_configurations_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_configurations
    ADD CONSTRAINT fk_material_configurations_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
