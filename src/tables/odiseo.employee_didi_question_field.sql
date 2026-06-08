-- Table: odiseo.employee_didi_question_field
-- Includes constraints and indexes

--

CREATE TABLE odiseo.employee_didi_question_field (
    id bigint NOT NULL,
    employee_didi_question_id bigint NOT NULL,
    setting_diagrammed_course_id bigint NOT NULL,
    value text,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    migrated_updated_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP,
    math_migration_status character varying(255) DEFAULT 'NOT_MIGRATED'::character varying NOT NULL,
    is_migrated boolean DEFAULT false NOT NULL,
    CONSTRAINT employee_didi_question_field_math_migration_status_new_check CHECK (((math_migration_status)::text = ANY (ARRAY[('NOT_MIGRATED'::character varying)::text, ('TO_BE_MIGRATED'::character varying)::text, ('MIGRATING'::character varying)::text, ('MIGRATED'::character varying)::text, ('NOT_MIGRATABLE'::character varying)::text, ('MIGRATION_FAILURE'::character varying)::text])))
);


ALTER TABLE odiseo.employee_didi_question_field OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.employee_didi_question_field
    ADD CONSTRAINT employee_didi_question_field_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_employee_didi_question_field_employee_didi_question_id ON odiseo.employee_didi_question_field USING btree (employee_didi_question_id);


--

--

ALTER TABLE ONLY odiseo.employee_didi_question_field
    ADD CONSTRAINT odiseo_employee_didi_question_field_employee_didi_question_id_f FOREIGN KEY (employee_didi_question_id) REFERENCES odiseo.employee_didi_question(id);


--

--

ALTER TABLE ONLY odiseo.employee_didi_question_field
    ADD CONSTRAINT odiseo_employee_didi_question_field_setting_diagrammed_course_i FOREIGN KEY (setting_diagrammed_course_id) REFERENCES odiseo.setting_diagrammed_courses(id);


--
