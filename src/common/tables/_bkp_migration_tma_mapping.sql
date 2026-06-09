-- Table: common._bkp_migration_tma_mapping
-- Includes constraints and indexes

--

CREATE TABLE common._bkp_migration_tma_mapping (
    old_tma_id BIGINT,
    new_tma_id BIGINT,
    new_tm_id INTEGER
);


ALTER TABLE common._bkp_migration_tma_mapping OWNER TO postgres;

--
