-- Table: common.failed_jobs
-- Includes constraints and indexes

--

CREATE TABLE common.failed_jobs (
    id BIGINT NOT NULL,
    UUID VARCHAR(255) NOT NULL,
    connection TEXT NOT NULL,
    queue TEXT NOT NULL,
    payload TEXT NOT NULL,
    exception TEXT NOT NULL,
    failed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE common.failed_jobs OWNER TO postgres;

--

--

ALTER TABLE common.failed_jobs
    ADD CONSTRAINT pk_failed_jobs PRIMARY KEY (id);


--

--

ALTER TABLE common.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (UUID);


--
