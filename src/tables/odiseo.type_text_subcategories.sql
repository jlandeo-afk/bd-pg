-- Table: odiseo.type_text_subcategories
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_text_subcategories (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    fl_status boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.type_text_subcategories OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_text_subcategories
    ADD CONSTRAINT type_text_subcategories_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.type_text_subcategories
    ADD CONSTRAINT type_text_subcategories_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_text_subcategories
    ADD CONSTRAINT type_text_subcategories_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.type_text_subcategories
    ADD CONSTRAINT type_text_subcategories_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
