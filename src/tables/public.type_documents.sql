-- Table: public.type_documents
-- Includes constraints and indexes

--

CREATE TABLE public.type_documents (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    created_by bigint,
    updated_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.type_documents OWNER TO postgres;

--

--

ALTER TABLE ONLY public.type_documents
    ADD CONSTRAINT type_documents_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY public.type_documents
    ADD CONSTRAINT type_documents_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY public.type_documents
    ADD CONSTRAINT type_documents_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
