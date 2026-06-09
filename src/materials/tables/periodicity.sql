-- Table: materials.periodicity
-- Includes constraints and indexes

--

CREATE TABLE materials.periodicity (
    id smallint NOT NULL,
    name character varying(20) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    quantity smallint
);


ALTER TABLE materials.periodicity OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.periodicity
    ADD CONSTRAINT periodicity_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.periodicity
    ADD CONSTRAINT periodicity_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.periodicity
    ADD CONSTRAINT periodicity_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.periodicity
    ADD CONSTRAINT periodicity_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
