-- Table: questions.parent_question
-- Includes constraints and indexes

--

CREATE TABLE questions.parent_question (
    id bigint NOT NULL,
    code character varying(25),
    description text NOT NULL,
    number_question character varying(255),
    number character varying(10),
    course_id smallint NOT NULL,
    status character varying(5) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    university_id smallint,
    year character varying(4),
    option_id smallint,
    modality_id smallint,
    version character varying(2),
    authorship character varying(255),
    fl_diagrammed boolean DEFAULT false NOT NULL,
    url_pdf character varying(255),
    region character varying(255),
    area character varying(255),
    short_description text,
    code_parent_uniq text,
    type_text_id bigint,
    text_traduction text,
    short_text_traduction text,
    description_b text,
    short_description_b text,
    level_id bigint,
    type_text_subcategory_id bigint,
    columns smallint DEFAULT '1'::smallint,
    search_text text,
    priority integer,
    CONSTRAINT chk_parent_question_priority CHECK (((priority = ANY (ARRAY[1, 4, 7])) OR (priority IS NULL)))
);


ALTER TABLE questions.parent_question OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.parent_question
    ADD CONSTRAINT odiseo_parent_question_code_unique UNIQUE (code);


--

--

ALTER TABLE ONLY questions.parent_question
    ADD CONSTRAINT parent_question_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.parent_question
    ADD CONSTRAINT odiseo_parent_question_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY questions.parent_question
    ADD CONSTRAINT odiseo_parent_question_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.parent_question
    ADD CONSTRAINT odiseo_parent_question_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.parent_question
    ADD CONSTRAINT odiseo_parent_question_modality_id_foreign FOREIGN KEY (modality_id) REFERENCES academic.modality(id);


--

--

ALTER TABLE ONLY questions.parent_question
    ADD CONSTRAINT odiseo_parent_question_option_id_foreign FOREIGN KEY (option_id) REFERENCES academic.option(id);


--

--

ALTER TABLE ONLY questions.parent_question
    ADD CONSTRAINT odiseo_parent_question_type_text_id_foreign FOREIGN KEY (type_text_id) REFERENCES common.type_text(id);


--

--

ALTER TABLE ONLY questions.parent_question
    ADD CONSTRAINT odiseo_parent_question_university_id_foreign FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE ONLY questions.parent_question
    ADD CONSTRAINT odiseo_parent_question_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.parent_question
    ADD CONSTRAINT parent_question_level_id_foreign FOREIGN KEY (level_id) REFERENCES academic.level(id);


--

--

ALTER TABLE ONLY questions.parent_question
    ADD CONSTRAINT parent_question_type_text_subcategory_id_foreign FOREIGN KEY (type_text_subcategory_id) REFERENCES common.type_text_subcategories(id);


--
