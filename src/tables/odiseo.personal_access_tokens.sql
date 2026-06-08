-- Table: odiseo.personal_access_tokens
-- Includes constraints and indexes

--

CREATE TABLE odiseo.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    token text NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    revoked boolean DEFAULT false NOT NULL
);


ALTER TABLE odiseo.personal_access_tokens OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.personal_access_tokens
    ADD CONSTRAINT odiseo_personal_access_tokens_token_unique UNIQUE (token);


--

--

ALTER TABLE ONLY odiseo.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--

--

CREATE INDEX odiseo_personal_access_tokens_tokenable_type_tokenable_id_index ON odiseo.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
