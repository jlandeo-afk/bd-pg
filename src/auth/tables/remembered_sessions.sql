-- Table: auth.remembered_sessions
-- Includes constraints and indexes

--

CREATE TABLE auth.remembered_sessions (
    id BIGINT NOT NULL,
    user_id INTEGER NOT NULL,
    remember_token VARCHAR(500) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    device_info VARCHAR(255),
    ip_address inet,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE auth.remembered_sessions OWNER TO postgres;

--

--

ALTER TABLE auth.remembered_sessions
    ADD CONSTRAINT pk_remembered_sessions PRIMARY KEY (id);


--

--

ALTER TABLE auth.remembered_sessions
    ADD CONSTRAINT remembered_sessions_remember_token_unique UNIQUE (remember_token);


--

--

CREATE INDEX idx_remembered_sessions_remember_token ON auth.remembered_sessions USING btree (remember_token);


--

--

CREATE INDEX idx_remembered_sessions_user_id_expires_at ON auth.remembered_sessions USING btree (user_id, expires_at);


--

--

ALTER TABLE auth.remembered_sessions
    ADD CONSTRAINT fk_remembered_sessions_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE RESTRICT;


--
