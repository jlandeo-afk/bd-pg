-- Table: odiseo.users_roles
-- Includes constraints and indexes

--

CREATE TABLE odiseo.users_roles (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    rol_id bigint NOT NULL,
    rol_parent_id bigint,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE odiseo.users_roles OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.users_roles
    ADD CONSTRAINT users_roles_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.users_roles
    ADD CONSTRAINT odiseo_users_roles_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.users_roles
    ADD CONSTRAINT odiseo_users_roles_rol_id_foreign FOREIGN KEY (rol_id) REFERENCES odiseo.roles(id);


--

--

ALTER TABLE ONLY odiseo.users_roles
    ADD CONSTRAINT odiseo_users_roles_rol_parent_id_foreign FOREIGN KEY (rol_parent_id) REFERENCES odiseo.users_roles(id);


--

--

ALTER TABLE ONLY odiseo.users_roles
    ADD CONSTRAINT odiseo_users_roles_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.users_roles
    ADD CONSTRAINT users_roles_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--
