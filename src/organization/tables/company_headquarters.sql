-- Table: organization.company_headquarters
-- Includes constraints and indexes

--

CREATE TABLE organization.company_headquarters (
    id integer NOT NULL,
    headquarter_id bigint NOT NULL,
    company_id bigint NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE organization.company_headquarters OWNER TO postgres;

--

--

ALTER TABLE ONLY organization.company_headquarters
    ADD CONSTRAINT company_headquarters_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY organization.company_headquarters
    ADD CONSTRAINT company_headquarters_company_id_foreign FOREIGN KEY (company_id) REFERENCES organization.companies(id);


--

--

ALTER TABLE ONLY organization.company_headquarters
    ADD CONSTRAINT company_headquarters_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY organization.company_headquarters
    ADD CONSTRAINT company_headquarters_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY organization.company_headquarters
    ADD CONSTRAINT company_headquarters_headquarter_id_foreign FOREIGN KEY (headquarter_id) REFERENCES organization.headquarters(id);


--

--

ALTER TABLE ONLY organization.company_headquarters
    ADD CONSTRAINT company_headquarters_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
