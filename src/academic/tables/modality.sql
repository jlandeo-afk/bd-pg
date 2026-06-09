-- Table: academic.modality
-- Includes constraints and indexes

--

CREATE TABLE academic.modality (
    id smallint NOT NULL,
    name character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    option_ids integer[] DEFAULT ARRAY[]::integer[],
    university_ids integer[] DEFAULT ARRAY[]::integer[],
    fl_allows_mark_frequent_topic boolean DEFAULT false NOT NULL
);


ALTER TABLE academic.modality OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.modality
    ADD CONSTRAINT modality_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.modality
    ADD CONSTRAINT odiseo_modality_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.modality
    ADD CONSTRAINT odiseo_modality_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.modality
    ADD CONSTRAINT odiseo_modality_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
