-- Table: materials.material_revision_items
-- Includes constraints and indexes

--

CREATE TABLE materials.material_revision_items (
    id BIGINT NOT NULL,
    material_revision_id BIGINT NOT NULL,
    detail_week_type_mat_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT
);


ALTER TABLE materials.material_revision_items OWNER TO postgres;

--

--

ALTER TABLE materials.material_revision_items
    ADD CONSTRAINT pk_material_revision_items PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_revision_items
    ADD CONSTRAINT uk_mat_rev_item UNIQUE (material_revision_id, detail_week_type_mat_id);


--

--

ALTER TABLE materials.material_revision_items
    ADD CONSTRAINT fk_material_revision_items_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_revision_items
    ADD CONSTRAINT fk_material_revision_items_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_revision_items
    ADD CONSTRAINT fk_material_revision_items_detail_week_type_mat FOREIGN KEY (detail_week_type_mat_id) REFERENCES academic.detail_week_type_mat(id);


--

--

ALTER TABLE materials.material_revision_items
    ADD CONSTRAINT fk_material_revision_items_material_revision FOREIGN KEY (material_revision_id) REFERENCES materials.material_revisions(id);


--

--

ALTER TABLE materials.material_revision_items
    ADD CONSTRAINT fk_material_revision_items_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
