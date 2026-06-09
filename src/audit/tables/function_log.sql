-- Table: audit.function_log
-- Includes constraints and indexes

--

CREATE TABLE audit.function_log (
    id BIGINT NOT NULL,
    datetime TIMESTAMPTZ DEFAULT now(),
    schema_name TEXT,
    function_name TEXT,
    tag TEXT,
    function_body TEXT,
    changed_by TEXT DEFAULT CURRENT_USER
);


ALTER TABLE audit.function_log OWNER TO postgres;

--

--

ALTER TABLE audit.function_log
    ADD CONSTRAINT pk_function_log PRIMARY KEY (id);


--

--

CREATE INDEX idx_function_log_datetime ON audit.function_log USING btree (datetime);


--

--

CREATE INDEX idx_function_log_function_name ON audit.function_log USING btree (function_name);


--
