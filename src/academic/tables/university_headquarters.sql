-- Table: academic.university_headquarters
-- Includes constraints and indexes

--

CREATE TABLE academic.university_headquarters (
    id smallint NOT NULL,
    university_id smallint NOT NULL,
    headquarters_id smallint NOT NULL,
    quantity_classroom INTEGER NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE academic.university_headquarters OWNER TO postgres;

--

--

ALTER TABLE academic.university_headquarters
    ADD CONSTRAINT pk_university_headquarters PRIMARY KEY (id);


--

--

ALTER TABLE academic.university_headquarters
    ADD CONSTRAINT fk_university_headquarters_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.university_headquarters
    ADD CONSTRAINT fk_university_headquarters_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.university_headquarters
    ADD CONSTRAINT fk_university_headquarters_headquarters FOREIGN KEY (headquarters_id) REFERENCES odiseo.headquarters(id);


--

--

ALTER TABLE academic.university_headquarters
    ADD CONSTRAINT fk_university_headquarters_university FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE academic.university_headquarters
    ADD CONSTRAINT fk_university_headquarters_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
