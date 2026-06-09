-- Table: academic.frequent_university_subtopic
-- Includes constraints and indexes

--

CREATE TABLE academic.frequent_university_subtopic (
    id bigint NOT NULL,
    university_id bigint NOT NULL,
    subtopic_id bigint NOT NULL,
    updated_by bigint,
    is_frequent boolean DEFAULT true NOT NULL,
    method character varying(255) DEFAULT 'system'::character varying NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT frequent_university_subtopic_method_check CHECK (((method)::text = ANY (ARRAY[('manual'::character varying)::text, ('system'::character varying)::text])))
);


ALTER TABLE academic.frequent_university_subtopic OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.frequent_university_subtopic
    ADD CONSTRAINT frequent_university_subtopic_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.frequent_university_subtopic
    ADD CONSTRAINT uq_university_subtopic UNIQUE (university_id, subtopic_id);


--

--

ALTER TABLE ONLY academic.frequent_university_subtopic
    ADD CONSTRAINT odiseo_frequent_university_subtopic_subtopic_id_foreign FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE ONLY academic.frequent_university_subtopic
    ADD CONSTRAINT odiseo_frequent_university_subtopic_university_id_foreign FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE ONLY academic.frequent_university_subtopic
    ADD CONSTRAINT odiseo_frequent_university_subtopic_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
