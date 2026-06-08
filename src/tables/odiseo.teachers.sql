-- Table: odiseo.teachers
-- Includes constraints and indexes

--

CREATE TABLE odiseo.teachers (
    id bigint NOT NULL,
    employee_id bigint NOT NULL,
    code character varying(20),
    limit_assigned_questions smallint DEFAULT '0'::smallint NOT NULL,
    limit_assigned_questions_initial smallint DEFAULT '0'::smallint NOT NULL,
    fl_unlimit_questions boolean DEFAULT false NOT NULL,
    level_rate_id bigint,
    goal smallint DEFAULT '0'::smallint NOT NULL,
    lot smallint DEFAULT '0'::smallint NOT NULL,
    fl_active boolean DEFAULT true NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    company_id bigint NOT NULL,
    limit_missing_questions integer DEFAULT 15 NOT NULL,
    fl_resolve_missing_questions boolean DEFAULT false NOT NULL
);


ALTER TABLE odiseo.teachers OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.teachers
    ADD CONSTRAINT teachers_code_company_unique UNIQUE (code, company_id);


--

--

ALTER TABLE ONLY odiseo.teachers
    ADD CONSTRAINT teachers_employee_id_unique UNIQUE (employee_id);


--

--

ALTER TABLE ONLY odiseo.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.teachers
    ADD CONSTRAINT teachers_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE ONLY odiseo.teachers
    ADD CONSTRAINT teachers_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.teachers
    ADD CONSTRAINT teachers_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.teachers
    ADD CONSTRAINT teachers_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES odiseo.employees(id);


--

--

ALTER TABLE ONLY odiseo.teachers
    ADD CONSTRAINT teachers_level_rate_id_foreign FOREIGN KEY (level_rate_id) REFERENCES odiseo.level_rates(id);


--

--

ALTER TABLE ONLY odiseo.teachers
    ADD CONSTRAINT teachers_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
