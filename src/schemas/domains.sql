-- Domains

--

CREATE DOMAIN odiseo.email_citext AS extensions.citext
	CONSTRAINT email_valid CHECK ((VALUE OPERATOR(extensions.~) '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'::extensions.citext));


ALTER DOMAIN odiseo.email_citext OWNER TO postgres;

--
