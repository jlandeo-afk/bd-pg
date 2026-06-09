-- Table: organization.company_headquarters
-- Includes constraints and indexes

--

CREATE TABLE organization.company_headquarters (
    id INTEGER NOT NULL,
    headquarter_id BIGINT NOT NULL,
    company_id BIGINT NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE organization.company_headquarters OWNER TO postgres;

--

--

ALTER TABLE organization.company_headquarters
    ADD CONSTRAINT pk_company_headquarters PRIMARY KEY (id);


--

--

ALTER TABLE organization.company_headquarters
    ADD CONSTRAINT fk_company_headquarters_company FOREIGN KEY (company_id) REFERENCES organization.companies(id);


--

--

ALTER TABLE organization.company_headquarters
    ADD CONSTRAINT fk_company_headquarters_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.company_headquarters
    ADD CONSTRAINT fk_company_headquarters_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.company_headquarters
    ADD CONSTRAINT fk_company_headquarters_headquarter FOREIGN KEY (headquarter_id) REFERENCES organization.headquarters(id);


--

--

ALTER TABLE organization.company_headquarters
    ADD CONSTRAINT fk_company_headquarters_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
