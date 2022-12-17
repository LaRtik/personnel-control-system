--
-- PostgreSQL database dump
--

-- Dumped from database version 15.0
-- Dumped by pg_dump version 15.0

-- Started on 2022-12-17 05:54:39

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 33375)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 3529 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 278 (class 1255 OID 33431)
-- Name: employee_fired(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.employee_fired(IN initiator_id integer, IN affected_id integer, IN reason text)
    LANGUAGE sql
    AS $$
	UPDATE employees
	SET access_level = 0, position_id = null, fire_date = CURRENT_TIMESTAMP, fire_reason = reason, archived = true
	WHERE id = affected_id;
	
	INSERT INTO logs(type, initiator_id, affected_id) VALUES
	(1, initiator_id, affected_id);
$$;


ALTER PROCEDURE public.employee_fired(IN initiator_id integer, IN affected_id integer, IN reason text) OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 33427)
-- Name: employee_hired(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.employee_hired(IN initiator_id integer, IN affected_id integer)
    LANGUAGE sql
    AS $$
	UPDATE employees
	SET access_level = 1
	WHERE id = affected_id;
	
	INSERT INTO logs(type, initiator_id, affected_id) VALUES
	(2, initiator_id, affected_id);
$$;


ALTER PROCEDURE public.employee_hired(IN initiator_id integer, IN affected_id integer) OWNER TO postgres;

--
-- TOC entry 276 (class 1255 OID 33428)
-- Name: employee_promoted(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.employee_promoted(IN initiator_id integer, IN affected_id integer)
    LANGUAGE sql
    AS $$
	UPDATE employees
	SET access_level = access_level + 1
	WHERE id = affected_id;
	
	INSERT INTO logs(type, initiator_id, affected_id) VALUES
	(12, initiator_id, affected_id);
$$;


ALTER PROCEDURE public.employee_promoted(IN initiator_id integer, IN affected_id integer) OWNER TO postgres;

--
-- TOC entry 275 (class 1255 OID 33421)
-- Name: employee_registered(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.employee_registered() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO logs(type, initiator_id) SELECT 3, NEW.id;
		RETURN NEW;
	END;
$$;


ALTER FUNCTION public.employee_registered() OWNER TO postgres;

--
-- TOC entry 290 (class 1255 OID 33440)
-- Name: new_departament(integer, text, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.new_departament(IN initiator_id integer, IN name text, IN head_id integer, IN deputy_head_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF (deputy_head_id = -1) THEN
		INSERT INTO departaments(name, head_id) VALUES
		(name, head_id);
		
		INSERT INTO logs(type, initiator_id, affected_id) VALUES
		(6, initiator_id, null),
		(7, initiator_id, head_id);
	ELSE
		INSERT INTO departaments(name, head_id, deputy_head_id) VALUES
		(name, head_id, deputy_head_id);
		
		INSERT INTO logs(type, initiator_id, affected_id) VALUES
		(6, initiator_id, null),
		(7, initiator_id, head_id),
		(8, initiator_id, deputy_head_id);
	END IF;
END;
$$;


ALTER PROCEDURE public.new_departament(IN initiator_id integer, IN name text, IN head_id integer, IN deputy_head_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 24614)
-- Name: access_levels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.access_levels (
    level integer NOT NULL,
    name text NOT NULL,
    description text,
    salary money NOT NULL,
    CONSTRAINT level_positive CHECK ((level >= 0))
);


ALTER TABLE public.access_levels OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 24613)
-- Name: access_levels_level_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.access_levels_level_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.access_levels_level_seq OWNER TO postgres;

--
-- TOC entry 3530 (class 0 OID 0)
-- Dependencies: 219
-- Name: access_levels_level_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.access_levels_level_seq OWNED BY public.access_levels.level;


--
-- TOC entry 227 (class 1259 OID 25197)
-- Name: access_levels_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.access_levels_permissions (
    access_level integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.access_levels_permissions OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 25215)
-- Name: activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activities (
    name character(50) NOT NULL,
    points integer NOT NULL,
    description text NOT NULL,
    required_access_level integer NOT NULL,
    CONSTRAINT activities_points_check CHECK ((points > 0))
);


ALTER TABLE public.activities OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 25229)
-- Name: activities_tickets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activities_tickets (
    id integer NOT NULL,
    description text,
    owner_id integer NOT NULL,
    tstamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    activity character(50) NOT NULL
);


ALTER TABLE public.activities_tickets OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 25228)
-- Name: activities_tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.activities_tickets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.activities_tickets_id_seq OWNER TO postgres;

--
-- TOC entry 3531 (class 0 OID 0)
-- Dependencies: 229
-- Name: activities_tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.activities_tickets_id_seq OWNED BY public.activities_tickets.id;


--
-- TOC entry 232 (class 1259 OID 25244)
-- Name: departaments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departaments (
    id integer NOT NULL,
    name text NOT NULL,
    head_id integer NOT NULL,
    deputy_head_id integer
);


ALTER TABLE public.departaments OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 25243)
-- Name: departaments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.departaments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.departaments_id_seq OWNER TO postgres;

--
-- TOC entry 3532 (class 0 OID 0)
-- Dependencies: 231
-- Name: departaments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.departaments_id_seq OWNED BY public.departaments.id;


--
-- TOC entry 216 (class 1259 OID 16400)
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    name text NOT NULL,
    surname text NOT NULL,
    date_of_birth date NOT NULL,
    personal_link text NOT NULL,
    phone_number text NOT NULL,
    email character(50) NOT NULL,
    city character(50) NOT NULL,
    additional_info text,
    access_level integer DEFAULT 0,
    position_id integer,
    activity_points numeric DEFAULT 0.00 NOT NULL,
    last_promotion_date date,
    hire_date date NOT NULL,
    fire_date date,
    fire_reason text,
    archived boolean DEFAULT false NOT NULL,
    pass_hash text DEFAULT public.crypt('123'::text, public.gen_salt('bf'::text)) NOT NULL
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16399)
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employees_id_seq OWNER TO postgres;

