-- Table: odiseo.institution_types
-- Includes constraints and indexes

--

CREATE TABLE odiseo.institution_types (
    id smallint NOT NULL,
    code character varying(30) NOT NULL,
    name character varying(100) NOT NULL,
    fl_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.institution_types OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.institution_types
    ADD CONSTRAINT institution_types_code_unique UNIQUE (code);


--

--

ALTER TABLE ONLY odiseo.institution_types
    ADD CONSTRAINT institution_types_pkey PRIMARY KEY (id);


--
