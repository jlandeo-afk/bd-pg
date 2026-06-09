-- Table: auth.password_reset_tokens
-- Includes constraints and indexes

--

CREATE TABLE auth.password_reset_tokens (
    email VARCHAR(255) NOT NULL,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ
);


ALTER TABLE auth.password_reset_tokens OWNER TO postgres;

--

--

ALTER TABLE auth.password_reset_tokens
    ADD CONSTRAINT pk_password_reset_tokens PRIMARY KEY (email);


--
