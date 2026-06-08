-- Table: odiseo.material_revisions
-- Includes constraints and indexes

--

CREATE TABLE odiseo.material_revisions (
    id bigint NOT NULL,
    material_id bigint NOT NULL,
    type_material_id smallint NOT NULL,
    start_week smallint NOT NULL,
    end_week smallint NOT NULL,
    delivery_date timestamp(0) without time zone NOT NULL,
    verify_date timestamp(0) without time zone,
    verified_by bigint,
    status character varying(50) DEFAULT 'queued'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    CONSTRAINT chk_material_revision_status CHECK (((status)::text = ANY (ARRAY[('queued'::character varying)::text, ('generating'::character varying)::text, ('pdf_delivered'::character varying)::text, ('verified'::character varying)::text, ('material_delivered'::character varying)::text])))
);


ALTER TABLE odiseo.material_revisions OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.material_revisions
    ADD CONSTRAINT material_revisions_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.material_revisions
    ADD CONSTRAINT fk_mat_rev_created_by FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_revisions
    ADD CONSTRAINT fk_mat_rev_deleted_by FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_revisions
    ADD CONSTRAINT fk_mat_rev_material FOREIGN KEY (material_id) REFERENCES odiseo.material(id);


--

--

ALTER TABLE ONLY odiseo.material_revisions
    ADD CONSTRAINT fk_mat_rev_type_material FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE ONLY odiseo.material_revisions
    ADD CONSTRAINT fk_mat_rev_updated_by FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_revisions
    ADD CONSTRAINT fk_mat_rev_verified_by FOREIGN KEY (verified_by) REFERENCES odiseo.users(id);


--
