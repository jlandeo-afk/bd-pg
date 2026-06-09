-- Table: questions.parent_question
-- Includes constraints and indexes

--

CREATE TABLE questions.parent_question (
    id BIGINT NOT NULL,
    code VARCHAR(25),
    description TEXT NOT NULL,
    number_question VARCHAR(255),
    number VARCHAR(10),
    course_id smallint NOT NULL,
    status VARCHAR(5) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    university_id smallint,
    year VARCHAR(4),
    option_id smallint,
    modality_id smallint,
    version VARCHAR(2),
    authorship VARCHAR(255),
    fl_diagrammed BOOLEAN DEFAULT false NOT NULL,
    url_pdf VARCHAR(255),
    region VARCHAR(255),
    area VARCHAR(255),
    short_description TEXT,
    code_parent_uniq TEXT,
    type_text_id BIGINT,
    text_traduction TEXT,
    short_text_traduction TEXT,
    description_b TEXT,
    short_description_b TEXT,
    level_id BIGINT,
    type_text_subcategory_id BIGINT,
    columns smallint DEFAULT '1'::smallint,
    search_text TEXT,
    priority INTEGER,
    CONSTRAINT chk_parent_question_priority CHECK (((priority = ANY (ARRAY[1, 4, 7])) OR (priority IS NULL)))
);


ALTER TABLE questions.parent_question OWNER TO postgres;

--

--

ALTER TABLE questions.parent_question
    ADD CONSTRAINT odiseo_parent_question_code_unique UNIQUE (code);


--

--

ALTER TABLE questions.parent_question
    ADD CONSTRAINT pk_parent_question PRIMARY KEY (id);


--

--

ALTER TABLE questions.parent_question
    ADD CONSTRAINT fk_parent_question_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE questions.parent_question
    ADD CONSTRAINT fk_parent_question_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.parent_question
    ADD CONSTRAINT fk_parent_question_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.parent_question
    ADD CONSTRAINT fk_parent_question_modality FOREIGN KEY (modality_id) REFERENCES academic.modality(id);


--

--

ALTER TABLE questions.parent_question
    ADD CONSTRAINT fk_parent_question_option FOREIGN KEY (option_id) REFERENCES academic.option(id);


--

--

ALTER TABLE questions.parent_question
    ADD CONSTRAINT fk_parent_question_type_text FOREIGN KEY (type_text_id) REFERENCES common.type_text(id);


--

--

ALTER TABLE questions.parent_question
    ADD CONSTRAINT fk_parent_question_university FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE questions.parent_question
    ADD CONSTRAINT fk_parent_question_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.parent_question
    ADD CONSTRAINT fk_parent_question_level FOREIGN KEY (level_id) REFERENCES academic.level(id);


--

--

ALTER TABLE questions.parent_question
    ADD CONSTRAINT fk_parent_question_type_text_subcategory FOREIGN KEY (type_text_subcategory_id) REFERENCES common.type_text_subcategories(id);


--
