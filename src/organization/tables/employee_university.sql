-- Table: organization.employee_university
-- Includes constraints and indexes

--

CREATE TABLE organization.employee_university (
    employee_id BIGINT NOT NULL,
    university_id smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    id BIGINT NOT NULL
);


ALTER TABLE organization.employee_university OWNER TO postgres;

--

--

ALTER TABLE organization.employee_university
    ADD CONSTRAINT pk_employee_university PRIMARY KEY (id);


--

--

ALTER TABLE organization.employee_university
    ADD CONSTRAINT fk_employee_university_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.employee_university
    ADD CONSTRAINT fk_employee_university_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.employee_university
    ADD CONSTRAINT fk_employee_university_employee FOREIGN KEY (employee_id) REFERENCES organization.employees(id);


--

--

ALTER TABLE organization.employee_university
    ADD CONSTRAINT fk_employee_university_university FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE organization.employee_university
    ADD CONSTRAINT fk_employee_university_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
