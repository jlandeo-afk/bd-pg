-- Table: questions.employee_question_document
-- Includes constraints and indexes

--

CREATE TABLE questions.employee_question_document (
    id BIGINT NOT NULL,
    employee_question_id BIGINT NOT NULL,
    type_archive_id smallint NOT NULL,
    document TEXT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    document_refuzed TEXT,
    fl_refuzed BOOLEAN DEFAULT false NOT NULL
);


ALTER TABLE questions.employee_question_document OWNER TO postgres;

--

--

ALTER TABLE questions.employee_question_document
    ADD CONSTRAINT pk_employee_question_document PRIMARY KEY (id);


--

--

ALTER TABLE questions.employee_question_document
    ADD CONSTRAINT fk_employee_question_document_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.employee_question_document
    ADD CONSTRAINT fk_employee_question_document_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.employee_question_document
    ADD CONSTRAINT fk_employee_question_document_employee_question FOREIGN KEY (employee_question_id) REFERENCES questions.employee_question(id);


--

--

ALTER TABLE questions.employee_question_document
    ADD CONSTRAINT fk_employee_question_document_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
