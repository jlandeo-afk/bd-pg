-- Table: common.type_text_to_subcategory
-- Includes constraints and indexes

--

CREATE TABLE common.type_text_to_subcategory (
    id bigint NOT NULL,
    type_text_id bigint NOT NULL,
    type_text_subcategory_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE common.type_text_to_subcategory OWNER TO postgres;

--

--

ALTER TABLE ONLY common.type_text_to_subcategory
    ADD CONSTRAINT type_text_to_subcategory_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY common.type_text_to_subcategory
    ADD CONSTRAINT type_text_to_subcategory_type_text_id_foreign FOREIGN KEY (type_text_id) REFERENCES common.type_text(id);


--

--

ALTER TABLE ONLY common.type_text_to_subcategory
    ADD CONSTRAINT type_text_to_subcategory_type_text_subcategory_id_foreign FOREIGN KEY (type_text_subcategory_id) REFERENCES common.type_text_subcategories(id);


--
