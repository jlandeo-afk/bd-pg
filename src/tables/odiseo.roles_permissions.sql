-- Table: odiseo.roles_permissions
-- Includes constraints and indexes

--

CREATE TABLE odiseo.roles_permissions (
    id bigint NOT NULL,
    rol_id bigint NOT NULL,
    permission_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    company_id integer DEFAULT 1 NOT NULL
);


ALTER TABLE odiseo.roles_permissions OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.roles_permissions
    ADD CONSTRAINT roles_permissions_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.roles_permissions
    ADD CONSTRAINT odiseo_roles_permissions_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.roles_permissions
    ADD CONSTRAINT odiseo_roles_permissions_permission_id_foreign FOREIGN KEY (permission_id) REFERENCES odiseo.permissions(id);


--

--

ALTER TABLE ONLY odiseo.roles_permissions
    ADD CONSTRAINT odiseo_roles_permissions_rol_id_foreign FOREIGN KEY (rol_id) REFERENCES odiseo.roles(id);


--

--

ALTER TABLE ONLY odiseo.roles_permissions
    ADD CONSTRAINT odiseo_roles_permissions_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.roles_permissions
    ADD CONSTRAINT roles_permissions_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--