--
-- TOC entry 3533 (class 0 OID 0)
-- Dependencies: 215
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- TOC entry 233 (class 1259 OID 25266)
-- Name: employees_projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees_projects (
    project_id integer NOT NULL,
    employee_id integer NOT NULL,
    salary money NOT NULL
);


ALTER TABLE public.employees_projects OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 25108)
-- Name: log_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_types (
    type integer NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.log_types OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 25107)
-- Name: log_types_type_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_types_type_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_types_type_seq OWNER TO postgres;

--
-- TOC entry 3534 (class 0 OID 0)
-- Dependencies: 225
-- Name: log_types_type_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_types_type_seq OWNED BY public.log_types.type;


--
-- TOC entry 238 (class 1259 OID 25398)
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs (
    id integer NOT NULL,
    type integer NOT NULL,
    initiator_id integer NOT NULL,
    affected_id integer,
    tstamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.logs OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 25397)
-- Name: logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.logs_id_seq OWNER TO postgres;

--
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 237
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.logs_id_seq OWNED BY public.logs.id;


--
-- TOC entry 224 (class 1259 OID 25099)
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    name character(50) NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 25098)
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.permissions_id_seq OWNER TO postgres;

--
-- TOC entry 3536 (class 0 OID 0)
-- Dependencies: 223
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- TOC entry 222 (class 1259 OID 24623)
-- Name: positions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.positions (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    salary money NOT NULL
);


ALTER TABLE public.positions OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 24622)
-- Name: positions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.positions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.positions_id_seq OWNER TO postgres;

--
-- TOC entry 3537 (class 0 OID 0)
-- Dependencies: 221
-- Name: positions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.positions_id_seq OWNED BY public.positions.id;


--
-- TOC entry 218 (class 1259 OID 24600)
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    name text NOT NULL,
    departament_id integer NOT NULL
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 24599)
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projects_id_seq OWNER TO postgres;

--
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 217
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- TOC entry 234 (class 1259 OID 25308)
-- Name: projects_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects_permissions (
    project_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.projects_permissions OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 25324)
-- Name: tickets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tickets (
    id integer NOT NULL,
    from_id integer NOT NULL,
    to_id integer NOT NULL,
    salary_change money NOT NULL,
    reason text NOT NULL,
    tstamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tickets OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 25323)
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tickets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tickets_id_seq OWNER TO postgres;

--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 235
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tickets_id_seq OWNED BY public.tickets.id;


--
-- TOC entry 3282 (class 2604 OID 24617)
-- Name: access_levels level; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.access_levels ALTER COLUMN level SET DEFAULT nextval('public.access_levels_level_seq'::regclass);


--
-- TOC entry 3286 (class 2604 OID 25232)
-- Name: activities_tickets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities_tickets ALTER COLUMN id SET DEFAULT nextval('public.activities_tickets_id_seq'::regclass);


--
-- TOC entry 3288 (class 2604 OID 25247)
-- Name: departaments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departaments ALTER COLUMN id SET DEFAULT nextval('public.departaments_id_seq'::regclass);


--
-- TOC entry 3276 (class 2604 OID 16403)
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- TOC entry 3285 (class 2604 OID 25111)
-- Name: log_types type; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_types ALTER COLUMN type SET DEFAULT nextval('public.log_types_type_seq'::regclass);


--
-- TOC entry 3291 (class 2604 OID 25401)
-- Name: logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs ALTER COLUMN id SET DEFAULT nextval('public.logs_id_seq'::regclass);


--
-- TOC entry 3284 (class 2604 OID 25102)
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- TOC entry 3283 (class 2604 OID 24626)
-- Name: positions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positions ALTER COLUMN id SET DEFAULT nextval('public.positions_id_seq'::regclass);


--
-- TOC entry 3281 (class 2604 OID 24603)
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- TOC entry 3289 (class 2604 OID 25327)
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets ALTER COLUMN id SET DEFAULT nextval('public.tickets_id_seq'::regclass);


--
-- TOC entry 3505 (class 0 OID 24614)
-- Dependencies: 220
-- Data for Name: access_levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.access_levels (level, name, description, salary) FROM stdin;
0	No level	Base access level, witch is granted just after registration	0,00 ?
1	Trainee	Trainee developer with base permissions	250,00 ?
2	Junior	More expirienced, than trainee	500,00 ?
3	Middle	Can be a deputy in departament	1 500,00 ?
4	Senior	Can be a head of departament	3 000,00 ?
5	Senior leader	Controls several departaments	4 000,00 ?
6	Deputy Manager	Controls the processes in the company. Can employ new Trainees and promote them	6 000,00 ?
7	Manager	Have full control of the company	10 000,00 ?
8	Director	Full control of the organization	15 000,00 ?
\.


