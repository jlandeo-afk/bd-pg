-- Table: materials.material_per_period_ballot_url
-- Includes constraints and indexes

--

CREATE TABLE materials.material_per_period_ballot_url (
    id BIGINT NOT NULL,
    material_per_period_ballot_id BIGINT NOT NULL,
    type_url VARCHAR(255) NOT NULL,
    job_url VARCHAR(255),
    job_id VARCHAR(255),
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    file_name VARCHAR(255),
    fl_job_process VARCHAR(255) DEFAULT 'unprocessed'::VARCHAR NOT NULL,
    retries smallint DEFAULT '0'::smallint NOT NULL,
    number_pages smallint,
    CONSTRAINT material_per_period_ballot_url_fl_job_process_check CHECK (((fl_job_process)::TEXT = ANY (ARRAY[('unprocessed'::VARCHAR)::TEXT, ('pending'::VARCHAR)::TEXT, ('processing'::VARCHAR)::TEXT, ('completed'::VARCHAR)::TEXT, ('failed'::VARCHAR)::TEXT, ('canceled'::VARCHAR)::TEXT]))),
    CONSTRAINT material_per_period_ballot_url_type_url_check CHECK (((type_url)::TEXT = ANY (ARRAY[('solution'::VARCHAR)::TEXT, ('without_solution'::VARCHAR)::TEXT, ('review_solution'::VARCHAR)::TEXT, ('review_without_solution'::VARCHAR)::TEXT, ('material_class'::VARCHAR)::TEXT])))
);


ALTER TABLE materials.material_per_period_ballot_url OWNER TO postgres;

--

--

ALTER TABLE materials.material_per_period_ballot_url
    ADD CONSTRAINT pk_material_per_period_ballot_url PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_per_period_ballot_url
    ADD CONSTRAINT fk_material_per_period_ballot_url_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_per_period_ballot_url
    ADD CONSTRAINT fk_material_per_period_ballot_url_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_per_period_ballot_url
    ADD CONSTRAINT fk_material_per_period_ballot_url_material_per_period_ballot FOREIGN KEY (material_per_period_ballot_id) REFERENCES materials.material_per_period_ballot(id);


--

--

ALTER TABLE materials.material_per_period_ballot_url
    ADD CONSTRAINT fk_material_per_period_ballot_url_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
