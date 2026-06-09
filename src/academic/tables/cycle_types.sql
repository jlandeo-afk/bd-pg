-- Table: academic.cycle_types
-- Includes constraints and indexes

--

CREATE TABLE academic.cycle_types (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE academic.cycle_types OWNER TO postgres;

--

--

ALTER TABLE academic.cycle_types
    ADD CONSTRAINT pk_cycle_types PRIMARY KEY (id);


--

--

ALTER TABLE academic.cycle_types
    ADD CONSTRAINT fk_cycle_types_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.cycle_types
    ADD CONSTRAINT fk_cycle_types_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.cycle_types
    ADD CONSTRAINT fk_cycle_types_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