--
-- TOC entry 3512 (class 0 OID 25197)
-- Dependencies: 227
-- Data for Name: access_levels_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.access_levels_permissions (access_level, permission_id) FROM stdin;
1	3
2	3
3	1
3	2
3	3
4	1
4	2
4	3
4	8
5	1
5	2
5	3
5	6
5	7
5	8
6	1
6	2
6	3
6	4
6	5
6	6
6	7
6	8
7	1
7	2
7	3
7	4
7	5
7	6
7	7
7	8
8	1
8	2
8	3
8	4
8	5
8	6
8	7
8	8
6	12
7	12
8	12
\.


--
-- TOC entry 3513 (class 0 OID 25215)
-- Dependencies: 228
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activities (name, points, description, required_access_level) FROM stdin;
Hire                                              	100	Hire new person	6
Promote                                           	50	Promote the employee	6
Fire                                              	50	Fire the employee	5
Ticket                                            	30	Ticket the employee	5
Report                                            	10	Report from the employee	1
New project feature                               	15	New feature in the project	3
New company feature                               	150	New feature in the company system	4
New project                                       	100	New project created	4
New departament                                   	200	New departament created	5
Welcome                                           	5	When employee is promoted from 0 to 1 level	0
Promotion                                         	25	When employee is promoted (level 1 and higher)	1
\.


--
-- TOC entry 3515 (class 0 OID 25229)
-- Dependencies: 230
-- Data for Name: activities_tickets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activities_tickets (id, description, owner_id, tstamp, activity) FROM stdin;
1	Hired new person	0	2022-12-02 17:57:53.076217	Hire                                              
2	Hired new person	1	2022-12-02 17:57:53.076217	Hire                                              
3	Hired new person	1	2022-12-02 17:57:53.076217	Hire                                              
4	Hired new person	1	2022-12-02 17:57:53.076217	Hire                                              
5	Hired new person	1	2022-12-02 17:57:53.076217	Hire                                              
6	Hired new person	1	2022-12-02 17:57:53.076217	Hire                                              
7	Hired new person	1	2022-12-02 17:57:53.076217	Hire                                              
8	Hired new person	1	2022-12-02 17:57:53.076217	Hire                                              
9	Hired new person	1	2022-12-02 17:57:53.076217	Hire                                              
10	Hired new person	1	2022-12-02 17:57:53.076217	Hire                                              
11	Hired new person	1	2022-12-02 17:57:53.076217	Hire                                              
12	Personnel Conrtol System	2	2022-12-02 17:57:53.076217	New company feature                               
13	Techinal support web	2	2022-12-02 17:57:53.076217	New project                                       
14	New report from the employee	1	2022-12-02 17:57:53.076217	Report                                            
15	New report from the employee	2	2022-12-02 17:57:53.076217	Report                                            
16	New report from the employee	3	2022-12-02 17:57:53.076217	Report                                            
17	New report from the employee	4	2022-12-02 17:57:53.076217	Report                                            
18	New report from the employee	5	2022-12-02 17:57:53.076217	Report                                            
19	New report from the employee	6	2022-12-02 17:57:53.076217	Report                                            
20	New report from the employee	7	2022-12-02 17:57:53.076217	Report                                            
21	New report from the employee	8	2022-12-02 17:57:53.076217	Report                                            
22	New report from the employee	9	2022-12-02 17:57:53.076217	Report                                            
23	New report from the employee	10	2022-12-02 17:57:53.076217	Report                                            
24	New report from the employee	11	2022-12-02 17:57:53.076217	Report                                            
25	New report from the employee	12	2022-12-02 17:57:53.076217	Report                                            
26	New report from the employee	13	2022-12-02 17:57:53.076217	Report                                            
27	New report from the employee	14	2022-12-02 17:57:53.076217	Report                                            
28	New report from the employee	15	2022-12-02 17:57:53.076217	Report                                            
29	New report from the employee	16	2022-12-02 17:57:53.076217	Report                                            
30	New report from the employee	17	2022-12-02 17:57:53.076217	Report                                            
\.


--
-- TOC entry 3517 (class 0 OID 25244)
-- Dependencies: 232
-- Data for Name: departaments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departaments (id, name, head_id, deputy_head_id) FROM stdin;
1	General departament	0	1
2	Techical support departament	2	8
3	Government projects departament	3	4
5	Test	27	\N
6	Test dep2	6	5
7	Test dep3	7	9
\.


