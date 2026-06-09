-- Table: common.type_archive
-- Includes constraints and indexes

--

CREATE TABLE common.type_archive (
    id smallint NOT NULL,
    name VARCHAR(20) NOT NULL,
    extension VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE common.type_archive OWNER TO postgres;

--

--

ALTER TABLE common.type_archive
    ADD CONSTRAINT pk_type_archive PRIMARY KEY (id);


--

--

ALTER TABLE common.type_archive
    ADD CONSTRAINT fk_type_archive_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
