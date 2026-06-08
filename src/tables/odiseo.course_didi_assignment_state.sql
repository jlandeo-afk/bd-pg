-- Table: odiseo.course_didi_assignment_state
-- Includes constraints and indexes

--

CREATE TABLE odiseo.course_didi_assignment_state (
    course_id integer NOT NULL,
    last_assigned_didi_index integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE odiseo.course_didi_assignment_state OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.course_didi_assignment_state
    ADD CONSTRAINT course_didi_assignment_state_pkey PRIMARY KEY (course_id);


--