--
-- TOC entry 3501 (class 0 OID 16400)
-- Dependencies: 216
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (id, name, surname, date_of_birth, personal_link, phone_number, email, city, additional_info, access_level, position_id, activity_points, last_promotion_date, hire_date, fire_date, fire_reason, archived, pass_hash) FROM stdin;
1	Alex	Filatov	2001-09-11	mylink.com/afilatov	78989899888	alex_filatov@mycompany.com                        	Los Angeles                                       	\N	7	1	0.00	2020-04-01	2020-04-01	\N	\N	f	$2a$06$Si5zmQ8ECwk40B1COsZFQOcYwel9nZWYXO0mQURDUQ.y7q5UhF.O6
2	Martin	DeSanta	2002-07-03	mylink.com/mdesanta	78989899889	martin_desanta@mycompany.com                      	Sacramento                                        	\N	5	1	0.00	2022-01-06	2020-09-08	\N	\N	f	$2a$06$RFjrrC.OjM7DqLQETzbXF.vRPF31K0zY3zX4U1wLBuqAODThcnDl6
3	Bryan	Stoks	2003-01-11	mylink.com/bstoks	78989899810	bryan_stoks@mycompany.com                         	San Francisco                                     	\N	5	1	0.00	2022-01-06	2021-01-08	\N	\N	f	$2a$06$sRj7znZtbciABEuGLdz12e5bj2vNBZWnKrWYnf0PDoUY9OsxnJi5G
4	Jimmy	Bonhart	2001-01-01	mylink.com/jbonhart	78989837489	jimmy_bonhart@mycompany.com                       	Los Angeles                                       	\N	4	7	0.00	2022-01-01	2021-01-01	\N	\N	f	$2a$06$OiItEk.xW1kRE4iXGzraYOMTN2OQV4nWZ7xmaiAjfgvIGfPnfofQu
5	Alex	Liquid	2001-01-01	mylink.com/aliquid	78989834489	alex_liquid@mycompany.com                         	Los Angeles                                       	\N	4	6	0.00	2022-01-01	2021-01-01	\N	\N	f	$2a$06$0Z5.xA8Knh.7WuJtCRxTweTTeHnLeTQPaoOD5HUHkFjHcVxkMH2dO
6	Avangard	Wallace	2001-01-01	mylink.com/awallace	78987837489	avangard_wallace@mycompany.com                    	Los Angeles                                       	\N	4	5	0.00	2022-01-01	2021-01-01	\N	\N	f	$2a$06$JFmcmfyVA3C6opoyU/8Gy.YlhguilTEHHcXkT3ePGYK8EkLrexFKq
7	Maksim	Wallace	2001-01-01	mylink.com/mwallace	88989837489	maksim_wallace@mycompany.com                      	Kiev                                              	\N	4	1	0.00	2022-01-01	2021-01-01	\N	\N	f	$2a$06$FrCShWILX83R8reD4Oi3sewZXftDZ/sSO1eNTer.UswdZtJFqJ9a2
8	Sebastian	Devis	2001-01-01	mylink.com/sdevis	78779837489	sebastian_devis@mycompany.com                     	Moscow                                            	\N	4	4	0.00	2022-01-01	2021-01-01	\N	\N	f	$2a$06$mn.rPwgUJDDQJGXj3AjH8OHAoo6PsuyOYYjMufaFfJm8zxaVcatTa
9	Dorian	Rouse	2001-01-01	mylink.com/drouse	78989837779	dorian_rouse@mycompany.com                        	Moscow                                            	\N	3	3	0.00	2022-01-01	2021-01-01	\N	\N	f	$2a$06$5J./9rmxjUHfSEdYQiSOiuvOZXOvzycSLbg5IP03iEM2/QxJZPf8.
10	Logan	Cornello	2001-01-01	mylink.com/lcornello	78989837777	logan_cornello@mycompany.com                      	Kiev                                              	\N	3	2	0.00	2022-01-01	2021-01-01	\N	\N	f	$2a$06$6ZoDZ2TQ670pMtxrFRdENeu0SwuB9mTOYsvhmmO.e3Hxr1niKu/rG
11	Arhont	Sherwood	2001-01-01	mylink.com/asherwood	77789837779	arhont_sherwood@mycompany.com                     	Los Angeles                                       	\N	3	2	0.00	2022-01-01	2021-01-01	\N	\N	f	$2a$06$q6/U4WqBzxY/XYaj5T0F9ue.MjQheLpbLGT4VSepoqeoUw5WjqxjG
12	Martin	Hennessy	2001-01-01	mylink.com/mhennessy	78989834479	martin_hennessy@mycompany.com                     	Moscow                                            	\N	2	7	0.00	2022-01-01	2021-12-01	\N	\N	f	$2a$06$98vmwyePznEPLj27TxwS7ugm8yecZGAdpHMiN/3rS7Lv9MRUrHtkK
13	Samuel	Morrisson	2001-01-01	mylink.com/smorrisson	78984434479	samuel_morrisson@mycompany.com                    	Moscow                                            	\N	2	8	0.00	2022-01-01	2021-12-01	\N	\N	f	$2a$06$bHxwmnF/Itsi.jYVbG9mgeAvw0Jz6xDnFbpfDu93lkC.CtSPsYVi6
14	Cody	Biden	2001-01-01	mylink.com/cbiden	78989834444	cody_biden@mycompany.com                          	Los Angeles                                       	\N	2	5	0.00	2022-01-01	2021-12-01	\N	\N	f	$2a$06$HKD.cbWSnXsZd8k37l8HROUMoL7tHPcvAvmf38gXK.i7dAAPDqdR2
15	William	Broun	2001-01-01	mylink.com/wbroun	78944834479	william_broun@mycompany.com                       	Moscow                                            	\N	1	4	0.00	2022-01-01	2022-07-01	\N	\N	f	$2a$06$MRMVm1xDK7j.JlzeUokgz.6BE5o7PZ.x6fxna.eybw4ILWuc8WD5i
16	Vissarion	Chicago	2001-01-01	mylink.com/vchicago	78944434479	vissarion_chicago@mycompany.com                   	Moscow                                            	\N	1	4	0.00	2022-01-01	2022-07-01	\N	\N	f	$2a$06$Eh4HG2kH76YDs6FVxoImpetcN1ula00w.qJnsdcXHxWZgxtIz.Z0C
17	Tea	Chicago	2001-01-01	mylink.com/tchicago	74444834479	tea_chicago@mycompany.com                         	Moscow                                            	\N	1	8	0.00	2022-01-01	2022-07-01	\N	\N	f	$2a$06$MCGFHFYLjDEoBxrfVLN3uugkHo3/n5nlgEFlXILenrNnOmQLTIA6u
0	Sam	Mason	1999-01-01	mylink.com/smason	78789798789	sam_mason@mycompany.com                           	San Francisco                                     	\N	8	1	0.00	2019-04-01	2019-04-01	\N	\N	f	$2a$06$5Wx2NhAIPgvijpYoR/I6LOdIzxXCqlvJRsLdEXqahpJHAZSfoq0WK
27	Ilya	Lazuk	2002-07-03	https://vk.com/lrtk3	+375296465380	i.lazuk@bk.ru                                     	Minsk                                             	 	5	\N	0.00	\N	2022-12-15	\N	\N	f	$2a$06$Doj5jOIKVk//7CV5X.d/FexAsV8uBxAEqq2rIshtPNX/mty/dNTX2
28	Vladislav	Pliska	1998-01-01	https://vk.com/oladushek	+375291337228	pliska_vladislav@gmail.com                        	Minsk                                             	 	0	\N	0.00	\N	2022-12-15	\N	\N	f	$2a$06$ds6hFa.uj7dn52A.NyraH.t.bln65WohtBdeEIebIZUL4w.9O2DOO
29	Bad	Employee	2003-03-03	https://vk.com/bad_employee	+37529111111	bad_employee@gmail.com                            	Minsk                                             	 Such a bad employee	0	\N	0.00	\N	2022-12-17	2022-12-17	bad employee	t	$2a$06$SHVaVHt8424IRZ6QPVtwa.4v2jACi5NSNqbwOXWe0XvyHNRXaEx5K
\.


