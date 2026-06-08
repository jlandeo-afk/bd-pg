-- Table: odiseo.type_archive
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_archive (
    id smallint NOT NULL,
    name character varying(20) NOT NULL,
    extension character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.type_archive OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_archive
    ADD CONSTRAINT type_archive_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.type_archive
    ADD CONSTRAINT odiseo_type_archive_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--
