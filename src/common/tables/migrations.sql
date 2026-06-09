-- Table: common.migrations
-- Includes constraints and indexes

--

CREATE TABLE common.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE common.migrations OWNER TO postgres;

--

--

ALTER TABLE ONLY common.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
