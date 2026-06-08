-- Table: odiseo.question_attributes_type
-- Includes constraints and indexes

--

CREATE TABLE odiseo.question_attributes_type (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    created_by integer NOT NULL,
    updated_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deleted_by integer
);


ALTER TABLE odiseo.question_attributes_type OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.question_attributes_type
    ADD CONSTRAINT question_attributes_type_pkey PRIMARY KEY (id);


--
