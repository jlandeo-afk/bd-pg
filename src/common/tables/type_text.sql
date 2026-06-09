-- Table: common.type_text
-- Includes constraints and indexes

--

CREATE TABLE common.type_text (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    fl_status boolean DEFAULT true NOT NULL,
    "position" smallint DEFAULT '0'::smallint NOT NULL
);


ALTER TABLE common.type_text OWNER TO postgres;

--

--

ALTER TABLE ONLY common.type_text
    ADD CONSTRAINT type_text_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY common.type_text
    ADD CONSTRAINT odiseo_type_text_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--

--

ALTER TABLE ONLY common.type_text
    ADD CONSTRAINT odiseo_type_text_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--

--

ALTER TABLE ONLY common.type_text
    ADD CONSTRAINT odiseo_type_text_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--
