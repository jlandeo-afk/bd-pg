-- Table: common._bkp_migration_tmc_mapping
-- Includes constraints and indexes

--

CREATE TABLE common._bkp_migration_tmc_mapping (
    old_tmc_id bigint,
    new_tmc_id bigint,
    new_tm_id integer
);


ALTER TABLE common._bkp_migration_tmc_mapping OWNER TO postgres;

--
