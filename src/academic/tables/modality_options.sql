-- Table: academic.modality_options
-- Includes constraints and indexes

--

CREATE TABLE academic.modality_options (
    id bigint NOT NULL,
    name character varying(255),
    option_university_id bigint NOT NULL,
    fl_allows_mark_frequent_topic boolean DEFAULT false NOT NULL,
    created_by bigint NOT NULL,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by bigint,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deleted_by bigint
);


ALTER TABLE academic.modality_options OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.modality_options
    ADD CONSTRAINT modality_options_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.modality_options
    ADD CONSTRAINT modality_options_option_university_id_foreign FOREIGN KEY (option_university_id) REFERENCES academic.option_university(id);


--
