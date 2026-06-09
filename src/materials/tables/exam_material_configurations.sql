-- Table: materials.exam_material_configurations
-- Includes constraints and indexes

--

CREATE TABLE materials.exam_material_configurations (
    id smallint NOT NULL,
    type_material_id bigint NOT NULL,
    cycle_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE materials.exam_material_configurations OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.exam_material_configurations
    ADD CONSTRAINT exam_material_configurations_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.exam_material_configurations
    ADD CONSTRAINT exam_material_configurations_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE ONLY materials.exam_material_configurations
    ADD CONSTRAINT odiseo_exam_material_configurations_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY materials.exam_material_configurations
    ADD CONSTRAINT odiseo_exam_material_configurations_cycle_id_foreign FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY materials.exam_material_configurations
    ADD CONSTRAINT odiseo_exam_material_configurations_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY materials.exam_material_configurations
    ADD CONSTRAINT odiseo_exam_material_configurations_type_material_id_foreign FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY materials.exam_material_configurations
    ADD CONSTRAINT odiseo_exam_material_configurations_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--
