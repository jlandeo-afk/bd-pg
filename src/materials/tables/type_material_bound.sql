-- Table: materials.type_material_bound
-- Includes constraints and indexes

--

CREATE TABLE materials.type_material_bound (
    id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    type_material_template_id BIGINT,
    type_material_template_extra_id BIGINT
);


ALTER TABLE materials.type_material_bound OWNER TO postgres;

--

--

ALTER TABLE materials.type_material_bound
    ADD CONSTRAINT pk_type_material_bound PRIMARY KEY (id);


--

--

ALTER TABLE materials.type_material_bound
    ADD CONSTRAINT type_material_bound_unique_pair UNIQUE (type_material_template_id, type_material_template_extra_id);


--

--

ALTER TABLE materials.type_material_bound
    ADD CONSTRAINT fk_type_material_bound_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_bound
    ADD CONSTRAINT fk_type_material_bound_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_bound
    ADD CONSTRAINT fk_type_material_bound_type_material_template_extra FOREIGN KEY (type_material_template_extra_id) REFERENCES materials.type_material_template(id);


--

--

ALTER TABLE materials.type_material_bound
    ADD CONSTRAINT fk_type_material_bound_type_material_template FOREIGN KEY (type_material_template_id) REFERENCES materials.type_material_template(id);


--

--

ALTER TABLE materials.type_material_bound
    ADD CONSTRAINT fk_type_material_bound_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
