-- Table: auth.roles_permissions
-- Includes constraints and indexes

--

CREATE TABLE auth.roles_permissions (
    id BIGINT NOT NULL,
    rol_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    company_id INTEGER DEFAULT 1 NOT NULL
);


ALTER TABLE auth.roles_permissions OWNER TO postgres;

--

--

ALTER TABLE auth.roles_permissions
    ADD CONSTRAINT pk_roles_permissions PRIMARY KEY (id);


--

--

ALTER TABLE auth.roles_permissions
    ADD CONSTRAINT fk_roles_permissions_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.roles_permissions
    ADD CONSTRAINT fk_roles_permissions_permission FOREIGN KEY (permission_id) REFERENCES auth.permissions(id);


--

--

ALTER TABLE auth.roles_permissions
    ADD CONSTRAINT fk_roles_permissions_rol FOREIGN KEY (rol_id) REFERENCES auth.roles(id);


--

--

ALTER TABLE auth.roles_permissions
    ADD CONSTRAINT fk_roles_permissions_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.roles_permissions
    ADD CONSTRAINT fk_roles_permissions_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--
