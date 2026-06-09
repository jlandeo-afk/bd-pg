-- Table: questions.field_diagrammed
-- Includes constraints and indexes

--

CREATE TABLE questions.field_diagrammed (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    name_nq character varying(255)
);


ALTER TABLE questions.field_diagrammed OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.field_diagrammed
    ADD CONSTRAINT field_diagrammed_pkey PRIMARY KEY (id);


--
