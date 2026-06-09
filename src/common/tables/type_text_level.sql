-- Table: common.type_text_level
-- Includes constraints and indexes

--

CREATE TABLE common.type_text_level (
    id smallint NOT NULL,
    level smallint NOT NULL,
    description VARCHAR(10) NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE common.type_text_level OWNER TO postgres;

--

--

ALTER TABLE common.type_text_level
    ADD CONSTRAINT pk_type_text_level PRIMARY KEY (id);


--

--

ALTER TABLE common.type_text_level
    ADD CONSTRAINT fk_type_text_level_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.type_text_level
    ADD CONSTRAINT fk_type_text_level_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.type_text_level
    ADD CONSTRAINT fk_type_text_level_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
