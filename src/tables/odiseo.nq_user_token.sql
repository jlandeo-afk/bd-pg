-- Table: odiseo.nq_user_token
-- Includes constraints and indexes

--

CREATE TABLE odiseo.nq_user_token (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    nq_user character varying(255) NOT NULL,
    nq_token character varying(255) NOT NULL,
    nq_expiration_date timestamp(0) without time zone,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.nq_user_token OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.nq_user_token
    ADD CONSTRAINT nq_user_token_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.nq_user_token
    ADD CONSTRAINT nq_user_token_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.nq_user_token
    ADD CONSTRAINT nq_user_token_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.nq_user_token
    ADD CONSTRAINT nq_user_token_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.nq_user_token
    ADD CONSTRAINT nq_user_token_user_id_foreign FOREIGN KEY (user_id) REFERENCES odiseo.users(id);


--
