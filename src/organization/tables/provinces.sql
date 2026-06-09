-- Table: organization.provinces
-- Includes constraints and indexes

--

CREATE TABLE organization.provinces (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    region_id BIGINT NOT NULL,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE organization.provinces OWNER TO postgres;

--

--

ALTER TABLE organization.provinces
    ADD CONSTRAINT pk_provinces PRIMARY KEY (id);


--

--

ALTER TABLE organization.provinces
    ADD CONSTRAINT fk_provinces_region FOREIGN KEY (region_id) REFERENCES organization.region(id);


--
