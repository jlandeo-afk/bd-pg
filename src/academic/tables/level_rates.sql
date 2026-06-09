-- Table: academic.level_rates
-- Includes constraints and indexes

--

CREATE TABLE academic.level_rates (
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


ALTER TABLE academic.level_rates OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.level_rates
    ADD CONSTRAINT level_rates_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.level_rates
    ADD CONSTRAINT odiseo_level_rates_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.level_rates
    ADD CONSTRAINT odiseo_level_rates_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.level_rates
    ADD CONSTRAINT odiseo_level_rates_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
