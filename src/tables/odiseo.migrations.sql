-- Table: odiseo.migrations
-- Includes constraints and indexes

--

CREATE TABLE odiseo.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE odiseo.migrations OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
