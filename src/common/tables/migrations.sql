-- Table: common.migrations
-- Includes constraints and indexes

--

CREATE TABLE common.migrations (
    id INTEGER NOT NULL,
    migration VARCHAR(255) NOT NULL,
    batch INTEGER NOT NULL
);


ALTER TABLE common.migrations OWNER TO postgres;

--

--

ALTER TABLE common.migrations
    ADD CONSTRAINT pk_migrations PRIMARY KEY (id);


--
