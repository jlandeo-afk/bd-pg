-- Table: odiseo.remembered_sessions
-- Includes constraints and indexes

--

CREATE TABLE odiseo.remembered_sessions (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    remember_token character varying(500) NOT NULL,
    expires_at timestamp(0) without time zone NOT NULL,
    device_info character varying(255),
    ip_address inet,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.remembered_sessions OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.remembered_sessions
    ADD CONSTRAINT remembered_sessions_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.remembered_sessions
    ADD CONSTRAINT remembered_sessions_remember_token_unique UNIQUE (remember_token);


--

--

CREATE INDEX remembered_sessions_remember_token_index ON odiseo.remembered_sessions USING btree (remember_token);


--

--

CREATE INDEX remembered_sessions_user_id_expires_at_index ON odiseo.remembered_sessions USING btree (user_id, expires_at);


--

--

ALTER TABLE ONLY odiseo.remembered_sessions
    ADD CONSTRAINT remembered_sessions_user_id_foreign FOREIGN KEY (user_id) REFERENCES odiseo.users(id) ON DELETE RESTRICT;


--
