-- Table: auth.personal_access_tokens
-- Includes constraints and indexes

--

CREATE TABLE auth.personal_access_tokens (
    id BIGINT NOT NULL,
    tokenable_type VARCHAR(255) NOT NULL,
    tokenable_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    token TEXT NOT NULL,
    abilities TEXT,
    last_used_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    revoked BOOLEAN DEFAULT false NOT NULL
);


ALTER TABLE auth.personal_access_tokens OWNER TO postgres;

--

--

ALTER TABLE auth.personal_access_tokens
    ADD CONSTRAINT odiseo_personal_access_tokens_token_unique UNIQUE (token);


--

--

ALTER TABLE auth.personal_access_tokens
    ADD CONSTRAINT pk_personal_access_tokens PRIMARY KEY (id);


--

--

CREATE INDEX idx_personal_access_tokens_tokenable_type_tokenable_id ON auth.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
