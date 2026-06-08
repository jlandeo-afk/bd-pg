-- Table: odiseo.districts
-- Includes constraints and indexes

--

CREATE TABLE odiseo.districts (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    region_id bigint NOT NULL,
    province_id bigint NOT NULL,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.districts OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.districts
    ADD CONSTRAINT districts_province_id_foreign FOREIGN KEY (province_id) REFERENCES odiseo.provinces(id);


--

--

ALTER TABLE ONLY odiseo.districts
    ADD CONSTRAINT districts_region_id_foreign FOREIGN KEY (region_id) REFERENCES odiseo.region(id);


--
