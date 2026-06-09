-- Table: academic.week
-- Includes constraints and indexes

--

CREATE TABLE academic.week (
    id smallint NOT NULL,
    description VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE academic.week OWNER TO postgres;

--

--

ALTER TABLE academic.week
    ADD CONSTRAINT pk_week PRIMARY KEY (id);


--

--

ALTER TABLE academic.week
    ADD CONSTRAINT fk_week_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.week
    ADD CONSTRAINT fk_week_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.week
    ADD CONSTRAINT fk_week_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
