-- Table: common.prospect
-- Includes constraints and indexes

--

CREATE TABLE common.prospect (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    charge VARCHAR(255) NOT NULL,
    type_company VARCHAR(255) NOT NULL,
    name_institute VARCHAR(255) NOT NULL,
    document_number VARCHAR(20) NOT NULL,
    code_id BIGINT NOT NULL,
    fl_validate BOOLEAN DEFAULT false NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT prospect_type_company_check CHECK (((type_company)::TEXT = ANY (ARRAY[('Academia'::VARCHAR)::TEXT, ('Colegio'::VARCHAR)::TEXT])))
);


ALTER TABLE common.prospect OWNER TO postgres;

--

--

ALTER TABLE common.prospect
    ADD CONSTRAINT pk_prospect PRIMARY KEY (id);


--

--

ALTER TABLE common.prospect
    ADD CONSTRAINT fk_prospect_code FOREIGN KEY (code_id) REFERENCES common.code_prospect(id);


--

--

ALTER TABLE common.prospect
    ADD CONSTRAINT fk_prospect_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.prospect
    ADD CONSTRAINT fk_prospect_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.prospect
    ADD CONSTRAINT fk_prospect_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
