-- Table: organization.classroom
-- Includes constraints and indexes

--

CREATE TABLE organization.classroom (
    id smallint NOT NULL,
    code VARCHAR(4) NOT NULL,
    number VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE organization.classroom OWNER TO postgres;

--

--

ALTER TABLE organization.classroom
    ADD CONSTRAINT pk_classroom PRIMARY KEY (id);


--

--

ALTER TABLE organization.classroom
    ADD CONSTRAINT fk_classroom_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.classroom
    ADD CONSTRAINT fk_classroom_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE organization.classroom
    ADD CONSTRAINT fk_classroom_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
