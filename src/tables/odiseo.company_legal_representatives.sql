-- Table: odiseo.company_legal_representatives
-- Includes constraints and indexes

--

CREATE TABLE odiseo.company_legal_representatives (
    id integer NOT NULL,
    company_id bigint NOT NULL,
    names character varying(60) NOT NULL,
    first_surname character varying(45) NOT NULL,
    second_surname character varying(45) NOT NULL,
    type_document_id bigint NOT NULL,
    document_number character varying(15) NOT NULL,
    email odiseo.email_citext NOT NULL,
    phone character varying(15),
    fl_active boolean DEFAULT true NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.company_legal_representatives OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.company_legal_representatives
    ADD CONSTRAINT company_legal_representatives_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.company_legal_representatives
    ADD CONSTRAINT company_legal_representatives_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE ONLY odiseo.company_legal_representatives
    ADD CONSTRAINT company_legal_representatives_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.company_legal_representatives
    ADD CONSTRAINT company_legal_representatives_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.company_legal_representatives
    ADD CONSTRAINT company_legal_representatives_type_document_id_foreign FOREIGN KEY (type_document_id) REFERENCES odiseo.type_documents(id);


--

--

ALTER TABLE ONLY odiseo.company_legal_representatives
    ADD CONSTRAINT company_legal_representatives_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
