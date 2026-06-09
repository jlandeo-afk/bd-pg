-- Table: materials.material_configurations
-- Includes constraints and indexes

--

CREATE TABLE materials.material_configurations (
    id bigint NOT NULL,
    company_id bigint NOT NULL,
    category character varying(150) NOT NULL,
    element character varying(150) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    is_global boolean DEFAULT true NOT NULL
);


ALTER TABLE materials.material_configurations OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_configurations
    ADD CONSTRAINT material_configurations_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_configurations
    ADD CONSTRAINT odiseo_material_configurations_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE ONLY materials.material_configurations
    ADD CONSTRAINT odiseo_material_configurations_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_configurations
    ADD CONSTRAINT odiseo_material_configurations_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_configurations
    ADD CONSTRAINT odiseo_material_configurations_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
