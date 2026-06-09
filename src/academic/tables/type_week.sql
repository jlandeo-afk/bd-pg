-- Table: academic.type_week
-- Includes constraints and indexes

--

CREATE TABLE academic.type_week (
    id BIGINT NOT NULL,
    description VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    color VARCHAR(7)
);


ALTER TABLE academic.type_week OWNER TO postgres;

--

--

ALTER TABLE academic.type_week
    ADD CONSTRAINT pk_type_week PRIMARY KEY (id);


--

--

ALTER TABLE academic.type_week
    ADD CONSTRAINT fk_type_week_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.type_week
    ADD CONSTRAINT fk_type_week_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.type_week
    ADD CONSTRAINT fk_type_week_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
