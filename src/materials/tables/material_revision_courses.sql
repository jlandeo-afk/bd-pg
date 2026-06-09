-- Table: materials.material_revision_courses
-- Includes constraints and indexes

--

CREATE TABLE materials.material_revision_courses (
    id BIGINT NOT NULL,
    material_revision_id BIGINT NOT NULL,
    course_id smallint NOT NULL,
    verify_date TIMESTAMPTZ,
    verified_by BIGINT,
    status VARCHAR(50) DEFAULT 'pending_verification'::VARCHAR NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    amount_questions_changed smallint DEFAULT '0'::smallint NOT NULL,
    CONSTRAINT chk_mat_rev_course_status CHECK (((status)::TEXT = ANY (ARRAY[('pending_verification'::VARCHAR)::TEXT, ('verified'::VARCHAR)::TEXT])))
);


ALTER TABLE materials.material_revision_courses OWNER TO postgres;

--

--

ALTER TABLE materials.material_revision_courses
    ADD CONSTRAINT pk_material_revision_courses PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_revision_courses
    ADD CONSTRAINT uk_mat_rev_course UNIQUE (material_revision_id, course_id);


--

--

ALTER TABLE materials.material_revision_courses
    ADD CONSTRAINT fk_material_revision_courses_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.material_revision_courses
    ADD CONSTRAINT fk_material_revision_courses_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_revision_courses
    ADD CONSTRAINT fk_material_revision_courses_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_revision_courses
    ADD CONSTRAINT fk_material_revision_courses_material_revision FOREIGN KEY (material_revision_id) REFERENCES materials.material_revisions(id);


--

--

ALTER TABLE materials.material_revision_courses
    ADD CONSTRAINT fk_material_revision_courses_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_revision_courses
    ADD CONSTRAINT fk_material_revision_courses_verified_by FOREIGN KEY (verified_by) REFERENCES auth.users(id);


--
