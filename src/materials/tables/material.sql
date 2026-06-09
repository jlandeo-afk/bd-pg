-- Table: materials.material
-- Includes constraints and indexes

--

CREATE TABLE materials.material (
    id bigint NOT NULL,
    cycle_id bigint NOT NULL,
    university_id smallint NOT NULL,
    headquarte_id smallint NOT NULL,
    headquarters_classroom_id smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    fl_verified_material_without_altern_code boolean DEFAULT false NOT NULL,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE materials.material OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material
    ADD CONSTRAINT material_pkey PRIMARY KEY (id);


--

--

CREATE INDEX material_university_id_index ON materials.material USING btree (university_id);


--

--

ALTER TABLE ONLY materials.material
    ADD CONSTRAINT material_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--

--

ALTER TABLE ONLY materials.material
    ADD CONSTRAINT odiseo_material_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material
    ADD CONSTRAINT odiseo_material_cycle_id_foreign FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id);


--

--

ALTER TABLE ONLY materials.material
    ADD CONSTRAINT odiseo_material_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material
    ADD CONSTRAINT odiseo_material_headquarte_id_foreign FOREIGN KEY (headquarte_id) REFERENCES odiseo.headquarters(id);


--

--

ALTER TABLE ONLY materials.material
    ADD CONSTRAINT odiseo_material_headquarters_classroom_id_foreign FOREIGN KEY (headquarters_classroom_id) REFERENCES odiseo.headquarters_classroom(id);


--

--

ALTER TABLE ONLY materials.material
    ADD CONSTRAINT odiseo_material_university_id_foreign FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE ONLY materials.material
    ADD CONSTRAINT odiseo_material_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
