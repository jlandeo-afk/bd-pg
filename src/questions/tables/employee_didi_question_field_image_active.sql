-- Table: questions.employee_didi_question_field_image_active
-- Includes constraints and indexes

--

CREATE TABLE questions.employee_didi_question_field_image_active (
    id bigint NOT NULL,
    employee_didi_question_id bigint NOT NULL,
    code character varying NOT NULL,
    image character varying NOT NULL,
    extension character varying NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE questions.employee_didi_question_field_image_active OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.employee_didi_question_field_image_active
    ADD CONSTRAINT employee_didi_question_field_image_active_pkey PRIMARY KEY (id, fl_status);


--
