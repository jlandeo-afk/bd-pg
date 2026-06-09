-- Table: academic.frequent_university_subtopic
-- Includes constraints and indexes

--

CREATE TABLE academic.frequent_university_subtopic (
    id BIGINT NOT NULL,
    university_id BIGINT NOT NULL,
    subtopic_id BIGINT NOT NULL,
    updated_by BIGINT,
    is_frequent BOOLEAN DEFAULT true NOT NULL,
    method VARCHAR(255) DEFAULT 'system'::VARCHAR NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    CONSTRAINT frequent_university_subtopic_method_check CHECK (((method)::TEXT = ANY (ARRAY[('manual'::VARCHAR)::TEXT, ('system'::VARCHAR)::TEXT])))
);


ALTER TABLE academic.frequent_university_subtopic OWNER TO postgres;

--

--

ALTER TABLE academic.frequent_university_subtopic
    ADD CONSTRAINT pk_frequent_university_subtopic PRIMARY KEY (id);


--

--

ALTER TABLE academic.frequent_university_subtopic
    ADD CONSTRAINT uq_university_subtopic UNIQUE (university_id, subtopic_id);


--

--

ALTER TABLE academic.frequent_university_subtopic
    ADD CONSTRAINT fk_frequent_university_subtopic_subtopic FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE academic.frequent_university_subtopic
    ADD CONSTRAINT fk_frequent_university_subtopic_university FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE academic.frequent_university_subtopic
    ADD CONSTRAINT fk_frequent_university_subtopic_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
