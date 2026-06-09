-- Table: auth.nq_user_request
-- Includes constraints and indexes

--

CREATE TABLE auth.nq_user_request (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    request_status character varying(255) DEFAULT 'to_be_requested'::character varying NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    CONSTRAINT nq_user_request_request_status_check CHECK (((request_status)::text = ANY (ARRAY[('to_be_requested'::character varying)::text, ('failed'::character varying)::text, ('requested'::character varying)::text, ('delivered'::character varying)::text])))
);


ALTER TABLE auth.nq_user_request OWNER TO postgres;

--

--

ALTER TABLE ONLY auth.nq_user_request
    ADD CONSTRAINT nq_req_user_id UNIQUE (user_id);


--

--

ALTER TABLE ONLY auth.nq_user_request
    ADD CONSTRAINT nq_user_id UNIQUE (user_id);


--

--

ALTER TABLE ONLY auth.nq_user_request
    ADD CONSTRAINT nq_user_request_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY auth.nq_user_request
    ADD CONSTRAINT nq_user_request_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY auth.nq_user_request
    ADD CONSTRAINT nq_user_request_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY auth.nq_user_request
    ADD CONSTRAINT nq_user_request_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
