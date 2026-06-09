-- Table: academic.option
-- Includes constraints and indexes

--

CREATE TABLE academic.option (
    id smallint NOT NULL,
    name VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    university_ids INTEGER[] DEFAULT ARRAY[]::INTEGER[]
);


ALTER TABLE academic.option OWNER TO postgres;

--

--

ALTER TABLE academic.option
    ADD CONSTRAINT pk_option PRIMARY KEY (id);


--

--

ALTER TABLE academic.option
    ADD CONSTRAINT fk_option_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.option
    ADD CONSTRAINT fk_option_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.option
    ADD CONSTRAINT fk_option_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
