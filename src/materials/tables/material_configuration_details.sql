-- Table: materials.material_configuration_details
-- Includes constraints and indexes

--

CREATE TABLE materials.material_configuration_details (
    id bigint NOT NULL,
    material_configuration_id bigint NOT NULL,
    name character varying(150) NOT NULL,
    value character varying(255),
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE materials.material_configuration_details OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_configuration_details
    ADD CONSTRAINT material_configuration_details_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_configuration_details
    ADD CONSTRAINT odiseo_material_configuration_details_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_configuration_details
    ADD CONSTRAINT odiseo_material_configuration_details_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_configuration_details
    ADD CONSTRAINT odiseo_material_configuration_details_material_configuration_id FOREIGN KEY (material_configuration_id) REFERENCES materials.material_configurations(id);


--

--

ALTER TABLE ONLY materials.material_configuration_details
    ADD CONSTRAINT odiseo_material_configuration_details_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
