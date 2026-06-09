-- Table: materials.type_material_periodicity
-- Includes constraints and indexes

--

CREATE TABLE materials.type_material_periodicity (
    id smallint NOT NULL,
    type_material_id smallint NOT NULL,
    periodicity_id smallint NOT NULL,
    quantity_week smallint,
    start_week smallint NOT NULL,
    group_previous_week boolean DEFAULT false NOT NULL,
    group_remaining_week boolean DEFAULT false NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE materials.type_material_periodicity OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.type_material_periodicity
    ADD CONSTRAINT type_material_periodicity_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.type_material_periodicity
    ADD CONSTRAINT type_material_periodicity_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE ONLY materials.type_material_periodicity
    ADD CONSTRAINT type_material_periodicity_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.type_material_periodicity
    ADD CONSTRAINT type_material_periodicity_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.type_material_periodicity
    ADD CONSTRAINT type_material_periodicity_periodicity_id_foreign FOREIGN KEY (periodicity_id) REFERENCES materials.periodicity(id);


--

--

ALTER TABLE ONLY materials.type_material_periodicity
    ADD CONSTRAINT type_material_periodicity_type_material_id_foreign FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE ONLY materials.type_material_periodicity
    ADD CONSTRAINT type_material_periodicity_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