--
-- TOC entry 3518 (class 0 OID 25266)
-- Dependencies: 233
-- Data for Name: employees_projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees_projects (project_id, employee_id, salary) FROM stdin;
1	12	100,00 ?
1	13	100,00 ?
1	14	100,00 ?
1	15	100,00 ?
1	16	100,00 ?
1	17	100,00 ?
3	4	300,00 ?
3	5	300,00 ?
3	6	300,00 ?
3	7	300,00 ?
3	8	300,00 ?
2	12	200,00 ?
2	13	200,00 ?
2	14	200,00 ?
\.


--
-- TOC entry 3511 (class 0 OID 25108)
-- Dependencies: 226
-- Data for Name: log_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_types (type, description) FROM stdin;
1	Fire employee
2	Hire employee
4	Ticket to employee
5	New project to departament
6	New departament
7	New head of departament
8	New deputy head of departament
9	New activity ticket
10	Add new activity
11	New permission added
12	Promote the employee
3	Registered
\.


--
-- TOC entry 3523 (class 0 OID 25398)
-- Dependencies: 238
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logs (id, type, initiator_id, affected_id, tstamp) FROM stdin;
1	3	0	\N	2022-12-03 14:12:07.351352
2	3	1	\N	2022-12-03 14:12:07.351352
3	2	0	1	2022-12-03 14:12:07.351352
4	3	2	\N	2022-12-03 14:16:09.452831
5	3	3	\N	2022-12-03 14:16:09.452831
6	3	4	\N	2022-12-03 14:16:09.452831
7	3	5	\N	2022-12-03 14:16:09.452831
8	3	6	\N	2022-12-03 14:16:09.452831
9	3	7	\N	2022-12-03 14:16:09.452831
10	3	8	\N	2022-12-03 14:16:09.452831
11	3	9	\N	2022-12-03 14:16:09.452831
12	3	10	\N	2022-12-03 14:16:09.452831
13	3	11	\N	2022-12-03 14:16:09.452831
14	3	12	\N	2022-12-03 14:16:09.452831
15	3	13	\N	2022-12-03 14:16:09.452831
16	3	14	\N	2022-12-03 14:16:09.452831
17	3	15	\N	2022-12-03 14:16:09.452831
18	3	16	\N	2022-12-03 14:16:09.452831
19	3	17	\N	2022-12-03 14:16:09.452831
20	2	1	2	2022-12-03 14:17:17.704636
21	2	1	3	2022-12-03 14:17:17.704636
22	2	1	4	2022-12-03 14:17:17.704636
23	2	1	5	2022-12-03 14:17:17.704636
24	2	1	6	2022-12-03 14:17:17.704636
25	2	1	7	2022-12-03 14:17:17.704636
26	2	1	8	2022-12-03 14:17:17.704636
27	2	1	9	2022-12-03 14:17:17.704636
28	2	1	10	2022-12-03 14:17:17.704636
29	2	1	11	2022-12-03 14:17:17.704636
30	2	1	12	2022-12-03 14:17:17.704636
31	2	1	13	2022-12-03 14:17:17.704636
32	2	1	14	2022-12-03 14:17:17.704636
33	2	1	15	2022-12-03 14:17:17.704636
34	2	1	16	2022-12-03 14:17:17.704636
35	2	1	17	2022-12-03 14:17:17.704636
36	12	1	15	2022-12-03 14:23:27.789204
37	12	1	16	2022-12-03 14:23:27.789204
38	12	1	17	2022-12-03 14:23:27.789204
39	12	1	12	2022-12-03 14:23:33.851281
40	12	1	13	2022-12-03 14:23:33.851281
41	12	1	14	2022-12-03 14:23:33.851281
42	12	1	12	2022-12-03 14:23:34.617334
43	12	1	13	2022-12-03 14:23:34.617334
44	12	1	14	2022-12-03 14:23:34.617334
45	12	1	9	2022-12-03 14:23:40.275006
46	12	1	10	2022-12-03 14:23:40.275006
47	12	1	11	2022-12-03 14:23:40.275006
48	12	1	9	2022-12-03 14:23:40.886217
49	12	1	10	2022-12-03 14:23:40.886217
50	12	1	11	2022-12-03 14:23:40.886217
51	12	1	9	2022-12-03 14:23:41.609789
52	12	1	10	2022-12-03 14:23:41.609789
53	12	1	11	2022-12-03 14:23:41.609789
54	12	1	4	2022-12-03 14:23:45.864022
55	12	1	5	2022-12-03 14:23:45.864022
56	12	1	6	2022-12-03 14:23:45.864022
57	12	1	7	2022-12-03 14:23:45.864022
58	12	1	8	2022-12-03 14:23:45.864022
59	12	1	4	2022-12-03 14:23:46.640944
60	12	1	5	2022-12-03 14:23:46.640944
61	12	1	6	2022-12-03 14:23:46.640944
62	12	1	7	2022-12-03 14:23:46.640944
63	12	1	8	2022-12-03 14:23:46.640944
64	12	1	4	2022-12-03 14:23:47.466621
65	12	1	5	2022-12-03 14:23:47.466621
66	12	1	6	2022-12-03 14:23:47.466621
67	12	1	7	2022-12-03 14:23:47.466621
68	12	1	8	2022-12-03 14:23:47.466621
69	12	1	4	2022-12-03 14:23:47.968856
70	12	1	5	2022-12-03 14:23:47.968856
71	12	1	6	2022-12-03 14:23:47.968856
72	12	1	7	2022-12-03 14:23:47.968856
73	12	1	8	2022-12-03 14:23:47.968856
74	12	1	2	2022-12-03 14:24:10.661227
75	12	1	3	2022-12-03 14:24:10.661227
76	12	1	2	2022-12-03 14:24:11.251452
77	12	1	3	2022-12-03 14:24:11.251452
78	12	1	2	2022-12-03 14:24:11.882013
79	12	1	3	2022-12-03 14:24:11.882013
80	12	1	2	2022-12-03 14:24:12.442679
81	12	1	3	2022-12-03 14:24:12.442679
82	12	1	2	2022-12-03 14:24:13.013658
83	12	1	3	2022-12-03 14:24:13.013658
85	3	27	\N	2022-12-15 15:18:16.679519
86	3	28	\N	2022-12-15 15:22:09.945991
174	2	1	27	2022-12-17 02:45:32.110695
177	12	1	27	2022-12-17 02:48:45.354216
179	12	1	27	2022-12-17 02:51:31.418862
180	12	1	27	2022-12-17 02:51:34.036372
181	12	1	27	2022-12-17 02:51:48.713752
183	2	1	29	2022-12-17 03:40:26.892873
185	6	1	\N	2022-12-17 05:37:39.465736
186	7	1	27	2022-12-17 05:37:39.465736
190	6	1	\N	2022-12-17 05:46:12.973433
191	7	1	7	2022-12-17 05:46:12.973433
192	8	1	9	2022-12-17 05:46:12.973433
173	2	1	27	2022-12-17 01:58:36.578765
178	12	1	27	2022-12-17 02:49:13.354957
182	3	29	\N	2022-12-17 03:32:44.847042
184	1	1	29	2022-12-17 03:46:46.73407
187	6	1	\N	2022-12-17 05:41:52.618436
188	7	1	6	2022-12-17 05:41:52.618436
189	8	1	5	2022-12-17 05:41:52.618436
\.


