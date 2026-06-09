-- Table: academic.option_university
-- Includes constraints and indexes

--

CREATE TABLE academic.option_university (
    id bigint NOT NULL,
    name character varying(255),
    university_id bigint,
    created_by bigint NOT NULL,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by bigint,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deleted_by bigint
);


ALTER TABLE academic.option_university OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.option_university
    ADD CONSTRAINT option_university_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.option_university
    ADD CONSTRAINT option_university_university_id_foreign FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--
