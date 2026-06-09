-- Table: organization.charge
-- Includes constraints and indexes

--

CREATE TABLE organization.charge (
    id smallint NOT NULL,
    UUID UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE organization.charge OWNER TO postgres;

--

--

ALTER TABLE organization.charge
    ADD CONSTRAINT pk_charge PRIMARY KEY (id);


--

--

ALTER TABLE organization.charge
    ADD CONSTRAINT fk_charge_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.charge
    ADD CONSTRAINT fk_charge_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.charge
    ADD CONSTRAINT fk_charge_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
