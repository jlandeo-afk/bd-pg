-- Table: materials.material_revision_courses
-- Includes constraints and indexes

--

CREATE TABLE materials.material_revision_courses (
    id bigint NOT NULL,
    material_revision_id bigint NOT NULL,
    course_id smallint NOT NULL,
    verify_date timestamp(0) without time zone,
    verified_by bigint,
    status character varying(50) DEFAULT 'pending_verification'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    amount_questions_changed smallint DEFAULT '0'::smallint NOT NULL,
    CONSTRAINT chk_mat_rev_course_status CHECK (((status)::text = ANY (ARRAY[('pending_verification'::character varying)::text, ('verified'::character varying)::text])))
);


ALTER TABLE materials.material_revision_courses OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_revision_courses
    ADD CONSTRAINT material_revision_courses_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_revision_courses
    ADD CONSTRAINT uk_mat_rev_course UNIQUE (material_revision_id, course_id);


--

--

ALTER TABLE ONLY materials.material_revision_courses
    ADD CONSTRAINT fk_mat_rev_course_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY materials.material_revision_courses
    ADD CONSTRAINT fk_mat_rev_course_cr_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_revision_courses
    ADD CONSTRAINT fk_mat_rev_course_del_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_revision_courses
    ADD CONSTRAINT fk_mat_rev_course_revision FOREIGN KEY (material_revision_id) REFERENCES materials.material_revisions(id);


--

--

ALTER TABLE ONLY materials.material_revision_courses
    ADD CONSTRAINT fk_mat_rev_course_up_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_revision_courses
    ADD CONSTRAINT fk_mat_rev_course_ver_by FOREIGN KEY (verified_by) REFERENCES auth.users(id);


--
