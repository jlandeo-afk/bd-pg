-- Table: common.status
-- Includes constraints and indexes

--

CREATE TABLE common.status (
    id integer NOT NULL,
    status_name character varying(255) NOT NULL,
    description text,
    related_table character varying(255) NOT NULL,
    created_by bigint,
    updated_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE common.status OWNER TO postgres;

--

--

ALTER TABLE ONLY common.status
    ADD CONSTRAINT status_id_unique UNIQUE (id);


--

--

ALTER TABLE ONLY common.status
    ADD CONSTRAINT status_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY common.status
    ADD CONSTRAINT status_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
