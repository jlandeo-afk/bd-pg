-- Table: academic.level_rates
-- Includes constraints and indexes

--

CREATE TABLE academic.level_rates (
    id BIGINT NOT NULL,
    level_name VARCHAR(255) NOT NULL,
    cost_per_question NUMERIC(10,2) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE academic.level_rates OWNER TO postgres;

--

--

ALTER TABLE academic.level_rates
    ADD CONSTRAINT pk_level_rates PRIMARY KEY (id);


--

--

ALTER TABLE academic.level_rates
    ADD CONSTRAINT fk_level_rates_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.level_rates
    ADD CONSTRAINT fk_level_rates_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.level_rates
    ADD CONSTRAINT fk_level_rates_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
