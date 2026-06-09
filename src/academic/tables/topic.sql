-- Table: academic.topic
-- Includes constraints and indexes

--

CREATE TABLE academic.topic (
    id smallint NOT NULL,
    code character varying(3) NOT NULL,
    name character varying(100) NOT NULL,
    course_id smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE academic.topic OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.topic
    ADD CONSTRAINT topic_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.topic
    ADD CONSTRAINT odiseo_topic_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY academic.topic
    ADD CONSTRAINT odiseo_topic_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.topic
    ADD CONSTRAINT odiseo_topic_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.topic
    ADD CONSTRAINT odiseo_topic_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
