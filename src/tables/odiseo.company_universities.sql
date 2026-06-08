-- Table: odiseo.company_universities
-- Includes constraints and indexes

--

CREATE TABLE odiseo.company_universities (
    id integer NOT NULL,
    company_id bigint NOT NULL,
    university_id bigint NOT NULL,
    fl_active boolean DEFAULT true NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.company_universities OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.company_universities
    ADD CONSTRAINT company_universities_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.company_universities
    ADD CONSTRAINT company_universities_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE ONLY odiseo.company_universities
    ADD CONSTRAINT company_universities_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.company_universities
    ADD CONSTRAINT company_universities_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.company_universities
    ADD CONSTRAINT company_universities_university_id_foreign FOREIGN KEY (university_id) REFERENCES odiseo.origin_university(id);


--

--

ALTER TABLE ONLY odiseo.company_universities
    ADD CONSTRAINT company_universities_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
