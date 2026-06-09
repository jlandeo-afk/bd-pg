-- Table: common.advanced_settings
-- Includes constraints and indexes

--

CREATE TABLE common.advanced_settings (
    id INTEGER NOT NULL,
    company_id INTEGER NOT NULL,
    similarity_percentage NUMERIC(4,2) NOT NULL,
    days_deadline smallint NOT NULL,
    hour_deadline time(0) without time zone NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    block_assigned_questions smallint DEFAULT '0'::smallint NOT NULL,
    block_assigned_questions_didi smallint DEFAULT '0'::smallint NOT NULL,
    limit_lower_question smallint DEFAULT '1'::smallint NOT NULL,
    limit_upper_question smallint DEFAULT '1'::smallint NOT NULL,
    cut_off_date INTEGER DEFAULT 24 NOT NULL,
    limit_assigned_questions_didi INTEGER DEFAULT 20 NOT NULL,
    limit_months_questions INTEGER DEFAULT 12 NOT NULL,
    fl_include_numbering BOOLEAN DEFAULT true NOT NULL,
    number_years_to_consider_question_repeated smallint DEFAULT '2'::smallint NOT NULL,
    fl_show_cycle_code_in_course_name_in_ballot BOOLEAN DEFAULT false NOT NULL,
    amount_questions_alternatives smallint DEFAULT '3'::smallint,
    limit_questions_to_change smallint DEFAULT '5'::smallint
);


ALTER TABLE common.advanced_settings OWNER TO postgres;

--

--

ALTER TABLE common.advanced_settings
    ADD CONSTRAINT pk_advanced_settings PRIMARY KEY (id);


--

--

ALTER TABLE common.advanced_settings
    ADD CONSTRAINT fk_advanced_settings_company FOREIGN KEY (company_id) REFERENCES organization.companies(id);


--
