-- Table: academic.syllabus_text_detail
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_text_detail (
    id BIGINT NOT NULL,
    syllabus_text_id INTEGER NOT NULL,
    style_type VARCHAR(3) NOT NULL,
    quantity INTEGER NOT NULL,
    created_by INTEGER NOT NULL,
    updated_by INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    deleted_by INTEGER
);


ALTER TABLE academic.syllabus_text_detail OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus_text_detail
    ADD CONSTRAINT pk_syllabus_text_detail PRIMARY KEY (id);


--

--

ALTER TABLE academic.syllabus_text_detail
    ADD CONSTRAINT fk_syllabus_text_detail_syllabus_text FOREIGN KEY (syllabus_text_id) REFERENCES academic.syllabus_texts(id);


--
