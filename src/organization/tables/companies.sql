-- Table: organization.companies
-- Includes constraints and indexes

--

CREATE TABLE organization.companies (
    id BIGINT NOT NULL,
    UUID UUID NOT NULL,
    social_reason VARCHAR(255) NOT NULL,
    commercial_name VARCHAR(255) NOT NULL,
    document_number VARCHAR(20) NOT NULL,
    schema VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_by BIGINT,
    deleted_at TIMESTAMPTZ,
    type_institution_id smallint NOT NULL,
    region_id BIGINT NOT NULL,
    province_id BIGINT NOT NULL,
    district_id BIGINT NOT NULL,
    contact_email odiseo.email_citext NOT NULL,
    billing_email odiseo.email_citext,
    main_phone VARCHAR(12) NOT NULL,
    webpage VARCHAR(100),
    facebook VARCHAR(100),
    instagram VARCHAR(100),
    tiktok VARCHAR(100),
    number_students INTEGER,
    number_collaborators INTEGER,
    education_level VARCHAR(50),
    plan VARCHAR(50),
    plan_start_date DATE,
    modality_payment VARCHAR(50),
    fl_active BOOLEAN DEFAULT true NOT NULL
);


ALTER TABLE organization.companies OWNER TO postgres;

--

--

ALTER TABLE organization.companies
    ADD CONSTRAINT pk_companies PRIMARY KEY (id);


--

--

ALTER TABLE organization.companies
    ADD CONSTRAINT fk_companies_district FOREIGN KEY (district_id) REFERENCES organization.districts(id);


--

--

ALTER TABLE organization.companies
    ADD CONSTRAINT fk_companies_province FOREIGN KEY (province_id) REFERENCES organization.provinces(id);


--

--

ALTER TABLE organization.companies
    ADD CONSTRAINT fk_companies_region FOREIGN KEY (region_id) REFERENCES organization.region(id);


--

--

ALTER TABLE organization.companies
    ADD CONSTRAINT fk_companies_type_institution FOREIGN KEY (type_institution_id) REFERENCES academic.institution_types(id);


--

--

ALTER TABLE organization.companies
    ADD CONSTRAINT fk_companies_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--
