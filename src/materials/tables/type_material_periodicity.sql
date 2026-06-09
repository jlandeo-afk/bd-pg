-- Table: materials.type_material_periodicity
-- Includes constraints and indexes

--

CREATE TABLE materials.type_material_periodicity (
    id smallint NOT NULL,
    type_material_id smallint NOT NULL,
    periodicity_id smallint NOT NULL,
    quantity_week smallint,
    start_week smallint NOT NULL,
    group_previous_week BOOLEAN DEFAULT false NOT NULL,
    group_remaining_week BOOLEAN DEFAULT false NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE materials.type_material_periodicity OWNER TO postgres;

--

--

ALTER TABLE materials.type_material_periodicity
    ADD CONSTRAINT pk_type_material_periodicity PRIMARY KEY (id);


--

--

ALTER TABLE materials.type_material_periodicity
    ADD CONSTRAINT fk_type_material_periodicity_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE materials.type_material_periodicity
    ADD CONSTRAINT fk_type_material_periodicity_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_periodicity
    ADD CONSTRAINT fk_type_material_periodicity_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_periodicity
    ADD CONSTRAINT fk_type_material_periodicity_periodicity FOREIGN KEY (periodicity_id) REFERENCES materials.periodicity(id);


--

--

ALTER TABLE materials.type_material_periodicity
    ADD CONSTRAINT fk_type_material_periodicity_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE materials.type_material_periodicity
    ADD CONSTRAINT fk_type_material_periodicity_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
