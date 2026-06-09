-- Table: auth.nq_user_request
-- Includes constraints and indexes

--

CREATE TABLE auth.nq_user_request (
    id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    request_status VARCHAR(255) DEFAULT 'to_be_requested'::VARCHAR NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT nq_user_request_request_status_check CHECK (((request_status)::TEXT = ANY (ARRAY[('to_be_requested'::VARCHAR)::TEXT, ('failed'::VARCHAR)::TEXT, ('requested'::VARCHAR)::TEXT, ('delivered'::VARCHAR)::TEXT])))
);


ALTER TABLE auth.nq_user_request OWNER TO postgres;

--

--

ALTER TABLE auth.nq_user_request
    ADD CONSTRAINT nq_req_user_id UNIQUE (user_id);


--

--

ALTER TABLE auth.nq_user_request
    ADD CONSTRAINT nq_user_id UNIQUE (user_id);


--

--

ALTER TABLE auth.nq_user_request
    ADD CONSTRAINT pk_nq_user_request PRIMARY KEY (id);


--

--

ALTER TABLE auth.nq_user_request
    ADD CONSTRAINT fk_nq_user_request_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.nq_user_request
    ADD CONSTRAINT fk_nq_user_request_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE auth.nq_user_request
    ADD CONSTRAINT fk_nq_user_request_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
