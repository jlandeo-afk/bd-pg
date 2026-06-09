-- Table: materials.material_revision_histories
-- Includes constraints and indexes

--

CREATE TABLE materials.material_revision_histories (
    id BIGINT NOT NULL,
    material_revision_id BIGINT NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    changed_by BIGINT NOT NULL,
    changed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE materials.material_revision_histories OWNER TO postgres;

--

--

ALTER TABLE materials.material_revision_histories
    ADD CONSTRAINT pk_material_revision_histories PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_revision_histories
    ADD CONSTRAINT fk_material_revision_histories_changed_by FOREIGN KEY (changed_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_revision_histories
    ADD CONSTRAINT fk_material_revision_histories_material_revision FOREIGN KEY (material_revision_id) REFERENCES materials.material_revisions(id);


--
