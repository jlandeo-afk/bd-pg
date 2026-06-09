-- Table: materials.material_per_period
-- Includes constraints and indexes

--

CREATE TABLE materials.material_per_period (
    id BIGINT NOT NULL,
    material_id BIGINT NOT NULL,
    type_material_id smallint NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE materials.material_per_period OWNER TO postgres;

--

--

ALTER TABLE materials.material_per_period
    ADD CONSTRAINT pk_material_per_period PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_per_period
    ADD CONSTRAINT per_material_and_type_id UNIQUE (material_id, type_material_id);


--

--

ALTER TABLE materials.material_per_period
    ADD CONSTRAINT fk_material_per_period_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_per_period
    ADD CONSTRAINT fk_material_per_period_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_per_period
    ADD CONSTRAINT fk_material_per_period_material FOREIGN KEY (material_id) REFERENCES materials.material(id);


--

--

ALTER TABLE materials.material_per_period
    ADD CONSTRAINT fk_material_per_period_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE materials.material_per_period
    ADD CONSTRAINT fk_material_per_period_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
