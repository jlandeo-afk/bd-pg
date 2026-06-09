-- Table: materials.material_ballot_stats_areas
-- Includes constraints and indexes

--

CREATE TABLE materials.material_ballot_stats_areas (
    id BIGINT NOT NULL,
    global_stats_id BIGINT NOT NULL,
    area_name VARCHAR(100) NOT NULL,
    total_questions smallint DEFAULT 0,
    new_questions smallint DEFAULT 0,
    repeated_year smallint DEFAULT 0,
    repeated_history smallint DEFAULT 0,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE materials.material_ballot_stats_areas OWNER TO postgres;

--

--

ALTER TABLE materials.material_ballot_stats_areas
    ADD CONSTRAINT pk_material_ballot_stats_areas PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_ballot_stats_areas
    ADD CONSTRAINT fk_material_ballot_stats_areas_global_stats FOREIGN KEY (global_stats_id) REFERENCES materials.material_ballot_stats_global(id) ON DELETE CASCADE;


--
