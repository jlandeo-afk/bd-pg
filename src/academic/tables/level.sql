-- Table: academic.level
-- Includes constraints and indexes

--

CREATE TABLE academic.level (
    id BIGINT NOT NULL,
    description VARCHAR(20) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    name VARCHAR(20),
    alias_nq VARCHAR(20)
);


ALTER TABLE academic.level OWNER TO postgres;

--

--

ALTER TABLE academic.level
    ADD CONSTRAINT pk_level PRIMARY KEY (id);


--

--

ALTER TABLE academic.level
    ADD CONSTRAINT fk_level_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.level
    ADD CONSTRAINT fk_level_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.level
    ADD CONSTRAINT fk_level_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
