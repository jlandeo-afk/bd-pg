-- Table: odiseo.advanced_settings
-- Includes constraints and indexes

--

CREATE TABLE odiseo.advanced_settings (
    id integer NOT NULL,
    company_id integer NOT NULL,
    similarity_percentage numeric(4,2) NOT NULL,
    days_deadline smallint NOT NULL,
    hour_deadline time(0) without time zone NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    block_assigned_questions smallint DEFAULT '0'::smallint NOT NULL,
    block_assigned_questions_didi smallint DEFAULT '0'::smallint NOT NULL,
    limit_lower_question smallint DEFAULT '1'::smallint NOT NULL,
    limit_upper_question smallint DEFAULT '1'::smallint NOT NULL,
    cut_off_date integer DEFAULT 24 NOT NULL,
    limit_assigned_questions_didi integer DEFAULT 20 NOT NULL,
    limit_months_questions integer DEFAULT 12 NOT NULL,
    fl_include_numbering boolean DEFAULT true NOT NULL,
    number_years_to_consider_question_repeated smallint DEFAULT '2'::smallint NOT NULL,
    fl_show_cycle_code_in_course_name_in_ballot boolean DEFAULT false NOT NULL,
    amount_questions_alternatives smallint DEFAULT '3'::smallint,
    limit_questions_to_change smallint DEFAULT '5'::smallint
);


ALTER TABLE odiseo.advanced_settings OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.advanced_settings
    ADD CONSTRAINT advanced_settings_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.advanced_settings
    ADD CONSTRAINT odiseo_advanced_settings_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--
