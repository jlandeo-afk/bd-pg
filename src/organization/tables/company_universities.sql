-- Table: organization.company_universities
-- Includes constraints and indexes

--

CREATE TABLE organization.company_universities (
    id INTEGER NOT NULL,
    company_id BIGINT NOT NULL,
    university_id BIGINT NOT NULL,
    fl_active BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE organization.company_universities OWNER TO postgres;

--

--

ALTER TABLE organization.company_universities
    ADD CONSTRAINT pk_company_universities PRIMARY KEY (id);


--

--

ALTER TABLE organization.company_universities
    ADD CONSTRAINT fk_company_universities_company FOREIGN KEY (company_id) REFERENCES organization.companies(id);


--

--

ALTER TABLE organization.company_universities
    ADD CONSTRAINT fk_company_universities_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.company_universities
    ADD CONSTRAINT fk_company_universities_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.company_universities
    ADD CONSTRAINT fk_company_universities_university FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE organization.company_universities
    ADD CONSTRAINT fk_company_universities_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
