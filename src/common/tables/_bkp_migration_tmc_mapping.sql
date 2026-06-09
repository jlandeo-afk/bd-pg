-- Table: common._bkp_migration_tmc_mapping
-- Includes constraints and indexes

--

CREATE TABLE common._bkp_migration_tmc_mapping (
    old_tmc_id BIGINT,
    new_tmc_id BIGINT,
    new_tm_id INTEGER
);


ALTER TABLE common._bkp_migration_tmc_mapping OWNER TO postgres;

--
