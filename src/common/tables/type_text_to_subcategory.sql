-- Table: common.type_text_to_subcategory
-- Includes constraints and indexes

--

CREATE TABLE common.type_text_to_subcategory (
    id BIGINT NOT NULL,
    type_text_id BIGINT NOT NULL,
    type_text_subcategory_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE common.type_text_to_subcategory OWNER TO postgres;

--

--

ALTER TABLE common.type_text_to_subcategory
    ADD CONSTRAINT pk_type_text_to_subcategory PRIMARY KEY (id);


--

--

ALTER TABLE common.type_text_to_subcategory
    ADD CONSTRAINT fk_type_text_to_subcategory_type_text FOREIGN KEY (type_text_id) REFERENCES common.type_text(id);


--

--

ALTER TABLE common.type_text_to_subcategory
    ADD CONSTRAINT fk_type_text_to_subcategory_type_text_subcategory FOREIGN KEY (type_text_subcategory_id) REFERENCES common.type_text_subcategories(id);


--
