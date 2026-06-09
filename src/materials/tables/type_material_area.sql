-- Table: materials.type_material_area
-- Includes constraints and indexes

--

CREATE TABLE materials.type_material_area (
    id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    type_material_id smallint NOT NULL,
    area_id smallint NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT
);


ALTER TABLE materials.type_material_area OWNER TO postgres;

--

--

ALTER TABLE materials.type_material_area
    ADD CONSTRAINT pk_type_material_area PRIMARY KEY (id);


--

--

ALTER TABLE materials.type_material_area
    ADD CONSTRAINT fk_type_material_area_area FOREIGN KEY (area_id) REFERENCES odiseo.exam_area(id);


--

--

ALTER TABLE materials.type_material_area
    ADD CONSTRAINT fk_type_material_area_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_area
    ADD CONSTRAINT fk_type_material_area_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_area
    ADD CONSTRAINT fk_type_material_area_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE materials.type_material_area
    ADD CONSTRAINT fk_type_material_area_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
