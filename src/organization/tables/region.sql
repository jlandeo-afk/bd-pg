-- Table: organization.region
-- Includes constraints and indexes

--

CREATE TABLE organization.region (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE organization.region OWNER TO postgres;

--

--

ALTER TABLE organization.region
    ADD CONSTRAINT pk_region PRIMARY KEY (id);


--

--

ALTER TABLE organization.region
    ADD CONSTRAINT fk_region_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.region
    ADD CONSTRAINT fk_region_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.region
    ADD CONSTRAINT fk_region_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
