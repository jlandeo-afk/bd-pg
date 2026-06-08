-- Table: odiseo.question_attributes
-- Includes constraints and indexes

--

CREATE TABLE odiseo.question_attributes (
    id bigint NOT NULL,
    question_attributes_type_id integer NOT NULL,
    question_id integer NOT NULL,
    value character varying(255) NOT NULL,
    created_by integer NOT NULL,
    updated_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deleted_by integer
);


ALTER TABLE odiseo.question_attributes OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.question_attributes
    ADD CONSTRAINT question_attributes_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.question_attributes
    ADD CONSTRAINT question_attributes_question_attributes_type_id_foreign FOREIGN KEY (question_attributes_type_id) REFERENCES odiseo.question_attributes_type(id);


--

--

ALTER TABLE ONLY odiseo.question_attributes
    ADD CONSTRAINT question_attributes_question_id_foreign FOREIGN KEY (question_id) REFERENCES odiseo.question(id);


--
