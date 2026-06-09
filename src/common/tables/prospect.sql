-- Table: common.prospect
-- Includes constraints and indexes

--

CREATE TABLE common.prospect (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    charge character varying(255) NOT NULL,
    type_company character varying(255) NOT NULL,
    name_institute character varying(255) NOT NULL,
    document_number character varying(20) NOT NULL,
    code_id bigint NOT NULL,
    fl_validate boolean DEFAULT false NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    CONSTRAINT prospect_type_company_check CHECK (((type_company)::text = ANY (ARRAY[('Academia'::character varying)::text, ('Colegio'::character varying)::text])))
);


ALTER TABLE common.prospect OWNER TO postgres;

--

--

ALTER TABLE ONLY common.prospect
    ADD CONSTRAINT prospect_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY common.prospect
    ADD CONSTRAINT odiseo_prospect_code_id_foreign FOREIGN KEY (code_id) REFERENCES common.code_prospect(id);


--

--

ALTER TABLE ONLY common.prospect
    ADD CONSTRAINT odiseo_prospect_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY common.prospect
    ADD CONSTRAINT odiseo_prospect_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY common.prospect
    ADD CONSTRAINT odiseo_prospect_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
