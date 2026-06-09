-- Table: auth.roles
-- Includes constraints and indexes

--

CREATE TABLE auth.roles (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(50),
    description TEXT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    fl_admin BOOLEAN DEFAULT false NOT NULL,
    fl_administrator BOOLEAN DEFAULT false NOT NULL,
    company_id INTEGER DEFAULT 1 NOT NULL
);


ALTER TABLE auth.roles OWNER TO postgres;

--

--

ALTER TABLE auth.roles
    ADD CONSTRAINT roles_name_company_id_unique UNIQUE (name, company_id);


--

--

ALTER TABLE auth.roles
    ADD CONSTRAINT pk_roles PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX uq_roles_name_company_id ON auth.roles USING btree (name, company_id) WHERE (fl_status = true);


--

--

ALTER TABLE auth.roles
    ADD CONSTRAINT fk_roles_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.roles
    ADD CONSTRAINT fk_roles_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.roles
    ADD CONSTRAINT fk_roles_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.roles
    ADD CONSTRAINT fk_roles_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--
