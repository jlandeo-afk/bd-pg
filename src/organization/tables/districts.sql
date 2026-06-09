-- Table: organization.districts
-- Includes constraints and indexes

--

CREATE TABLE organization.districts (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    region_id BIGINT NOT NULL,
    province_id BIGINT NOT NULL,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE organization.districts OWNER TO postgres;

--

--

ALTER TABLE organization.districts
    ADD CONSTRAINT pk_districts PRIMARY KEY (id);


--

--

ALTER TABLE organization.districts
    ADD CONSTRAINT fk_districts_province FOREIGN KEY (province_id) REFERENCES organization.provinces(id);


--

--

ALTER TABLE organization.districts
    ADD CONSTRAINT fk_districts_region FOREIGN KEY (region_id) REFERENCES organization.region(id);


--
