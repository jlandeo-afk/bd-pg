-- Table: odiseo.headquarters
-- Includes constraints and indexes

--

CREATE TABLE odiseo.headquarters (
    id smallint NOT NULL,
    code character varying(255),
    name character varying(255) NOT NULL,
    slug character varying(7) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    address character varying(150)
);


ALTER TABLE odiseo.headquarters OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.headquarters
    ADD CONSTRAINT headquarters_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.headquarters
    ADD CONSTRAINT odiseo_headquarters_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.headquarters
    ADD CONSTRAINT odiseo_headquarters_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.headquarters
    ADD CONSTRAINT odiseo_headquarters_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
