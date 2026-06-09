-- Table: academic.syllabus_text_distributions
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_text_distributions (
    id BIGINT NOT NULL,
    syllabus_text_week_id BIGINT NOT NULL,
    type_material_id BIGINT NOT NULL,
    distribution_type VARCHAR(255) DEFAULT 'TEXT'::VARCHAR NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL,
    CONSTRAINT syllabus_text_distributions_distribution_type_check CHECK (((distribution_type)::TEXT = ANY (ARRAY[('TEXT'::VARCHAR)::TEXT, ('QUESTION'::VARCHAR)::TEXT])))
);


ALTER TABLE academic.syllabus_text_distributions OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus_text_distributions
    ADD CONSTRAINT pk_syllabus_text_distributions PRIMARY KEY (id);


--

--

ALTER TABLE academic.syllabus_text_distributions
    ADD CONSTRAINT fk_syllabus_text_distributions_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--

--

ALTER TABLE academic.syllabus_text_distributions
    ADD CONSTRAINT fk_syllabus_text_distributions_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_text_distributions
    ADD CONSTRAINT fk_syllabus_text_distributions_syllabus_text_week FOREIGN KEY (syllabus_text_week_id) REFERENCES academic.syllabus_text_weeks(id);


--

--

ALTER TABLE academic.syllabus_text_distributions
    ADD CONSTRAINT fk_syllabus_text_distributions_type_material FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE academic.syllabus_text_distributions
    ADD CONSTRAINT fk_syllabus_text_distributions_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
