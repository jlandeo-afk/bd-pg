-- Table: organization.company_legal_representatives
-- Includes constraints and indexes

--

CREATE TABLE organization.company_legal_representatives (
    id INTEGER NOT NULL,
    company_id BIGINT NOT NULL,
    names VARCHAR(60) NOT NULL,
    first_surname VARCHAR(45) NOT NULL,
    second_surname VARCHAR(45) NOT NULL,
    type_document_id BIGINT NOT NULL,
    document_number VARCHAR(15) NOT NULL,
    email odiseo.email_citext NOT NULL,
    phone VARCHAR(15),
    fl_active BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE organization.company_legal_representatives OWNER TO postgres;

--

--

ALTER TABLE organization.company_legal_representatives
    ADD CONSTRAINT pk_company_legal_representatives PRIMARY KEY (id);


--

--

ALTER TABLE organization.company_legal_representatives
    ADD CONSTRAINT fk_company_legal_representatives_company FOREIGN KEY (company_id) REFERENCES organization.companies(id);


--

--

ALTER TABLE organization.company_legal_representatives
    ADD CONSTRAINT fk_company_legal_representatives_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.company_legal_representatives
    ADD CONSTRAINT fk_company_legal_representatives_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.company_legal_representatives
    ADD CONSTRAINT fk_company_legal_representatives_type_document FOREIGN KEY (type_document_id) REFERENCES common.type_documents(id);


--

--

ALTER TABLE organization.company_legal_representatives
    ADD CONSTRAINT fk_company_legal_representatives_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
