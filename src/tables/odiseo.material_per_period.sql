-- Table: odiseo.material_per_period
-- Includes constraints and indexes

--

CREATE TABLE odiseo.material_per_period (
    id bigint NOT NULL,
    material_id bigint NOT NULL,
    type_material_id smallint NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.material_per_period OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.material_per_period
    ADD CONSTRAINT material_per_period_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.material_per_period
    ADD CONSTRAINT per_material_and_type_id UNIQUE (material_id, type_material_id);


--

--

ALTER TABLE ONLY odiseo.material_per_period
    ADD CONSTRAINT material_per_period_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_per_period
    ADD CONSTRAINT material_per_period_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_per_period
    ADD CONSTRAINT material_per_period_material_id_foreign FOREIGN KEY (material_id) REFERENCES odiseo.material(id);


--

--

ALTER TABLE ONLY odiseo.material_per_period
    ADD CONSTRAINT material_per_period_type_material_id_foreign FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE ONLY odiseo.material_per_period
    ADD CONSTRAINT material_per_period_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
