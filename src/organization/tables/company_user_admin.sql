-- Table: organization.company_user_admin
-- Includes constraints and indexes

--

CREATE TABLE organization.company_user_admin (
    id INTEGER NOT NULL,
    company_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    fl_active BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE organization.company_user_admin OWNER TO postgres;

--

--

ALTER TABLE organization.company_user_admin
    ADD CONSTRAINT pk_company_user_admin PRIMARY KEY (id);


--

--

ALTER TABLE organization.company_user_admin
    ADD CONSTRAINT fk_company_user_admin_company FOREIGN KEY (company_id) REFERENCES organization.companies(id);


--

--

ALTER TABLE organization.company_user_admin
    ADD CONSTRAINT fk_company_user_admin_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.company_user_admin
    ADD CONSTRAINT fk_company_user_admin_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.company_user_admin
    ADD CONSTRAINT fk_company_user_admin_employee FOREIGN KEY (employee_id) REFERENCES organization.employees(id);


--

--

ALTER TABLE organization.company_user_admin
    ADD CONSTRAINT fk_company_user_admin_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
