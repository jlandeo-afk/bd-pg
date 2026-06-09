-- Table: materials.type_material
-- Includes constraints and indexes

--

CREATE TABLE materials.type_material (
    id smallint NOT NULL,
    description VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    code VARCHAR(4),
    amount_question INTEGER DEFAULT 0 NOT NULL,
    fl_exam BOOLEAN DEFAULT false NOT NULL,
    type_material_template_id BIGINT,
    fl_class_material BOOLEAN DEFAULT false NOT NULL,
    thread smallint DEFAULT '1'::smallint NOT NULL,
    percentage NUMERIC(5,2) DEFAULT '30'::NUMERIC NOT NULL,
    parent_id BIGINT,
    level_order BOOLEAN DEFAULT false NOT NULL,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL,
    "position" smallint DEFAULT '0'::smallint NOT NULL,
    order_date TIMESTAMPTZ,
    cycle_id BIGINT
);


ALTER TABLE materials.type_material OWNER TO postgres;

--

--

ALTER TABLE materials.type_material
    ADD CONSTRAINT pk_type_material PRIMARY KEY (id);


--

--

ALTER TABLE materials.type_material
    ADD CONSTRAINT fk_type_material_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material
    ADD CONSTRAINT fk_type_material_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material
    ADD CONSTRAINT fk_type_material_parent FOREIGN KEY (parent_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE materials.type_material
    ADD CONSTRAINT fk_type_material_type_material_template FOREIGN KEY (type_material_template_id) REFERENCES materials.type_material_template(id);


--

--

ALTER TABLE materials.type_material
    ADD CONSTRAINT fk_type_material_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material
    ADD CONSTRAINT fk_type_material_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE materials.type_material
    ADD CONSTRAINT fk_type_material_cycle FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id);


--
