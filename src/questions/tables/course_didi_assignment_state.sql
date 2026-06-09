-- Table: academic.course_didi_assignment_state
-- Includes constraints and indexes

--

CREATE TABLE academic.course_didi_assignment_state (
    course_id INTEGER NOT NULL,
    last_assigned_didi_index INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);


ALTER TABLE academic.course_didi_assignment_state OWNER TO postgres;

--

--

ALTER TABLE academic.course_didi_assignment_state
    ADD CONSTRAINT pk_course_didi_assignment_state PRIMARY KEY (course_id);


--
