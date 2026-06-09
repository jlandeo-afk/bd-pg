-- Table: questions.alternative_maths
-- Includes constraints and indexes

--

CREATE TABLE questions.alternative_maths (
    id bigint NOT NULL,
    code character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    alternative_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    properties json NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE questions.alternative_maths OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.alternative_maths
    ADD CONSTRAINT alternative_maths_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.alternative_maths
    ADD CONSTRAINT odiseo_alternative_maths_alternative_id_foreign FOREIGN KEY (alternative_id) REFERENCES questions.alternative(id);


--

--

ALTER TABLE ONLY questions.alternative_maths
    ADD CONSTRAINT odiseo_alternative_maths_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.alternative_maths
    ADD CONSTRAINT odiseo_alternative_maths_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.alternative_maths
    ADD CONSTRAINT odiseo_alternative_maths_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
