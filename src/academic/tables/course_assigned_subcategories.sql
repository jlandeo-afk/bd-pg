-- Table: academic.course_assigned_subcategories
-- Includes constraints and indexes

--

CREATE TABLE academic.course_assigned_subcategories (
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


ALTER TABLE academic.course_assigned_subcategories OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.course_assigned_subcategories
    ADD CONSTRAINT course_assigned_subcategories_pkey PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX unique_active_assigned_subcategory ON academic.course_assigned_subcategories USING btree (course_assigned_category_id, subcategory_id) WHERE (deleted_at IS NULL);


--

--

ALTER TABLE ONLY academic.course_assigned_subcategories
    ADD CONSTRAINT course_assigned_subcategories_course_assigned_category_id_forei FOREIGN KEY (course_assigned_category_id) REFERENCES academic.course_assigned_categories(id);


--

--

ALTER TABLE ONLY academic.course_assigned_subcategories
    ADD CONSTRAINT course_assigned_subcategories_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE RESTRICT;


--

--

ALTER TABLE ONLY academic.course_assigned_subcategories
    ADD CONSTRAINT course_assigned_subcategories_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id) ON DELETE RESTRICT;


--

--

ALTER TABLE ONLY academic.course_assigned_subcategories
    ADD CONSTRAINT course_assigned_subcategories_subcategory_id_foreign FOREIGN KEY (subcategory_id) REFERENCES common.type_text_subcategories(id) ON DELETE RESTRICT;


--

--

ALTER TABLE ONLY academic.course_assigned_subcategories
    ADD CONSTRAINT course_assigned_subcategories_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE RESTRICT;


--
