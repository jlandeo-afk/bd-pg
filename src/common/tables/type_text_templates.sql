-- Table: common.type_text_templates
-- Includes constraints and indexes

--

CREATE TABLE common.type_text_templates (
    id smallint NOT NULL,
    name character varying(255) NOT NULL,
    description_text character varying(255),
    description_subquestion character varying(255),
    text_attributes character varying(255) NOT NULL,
    subquestion_attributes character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT type_text_templates_subquestion_attributes_check CHECK (((subquestion_attributes)::text = ANY (ARRAY[('none'::character varying)::text, ('category'::character varying)::text, ('topic'::character varying)::text]))),
    CONSTRAINT type_text_templates_text_attributes_check CHECK (((text_attributes)::text = ANY (ARRAY[('none'::character varying)::text, ('category'::character varying)::text, ('topic'::character varying)::text])))
);


ALTER TABLE common.type_text_templates OWNER TO postgres;

--

--

ALTER TABLE ONLY common.type_text_templates
    ADD CONSTRAINT type_text_templates_pkey PRIMARY KEY (id);


--
