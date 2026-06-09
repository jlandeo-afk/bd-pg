-- Table: academic.syllabus_texts
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_texts (
    id BIGINT NOT NULL,
    syllabus_text_distribution_id BIGINT NOT NULL,
    type_text_id BIGINT NOT NULL,
    type_text_subcategory_id BIGINT NOT NULL,
    "position" INTEGER NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE academic.syllabus_texts OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus_texts
    ADD CONSTRAINT pk_syllabus_texts PRIMARY KEY (id);


--

--

ALTER TABLE academic.syllabus_texts
    ADD CONSTRAINT fk_syllabus_texts_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--

--

ALTER TABLE academic.syllabus_texts
    ADD CONSTRAINT fk_syllabus_texts_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_texts
    ADD CONSTRAINT fk_syllabus_texts_syllabus_text_distribution FOREIGN KEY (syllabus_text_distribution_id) REFERENCES academic.syllabus_text_distributions(id);


--

--

ALTER TABLE academic.syllabus_texts
    ADD CONSTRAINT fk_syllabus_texts_type_text FOREIGN KEY (type_text_id) REFERENCES common.type_text(id);


--

--

ALTER TABLE academic.syllabus_texts
    ADD CONSTRAINT fk_syllabus_texts_type_text_subcategory FOREIGN KEY (type_text_subcategory_id) REFERENCES common.type_text_subcategories(id);


--

--

ALTER TABLE academic.syllabus_texts
    ADD CONSTRAINT fk_syllabus_texts_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
