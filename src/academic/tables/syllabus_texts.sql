-- Table: academic.syllabus_texts
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_texts (
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


ALTER TABLE academic.syllabus_texts OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.syllabus_texts
    ADD CONSTRAINT syllabus_texts_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.syllabus_texts
    ADD CONSTRAINT syllabus_texts_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY academic.syllabus_texts
    ADD CONSTRAINT syllabus_texts_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.syllabus_texts
    ADD CONSTRAINT syllabus_texts_syllabus_text_distribution_id_foreign FOREIGN KEY (syllabus_text_distribution_id) REFERENCES academic.syllabus_text_distributions(id);


--

--

ALTER TABLE ONLY academic.syllabus_texts
    ADD CONSTRAINT syllabus_texts_type_text_id_foreign FOREIGN KEY (type_text_id) REFERENCES common.type_text(id);


--

--

ALTER TABLE ONLY academic.syllabus_texts
    ADD CONSTRAINT syllabus_texts_type_text_subcategory_id_foreign FOREIGN KEY (type_text_subcategory_id) REFERENCES common.type_text_subcategories(id);


--

--

ALTER TABLE ONLY academic.syllabus_texts
    ADD CONSTRAINT syllabus_texts_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
