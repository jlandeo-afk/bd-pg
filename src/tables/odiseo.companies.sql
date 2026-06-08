-- Table: odiseo.companies
-- Includes constraints and indexes

--

CREATE TABLE odiseo.companies (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    social_reason character varying(255) NOT NULL,
    commercial_name character varying(255) NOT NULL,
    document_number character varying(20) NOT NULL,
    schema character varying(255) NOT NULL,
    address character varying(255) NOT NULL,
    created_by bigint,
    updated_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_by bigint,
    deleted_at timestamp(0) without time zone,
    type_institution_id smallint NOT NULL,
    region_id bigint NOT NULL,
    province_id bigint NOT NULL,
    district_id bigint NOT NULL,
    contact_email odiseo.email_citext NOT NULL,
    billing_email odiseo.email_citext,
    main_phone character varying(12) NOT NULL,
    webpage character varying(100),
    facebook character varying(100),
    instagram character varying(100),
    tiktok character varying(100),
    number_students integer,
    number_collaborators integer,
    education_level character varying(50),
    plan character varying(50),
    plan_start_date date,
    modality_payment character varying(50),
    fl_active boolean DEFAULT true NOT NULL
);


ALTER TABLE odiseo.companies OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.companies
    ADD CONSTRAINT companies_district_id_foreign FOREIGN KEY (district_id) REFERENCES odiseo.districts(id);


--

--

ALTER TABLE ONLY odiseo.companies
    ADD CONSTRAINT companies_province_id_foreign FOREIGN KEY (province_id) REFERENCES odiseo.provinces(id);


--

--

ALTER TABLE ONLY odiseo.companies
    ADD CONSTRAINT companies_region_id_foreign FOREIGN KEY (region_id) REFERENCES odiseo.region(id);


--

--

ALTER TABLE ONLY odiseo.companies
    ADD CONSTRAINT companies_type_institution_id_foreign FOREIGN KEY (type_institution_id) REFERENCES odiseo.institution_types(id);


--

--

ALTER TABLE ONLY odiseo.companies
    ADD CONSTRAINT odiseo_companies_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--
