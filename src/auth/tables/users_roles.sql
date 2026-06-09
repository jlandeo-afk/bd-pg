-- Table: auth.users_roles
-- Includes constraints and indexes

--

CREATE TABLE auth.users_roles (
    id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    rol_id BIGINT NOT NULL,
    rol_parent_id BIGINT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE auth.users_roles OWNER TO postgres;

--

--

ALTER TABLE auth.users_roles
    ADD CONSTRAINT pk_users_roles PRIMARY KEY (id);


--

--

ALTER TABLE auth.users_roles
    ADD CONSTRAINT fk_users_roles_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.users_roles
    ADD CONSTRAINT fk_users_roles_rol FOREIGN KEY (rol_id) REFERENCES auth.roles(id);


--

--

ALTER TABLE auth.users_roles
    ADD CONSTRAINT fk_users_roles_rol_parent FOREIGN KEY (rol_parent_id) REFERENCES auth.users_roles(id);


--

--

ALTER TABLE auth.users_roles
    ADD CONSTRAINT fk_users_roles_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.users_roles
    ADD CONSTRAINT fk_users_roles_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--
