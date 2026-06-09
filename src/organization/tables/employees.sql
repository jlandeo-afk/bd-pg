-- Table: organization.employees
-- Includes constraints and indexes

--

CREATE TABLE organization.employees (
    id BIGINT NOT NULL,
    UUID UUID NOT NULL,
    user_id BIGINT,
    first_name VARCHAR(60) NOT NULL,
    first_surname VARCHAR(45) NOT NULL,
    second_surname VARCHAR(45) NOT NULL,
    type_document_id BIGINT NOT NULL,
    document VARCHAR(30),
    email odiseo.email_citext,
    phone VARCHAR(12),
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    code VARCHAR(255),
    limit_assigned_questions smallint DEFAULT 0 NOT NULL,
    limit_assigned_questions_initial smallint DEFAULT '0'::smallint,
    fl_unlimit_questions BOOLEAN DEFAULT false NOT NULL,
    charge_id BIGINT,
    gpt BOOLEAN DEFAULT false NOT NULL,
    level_id BIGINT,
    goal INTEGER,
    lot smallint,
    company_id INTEGER,
    limit_missing_questions INTEGER DEFAULT 15,
    fl_resolve_missing_questions BOOLEAN DEFAULT false,
    CONSTRAINT limit_goal_chk CHECK (((goal >= 0) AND (goal <= 300))),
    CONSTRAINT limit_lot_chk CHECK (((lot >= 0) AND (lot <= 100)))
);


ALTER TABLE organization.employees OWNER TO postgres;

--

--

ALTER TABLE organization.employees
    ADD CONSTRAINT pk_employees PRIMARY KEY (id);


--

--

CREATE INDEX idx_employees_user_id ON organization.employees USING btree (user_id);


--

--

ALTER TABLE organization.employees
    ADD CONSTRAINT fk_employees_company FOREIGN KEY (company_id) REFERENCES organization.companies(id);


--

--

ALTER TABLE organization.employees
    ADD CONSTRAINT fk_employees_charge FOREIGN KEY (charge_id) REFERENCES organization.charge(id);


--

--

ALTER TABLE organization.employees
    ADD CONSTRAINT fk_employees_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.employees
    ADD CONSTRAINT fk_employees_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.employees
    ADD CONSTRAINT fk_employees_level FOREIGN KEY (level_id) REFERENCES academic.level_rates(id);


--

--

ALTER TABLE organization.employees
    ADD CONSTRAINT fk_employees_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
