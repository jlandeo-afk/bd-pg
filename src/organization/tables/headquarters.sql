-- Table: organization.headquarters
-- Includes constraints and indexes

--

CREATE TABLE organization.headquarters (
    id smallint NOT NULL,
    code VARCHAR(255),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(7) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    address VARCHAR(150)
);


ALTER TABLE organization.headquarters OWNER TO postgres;

--

--

ALTER TABLE organization.headquarters
    ADD CONSTRAINT pk_headquarters PRIMARY KEY (id);


--

--

ALTER TABLE organization.headquarters
    ADD CONSTRAINT fk_headquarters_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.headquarters
    ADD CONSTRAINT fk_headquarters_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.headquarters
    ADD CONSTRAINT fk_headquarters_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