--
-- TOC entry 3509 (class 0 OID 25099)
-- Dependencies: 224
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permissions (id, name, description) FROM stdin;
1	Git push                                          	Can push changes to the git
2	Code review                                       	Can participate in code reviews
3	Chat                                              	Can use project chat
4	Promote                                           	Can promote other employees
5	Hire                                              	Can promote other persons
6	Fire                                              	Can fire other employees
7	Invite to the departament                         	Can add other employees to the departament
8	New project                                       	Can add new project
9	Government database                               	Access for government database
10	Employees logs                                    	Access for full employees logs
11	Users database                                    	Access for users database
12	New departament                                   	Can create departaments
\.


--
-- TOC entry 3507 (class 0 OID 24623)
-- Dependencies: 222
-- Data for Name: positions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.positions (id, name, description, salary) FROM stdin;
1	Back-end developer	Develops server-side logic	520,00 ?
2	Front-end develeoper	Develops UI logic	400,00 ?
3	DevOps Engineer	From developers to production	550,00 ?
4	Data Engineer	Process raw data	510,00 ?
5	Machine-Learning Engineer	Trains neural networks with data	600,00 ?
6	Mobile developer	Creates Anroid / iOS application	500,00 ?
7	Secity Engineer	Creates infrastructure for security development	550,00 ?
8	UI Artist	Designs the UI	450,00 ?
\.


