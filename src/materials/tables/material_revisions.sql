-- Table: materials.material_revisions
-- Includes constraints and indexes

--

CREATE TABLE materials.material_revisions (
    id BIGINT NOT NULL,
    material_id BIGINT NOT NULL,
    type_material_id smallint NOT NULL,
    start_week smallint NOT NULL,
    end_week smallint NOT NULL,
    delivery_date TIMESTAMPTZ NOT NULL,
    verify_date TIMESTAMPTZ,
    verified_by BIGINT,
    status VARCHAR(50) DEFAULT 'queued'::VARCHAR NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    CONSTRAINT chk_material_revision_status CHECK (((status)::TEXT = ANY (ARRAY[('queued'::VARCHAR)::TEXT, ('generating'::VARCHAR)::TEXT, ('pdf_delivered'::VARCHAR)::TEXT, ('verified'::VARCHAR)::TEXT, ('material_delivered'::VARCHAR)::TEXT])))
);


ALTER TABLE materials.material_revisions OWNER TO postgres;

--

--

ALTER TABLE materials.material_revisions
    ADD CONSTRAINT pk_material_revisions PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_revisions
    ADD CONSTRAINT fk_material_revisions_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_revisions
    ADD CONSTRAINT fk_material_revisions_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_revisions
    ADD CONSTRAINT fk_material_revisions_material FOREIGN KEY (material_id) REFERENCES materials.material(id);


--

--

ALTER TABLE materials.material_revisions
    ADD CONSTRAINT fk_material_revisions_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE materials.material_revisions
    ADD CONSTRAINT fk_material_revisions_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_revisions
    ADD CONSTRAINT fk_material_revisions_verified_by FOREIGN KEY (verified_by) REFERENCES auth.users(id);


--
