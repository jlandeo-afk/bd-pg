-- Table: odiseo.parent_question_correlative
-- Includes constraints and indexes

--

CREATE TABLE odiseo.parent_question_correlative (
    id bigint NOT NULL,
    course_id integer NOT NULL,
    correlative integer NOT NULL,
    created_by integer NOT NULL,
    updated_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_by integer,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.parent_question_correlative OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.parent_question_correlative
    ADD CONSTRAINT parent_question_correlative_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.parent_question_correlative
    ADD CONSTRAINT parent_question_correlative_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--
