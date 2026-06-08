-- Table: odiseo.question_correlative
-- Includes constraints and indexes

--

CREATE TABLE odiseo.question_correlative (
    id bigint NOT NULL,
    course_id integer NOT NULL,
    correlative integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    apply_text boolean DEFAULT false NOT NULL
);


ALTER TABLE odiseo.question_correlative OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.question_correlative
    ADD CONSTRAINT question_correlative_pkey PRIMARY KEY (id);


--
