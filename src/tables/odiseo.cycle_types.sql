-- Table: odiseo.cycle_types
-- Includes constraints and indexes

--

CREATE TABLE odiseo.cycle_types (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.cycle_types OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.cycle_types
    ADD CONSTRAINT cycle_types_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.cycle_types
    ADD CONSTRAINT odiseo_cycle_types_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.cycle_types
    ADD CONSTRAINT odiseo_cycle_types_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.cycle_types
    ADD CONSTRAINT odiseo_cycle_types_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
