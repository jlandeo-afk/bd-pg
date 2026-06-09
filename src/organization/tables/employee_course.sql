-- Table: organization.employee_course
-- Includes constraints and indexes

--

CREATE TABLE organization.employee_course (
    id BIGINT NOT NULL,
    teacher_id BIGINT,
    course_id BIGINT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE organization.employee_course OWNER TO postgres;

--

--

ALTER TABLE organization.employee_course
    ADD CONSTRAINT pk_employee_course PRIMARY KEY (id);


--

--

ALTER TABLE organization.employee_course
    ADD CONSTRAINT fk_employee_course_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE organization.employee_course
    ADD CONSTRAINT fk_employee_course_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.employee_course
    ADD CONSTRAINT fk_employee_course_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.employee_course
    ADD CONSTRAINT fk_employee_course_teacher FOREIGN KEY (teacher_id) REFERENCES organization.employees(id);


--

--

ALTER TABLE organization.employee_course
    ADD CONSTRAINT fk_employee_course_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
