-- Table: common.type_text
-- Includes constraints and indexes

--

CREATE TABLE common.type_text (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    "position" smallint DEFAULT '0'::smallint NOT NULL
);


ALTER TABLE common.type_text OWNER TO postgres;

--

--

ALTER TABLE common.type_text
    ADD CONSTRAINT pk_type_text PRIMARY KEY (id);


--

--

ALTER TABLE common.type_text
    ADD CONSTRAINT fk_type_text_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--

--

ALTER TABLE common.type_text
    ADD CONSTRAINT fk_type_text_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--

--

ALTER TABLE common.type_text
    ADD CONSTRAINT fk_type_text_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--
