-- Table: odiseo.code_prospect
-- Includes constraints and indexes

--

CREATE TABLE odiseo.code_prospect (
    id bigint NOT NULL,
    code character varying(10) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.code_prospect OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.code_prospect
    ADD CONSTRAINT code_prospect_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.code_prospect
    ADD CONSTRAINT odiseo_code_prospect_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.code_prospect
    ADD CONSTRAINT odiseo_code_prospect_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.code_prospect
    ADD CONSTRAINT odiseo_code_prospect_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
