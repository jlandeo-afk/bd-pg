-- Table: materials.material_ballot_stats_global
-- Includes constraints and indexes

--

CREATE TABLE materials.material_ballot_stats_global (
    id bigint NOT NULL,
    material_per_period_ballot_id bigint NOT NULL,
    number_pages smallint DEFAULT 0,
    total_questions smallint DEFAULT 0,
    new_questions smallint DEFAULT 0,
    repeated_year smallint DEFAULT 0,
    repeated_history smallint DEFAULT 0,
    created_by integer NOT NULL,
    updated_by integer NOT NULL,
    deleted_by integer,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE materials.material_ballot_stats_global OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_ballot_stats_global
    ADD CONSTRAINT material_ballot_stats_global_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_ballot_stats_global
    ADD CONSTRAINT fk_stats_global_ballot FOREIGN KEY (material_per_period_ballot_id) REFERENCES materials.material_per_period_ballot(id) ON DELETE CASCADE;


--
