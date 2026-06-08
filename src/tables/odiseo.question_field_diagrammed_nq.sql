-- Table: odiseo.question_field_diagrammed_nq
-- Includes constraints and indexes

--

CREATE TABLE odiseo.question_field_diagrammed_nq (
    id bigint NOT NULL,
    question_teacher_ia_id bigint NOT NULL,
    field_diagrammed_id bigint NOT NULL,
    content text,
    "position" smallint,
    course_id smallint,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.question_field_diagrammed_nq OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.question_field_diagrammed_nq
    ADD CONSTRAINT question_field_diagrammed_nq_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.question_field_diagrammed_nq
    ADD CONSTRAINT fk_qfdn_course FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.question_field_diagrammed_nq
    ADD CONSTRAINT fk_qfdn_created_by FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.question_field_diagrammed_nq
    ADD CONSTRAINT fk_qfdn_field FOREIGN KEY (field_diagrammed_id) REFERENCES odiseo.field_diagrammed(id);


--

--

ALTER TABLE ONLY odiseo.question_field_diagrammed_nq
    ADD CONSTRAINT fk_qfdn_question FOREIGN KEY (question_teacher_ia_id) REFERENCES odiseo.question_teacher_ia(id);


--
