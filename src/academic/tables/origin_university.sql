-- Table: academic.origin_university
-- Includes constraints and indexes

--

CREATE TABLE academic.origin_university (
    id smallint NOT NULL,
    name VARCHAR(255) NOT NULL,
    type smallint NOT NULL,
    fl_active BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    slug VARCHAR(10),
    region_id smallint,
    areas TEXT DEFAULT '[]'::TEXT NOT NULL,
    code VARCHAR(255),
    versions TEXT DEFAULT '[]'::TEXT NOT NULL
);


ALTER TABLE academic.origin_university OWNER TO postgres;

--

--

ALTER TABLE academic.origin_university
    ADD CONSTRAINT pk_origin_university PRIMARY KEY (id);


--

--

ALTER TABLE academic.origin_university
    ADD CONSTRAINT fk_origin_university_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.origin_university
    ADD CONSTRAINT fk_origin_university_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.origin_university
    ADD CONSTRAINT fk_origin_university_region FOREIGN KEY (region_id) REFERENCES odiseo.region(id);


--

--

ALTER TABLE academic.origin_university
    ADD CONSTRAINT fk_origin_university_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
