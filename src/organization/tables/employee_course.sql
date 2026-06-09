-- Table: organization.employee_course
-- Includes constraints and indexes

--

CREATE TABLE organization.employee_course (
    id bigint NOT NULL,
    teacher_id bigint,
    course_id bigint,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE organization.employee_course OWNER TO postgres;

--

--

ALTER TABLE ONLY organization.employee_course
    ADD CONSTRAINT employee_course_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY organization.employee_course
    ADD CONSTRAINT odiseo_employee_course_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY organization.employee_course
    ADD CONSTRAINT odiseo_employee_course_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY organization.employee_course
    ADD CONSTRAINT odiseo_employee_course_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY organization.employee_course
    ADD CONSTRAINT odiseo_employee_course_teacher_id_foreign FOREIGN KEY (teacher_id) REFERENCES organization.employees(id);


--

--

ALTER TABLE ONLY organization.employee_course
    ADD CONSTRAINT odiseo_employee_course_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
