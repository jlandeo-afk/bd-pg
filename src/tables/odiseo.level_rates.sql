-- Table: odiseo.level_rates
-- Includes constraints and indexes

--

CREATE TABLE odiseo.level_rates (
    id bigint NOT NULL,
    level_name character varying(255) NOT NULL,
    cost_per_question numeric(10,2) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.level_rates OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.level_rates
    ADD CONSTRAINT level_rates_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.level_rates
    ADD CONSTRAINT odiseo_level_rates_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.level_rates
    ADD CONSTRAINT odiseo_level_rates_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.level_rates
    ADD CONSTRAINT odiseo_level_rates_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
