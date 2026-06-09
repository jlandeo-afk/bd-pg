-- Table: organization.company_user_admin
-- Includes constraints and indexes

--

CREATE TABLE organization.company_user_admin (
    id integer NOT NULL,
    company_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    fl_active boolean DEFAULT true NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE organization.company_user_admin OWNER TO postgres;

--

--

ALTER TABLE ONLY organization.company_user_admin
    ADD CONSTRAINT company_user_admin_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY organization.company_user_admin
    ADD CONSTRAINT company_user_admin_company_id_foreign FOREIGN KEY (company_id) REFERENCES organization.companies(id);


--

--

ALTER TABLE ONLY organization.company_user_admin
    ADD CONSTRAINT company_user_admin_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY organization.company_user_admin
    ADD CONSTRAINT company_user_admin_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY organization.company_user_admin
    ADD CONSTRAINT company_user_admin_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES organization.employees(id);


--

--

ALTER TABLE ONLY organization.company_user_admin
    ADD CONSTRAINT company_user_admin_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
