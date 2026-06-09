-- Table: auth.password_reset_tokens
-- Includes constraints and indexes

--

CREATE TABLE auth.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE auth.password_reset_tokens OWNER TO postgres;

--

--

ALTER TABLE ONLY auth.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
