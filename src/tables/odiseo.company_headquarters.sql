-- Table: odiseo.company_headquarters
-- Includes constraints and indexes

--

CREATE TABLE odiseo.company_headquarters (
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


ALTER TABLE odiseo.company_headquarters OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.company_headquarters
    ADD CONSTRAINT company_headquarters_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.company_headquarters
    ADD CONSTRAINT company_headquarters_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE ONLY odiseo.company_headquarters
    ADD CONSTRAINT company_headquarters_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.company_headquarters
    ADD CONSTRAINT company_headquarters_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.company_headquarters
    ADD CONSTRAINT company_headquarters_headquarter_id_foreign FOREIGN KEY (headquarter_id) REFERENCES odiseo.headquarters(id);


--

--

ALTER TABLE ONLY odiseo.company_headquarters
    ADD CONSTRAINT company_headquarters_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
