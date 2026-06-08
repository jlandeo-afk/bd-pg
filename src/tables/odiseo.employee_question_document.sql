-- Table: odiseo.employee_question_document
-- Includes constraints and indexes

--

CREATE TABLE odiseo.employee_question_document (
    id bigint NOT NULL,
    employee_question_id bigint NOT NULL,
    type_archive_id smallint NOT NULL,
    document text NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    document_refuzed text,
    fl_refuzed boolean DEFAULT false NOT NULL
);


ALTER TABLE odiseo.employee_question_document OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.employee_question_document
    ADD CONSTRAINT employee_question_document_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.employee_question_document
    ADD CONSTRAINT odiseo_employee_question_document_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.employee_question_document
    ADD CONSTRAINT odiseo_employee_question_document_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.employee_question_document
    ADD CONSTRAINT odiseo_employee_question_document_employee_question_id_foreign FOREIGN KEY (employee_question_id) REFERENCES odiseo.employee_question(id);


--

--

ALTER TABLE ONLY odiseo.employee_question_document
    ADD CONSTRAINT odiseo_employee_question_document_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
