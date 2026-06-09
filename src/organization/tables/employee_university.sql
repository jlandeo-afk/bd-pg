-- Table: organization.employee_university
-- Includes constraints and indexes

--

CREATE TABLE organization.employee_university (
    employee_id bigint NOT NULL,
    university_id smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    id bigint NOT NULL
);


ALTER TABLE organization.employee_university OWNER TO postgres;

--

--

ALTER TABLE ONLY organization.employee_university
    ADD CONSTRAINT employee_university_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY organization.employee_university
    ADD CONSTRAINT odiseo_employee_university_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY organization.employee_university
    ADD CONSTRAINT odiseo_employee_university_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY organization.employee_university
    ADD CONSTRAINT odiseo_employee_university_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES organization.employees(id);


--

--

ALTER TABLE ONLY organization.employee_university
    ADD CONSTRAINT odiseo_employee_university_university_id_foreign FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE ONLY organization.employee_university
    ADD CONSTRAINT odiseo_employee_university_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
