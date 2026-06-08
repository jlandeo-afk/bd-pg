-- Table: odiseo.failed_jobs
-- Includes constraints and indexes

--

CREATE TABLE odiseo.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE odiseo.failed_jobs OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
