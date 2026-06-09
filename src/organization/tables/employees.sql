-- Table: organization.employees
-- Includes constraints and indexes

--

CREATE TABLE organization.employees (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    user_id bigint,
    first_name character varying(60) NOT NULL,
    first_surname character varying(45) NOT NULL,
    second_surname character varying(45) NOT NULL,
    type_document_id bigint NOT NULL,
    document character varying(30),
    email odiseo.email_citext,
    phone character varying(12),
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    code character varying(255),
    limit_assigned_questions smallint DEFAULT 0 NOT NULL,
    limit_assigned_questions_initial smallint DEFAULT '0'::smallint,
    fl_unlimit_questions boolean DEFAULT false NOT NULL,
    charge_id bigint,
    gpt boolean DEFAULT false NOT NULL,
    level_id bigint,
    goal integer,
    lot smallint,
    company_id integer,
    limit_missing_questions integer DEFAULT 15,
    fl_resolve_missing_questions boolean DEFAULT false,
    CONSTRAINT limit_goal_chk CHECK (((goal >= 0) AND (goal <= 300))),
    CONSTRAINT limit_lot_chk CHECK (((lot >= 0) AND (lot <= 100)))
);


ALTER TABLE organization.employees OWNER TO postgres;

--

--

ALTER TABLE ONLY organization.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_employees_user_id ON organization.employees USING btree (user_id);


--

--

ALTER TABLE ONLY organization.employees
    ADD CONSTRAINT employees_company_id_foreign FOREIGN KEY (company_id) REFERENCES organization.companies(id);


--

--

ALTER TABLE ONLY organization.employees
    ADD CONSTRAINT odiseo_employees_charge_id_foreign FOREIGN KEY (charge_id) REFERENCES organization.charge(id);


--

--

ALTER TABLE ONLY organization.employees
    ADD CONSTRAINT odiseo_employees_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY organization.employees
    ADD CONSTRAINT odiseo_employees_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY organization.employees
    ADD CONSTRAINT odiseo_employees_level_id_foreign FOREIGN KEY (level_id) REFERENCES academic.level_rates(id);


--

--

ALTER TABLE ONLY organization.employees
    ADD CONSTRAINT odiseo_employees_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
