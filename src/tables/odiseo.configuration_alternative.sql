-- Table: odiseo.configuration_alternative
-- Includes constraints and indexes

--

CREATE TABLE odiseo.configuration_alternative (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    columns smallint DEFAULT '3'::smallint NOT NULL,
    styles text DEFAULT '{}'::text NOT NULL,
    fl_image boolean DEFAULT false NOT NULL,
    fl_default boolean DEFAULT false NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    company_id bigint NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.configuration_alternative OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.configuration_alternative
    ADD CONSTRAINT configuration_alternative_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.configuration_alternative
    ADD CONSTRAINT odiseo_configuration_alternative_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE ONLY odiseo.configuration_alternative
    ADD CONSTRAINT odiseo_configuration_alternative_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.configuration_alternative
    ADD CONSTRAINT odiseo_configuration_alternative_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.configuration_alternative
    ADD CONSTRAINT odiseo_configuration_alternative_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
