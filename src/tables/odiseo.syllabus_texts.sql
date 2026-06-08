-- Table: odiseo.syllabus_texts
-- Includes constraints and indexes

--

CREATE TABLE odiseo.syllabus_texts (
    id bigint NOT NULL,
    syllabus_text_distribution_id bigint NOT NULL,
    type_text_id bigint NOT NULL,
    type_text_subcategory_id bigint NOT NULL,
    "position" integer NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    fl_status boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE odiseo.syllabus_texts OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.syllabus_texts
    ADD CONSTRAINT syllabus_texts_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.syllabus_texts
    ADD CONSTRAINT syllabus_texts_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY odiseo.syllabus_texts
    ADD CONSTRAINT syllabus_texts_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_texts
    ADD CONSTRAINT syllabus_texts_syllabus_text_distribution_id_foreign FOREIGN KEY (syllabus_text_distribution_id) REFERENCES odiseo.syllabus_text_distributions(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_texts
    ADD CONSTRAINT syllabus_texts_type_text_id_foreign FOREIGN KEY (type_text_id) REFERENCES odiseo.type_text(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_texts
    ADD CONSTRAINT syllabus_texts_type_text_subcategory_id_foreign FOREIGN KEY (type_text_subcategory_id) REFERENCES odiseo.type_text_subcategories(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_texts
    ADD CONSTRAINT syllabus_texts_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
