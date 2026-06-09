-- Table: common.status
-- Includes constraints and indexes

--

CREATE TABLE common.status (
    id INTEGER NOT NULL,
    status_name VARCHAR(255) NOT NULL,
    description TEXT,
    related_table VARCHAR(255) NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE common.status OWNER TO postgres;

--

--

ALTER TABLE common.status
    ADD CONSTRAINT status_id_unique UNIQUE (id);


--

--

ALTER TABLE common.status
    ADD CONSTRAINT fk_status_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.status
    ADD CONSTRAINT fk_status_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
