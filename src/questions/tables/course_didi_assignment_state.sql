-- Table: academic.course_didi_assignment_state
-- Includes constraints and indexes

--

CREATE TABLE academic.course_didi_assignment_state (
    course_id integer NOT NULL,
    last_assigned_didi_index integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE academic.course_didi_assignment_state OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.course_didi_assignment_state
    ADD CONSTRAINT course_didi_assignment_state_pkey PRIMARY KEY (course_id);


--