--
-- TOC entry 3503 (class 0 OID 24600)
-- Dependencies: 218
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, name, departament_id) FROM stdin;
1	HR web-platform	1
2	User support web-platform	2
3	Government tax web-platform	3
\.


--
-- TOC entry 3519 (class 0 OID 25308)
-- Dependencies: 234
-- Data for Name: projects_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects_permissions (project_id, permission_id) FROM stdin;
1	4
1	5
1	6
1	7
1	10
2	11
3	9
\.


--
-- TOC entry 3521 (class 0 OID 25324)
-- Dependencies: 236
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tickets (id, from_id, to_id, salary_change, reason, tstamp) FROM stdin;
1	0	1	-30,00 ?	Late with the report	2022-12-02 18:00:58.375038
2	1	2	30,00 ?	New system implemented faster than expected	2022-12-02 18:00:58.375038
3	1	3	15,00 ?	Help with report checking	2022-12-02 18:00:58.375038
\.


--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 219
-- Name: access_levels_level_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.access_levels_level_seq', 1, false);


--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 229
-- Name: activities_tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.activities_tickets_id_seq', 30, true);


--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 231
-- Name: departaments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.departaments_id_seq', 7, true);


--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 215
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employees_id_seq', 29, true);


--
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 225
-- Name: log_types_type_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_types_type_seq', 12, true);


--
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 237
-- Name: logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.logs_id_seq', 192, true);


--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 223
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.permissions_id_seq', 12, true);


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 221
-- Name: positions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.positions_id_seq', 8, true);


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 217
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.projects_id_seq', 3, true);


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 235
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tickets_id_seq', 3, true);


--
-- TOC entry 3313 (class 2606 OID 25201)
-- Name: access_levels_permissions access_levels_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.access_levels_permissions
    ADD CONSTRAINT access_levels_permissions_pkey PRIMARY KEY (access_level, permission_id);


--
-- TOC entry 3303 (class 2606 OID 24621)
-- Name: access_levels access_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.access_levels
    ADD CONSTRAINT access_levels_pkey PRIMARY KEY (level);


--
-- TOC entry 3316 (class 2606 OID 25222)
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (name);


--
-- TOC entry 3319 (class 2606 OID 25237)
-- Name: activities_tickets activities_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities_tickets
    ADD CONSTRAINT activities_tickets_pkey PRIMARY KEY (id);


--
-- TOC entry 3321 (class 2606 OID 25255)
-- Name: departaments departaments_deputy_head_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departaments
    ADD CONSTRAINT departaments_deputy_head_id_key UNIQUE (deputy_head_id);


--
-- TOC entry 3324 (class 2606 OID 25253)
-- Name: departaments departaments_head_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departaments
    ADD CONSTRAINT departaments_head_id_key UNIQUE (head_id);


--
-- TOC entry 3326 (class 2606 OID 25251)
-- Name: departaments departaments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departaments
    ADD CONSTRAINT departaments_pkey PRIMARY KEY (id);


--
-- TOC entry 3297 (class 2606 OID 16409)
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- TOC entry 3329 (class 2606 OID 25270)
-- Name: employees_projects employees_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees_projects
    ADD CONSTRAINT employees_projects_pkey PRIMARY KEY (project_id, employee_id);


--
-- TOC entry 3309 (class 2606 OID 25115)
-- Name: log_types log_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_types
    ADD CONSTRAINT log_types_pkey PRIMARY KEY (type);


--
-- TOC entry 3337 (class 2606 OID 25404)
-- Name: logs logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- TOC entry 3307 (class 2606 OID 25106)
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 3305 (class 2606 OID 24630)
-- Name: positions positions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (id);


--
-- TOC entry 3331 (class 2606 OID 25312)
-- Name: projects_permissions projects_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects_permissions
    ADD CONSTRAINT projects_permissions_pkey PRIMARY KEY (project_id, permission_id);


--
-- TOC entry 3300 (class 2606 OID 24607)
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- TOC entry 3334 (class 2606 OID 25332)
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- TOC entry 3301 (class 1259 OID 25359)
-- Name: access_levels_level_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX access_levels_level_index ON public.access_levels USING btree (level);


--
-- TOC entry 3311 (class 1259 OID 25360)
-- Name: access_levels_permissions_access_level_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX access_levels_permissions_access_level_index ON public.access_levels_permissions USING btree (access_level);


--
-- TOC entry 3314 (class 1259 OID 25361)
-- Name: activities_name_required_access_level_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX activities_name_required_access_level_index ON public.activities USING btree (name, required_access_level);


--
-- TOC entry 3317 (class 1259 OID 25362)
-- Name: activities_tickets_owner_id_activity_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX activities_tickets_owner_id_activity_index ON public.activities_tickets USING btree (owner_id, activity);


--
-- TOC entry 3322 (class 1259 OID 25363)
-- Name: departaments_head_id_deputy_head_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX departaments_head_id_deputy_head_id_index ON public.departaments USING btree (head_id, deputy_head_id);


--
-- TOC entry 3295 (class 1259 OID 25370)
-- Name: employees_id_access_level_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX employees_id_access_level_index ON public.employees USING btree (id, access_level);


