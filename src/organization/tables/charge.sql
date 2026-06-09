-- Table: organization.charge
-- Includes constraints and indexes

--

CREATE TABLE organization.charge (
    id smallint NOT NULL,
    uuid uuid NOT NULL,
    name character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE organization.charge OWNER TO postgres;

--

--

ALTER TABLE ONLY organization.charge
    ADD CONSTRAINT charge_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY organization.charge
    ADD CONSTRAINT odiseo_charge_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY organization.charge
    ADD CONSTRAINT odiseo_charge_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY organization.charge
    ADD CONSTRAINT odiseo_charge_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
