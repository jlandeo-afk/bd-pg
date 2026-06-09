-- Table: academic.course
-- Includes constraints and indexes

--

CREATE TABLE academic.course (
    id smallint NOT NULL,
    code character varying(3) NOT NULL,
    name character varying(30) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    area_id bigint,
    fl_pseudo_course boolean DEFAULT false NOT NULL,
    apply_text boolean DEFAULT false NOT NULL,
    alias_nq character varying(255),
    agreement_url character varying(255),
    agreement_file_name character varying(255),
    type_text_template_id smallint,
    show_context_nq boolean DEFAULT true NOT NULL
);


ALTER TABLE academic.course OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.course
    ADD CONSTRAINT odiseo_course_code_unique UNIQUE (code);


--

--

ALTER TABLE ONLY academic.course
    ADD CONSTRAINT course_type_text_template_id_foreign FOREIGN KEY (type_text_template_id) REFERENCES common.type_text_templates(id);


--

--

ALTER TABLE ONLY academic.course
    ADD CONSTRAINT odiseo_course_area_id_foreign FOREIGN KEY (area_id) REFERENCES odiseo.area(id);


--

--

ALTER TABLE ONLY academic.course
    ADD CONSTRAINT odiseo_course_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.course
    ADD CONSTRAINT odiseo_course_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.course
    ADD CONSTRAINT odiseo_course_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
