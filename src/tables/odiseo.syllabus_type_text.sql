-- Table: odiseo.syllabus_type_text
-- Includes constraints and indexes

--

CREATE TABLE odiseo.syllabus_type_text (
    id bigint NOT NULL,
    type_text_id bigint NOT NULL,
    syllabus_id bigint NOT NULL,
    week integer NOT NULL,
    quantity integer NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    deleted_by bigint,
    updated_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.syllabus_type_text OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.syllabus_type_text
    ADD CONSTRAINT syllabus_type_text_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.syllabus_type_text
    ADD CONSTRAINT odiseo_syllabus_type_text_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_type_text
    ADD CONSTRAINT odiseo_syllabus_type_text_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_type_text
    ADD CONSTRAINT odiseo_syllabus_type_text_syllabus_id_foreign FOREIGN KEY (syllabus_id) REFERENCES odiseo.syllabus(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_type_text
    ADD CONSTRAINT odiseo_syllabus_type_text_type_text_id_foreign FOREIGN KEY (type_text_id) REFERENCES odiseo.type_text(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_type_text
    ADD CONSTRAINT odiseo_syllabus_type_text_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
