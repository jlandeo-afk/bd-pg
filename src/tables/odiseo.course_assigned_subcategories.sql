-- Table: odiseo.course_assigned_subcategories
-- Includes constraints and indexes

--

CREATE TABLE odiseo.course_assigned_subcategories (
    id bigint NOT NULL,
    course_assigned_category_id bigint NOT NULL,
    subcategory_id integer NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.course_assigned_subcategories OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.course_assigned_subcategories
    ADD CONSTRAINT course_assigned_subcategories_pkey PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX unique_active_assigned_subcategory ON odiseo.course_assigned_subcategories USING btree (course_assigned_category_id, subcategory_id) WHERE (deleted_at IS NULL);


--

--

ALTER TABLE ONLY odiseo.course_assigned_subcategories
    ADD CONSTRAINT course_assigned_subcategories_course_assigned_category_id_forei FOREIGN KEY (course_assigned_category_id) REFERENCES odiseo.course_assigned_categories(id);


--

--

ALTER TABLE ONLY odiseo.course_assigned_subcategories
    ADD CONSTRAINT course_assigned_subcategories_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id) ON DELETE RESTRICT;


--

--

ALTER TABLE ONLY odiseo.course_assigned_subcategories
    ADD CONSTRAINT course_assigned_subcategories_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id) ON DELETE RESTRICT;


--

--

ALTER TABLE ONLY odiseo.course_assigned_subcategories
    ADD CONSTRAINT course_assigned_subcategories_subcategory_id_foreign FOREIGN KEY (subcategory_id) REFERENCES odiseo.type_text_subcategories(id) ON DELETE RESTRICT;


--

--

ALTER TABLE ONLY odiseo.course_assigned_subcategories
    ADD CONSTRAINT course_assigned_subcategories_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id) ON DELETE RESTRICT;


--
