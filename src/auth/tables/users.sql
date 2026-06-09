-- Table: auth.users
-- Includes constraints and indexes

--

CREATE TABLE auth.users (
    id bigint NOT NULL,
    uuid uuid,
    "user" character varying(255),
    email odiseo.email_citext,
    password character varying(255) NOT NULL,
    fl_password_confirmed boolean DEFAULT false NOT NULL,
    email_verified_at timestamp(0) without time zone,
    api_token character varying(255),
    fl_status boolean DEFAULT true NOT NULL,
    status_session smallint NOT NULL,
    last_login timestamp(0) without time zone,
    image character varying(255),
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    company_id integer,
    token_nq text,
    fl_suspended boolean DEFAULT false NOT NULL
);


ALTER TABLE auth.users OWNER TO postgres;

--

--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT odiseo_users_user_unique UNIQUE ("user");


--

--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT odiseo_users_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT odiseo_users_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT odiseo_users_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT odiseo_users_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
