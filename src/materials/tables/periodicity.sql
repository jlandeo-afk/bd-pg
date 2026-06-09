-- Table: materials.periodicity
-- Includes constraints and indexes

--

CREATE TABLE materials.periodicity (
    id smallint NOT NULL,
    name VARCHAR(20) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    quantity smallint
);


ALTER TABLE materials.periodicity OWNER TO postgres;

--

--

ALTER TABLE materials.periodicity
    ADD CONSTRAINT pk_periodicity PRIMARY KEY (id);


--

--

ALTER TABLE materials.periodicity
    ADD CONSTRAINT fk_periodicity_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.periodicity
    ADD CONSTRAINT fk_periodicity_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.periodicity
    ADD CONSTRAINT fk_periodicity_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
