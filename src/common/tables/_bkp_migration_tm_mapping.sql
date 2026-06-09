-- Table: common._bkp_migration_tm_mapping
-- Includes constraints and indexes

--

CREATE TABLE common._bkp_migration_tm_mapping (
    old_tm_id smallint,
    new_tm_id INTEGER,
    cycle_id BIGINT,
    rn BIGINT
);


ALTER TABLE common._bkp_migration_tm_mapping OWNER TO postgres;

--
