-- Table: common.type_text_subcategories
-- Includes constraints and indexes

--

CREATE TABLE common.type_text_subcategories (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE common.type_text_subcategories OWNER TO postgres;

--

--

ALTER TABLE common.type_text_subcategories
    ADD CONSTRAINT pk_type_text_subcategories PRIMARY KEY (id);


--

--

ALTER TABLE common.type_text_subcategories
    ADD CONSTRAINT fk_type_text_subcategories_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.type_text_subcategories
    ADD CONSTRAINT fk_type_text_subcategories_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.type_text_subcategories
    ADD CONSTRAINT fk_type_text_subcategories_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
