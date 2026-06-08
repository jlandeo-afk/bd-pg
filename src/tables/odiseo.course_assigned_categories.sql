-- Table: odiseo.course_assigned_categories
-- Includes constraints and indexes

--

CREATE TABLE odiseo.course_assigned_categories (
    id bigint NOT NULL,
    course_id bigint NOT NULL,
    type_text_id integer NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.course_assigned_categories OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.course_assigned_categories
    ADD CONSTRAINT course_assigned_categories_course_id_type_text_id_unique UNIQUE (course_id, type_text_id);


--

--

ALTER TABLE ONLY odiseo.course_assigned_categories
    ADD CONSTRAINT course_assigned_categories_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.course_assigned_categories
    ADD CONSTRAINT course_assigned_categories_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY odiseo.course_assigned_categories
    ADD CONSTRAINT course_assigned_categories_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.course_assigned_categories
    ADD CONSTRAINT course_assigned_categories_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.course_assigned_categories
    ADD CONSTRAINT course_assigned_categories_type_text_id_foreign FOREIGN KEY (type_text_id) REFERENCES odiseo.type_text(id) ON DELETE RESTRICT;


--

--

ALTER TABLE ONLY odiseo.course_assigned_categories
    ADD CONSTRAINT course_assigned_categories_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
