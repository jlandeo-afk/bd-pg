-- Table: odiseo._bkp_migration_tm_mapping
-- Includes constraints and indexes

--

CREATE TABLE odiseo._bkp_migration_tm_mapping (
    old_tm_id smallint,
    new_tm_id integer,
    cycle_id bigint,
    rn bigint
);


ALTER TABLE odiseo._bkp_migration_tm_mapping OWNER TO postgres;

--
