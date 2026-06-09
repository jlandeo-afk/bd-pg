-- Table: audit.function_log
-- Includes constraints and indexes

--

CREATE TABLE audit.function_log (
    id bigint NOT NULL,
    datetime timestamp without time zone DEFAULT now(),
    schema_name text,
    function_name text,
    tag text,
    function_body text,
    changed_by text DEFAULT CURRENT_USER
);


ALTER TABLE audit.function_log OWNER TO postgres;

--

--

ALTER TABLE ONLY audit.function_log
    ADD CONSTRAINT function_log_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_function_log_datetime ON audit.function_log USING btree (datetime);


--

--

CREATE INDEX idx_function_log_name ON audit.function_log USING btree (function_name);


--
