-- Table: common.code_prospect
-- Includes constraints and indexes

--

CREATE TABLE common.code_prospect (
    id BIGINT NOT NULL,
    code VARCHAR(10) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE common.code_prospect OWNER TO postgres;

--

--

ALTER TABLE common.code_prospect
    ADD CONSTRAINT pk_code_prospect PRIMARY KEY (id);


--

--

ALTER TABLE common.code_prospect
    ADD CONSTRAINT fk_code_prospect_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.code_prospect
    ADD CONSTRAINT fk_code_prospect_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.code_prospect
    ADD CONSTRAINT fk_code_prospect_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
