-- Table: organization.teachers
-- Includes constraints and indexes

--

CREATE TABLE organization.teachers (
    id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    code VARCHAR(20),
    limit_assigned_questions smallint DEFAULT '0'::smallint NOT NULL,
    limit_assigned_questions_initial smallint DEFAULT '0'::smallint NOT NULL,
    fl_unlimit_questions BOOLEAN DEFAULT false NOT NULL,
    level_rate_id BIGINT,
    goal smallint DEFAULT '0'::smallint NOT NULL,
    lot smallint DEFAULT '0'::smallint NOT NULL,
    fl_active BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    company_id BIGINT NOT NULL,
    limit_missing_questions INTEGER DEFAULT 15 NOT NULL,
    fl_resolve_missing_questions BOOLEAN DEFAULT false NOT NULL
);


ALTER TABLE organization.teachers OWNER TO postgres;

--

--

ALTER TABLE organization.teachers
    ADD CONSTRAINT teachers_code_company_unique UNIQUE (code, company_id);


--

--

ALTER TABLE organization.teachers
    ADD CONSTRAINT teachers_employee_id_unique UNIQUE (employee_id);


--

--

ALTER TABLE organization.teachers
    ADD CONSTRAINT pk_teachers PRIMARY KEY (id);


--

--

ALTER TABLE organization.teachers
    ADD CONSTRAINT fk_teachers_company FOREIGN KEY (company_id) REFERENCES organization.companies(id);


--

--

ALTER TABLE organization.teachers
    ADD CONSTRAINT fk_teachers_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.teachers
    ADD CONSTRAINT fk_teachers_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.teachers
    ADD CONSTRAINT fk_teachers_employee FOREIGN KEY (employee_id) REFERENCES organization.employees(id);


--

--

ALTER TABLE organization.teachers
    ADD CONSTRAINT fk_teachers_level_rate FOREIGN KEY (level_rate_id) REFERENCES academic.level_rates(id);


--

--

ALTER TABLE organization.teachers
    ADD CONSTRAINT fk_teachers_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
