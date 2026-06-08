-- Table: odiseo.type_documents
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_documents (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    created_by integer,
    updated_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.type_documents OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_documents
    ADD CONSTRAINT type_documents_pkey PRIMARY KEY (id);


--
