-- Table: materials.material_per_period_ballot_class
-- Includes constraints and indexes

--

CREATE TABLE materials.material_per_period_ballot_class (
    id BIGINT NOT NULL,
    material_per_period_ballot_url_id BIGINT NOT NULL,
    course_id smallint NOT NULL,
    file_name VARCHAR(255),
    fl_job_process VARCHAR(255) DEFAULT 'unprocessed'::VARCHAR NOT NULL,
    job_url VARCHAR(255),
    job_id VARCHAR(255),
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT material_per_period_ballot_class_fl_job_process_check CHECK (((fl_job_process)::TEXT = ANY (ARRAY[('unprocessed'::VARCHAR)::TEXT, ('pending'::VARCHAR)::TEXT, ('processing'::VARCHAR)::TEXT, ('completed'::VARCHAR)::TEXT, ('failed'::VARCHAR)::TEXT, ('canceled'::VARCHAR)::TEXT])))
);


ALTER TABLE materials.material_per_period_ballot_class OWNER TO postgres;

--

--

ALTER TABLE materials.material_per_period_ballot_class
    ADD CONSTRAINT pk_material_per_period_ballot_class PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_per_period_ballot_class
    ADD CONSTRAINT fk_material_per_period_ballot_class_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.material_per_period_ballot_class
    ADD CONSTRAINT fk_material_per_period_ballot_class_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_per_period_ballot_class
    ADD CONSTRAINT fk_material_per_period_ballot_class_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_per_period_ballot_class
    ADD CONSTRAINT fk_material_per_period_ballot_class_material_per_period_ballot_url FOREIGN KEY (material_per_period_ballot_url_id) REFERENCES materials.material_per_period_ballot_url(id);


--

--

ALTER TABLE materials.material_per_period_ballot_class
    ADD CONSTRAINT fk_material_per_period_ballot_class_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
