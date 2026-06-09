-- Table: exams.exam_area
-- Includes constraints and indexes

--

CREATE TABLE exams.exam_area (
    id smallint NOT NULL,
    description VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    short_description VARCHAR(255)
);


ALTER TABLE exams.exam_area OWNER TO postgres;

--

--

ALTER TABLE exams.exam_area
    ADD CONSTRAINT pk_exam_area PRIMARY KEY (id);


--

--

ALTER TABLE exams.exam_area
    ADD CONSTRAINT fk_exam_area_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE exams.exam_area
    ADD CONSTRAINT fk_exam_area_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE exams.exam_area
    ADD CONSTRAINT fk_exam_area_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
