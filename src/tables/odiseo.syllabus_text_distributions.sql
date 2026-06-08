-- Table: odiseo.syllabus_text_distributions
-- Includes constraints and indexes

--

CREATE TABLE odiseo.syllabus_text_distributions (
    id bigint NOT NULL,
    syllabus_text_week_id bigint NOT NULL,
    type_material_id bigint NOT NULL,
    distribution_type character varying(255) DEFAULT 'TEXT'::character varying NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    fl_status boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    company_id bigint DEFAULT '1'::bigint NOT NULL,
    CONSTRAINT syllabus_text_distributions_distribution_type_check CHECK (((distribution_type)::text = ANY (ARRAY[('TEXT'::character varying)::text, ('QUESTION'::character varying)::text])))
);


ALTER TABLE odiseo.syllabus_text_distributions OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.syllabus_text_distributions
    ADD CONSTRAINT syllabus_text_distributions_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.syllabus_text_distributions
    ADD CONSTRAINT syllabus_text_distributions_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY odiseo.syllabus_text_distributions
    ADD CONSTRAINT syllabus_text_distributions_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_text_distributions
    ADD CONSTRAINT syllabus_text_distributions_syllabus_text_week_id_foreign FOREIGN KEY (syllabus_text_week_id) REFERENCES odiseo.syllabus_text_weeks(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_text_distributions
    ADD CONSTRAINT syllabus_text_distributions_type_material_id_foreign FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE ONLY odiseo.syllabus_text_distributions
    ADD CONSTRAINT syllabus_text_distributions_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
