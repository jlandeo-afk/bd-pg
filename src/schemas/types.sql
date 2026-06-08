-- Custom Types

--

CREATE TYPE odiseo.massive_attribute_result AS (
	code character varying,
	status character varying,
	error text
);


ALTER TYPE odiseo.massive_attribute_result OWNER TO postgres;

--
