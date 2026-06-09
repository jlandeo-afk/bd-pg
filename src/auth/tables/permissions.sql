-- Table: auth.permissions
-- Includes constraints and indexes

--

CREATE TABLE auth.permissions (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    module VARCHAR(255),
    fl_administrator BOOLEAN DEFAULT false NOT NULL,
    fl_to_use_client BOOLEAN DEFAULT false NOT NULL
);


ALTER TABLE auth.permissions OWNER TO postgres;

--

--

ALTER TABLE auth.permissions
    ADD CONSTRAINT odiseo_permissions_name_unique UNIQUE (name);


--

--

ALTER TABLE auth.permissions
    ADD CONSTRAINT pk_permissions PRIMARY KEY (id);


--

--

ALTER TABLE auth.permissions
    ADD CONSTRAINT fk_permissions_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.permissions
    ADD CONSTRAINT fk_permissions_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.permissions
    ADD CONSTRAINT fk_permissions_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
