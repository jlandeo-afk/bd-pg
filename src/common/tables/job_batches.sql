-- Table: common.job_batches
-- Includes constraints and indexes

--

CREATE TABLE common.job_batches (
    id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    total_jobs INTEGER NOT NULL,
    pending_jobs INTEGER NOT NULL,
    failed_jobs INTEGER NOT NULL,
    failed_job_ids TEXT NOT NULL,
    options TEXT,
    cancelled_at INTEGER,
    created_at INTEGER NOT NULL,
    finished_at INTEGER
);


ALTER TABLE common.job_batches OWNER TO postgres;

--

--

ALTER TABLE common.job_batches
    ADD CONSTRAINT pk_job_batches PRIMARY KEY (id);


--
