-- Table: auth.users
-- Includes constraints and indexes

--

CREATE TABLE auth.users (
    id BIGINT NOT NULL,
    UUID UUID,
    "user" VARCHAR(255),
    email odiseo.email_citext,
    password VARCHAR(255) NOT NULL,
    fl_password_confirmed BOOLEAN DEFAULT false NOT NULL,
    email_verified_at TIMESTAMPTZ,
    api_token VARCHAR(255),
    fl_status BOOLEAN DEFAULT true NOT NULL,
    status_session smallint NOT NULL,
    last_login TIMESTAMPTZ,
    image VARCHAR(255),
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    company_id INTEGER,
    token_nq TEXT,
    fl_suspended BOOLEAN DEFAULT false NOT NULL
);


ALTER TABLE auth.users OWNER TO postgres;

--

--

ALTER TABLE auth.users
    ADD CONSTRAINT odiseo_users_user_unique UNIQUE ("user");


--

--

ALTER TABLE auth.users
    ADD CONSTRAINT pk_users PRIMARY KEY (id);


--

--

ALTER TABLE auth.users
    ADD CONSTRAINT fk_users_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE auth.users
    ADD CONSTRAINT fk_users_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.users
    ADD CONSTRAINT fk_users_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.users
    ADD CONSTRAINT fk_users_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
