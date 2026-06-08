-- Table: odiseo.employee_didi_question_field_image
-- Includes constraints and indexes

--

CREATE TABLE odiseo.employee_didi_question_field_image (
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
)
PARTITION BY LIST (fl_status);


ALTER TABLE odiseo.employee_didi_question_field_image OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.employee_didi_question_field_image
    ADD CONSTRAINT employee_didi_question_field_image_pkey1 PRIMARY KEY (id, fl_status);


--

--

ALTER TABLE odiseo.employee_didi_question_field_image
    ADD CONSTRAINT employee_didi_question_field_ima_employee_didi_question_id_fkey FOREIGN KEY (employee_didi_question_id) REFERENCES odiseo.employee_didi_question(id);


--

--

ALTER TABLE odiseo.employee_didi_question_field_image
    ADD CONSTRAINT employee_didi_question_field_image_created_by_fkey FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE odiseo.employee_didi_question_field_image
    ADD CONSTRAINT employee_didi_question_field_image_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE odiseo.employee_didi_question_field_image
    ADD CONSTRAINT employee_didi_question_field_image_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
