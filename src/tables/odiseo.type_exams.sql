-- Table: odiseo.type_exams
-- Includes constraints and indexes

--

CREATE TABLE odiseo.type_exams (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.type_exams OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.type_exams
    ADD CONSTRAINT type_exams_pkey PRIMARY KEY (id);


--
