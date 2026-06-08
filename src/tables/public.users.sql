-- Table: public.users
-- Includes constraints and indexes

--

CREATE TABLE public.users (
    id bigint NOT NULL,
    uuid uuid,
    "user" character varying(255),
    email character varying(255),
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
    deleted_at timestamp(0) without time zone
);


ALTER TABLE public.users OWNER TO postgres;

--

--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--

--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_unique UNIQUE ("user");


--

--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--

--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id) ON DELETE SET NULL;


--

--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
