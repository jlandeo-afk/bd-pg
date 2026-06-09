-- Table: academic.type_week
-- Includes constraints and indexes

--

CREATE TABLE academic.type_week (
    id bigint NOT NULL,
    description character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    color character varying(7)
);


ALTER TABLE academic.type_week OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.type_week
    ADD CONSTRAINT type_week_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.type_week
    ADD CONSTRAINT odiseo_type_week_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.type_week
    ADD CONSTRAINT odiseo_type_week_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.type_week
    ADD CONSTRAINT odiseo_type_week_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
