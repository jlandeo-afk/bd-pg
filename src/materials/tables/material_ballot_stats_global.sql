-- Table: materials.material_ballot_stats_global
-- Includes constraints and indexes

--

CREATE TABLE materials.material_ballot_stats_global (
    id BIGINT NOT NULL,
    material_per_period_ballot_id BIGINT NOT NULL,
    number_pages smallint DEFAULT 0,
    total_questions smallint DEFAULT 0,
    new_questions smallint DEFAULT 0,
    repeated_year smallint DEFAULT 0,
    repeated_history smallint DEFAULT 0,
    created_by INTEGER NOT NULL,
    updated_by INTEGER NOT NULL,
    deleted_by INTEGER,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE materials.material_ballot_stats_global OWNER TO postgres;

--

--

ALTER TABLE materials.material_ballot_stats_global
    ADD CONSTRAINT pk_material_ballot_stats_global PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_ballot_stats_global
    ADD CONSTRAINT fk_material_ballot_stats_global_material_per_period_ballot FOREIGN KEY (material_per_period_ballot_id) REFERENCES materials.material_per_period_ballot(id) ON DELETE CASCADE;


--
