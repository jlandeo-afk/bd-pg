-- Table: odiseo.material_revision_histories
-- Includes constraints and indexes

--

CREATE TABLE odiseo.material_revision_histories (
    id bigint NOT NULL,
    material_revision_id bigint NOT NULL,
    old_status character varying(50),
    new_status character varying(50) NOT NULL,
    changed_by bigint NOT NULL,
    changed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE odiseo.material_revision_histories OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.material_revision_histories
    ADD CONSTRAINT material_revision_histories_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.material_revision_histories
    ADD CONSTRAINT fk_mat_rev_history_chg_by FOREIGN KEY (changed_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_revision_histories
    ADD CONSTRAINT fk_mat_rev_history_revision FOREIGN KEY (material_revision_id) REFERENCES odiseo.material_revisions(id);


--
