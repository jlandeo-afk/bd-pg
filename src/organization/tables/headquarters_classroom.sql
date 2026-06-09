-- Table: organization.headquarters_classroom
-- Includes constraints and indexes

--

CREATE TABLE organization.headquarters_classroom (
    id smallint NOT NULL,
    headquarters_id smallint NOT NULL,
    classroom_id smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE organization.headquarters_classroom OWNER TO postgres;

--

--

ALTER TABLE organization.headquarters_classroom
    ADD CONSTRAINT pk_headquarters_classroom PRIMARY KEY (id);


--

--

ALTER TABLE organization.headquarters_classroom
    ADD CONSTRAINT fk_headquarters_classroom_classroom FOREIGN KEY (classroom_id) REFERENCES organization.classroom(id);


--

--

ALTER TABLE organization.headquarters_classroom
    ADD CONSTRAINT fk_headquarters_classroom_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.headquarters_classroom
    ADD CONSTRAINT fk_headquarters_classroom_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.headquarters_classroom
    ADD CONSTRAINT fk_headquarters_classroom_headquarters FOREIGN KEY (headquarters_id) REFERENCES organization.headquarters(id);


--

--

ALTER TABLE organization.headquarters_classroom
    ADD CONSTRAINT fk_headquarters_classroom_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
