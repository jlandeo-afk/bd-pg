-- Table: materials.material_revision_items
-- Includes constraints and indexes

--

CREATE TABLE materials.material_revision_items (
    id bigint NOT NULL,
    material_revision_id bigint NOT NULL,
    detail_week_type_mat_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint
);


ALTER TABLE materials.material_revision_items OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_revision_items
    ADD CONSTRAINT material_revision_items_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_revision_items
    ADD CONSTRAINT uk_mat_rev_item UNIQUE (material_revision_id, detail_week_type_mat_id);


--

--

ALTER TABLE ONLY materials.material_revision_items
    ADD CONSTRAINT fk_mat_rev_item_cr_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_revision_items
    ADD CONSTRAINT fk_mat_rev_item_del_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_revision_items
    ADD CONSTRAINT fk_mat_rev_item_detail FOREIGN KEY (detail_week_type_mat_id) REFERENCES academic.detail_week_type_mat(id);


--

--

ALTER TABLE ONLY materials.material_revision_items
    ADD CONSTRAINT fk_mat_rev_item_revision FOREIGN KEY (material_revision_id) REFERENCES materials.material_revisions(id);


--

--

ALTER TABLE ONLY materials.material_revision_items
    ADD CONSTRAINT fk_mat_rev_item_up_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
