-- Table: academic.course_assigned_categories
-- Includes constraints and indexes

--

CREATE TABLE academic.course_assigned_categories (
    id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    type_text_id INTEGER NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE academic.course_assigned_categories OWNER TO postgres;

--

--

ALTER TABLE academic.course_assigned_categories
    ADD CONSTRAINT course_assigned_categories_course_id_type_text_id_unique UNIQUE (course_id, type_text_id);


--

--

ALTER TABLE academic.course_assigned_categories
    ADD CONSTRAINT pk_course_assigned_categories PRIMARY KEY (id);


--

--

ALTER TABLE academic.course_assigned_categories
    ADD CONSTRAINT fk_course_assigned_categories_course FOREIGN KEY (course_id) REFERENCES academic.course(id) ON DELETE CASCADE;


--

--

ALTER TABLE academic.course_assigned_categories
    ADD CONSTRAINT fk_course_assigned_categories_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.course_assigned_categories
    ADD CONSTRAINT fk_course_assigned_categories_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.course_assigned_categories
    ADD CONSTRAINT fk_course_assigned_categories_type_text FOREIGN KEY (type_text_id) REFERENCES common.type_text(id) ON DELETE RESTRICT;


--

--

ALTER TABLE academic.course_assigned_categories
    ADD CONSTRAINT fk_course_assigned_categories_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
