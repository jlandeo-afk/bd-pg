-- Table: odiseo.job_batches
-- Includes constraints and indexes

--

CREATE TABLE odiseo.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


ALTER TABLE odiseo.job_batches OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
