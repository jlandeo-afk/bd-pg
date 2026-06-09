-- Table: auth.permissions
-- Includes constraints and indexes

--

CREATE TABLE auth.permissions (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    module character varying(255),
    fl_administrator boolean DEFAULT false NOT NULL,
    fl_to_use_client boolean DEFAULT false NOT NULL
);


ALTER TABLE auth.permissions OWNER TO postgres;

--

--

ALTER TABLE ONLY auth.permissions
    ADD CONSTRAINT odiseo_permissions_name_unique UNIQUE (name);


--

--

ALTER TABLE ONLY auth.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY auth.permissions
    ADD CONSTRAINT odiseo_permissions_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY auth.permissions
    ADD CONSTRAINT odiseo_permissions_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY auth.permissions
    ADD CONSTRAINT odiseo_permissions_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
