-- Table: materials.exam_material_configurations
-- Includes constraints and indexes

--

CREATE TABLE materials.exam_material_configurations (
    id smallint NOT NULL,
    type_material_id BIGINT NOT NULL,
    cycle_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE materials.exam_material_configurations OWNER TO postgres;

--

--

ALTER TABLE materials.exam_material_configurations
    ADD CONSTRAINT pk_exam_material_configurations PRIMARY KEY (id);


--

--

ALTER TABLE materials.exam_material_configurations
    ADD CONSTRAINT fk_exam_material_configurations_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE materials.exam_material_configurations
    ADD CONSTRAINT fk_exam_material_configurations_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.exam_material_configurations
    ADD CONSTRAINT fk_exam_material_configurations_cycle FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.exam_material_configurations
    ADD CONSTRAINT fk_exam_material_configurations_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.exam_material_configurations
    ADD CONSTRAINT fk_exam_material_configurations_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.exam_material_configurations
    ADD CONSTRAINT fk_exam_material_configurations_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE CASCADE;


--
