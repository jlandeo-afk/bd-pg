-- Table: auth.nq_user_token
-- Includes constraints and indexes

--

CREATE TABLE auth.nq_user_token (
    id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    nq_user VARCHAR(255) NOT NULL,
    nq_token VARCHAR(255) NOT NULL,
    nq_expiration_date TIMESTAMPTZ,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE auth.nq_user_token OWNER TO postgres;

--

--

ALTER TABLE auth.nq_user_token
    ADD CONSTRAINT pk_nq_user_token PRIMARY KEY (id);


--

--

ALTER TABLE auth.nq_user_token
    ADD CONSTRAINT fk_nq_user_token_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.nq_user_token
    ADD CONSTRAINT fk_nq_user_token_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.nq_user_token
    ADD CONSTRAINT fk_nq_user_token_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.nq_user_token
    ADD CONSTRAINT fk_nq_user_token_user FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
