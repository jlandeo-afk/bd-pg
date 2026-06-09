-- Table: academic.syllabus_type_text
-- Includes constraints and indexes

--

CREATE TABLE academic.syllabus_type_text (
    id BIGINT NOT NULL,
    type_text_id BIGINT NOT NULL,
    syllabus_id BIGINT NOT NULL,
    week INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    deleted_by BIGINT,
    updated_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE academic.syllabus_type_text OWNER TO postgres;

--

--

ALTER TABLE academic.syllabus_type_text
    ADD CONSTRAINT pk_syllabus_type_text PRIMARY KEY (id);


--

--

ALTER TABLE academic.syllabus_type_text
    ADD CONSTRAINT fk_syllabus_type_text_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_type_text
    ADD CONSTRAINT fk_syllabus_type_text_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.syllabus_type_text
    ADD CONSTRAINT fk_syllabus_type_text_syllabus FOREIGN KEY (syllabus_id) REFERENCES academic.syllabus(id);


--

--

ALTER TABLE academic.syllabus_type_text
    ADD CONSTRAINT fk_syllabus_type_text_type_text FOREIGN KEY (type_text_id) REFERENCES common.type_text(id);


--

--

ALTER TABLE academic.syllabus_type_text
    ADD CONSTRAINT fk_syllabus_type_text_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
