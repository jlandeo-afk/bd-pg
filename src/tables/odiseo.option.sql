-- Table: odiseo.option
-- Includes constraints and indexes

--

CREATE TABLE odiseo.option (
    id smallint NOT NULL,
    name character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    university_ids integer[] DEFAULT ARRAY[]::integer[]
);


ALTER TABLE odiseo.option OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.option
    ADD CONSTRAINT option_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.option
    ADD CONSTRAINT odiseo_option_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.option
    ADD CONSTRAINT odiseo_option_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.option
    ADD CONSTRAINT odiseo_option_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
