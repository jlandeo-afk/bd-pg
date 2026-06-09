-- Table: common._bkp_migration_tma_mapping
-- Includes constraints and indexes

--

CREATE TABLE common._bkp_migration_tma_mapping (
    old_tma_id bigint,
    new_tma_id bigint,
    new_tm_id integer
);


ALTER TABLE common._bkp_migration_tma_mapping OWNER TO postgres;

--
