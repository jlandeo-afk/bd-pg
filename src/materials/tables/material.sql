-- Table: materials.material
-- Includes constraints and indexes

--

CREATE TABLE materials.material (
    id BIGINT NOT NULL,
    cycle_id BIGINT NOT NULL,
    university_id smallint NOT NULL,
    headquarte_id smallint NOT NULL,
    headquarters_classroom_id smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    fl_verified_material_without_altern_code BOOLEAN DEFAULT false NOT NULL,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE materials.material OWNER TO postgres;

--

--

ALTER TABLE materials.material
    ADD CONSTRAINT pk_material PRIMARY KEY (id);


--

--

CREATE INDEX idx_material_university_id ON materials.material USING btree (university_id);


--

--

ALTER TABLE materials.material
    ADD CONSTRAINT fk_material_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE RESTRICT;


--

--

ALTER TABLE materials.material
    ADD CONSTRAINT fk_material_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material
    ADD CONSTRAINT fk_material_cycle FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id);


--

--

ALTER TABLE materials.material
    ADD CONSTRAINT fk_material_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material
    ADD CONSTRAINT fk_material_headquarte FOREIGN KEY (headquarte_id) REFERENCES odiseo.headquarters(id);


--

--

ALTER TABLE materials.material
    ADD CONSTRAINT fk_material_headquarters_classroom FOREIGN KEY (headquarters_classroom_id) REFERENCES odiseo.headquarters_classroom(id);


--

--

ALTER TABLE materials.material
    ADD CONSTRAINT fk_material_university FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE materials.material
    ADD CONSTRAINT fk_material_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
