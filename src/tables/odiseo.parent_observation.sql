-- Table: odiseo.parent_observation
-- Includes constraints and indexes

--

CREATE TABLE odiseo.parent_observation (
    id bigint NOT NULL,
    description text NOT NULL,
    similitaries text DEFAULT '[]'::text NOT NULL,
    parent_id bigint NOT NULL,
    type character varying(5) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.parent_observation OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.parent_observation
    ADD CONSTRAINT parent_observation_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.parent_observation
    ADD CONSTRAINT odiseo_parent_observation_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.parent_observation
    ADD CONSTRAINT odiseo_parent_observation_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.parent_observation
    ADD CONSTRAINT odiseo_parent_observation_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES odiseo.parent_question(id);


--

--

ALTER TABLE ONLY odiseo.parent_observation
    ADD CONSTRAINT odiseo_parent_observation_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
