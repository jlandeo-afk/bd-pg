-- Table: materials.type_material_detail_template
-- Includes constraints and indexes

--

CREATE TABLE materials.type_material_detail_template (
    id BIGINT NOT NULL,
    type_material_id smallint NOT NULL,
    week smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE materials.type_material_detail_template OWNER TO postgres;

--

--

ALTER TABLE materials.type_material_detail_template
    ADD CONSTRAINT pk_type_material_detail_template PRIMARY KEY (id);


--

--

ALTER TABLE materials.type_material_detail_template
    ADD CONSTRAINT fk_type_material_detail_template_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_detail_template
    ADD CONSTRAINT fk_type_material_detail_template_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_detail_template
    ADD CONSTRAINT fk_type_material_detail_template_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE materials.type_material_detail_template
    ADD CONSTRAINT fk_type_material_detail_template_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
