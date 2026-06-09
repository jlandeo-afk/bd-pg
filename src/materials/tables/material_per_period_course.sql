-- Table: materials.material_per_period_course
-- Includes constraints and indexes

--

CREATE TABLE materials.material_per_period_course (
    id BIGINT NOT NULL,
    material_per_period_ballot_id BIGINT NOT NULL,
    course_id smallint NOT NULL,
    type VARCHAR(255) NOT NULL,
    url VARCHAR(255),
    job_id VARCHAR(255),
    job_status VARCHAR(255) DEFAULT 'unprocessed'::VARCHAR NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    pages smallint DEFAULT '0'::smallint NOT NULL,
    retries smallint DEFAULT '0'::smallint NOT NULL,
    CONSTRAINT material_per_period_course_job_status_check CHECK (((job_status)::TEXT = ANY (ARRAY[('unprocessed'::VARCHAR)::TEXT, ('pending'::VARCHAR)::TEXT, ('processing'::VARCHAR)::TEXT, ('completed'::VARCHAR)::TEXT, ('failed'::VARCHAR)::TEXT, ('canceled'::VARCHAR)::TEXT]))),
    CONSTRAINT material_per_period_course_type_check CHECK (((type)::TEXT = ANY (ARRAY[('solution'::VARCHAR)::TEXT, ('without_solution'::VARCHAR)::TEXT, ('review_solution'::VARCHAR)::TEXT, ('review_without_solution'::VARCHAR)::TEXT, ('material_class'::VARCHAR)::TEXT])))
);


ALTER TABLE materials.material_per_period_course OWNER TO postgres;

--

--

ALTER TABLE materials.material_per_period_course
    ADD CONSTRAINT pk_material_per_period_course PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_per_period_course
    ADD CONSTRAINT period_id_course_type UNIQUE (material_per_period_ballot_id, course_id, type);


--

--

ALTER TABLE materials.material_per_period_course
    ADD CONSTRAINT fk_material_per_period_course_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.material_per_period_course
    ADD CONSTRAINT fk_material_per_period_course_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_per_period_course
    ADD CONSTRAINT fk_material_per_period_course_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_per_period_course
    ADD CONSTRAINT fk_material_per_period_course_material_per_period_ballot FOREIGN KEY (material_per_period_ballot_id) REFERENCES materials.material_per_period_ballot(id);


--

--

ALTER TABLE materials.material_per_period_course
    ADD CONSTRAINT fk_material_per_period_course_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
