-- Table: common.type_documents
-- Includes constraints and indexes

--

CREATE TABLE common.type_documents (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE common.type_documents OWNER TO postgres;

--

--

ALTER TABLE common.type_documents
    ADD CONSTRAINT pk_type_documents PRIMARY KEY (id);


--

--

ALTER TABLE common.type_documents
    ADD CONSTRAINT fk_type_documents_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.type_documents
    ADD CONSTRAINT fk_type_documents_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
