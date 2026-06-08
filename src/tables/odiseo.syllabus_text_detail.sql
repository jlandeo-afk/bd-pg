-- Table: odiseo.syllabus_text_detail
-- Includes constraints and indexes

--

CREATE TABLE odiseo.syllabus_text_detail (
    id bigint NOT NULL,
    syllabus_text_id integer NOT NULL,
    style_type character varying(3) NOT NULL,
    quantity integer NOT NULL,
    created_by integer NOT NULL,
    updated_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deleted_by integer
);


ALTER TABLE odiseo.syllabus_text_detail OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.syllabus_text_detail
    ADD CONSTRAINT syllabus_text_detail_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.syllabus_text_detail
    ADD CONSTRAINT syllabus_text_detail_syllabus_text_id_foreign FOREIGN KEY (syllabus_text_id) REFERENCES odiseo.syllabus_texts(id);


--