--
-- TOC entry 3327 (class 1259 OID 25365)
-- Name: employees_projects_employee_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX employees_projects_employee_id_index ON public.employees_projects USING btree (employee_id);


--
-- TOC entry 3310 (class 1259 OID 25366)
-- Name: log_types_type_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX log_types_type_index ON public.log_types USING btree (type);


--
-- TOC entry 3298 (class 1259 OID 25367)
-- Name: projects_departament_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX projects_departament_id_index ON public.projects USING btree (departament_id);


--
-- TOC entry 3332 (class 1259 OID 25368)
-- Name: projects_permissions_project_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX projects_permissions_project_id_index ON public.projects_permissions USING btree (project_id);


--
-- TOC entry 3335 (class 1259 OID 25369)
-- Name: tickets_to_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tickets_to_id_index ON public.tickets USING btree (to_id);


--
-- TOC entry 3357 (class 2620 OID 33422)
-- Name: employees employee_registered; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER employee_registered AFTER INSERT ON public.employees FOR EACH ROW EXECUTE FUNCTION public.employee_registered();


--
-- TOC entry 3341 (class 2606 OID 25202)
-- Name: access_levels_permissions access_levels_permissions_access_level_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.access_levels_permissions
    ADD CONSTRAINT access_levels_permissions_access_level_fkey FOREIGN KEY (access_level) REFERENCES public.access_levels(level) ON DELETE CASCADE;


--
-- TOC entry 3342 (class 2606 OID 25207)
-- Name: access_levels_permissions access_levels_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.access_levels_permissions
    ADD CONSTRAINT access_levels_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- TOC entry 3343 (class 2606 OID 25223)
-- Name: activities activities_required_access_level_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_required_access_level_fkey FOREIGN KEY (required_access_level) REFERENCES public.access_levels(level) ON DELETE RESTRICT;


--
-- TOC entry 3344 (class 2606 OID 25354)
-- Name: activities_tickets activities_tickets_activity_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities_tickets
    ADD CONSTRAINT activities_tickets_activity_fkey FOREIGN KEY (activity) REFERENCES public.activities(name) ON DELETE CASCADE;


--
-- TOC entry 3345 (class 2606 OID 25238)
-- Name: activities_tickets activities_tickets_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities_tickets
    ADD CONSTRAINT activities_tickets_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- TOC entry 3346 (class 2606 OID 25261)
-- Name: departaments departaments_deputy_head_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departaments
    ADD CONSTRAINT departaments_deputy_head_id_fkey FOREIGN KEY (deputy_head_id) REFERENCES public.employees(id) ON DELETE RESTRICT;


--
-- TOC entry 3347 (class 2606 OID 25256)
-- Name: departaments departaments_head_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departaments
    ADD CONSTRAINT departaments_head_id_fkey FOREIGN KEY (head_id) REFERENCES public.employees(id) ON DELETE RESTRICT;


--
-- TOC entry 3348 (class 2606 OID 25276)
-- Name: employees_projects employees_projects_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees_projects
    ADD CONSTRAINT employees_projects_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- TOC entry 3349 (class 2606 OID 25271)
-- Name: employees_projects employees_projects_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees_projects
    ADD CONSTRAINT employees_projects_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- TOC entry 3338 (class 2606 OID 25343)
-- Name: employees fk_employees_access_levels; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT fk_employees_access_levels FOREIGN KEY (access_level) REFERENCES public.access_levels(level) ON DELETE SET DEFAULT (access_level);


--
-- TOC entry 3339 (class 2606 OID 25348)
-- Name: employees fk_employees_positions; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT fk_employees_positions FOREIGN KEY (position_id) REFERENCES public.positions(id) ON DELETE SET NULL (position_id);


--
-- TOC entry 3354 (class 2606 OID 25415)
-- Name: logs logs_affected_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_affected_id_fkey FOREIGN KEY (affected_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- TOC entry 3355 (class 2606 OID 25410)
-- Name: logs logs_initiator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_initiator_id_fkey FOREIGN KEY (initiator_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- TOC entry 3356 (class 2606 OID 25405)
-- Name: logs logs_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_type_fkey FOREIGN KEY (type) REFERENCES public.log_types(type) ON DELETE SET DEFAULT;


--
-- TOC entry 3340 (class 2606 OID 25303)
-- Name: projects projects_departament_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_departament_id_fk FOREIGN KEY (departament_id) REFERENCES public.departaments(id) ON DELETE RESTRICT;


--
-- TOC entry 3350 (class 2606 OID 25318)
-- Name: projects_permissions projects_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects_permissions
    ADD CONSTRAINT projects_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- TOC entry 3351 (class 2606 OID 25313)
-- Name: projects_permissions projects_permissions_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects_permissions
    ADD CONSTRAINT projects_permissions_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- TOC entry 3352 (class 2606 OID 25333)
-- Name: tickets tickets_from_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_from_id_fkey FOREIGN KEY (from_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- TOC entry 3353 (class 2606 OID 25338)
-- Name: tickets tickets_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_to_id_fkey FOREIGN KEY (to_id) REFERENCES public.employees(id) ON DELETE CASCADE;


-- Completed on 2022-12-17 05:54:41

--
-- PostgreSQL database dump complete
--

