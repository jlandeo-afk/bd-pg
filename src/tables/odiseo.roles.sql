-- Table: odiseo.roles
-- Includes constraints and indexes

--

CREATE TABLE odiseo.roles (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(50),
    description text,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    fl_admin boolean DEFAULT false NOT NULL,
    fl_administrator boolean DEFAULT false NOT NULL,
    company_id integer DEFAULT 1 NOT NULL
);


ALTER TABLE odiseo.roles OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.roles
    ADD CONSTRAINT roles_name_company_id_unique UNIQUE (name, company_id);


--

--

ALTER TABLE ONLY odiseo.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX unique_active_role ON odiseo.roles USING btree (name, company_id) WHERE (fl_status = true);


--

--

ALTER TABLE ONLY odiseo.roles
    ADD CONSTRAINT odiseo_roles_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.roles
    ADD CONSTRAINT odiseo_roles_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.roles
    ADD CONSTRAINT odiseo_roles_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.roles
    ADD CONSTRAINT roles_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--
