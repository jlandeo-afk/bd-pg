-- Table: odiseo.level
-- Includes constraints and indexes

--

CREATE TABLE odiseo.level (
    id bigint NOT NULL,
    description character varying(20) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    name character varying(20),
    alias_nq character varying(20)
);


ALTER TABLE odiseo.level OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.level
    ADD CONSTRAINT level_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.level
    ADD CONSTRAINT odiseo_level_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.level
    ADD CONSTRAINT odiseo_level_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.level
    ADD CONSTRAINT odiseo_level_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
