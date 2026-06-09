-- Table: common.type_text_level
-- Includes constraints and indexes

--

CREATE TABLE common.type_text_level (
    id smallint NOT NULL,
    level smallint NOT NULL,
    description character varying(10) NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE common.type_text_level OWNER TO postgres;

--

--

ALTER TABLE ONLY common.type_text_level
    ADD CONSTRAINT type_text_level_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY common.type_text_level
    ADD CONSTRAINT type_text_level_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY common.type_text_level
    ADD CONSTRAINT type_text_level_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY common.type_text_level
    ADD CONSTRAINT type_text_level_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
