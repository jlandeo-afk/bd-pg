-- Table: odiseo.provinces
-- Includes constraints and indexes

--

CREATE TABLE odiseo.provinces (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    region_id bigint NOT NULL,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.provinces OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.provinces
    ADD CONSTRAINT provinces_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.provinces
    ADD CONSTRAINT provinces_region_id_foreign FOREIGN KEY (region_id) REFERENCES odiseo.region(id);


--
