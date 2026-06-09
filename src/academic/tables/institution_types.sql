-- Table: academic.institution_types
-- Includes constraints and indexes

--

CREATE TABLE academic.institution_types (
    id smallint NOT NULL,
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    fl_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE academic.institution_types OWNER TO postgres;

--

--

ALTER TABLE academic.institution_types
    ADD CONSTRAINT institution_types_code_unique UNIQUE (code);


--

--

ALTER TABLE academic.institution_types
    ADD CONSTRAINT pk_institution_types PRIMARY KEY (id);


--
