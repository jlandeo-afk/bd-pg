-- Table: questions.employee_question
-- Includes constraints and indexes

--

CREATE TABLE questions.employee_question (
    id bigint NOT NULL,
    teacher_id bigint,
    question_id bigint,
    alternative_id bigint,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    type character varying(255) DEFAULT 'MANUAL'::character varying NOT NULL,
    document_solution text,
    week integer,
    year integer,
    solved boolean DEFAULT false NOT NULL,
    url_pdf_question_solution character varying(255),
    board_json text,
    board_refuzed text,
    fl_refuzed boolean DEFAULT false NOT NULL,
    editor_content text,
    url_pdf_question_solution_updated_at timestamp(0) without time zone
);


ALTER TABLE questions.employee_question OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.employee_question
    ADD CONSTRAINT employee_question_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_employee_question_active ON questions.employee_question USING btree (question_id) WHERE (fl_status = true);


--

--

ALTER TABLE ONLY questions.employee_question
    ADD CONSTRAINT odiseo_employee_question_alternative_id_foreign FOREIGN KEY (alternative_id) REFERENCES questions.alternative(id);


--

--

ALTER TABLE ONLY questions.employee_question
    ADD CONSTRAINT odiseo_employee_question_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.employee_question
    ADD CONSTRAINT odiseo_employee_question_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.employee_question
    ADD CONSTRAINT odiseo_employee_question_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE ONLY questions.employee_question
    ADD CONSTRAINT odiseo_employee_question_teacher_id_foreign FOREIGN KEY (teacher_id) REFERENCES odiseo.employees(id);


--

--

ALTER TABLE ONLY questions.employee_question
    ADD CONSTRAINT odiseo_employee_question_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
