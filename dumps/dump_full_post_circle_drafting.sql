
--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Drop databases
--

DROP DATABASE omscore_dev;




--
-- Drop roles
--

DROP ROLE postgres;


--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md53175bce1d3201d16594cebf9d7eb3f9d';






--
-- Database creation
--

CREATE DATABASE omscore_dev WITH TEMPLATE = template0 OWNER = postgres;
REVOKE CONNECT,TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE template1 TO PUBLIC;


\connect omscore_dev

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: bodies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE bodies (
    id bigint NOT NULL,
    name character varying(255),
    email character varying(255),
    phone character varying(255),
    address character varying(255),
    description text,
    legacy_key character varying(255),
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE bodies OWNER TO postgres;

--
-- Name: bodies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE bodies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bodies_id_seq OWNER TO postgres;

--
-- Name: bodies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE bodies_id_seq OWNED BY bodies.id;


--
-- Name: body_memberships; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE body_memberships (
    id bigint NOT NULL,
    comment text,
    body_id bigint,
    member_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE body_memberships OWNER TO postgres;

--
-- Name: body_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE body_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE body_memberships_id_seq OWNER TO postgres;

--
-- Name: body_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE body_memberships_id_seq OWNED BY body_memberships.id;


--
-- Name: campaigns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE campaigns (
    id bigint NOT NULL,
    name character varying(255),
    url character varying(255) NOT NULL,
    active boolean DEFAULT false NOT NULL,
    description_short character varying(400),
    description_long text,
    activate_user boolean DEFAULT false NOT NULL,
    autojoin_body_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE campaigns OWNER TO postgres;

--
-- Name: campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE campaigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE campaigns_id_seq OWNER TO postgres;

--
-- Name: campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE campaigns_id_seq OWNED BY campaigns.id;


--
-- Name: circle_memberships; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE circle_memberships (
    id bigint NOT NULL,
    circle_admin boolean DEFAULT false NOT NULL,
    "position" character varying(255),
    circle_id bigint,
    member_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE circle_memberships OWNER TO postgres;

--
-- Name: circle_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE circle_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE circle_memberships_id_seq OWNER TO postgres;

--
-- Name: circle_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE circle_memberships_id_seq OWNED BY circle_memberships.id;


--
-- Name: circle_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE circle_permissions (
    id bigint NOT NULL,
    circle_id bigint,
    permission_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE circle_permissions OWNER TO postgres;

--
-- Name: circle_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE circle_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE circle_permissions_id_seq OWNER TO postgres;

--
-- Name: circle_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE circle_permissions_id_seq OWNED BY circle_permissions.id;


--
-- Name: circles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE circles (
    id bigint NOT NULL,
    name character varying(255),
    description text,
    joinable boolean DEFAULT false NOT NULL,
    body_id bigint,
    parent_circle_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE circles OWNER TO postgres;

--
-- Name: circles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE circles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE circles_id_seq OWNER TO postgres;

--
-- Name: circles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE circles_id_seq OWNED BY circles.id;


--
-- Name: join_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE join_requests (
    id bigint NOT NULL,
    motivation text,
    approved boolean DEFAULT false NOT NULL,
    member_id bigint,
    body_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE join_requests OWNER TO postgres;

--
-- Name: join_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE join_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE join_requests_id_seq OWNER TO postgres;

--
-- Name: join_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE join_requests_id_seq OWNED BY join_requests.id;


--
-- Name: mail_confirmations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE mail_confirmations (
    id bigint NOT NULL,
    url character varying(255),
    submission_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE mail_confirmations OWNER TO postgres;

--
-- Name: mail_confirmations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE mail_confirmations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mail_confirmations_id_seq OWNER TO postgres;

--
-- Name: mail_confirmations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE mail_confirmations_id_seq OWNED BY mail_confirmations.id;


--
-- Name: members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE members (
    id bigint NOT NULL,
    user_id bigint,
    first_name character varying(255),
    last_name character varying(255),
    date_of_birth date,
    gender character varying(255),
    phone character varying(255),
    seo_url character varying(255),
    address character varying(255),
    about_me text,
    primary_body_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE members OWNER TO postgres;

--
-- Name: members_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE members_id_seq OWNER TO postgres;

--
-- Name: members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE members_id_seq OWNED BY members.id;


--
-- Name: password_resets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE password_resets (
    id bigint NOT NULL,
    url character varying(255),
    user_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE password_resets OWNER TO postgres;

--
-- Name: password_resets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE password_resets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE password_resets_id_seq OWNER TO postgres;

--
-- Name: password_resets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE password_resets_id_seq OWNED BY password_resets.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE permissions (
    id bigint NOT NULL,
    scope character varying(255),
    action character varying(255),
    object character varying(255),
    description text,
    always_assigned boolean DEFAULT false NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE permissions OWNER TO postgres;

--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE permissions_id_seq OWNER TO postgres;

--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE permissions_id_seq OWNED BY permissions.id;


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE refresh_tokens (
    id bigint NOT NULL,
    token text NOT NULL,
    device character varying(255),
    user_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE refresh_tokens OWNER TO postgres;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE refresh_tokens_id_seq OWNER TO postgres;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE refresh_tokens_id_seq OWNED BY refresh_tokens.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp without time zone
);


ALTER TABLE schema_migrations OWNER TO postgres;

--
-- Name: submissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE submissions (
    id bigint NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    motivation text,
    mail_confirmed boolean DEFAULT false NOT NULL,
    user_id bigint,
    campaign_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE submissions OWNER TO postgres;

--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE submissions_id_seq OWNER TO postgres;

--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE submissions_id_seq OWNED BY submissions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255),
    active boolean DEFAULT false NOT NULL,
    superadmin boolean DEFAULT false NOT NULL,
    member_id integer,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: bodies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY bodies ALTER COLUMN id SET DEFAULT nextval('bodies_id_seq'::regclass);


--
-- Name: body_memberships id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY body_memberships ALTER COLUMN id SET DEFAULT nextval('body_memberships_id_seq'::regclass);


--
-- Name: campaigns id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaigns ALTER COLUMN id SET DEFAULT nextval('campaigns_id_seq'::regclass);


--
-- Name: circle_memberships id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY circle_memberships ALTER COLUMN id SET DEFAULT nextval('circle_memberships_id_seq'::regclass);


--
-- Name: circle_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY circle_permissions ALTER COLUMN id SET DEFAULT nextval('circle_permissions_id_seq'::regclass);


--
-- Name: circles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY circles ALTER COLUMN id SET DEFAULT nextval('circles_id_seq'::regclass);


--
-- Name: join_requests id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY join_requests ALTER COLUMN id SET DEFAULT nextval('join_requests_id_seq'::regclass);


--
-- Name: mail_confirmations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mail_confirmations ALTER COLUMN id SET DEFAULT nextval('mail_confirmations_id_seq'::regclass);


--
-- Name: members id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY members ALTER COLUMN id SET DEFAULT nextval('members_id_seq'::regclass);


--
-- Name: password_resets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY password_resets ALTER COLUMN id SET DEFAULT nextval('password_resets_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY permissions ALTER COLUMN id SET DEFAULT nextval('permissions_id_seq'::regclass);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY refresh_tokens ALTER COLUMN id SET DEFAULT nextval('refresh_tokens_id_seq'::regclass);


--
-- Name: submissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY submissions ALTER COLUMN id SET DEFAULT nextval('submissions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Data for Name: bodies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) FROM stdin;
1	AEGEE-Dresden	info@aegee-dresden.org	don't call us	Dresden	Very prehistoric antenna	DRE	2018-05-02 18:01:11.553103	2018-05-02 18:01:11.553113
13	Action Agenda Coordination Committee	act@aegee.org	\N	Notelaarsstraat 55	The Action Agenda Coordination Committee (ACT) supports locals and European Bodies to implement the Action Agenda, which states the goals that we as an organisation want to achieve for our Focus Areas.	QAA	2018-05-02 21:58:54.760566	2018-05-03 08:49:24.257251
4	Juridical Commission	juridical@aegee.org	\N	Notelaarsstraat 55	Since 1987 the Juridical Commission of AEGEE-Europe has been providing the whole Association with the most reliable sources of information as well as with internal legal consultancy. For all these years, the Commission has earned it's place as the most important partner of the Comité Directeur and the Agora’s most trusted advisor.	XJU	2018-05-02 20:08:21.966783	2018-05-02 20:08:21.966792
5	Mediation Commission	medcom@aegee.org	\N	Notelaarsstraat 55	The Mediation Commission (former Members Commission) acts in case a dispute occurs between members of AEGEE-Europe (locals, AEGEE-Academy), and is responsible for making decisions in these cases, occasionally leading to disciplinary sanctions against the ordinary member (local) of AEGEE-Europe. After carrying out an investigation, the Mediation Commission can suggest sanctions (including expulsion of a local from the Network) to be applied by the Comité Directeur and after by ratification of the Agora. In other words, in case there is a violation of the CIA, financial regulations, national law etc. by the ordinary member, the MedCom is activated.	XME	2018-05-02 20:20:21.296668	2018-05-02 20:20:21.296676
6	Network Commission	netcom@aegee.org	\N	Notelaarsstraat 55	The Network Commission consists of up to eleven members elected by the Agora for the duration of twelve months. It’s primary tasks are to ensure the smooth functioning of the AEGEE locals that form the Network, and to enhance the internal communication both within the Network itself, and between the Network and AEGEE-Europe. Each Network Commissioner should always act in the interest of the Network as a whole, be a trusted source of information and give the best example of an active AEGEE member.	XNE	2018-05-02 20:24:50.296874	2018-05-02 20:24:50.296884
7	AEGEE-Academy	board@aegee-academy.org	\N	Achter St.-Pieter 25, 3512HR Utrecht	AEGEE-Academy is the official pool of trainers of AEGEE, where we train AEGEEans in various skills that prepare them for their working life, their AEGEE life and contribute to their self-development. We provide training activities, experienced trainers and feedback on session designs for every type of local or international activity in AEGEE. We also train trainers and anyone that can benefit from knowledge on non-formal education methodologies on how to incorporate them in their activities. This way we help building a stronger network, where non-formal education is the key.	XIE	2018-05-02 20:31:57.492188	2018-05-02 20:31:57.492196
3	Audit Commission	audit@aegee.org	\N	Notelaarsstraat 55	Entitled AEGEE body of financially competent members for auditing, checking, reporting, improving and investigating on the finances of AEGEE-Europe and AEGEE Locals within our Organisation.	XAU	2018-05-02 19:59:32.398314	2018-05-02 20:57:49.540424
22	Public Relations Committee	prc@aegee.org	\N	Notelaarsstraat 55	Main aim of PRC is to support AEGEE-Europe and it's locals with tasks related to Public Relations, communications, graphic design, promotion planning and journalism.	PRW	2018-05-03 11:49:47.528604	2018-05-03 11:49:47.528612
8	Events Quality Assurance Committee	quality.events@aegee.org	\N	Notelaarsstraat 55	The Events Quality Assurance Committee’s role is to help and support the Locals in organising quality events. Our goal is to approve the quality and to increase the impact of the European events in AEGEE and outside of it.	EVC	2018-05-02 20:48:36.199812	2018-05-02 21:00:36.89381
12	AEGEE-Enschede	board@aegee-enschede.nl	+31534321040	Oude Markt 24 7511 GB Enschede The Netherlands	AEGEE-Enschede one of the largest student associations in Enschede. There is no limit to the possibilities within AEGEE.	ENS	2018-05-02 21:28:27.080883	2018-05-02 21:28:27.080891
9	Chair Team of the Agora	chair@aegee.org	\N	Notelaarsstraat 55	The Chair team is responsible for preparing and moderating the Agorae. They preside over them, take the minutes and are responsible for the IT during the events.	XCH	2018-05-02 20:57:11.731766	2018-05-02 21:46:30.370472
14	Corporate & Institutional Relations Committee	circ@aegee.org	\N	Notelaarsstraat 55	The Corporate & Institutional Relations Committee (CIRC) is a supporting committee of AEGEE-Europe and was established by the Agora Enschede 2012. The tasks of the CIRC are such as  supporting the work of AEGEE-Europe and ensure its financial sustainability providing help, analyse the needs of the Network and European level, supporting the locals on fundraising issues, implementing the fundraising strategy and increase the financial resources of AEGEE-Europe. The CIRC holds an internal and external role and is entitled to act towards the stakeholders of AEGEE-Europe with permission and supervision of the Comité Directeur.	CRC	2018-05-03 08:50:31.434227	2018-05-03 08:50:43.685164
10	Civic Education Working Group	wg@civiceducation.eu	\N	Notelaarsstraat 55	The Civic Education Working Group is coordinating AEGEE's work on Civic Education. The role is to make sure AEGEE achieves it's objectives by helping locals with the activities, delivering different workshops during AEGEE events, raising awareness for Civic Education inside and outside our association, following up on the European Citizens' Initiative and more.	CEW	2018-05-02 21:04:38.277988	2018-05-03 09:13:48.949268
17	European Citizenship Working Group	ecwg@aegee.org	\N	Notelaarsstraat 55	The European Citizenship Working Group is coordinating AEGEE's work on European Citizenship. This Focus Area has the aim to empower young people to become active and critical European citizens by educating them on the diversity of European cultures and by enabling them to take an active role in shaping the European project.	ECW	2018-05-03 09:18:03.400815	2018-05-03 09:18:03.400824
11	AEGEE Election Observation (Project)	aeo@aegee.org	\N	Notelaarsstraat 55	AEGEE Election Observation organises observation missions to elections in Europe. A typical mission lasts for 7 days and consists of 24 young European observers (any AEGEE member can apply to be an observer). During the mission, they meet politicians, institutions and youth organisations,on election day they observe the voting and vote-counting procedures on the ground. After the mission, they publish a report about the elections - and in particular about the participation of young people in these elections.	QEO	2018-05-02 21:15:35.706482	2018-05-03 13:58:37.534071
25	Eastern Partnership Project	eap@aegee.org	\N	Notelaarsstraat 55	The Eastern Partnership project of AEGEE started in 2011 and since then it became more and more successful. It organises conferences, writes articles, makes interviews and generally tries to raise awareness about the Eastern European Partnership countries to help bringing them closer to the European Union.	QEP	2018-05-03 14:32:37.026934	2018-05-03 14:32:37.026942
26	European Planning Meeting	projects@aegee.org	\N	Notelaarsstraat 55	The European Planning Meeting (EPM) is the annual thematic conference of AEGEE-Europe, providing a space for the Network to exchange views and ideas on the Focus Areas of the Strategic Plan and any other topic considered relevant.	QEC	2018-05-03 14:51:15.551759	2018-05-03 14:51:15.551768
16	Equal Rights Working Group	thedodora.giakoumelou@aegee.org	\N	Notelaarsstraat 55	The Equal Rights Working Group is coordinating AEGEE's work on Equal Rights. The focus area has the aim to acknowledge and tackle discrimination based on gender identity, expression and sexual orientation, promoting equity from an intersectional perspective.	ERW	2018-05-03 09:11:02.575987	2018-05-03 09:12:36.166125
20	Information Technology Committee	itc@aegee.org	\N	Notelaarsstraat 55	The Information Technology Committee (ITC) is a supportive body of AEGEE-Europe. It’s primary aim is to help AEGEE with anything related to IT. The Information Technology Committee is divided in several informal Teams that act fairly independent.	IUG	2018-05-03 10:00:35.286371	2018-05-03 10:00:35.286379
23	Europe on Track Project	europeontrack@aegee.org	\N	Notelaarsstraat 55	Europe on Track is a youth-led project where nine young ambassadors cross Europe with InterRail passes for one month, informing and interviewing young people about their vision of the Europe of tomorrow. In order to do so, they participate in local events bringing content and creating spaces for dialogue and discussion with a main focus that changes every year, achieving a bigger impact through a travel blog, videos and social media.	QET	2018-05-03 12:03:32.888134	2018-05-03 12:03:32.888142
24	YVote 2019 Project	philipp.blum@aegee-aachen.org	\N	Notelaarsstraat 55	The Y Vote project strives to inform people in Europe, especially the youth, in order to equip them with the needed knowledge and to encourage them to be engaged in the democratic process in the future.	E19	2018-05-03 14:21:44.708395	2018-05-03 14:21:44.708403
18	Youth Development Working Group	ydwg@aegee.org	\N	Notelaarsstraat 55	The Youth Development Working Group is coordinating AEGEE's work on Youth Development. This Focus Area has the aim to provide young people with opportunities to gain transversal skills and competences that contribute to their personal and professional development.	YDW	2018-05-03 09:26:59.517405	2018-05-03 09:26:59.517413
2	Comité Directeur	cd@aegee.org	\N	Notelaarsstraat 55, 1000 Brussel, Belgium	The Comité Directeur is the European Board of Directors. It administers the association and is composed of a maximum of seven members by the General Assembly for the term of one year. The Comité Directeur is vested with the widest possible powers to act in the name of the association.	XEU	2018-05-02 19:03:42.916437	2018-05-03 09:36:41.312064
15	Human Resources Committee	hrc@aegee.org	\N	Notelaarsstraat 55	The mission of the Human Ressources Committee is to support and educate the Network of AEGEE in the field of Human Resources Management (HRM/HR). It coordinates the implementation of a tailored HR cycle according to the needs of AEGEE and assist any local and European Body in need of guidance. Through Internal education, we ensure that the new members who enter AEGEE receive all necessary skills and knowledge to rise inside the Network in any positions they wish to. Finally, we bring value to the AEGEE Network by providing mentoring and guidance to the locals and European Bodies, and supporting them in creating a sustainable and effective working atmosphere inside their teams.	HRC	2018-05-03 09:01:01.866512	2018-05-03 09:50:22.786819
19	Summer University Project	suct@aegee.org	\N	Notelaarsstraat 55	The Summer University Project is centrally coordinated by the Summer University Coordination Team. The SUCT is a team of four AEGEE-members from different parts of Europe plus one appointed Comité Directeur member.	QSU	2018-05-03 09:55:50.767773	2018-05-03 09:57:20.089642
21	The AEGEEan Magazine Committee	aegeean@aegee.org	\N	Notelaarsstraat 55	The AEGEEan is the official magazine of AEGEE. It was founded to be the place for members to access relevant news about our organisation, and to be the place for people to share their AEGEE experience: a magazine of, by, and for members of AEGEE.	QAE	2018-05-03 11:43:27.889188	2018-05-03 11:44:26.46757
27	30 Years of SU Project	su30@aegee.org	\N	Notelaarsstraat 55	The main aim of the 30th anniversary project is to assess how the Summer University project is currently seen and subsequently identify its present as well as future identity.	S30	2018-05-03 16:38:53.307715	2018-05-03 16:38:53.307723
29	Les Anciens	anciens-board-l@aegee.org	\N	Europe	Les Anciens d’AEGEE is the alumni organisation for former AEGEE members. It organises regular events where members meet and supports AEGEE when and where possible.	XAN	2018-05-03 17:16:52.596163	2018-05-03 17:16:52.596171
28	Honorary Members	president@aegee.org	\N	Notelaarsstraat 55	Honorary Members are individuals, having performed outstanding service for the community of AEGEE-Europe, upon whom the Association desires to confer special distinction.	XHO	2018-05-03 17:04:46.066781	2018-05-03 17:04:46.06679
\.


--
-- Data for Name: body_memberships; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY body_memberships (id, comment, body_id, member_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY campaigns (id, name, url, active, description_short, description_long, activate_user, autojoin_body_id, inserted_at, updated_at) FROM stdin;
1	Default recruitment campaign	default	t	Signup to our app!	Really, sign up to our app!	t	\N	2018-05-02 18:01:11.214009	2018-05-02 18:01:11.214018
\.


--
-- Data for Name: circle_memberships; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY circle_memberships (id, circle_admin, "position", circle_id, member_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: circle_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY circle_permissions (id, circle_id, permission_id, inserted_at, updated_at) FROM stdin;
1	2	43	2018-05-02 18:01:11.682797	2018-05-02 18:01:11.682804
2	2	36	2018-05-02 18:01:11.684718	2018-05-02 18:01:11.684726
3	2	39	2018-05-02 18:01:11.685627	2018-05-02 18:01:11.685633
4	2	30	2018-05-02 18:01:11.686435	2018-05-02 18:01:11.686442
5	2	34	2018-05-02 18:01:11.687327	2018-05-02 18:01:11.687334
6	4	1	2018-05-02 18:01:11.704845	2018-05-02 18:01:11.704852
7	4	2	2018-05-02 18:01:11.706138	2018-05-02 18:01:11.706145
8	4	3	2018-05-02 18:01:11.70687	2018-05-02 18:01:11.706875
9	4	4	2018-05-02 18:01:11.707615	2018-05-02 18:01:11.70762
10	4	5	2018-05-02 18:01:11.708391	2018-05-02 18:01:11.708396
11	4	6	2018-05-02 18:01:11.709043	2018-05-02 18:01:11.709048
12	4	7	2018-05-02 18:01:11.709623	2018-05-02 18:01:11.709628
13	4	8	2018-05-02 18:01:11.710271	2018-05-02 18:01:11.710276
14	4	9	2018-05-02 18:01:11.710816	2018-05-02 18:01:11.710821
15	4	10	2018-05-02 18:01:11.711366	2018-05-02 18:01:11.711372
16	4	11	2018-05-02 18:01:11.711916	2018-05-02 18:01:11.711922
17	4	12	2018-05-02 18:01:11.712789	2018-05-02 18:01:11.712795
18	4	13	2018-05-02 18:01:11.713323	2018-05-02 18:01:11.713329
19	4	14	2018-05-02 18:01:11.71382	2018-05-02 18:01:11.713825
20	4	15	2018-05-02 18:01:11.714472	2018-05-02 18:01:11.714478
21	4	16	2018-05-02 18:01:11.715039	2018-05-02 18:01:11.715044
22	4	17	2018-05-02 18:01:11.7156	2018-05-02 18:01:11.715604
23	4	18	2018-05-02 18:01:11.716095	2018-05-02 18:01:11.7161
24	4	19	2018-05-02 18:01:11.716639	2018-05-02 18:01:11.716645
25	4	20	2018-05-02 18:01:11.717177	2018-05-02 18:01:11.717182
26	4	21	2018-05-02 18:01:11.717782	2018-05-02 18:01:11.717787
27	4	22	2018-05-02 18:01:11.718316	2018-05-02 18:01:11.71832
28	4	23	2018-05-02 18:01:11.71881	2018-05-02 18:01:11.718815
29	4	24	2018-05-02 18:01:11.719281	2018-05-02 18:01:11.719285
30	4	25	2018-05-02 18:01:11.719823	2018-05-02 18:01:11.719828
31	4	26	2018-05-02 18:01:11.720335	2018-05-02 18:01:11.720341
32	4	27	2018-05-02 18:01:11.720903	2018-05-02 18:01:11.720908
33	4	28	2018-05-02 18:01:11.721402	2018-05-02 18:01:11.721406
34	4	29	2018-05-02 18:01:11.721914	2018-05-02 18:01:11.721918
35	4	30	2018-05-02 18:01:11.722532	2018-05-02 18:01:11.722539
36	4	31	2018-05-02 18:01:11.723205	2018-05-02 18:01:11.723211
37	4	32	2018-05-02 18:01:11.723799	2018-05-02 18:01:11.723805
38	4	33	2018-05-02 18:01:11.724324	2018-05-02 18:01:11.724329
39	4	34	2018-05-02 18:01:11.724897	2018-05-02 18:01:11.724902
40	4	35	2018-05-02 18:01:11.725401	2018-05-02 18:01:11.725406
41	4	36	2018-05-02 18:01:11.725886	2018-05-02 18:01:11.725892
42	4	37	2018-05-02 18:01:11.726444	2018-05-02 18:01:11.72645
43	4	38	2018-05-02 18:01:11.726994	2018-05-02 18:01:11.726999
44	4	39	2018-05-02 18:01:11.727629	2018-05-02 18:01:11.727636
45	4	43	2018-05-02 18:01:11.728274	2018-05-02 18:01:11.72828
46	4	40	2018-05-02 18:01:11.728786	2018-05-02 18:01:11.72879
47	4	50	2018-05-02 18:01:11.729266	2018-05-02 18:01:11.729271
48	4	41	2018-05-02 18:01:11.729738	2018-05-02 18:01:11.729743
49	4	51	2018-05-02 18:01:11.730228	2018-05-02 18:01:11.730234
50	4	42	2018-05-02 18:01:11.730754	2018-05-02 18:01:11.73076
51	4	52	2018-05-02 18:01:11.731297	2018-05-02 18:01:11.731303
52	4	44	2018-05-02 18:01:11.731836	2018-05-02 18:01:11.731842
53	4	54	2018-05-02 18:01:11.73233	2018-05-02 18:01:11.732334
54	4	45	2018-05-02 18:01:11.733034	2018-05-02 18:01:11.733039
55	4	46	2018-05-02 18:01:11.733527	2018-05-02 18:01:11.733531
56	4	47	2018-05-02 18:01:11.734066	2018-05-02 18:01:11.73407
57	4	48	2018-05-02 18:01:11.734572	2018-05-02 18:01:11.734576
58	4	49	2018-05-02 18:01:11.735048	2018-05-02 18:01:11.735053
59	4	53	2018-05-02 18:01:11.735555	2018-05-02 18:01:11.735561
60	6	19	2018-05-02 19:45:55.278936	2018-05-02 19:45:55.278941
61	49	25	2018-05-03 15:06:58.877274	2018-05-03 15:06:58.877277
62	49	28	2018-05-03 15:07:27.550956	2018-05-03 15:07:27.55096
63	49	26	2018-05-03 15:08:42.157355	2018-05-03 15:08:42.15736
64	49	31	2018-05-03 15:10:03.515749	2018-05-03 15:10:03.515752
65	35	25	2018-05-03 15:19:26.506032	2018-05-03 15:19:26.506039
66	35	28	2018-05-03 15:19:29.200352	2018-05-03 15:19:29.200356
67	35	33	2018-05-03 15:19:47.906545	2018-05-03 15:19:47.90655
68	35	26	2018-05-03 15:20:02.118435	2018-05-03 15:20:02.11844
69	35	24	2018-05-03 15:20:13.297738	2018-05-03 15:20:13.297742
70	35	31	2018-05-03 15:20:36.184664	2018-05-03 15:20:36.184668
71	35	49	2018-05-03 16:08:32.891486	2018-05-03 16:08:32.891491
72	35	29	2018-05-03 16:08:48.813376	2018-05-03 16:08:48.81338
73	35	21	2018-05-03 16:09:31.453801	2018-05-03 16:09:31.453805
74	35	51	2018-05-03 16:09:43.051245	2018-05-03 16:09:43.051248
75	35	52	2018-05-03 16:09:47.224651	2018-05-03 16:09:47.224656
76	35	54	2018-05-03 16:09:51.225156	2018-05-03 16:09:51.225161
77	35	53	2018-05-03 16:09:54.127803	2018-05-03 16:09:54.127807
78	35	13	2018-05-03 16:10:07.876615	2018-05-03 16:10:07.876619
79	35	10	2018-05-03 16:10:17.596505	2018-05-03 16:10:17.596511
80	35	17	2018-05-03 16:10:21.08565	2018-05-03 16:10:21.085655
81	35	19	2018-05-03 16:10:26.707538	2018-05-03 16:10:26.707544
82	35	7	2018-05-03 16:10:32.938744	2018-05-03 16:10:32.938749
83	35	15	2018-05-03 16:10:38.90522	2018-05-03 16:10:38.905224
84	35	5	2018-05-03 16:10:44.99832	2018-05-03 16:10:44.998325
85	35	11	2018-05-03 16:10:50.125175	2018-05-03 16:10:50.12518
86	35	6	2018-05-03 16:10:54.742732	2018-05-03 16:10:54.742739
87	35	37	2018-05-03 16:11:10.661959	2018-05-03 16:11:10.661965
88	35	45	2018-05-03 16:11:28.355994	2018-05-03 16:11:28.356
89	35	40	2018-05-03 16:11:35.232432	2018-05-03 16:11:35.232437
\.


--
-- Data for Name: circles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) FROM stdin;
3	IT interest group	IT-interested people in the system	t	\N	\N	2018-05-02 18:01:11.612989	2018-05-02 18:01:11.612998
4	Superadmins	This circle holds all permissions in the system and thus effectively makes you superadmin	f	\N	\N	2018-05-02 18:01:11.627927	2018-05-02 18:01:11.627939
1	Board AEGEE-Dresden	basically doing nothing	f	1	2	2018-05-02 18:01:11.582192	2018-05-02 18:01:11.644429
6	General members circle	All members of Antennae and Contact-Antennae	f	\N	\N	2018-05-02 19:45:10.513283	2018-05-02 19:45:10.513291
8	Audit Commissioners	Circle of Audit Commissioners	f	3	2	2018-05-02 20:05:48.441287	2018-05-02 20:06:04.464914
9	Juridical Commissioners	Circle of Juridical Commissioners	f	4	2	2018-05-02 20:13:37.197634	2018-05-02 20:14:58.037365
10	Mediation Commissioners	Circle of Mediation Commissioners	f	5	2	2018-05-02 20:20:39.658759	2018-05-02 20:21:57.353637
11	Network Commissioners	Circle of Network Commissioners	f	6	2	2018-05-02 20:27:34.395052	2018-05-02 20:27:49.040716
12	Board AEGEE-Academy	Board members of the Academy	f	7	2	2018-05-02 20:32:31.132334	2018-05-02 20:32:47.650733
13	AEGEE-Academy members	Members of AEGEE-Academy need to be members of an AEGEE local. (Circle should not be child of general members circle)	f	7	\N	2018-05-02 20:34:42.708721	2018-05-02 20:35:38.123146
14	EQAC Speaker Team	Speaker Team of the Events Quality Assurance Committee	f	8	2	2018-05-02 20:50:28.21424	2018-05-02 20:50:49.79318
15	Chairs	The Chair and Vice-Chair are elected by the Agora	f	9	2	2018-05-02 21:00:00.875618	2018-05-02 21:00:20.223893
19	Gender Equality Interest Group	The Gender Equality Interest Group creates a space for discussion and learning about issues regarding gender. We strive for equality within our network as well as outside of it, focusing on gender and taking into account other ways of discrimination from an intersectional perspective. If you are interested in organizing an activity about the topic don’t hesitate to ask us for materials.	t	\N	\N	2018-05-02 21:22:21.937682	2018-05-02 21:22:33.889603
20	Health4Youth Interest Group	"H4Y IG stands for educating AEGEEans about health matters. Our goal is to promote a healthy lifestyle among European students and motivate them to adopt it in their lives.   What exactly do we do? Healthy SUs and other events, workshops, surveys, booklets and much more! Brainstorming Skype meetings take place once a month. Join and make AEGEE more healthy one AEGEEan at a time.	t	\N	\N	2018-05-02 21:23:21.241894	2018-05-02 21:23:21.241904
21	Language Interest Group	The goal of the Language Interest Group is to raise the awareness within AEGEE about the value of multilingualism, to encourage and help AEGEEans to learn more foreign languages and to discuss issues related to language policies and diversity, as well as to minority languages. By organising different projects and supporting locals in the organisation of language related activities and events, we are breaking language barriers and promoting the benefits of language learning.	t	\N	\N	2018-05-02 21:23:57.658708	2018-05-02 21:23:57.658717
22	Board AEGEE-Enschede	The Board can be found on weekdays between 10:00-17:00 at the Office of AEGEE-Enschede in the Pakkerij and on Tuesday and Thursday evenings in our pub Asterion.	f	12	2	2018-05-02 21:30:11.002392	2018-05-02 21:32:10.959859
17	CEWG Coordinator	The Coordinator is responsible for the recruitment of the Policy Officer and the other Working Group Members.	f	10	2	2018-05-02 21:07:30.256859	2018-05-02 21:32:39.758453
18	AEO Project Managers	Three representatives in the function of Project Manager, Financial Manager and Content Manager, whose exact responsibilities are defined in the contract.	f	11	2	2018-05-02 21:21:29.771685	2018-05-02 21:32:50.784458
24	DRINK-WISE	DRINKWISE is striving to explore issues related to drinking and aspects of the drinking culture that make us feel united or divided. One of the goals is also to highlight the importance of traditional drinks as part of our local culture and to promote responsible and healthy drinking habits.	t	\N	\N	2018-05-02 21:36:01.710414	2018-05-02 21:36:26.14874
25	Liasson Officers	The Liaison Officers are experienced AEGEE members who work with an organisation specifically assigned to them together with a board member of AEGEE-Europe in order to maximize the cooperation possibility. The Liaison Office ensures bigger capacity for AEGEE to be actively contributing to European and global processes and developments and realise concrete activities that will further strengthen AEGEEs position.	f	\N	\N	2018-05-02 21:37:17.207782	2018-05-02 21:37:17.20779
26	CIRC Speaker Team	The speaker team (ST) is responsible to send the open call to announce-l for new members upon internal needs and decides upon the selection of membership applications	f	14	2	2018-05-03 08:52:59.792175	2018-05-03 08:53:15.217222
27	ACT Speaker Team	The ACT is coordinated by the Speaker, up to two Vice-Speakers and the CD member responsible for the Action Agenda	f	13	2	2018-05-03 08:55:21.364765	2018-05-03 08:55:31.010388
2	General board circle	This is the toplevel circle for all boards in the system. It grants boards administrative rights for their body.	f	\N	\N	2018-05-02 18:01:11.594686	2018-05-03 08:56:02.955449
28	HRC Board	The HRC Board consists of two elected members and one appointed Comité Directeur member.	f	15	2	2018-05-03 09:02:23.492827	2018-05-03 09:02:47.44632
29	ECWG Coordinator	The Coordinator is responsible for the recruitment of the Policy Officer and the other Working Group Members.	f	17	2	2018-05-03 09:22:27.90235	2018-05-03 09:22:45.206766
30	ERWG Coordinator	The Coordinator is responsible for the recruitment of the Policy Officer and the other Working Group Members.	f	16	2	2018-05-03 09:23:13.453221	2018-05-03 09:23:25.732016
31	YDWG Coordinator	The Coordinator is responsible for the recruitment of the Policy Officer and the other Working Group Members.	f	18	2	2018-05-03 09:28:24.939959	2018-05-03 09:28:49.329461
33	ITC Board	The ITC Board is responsible for the coordination of the different teams	f	20	\N	2018-05-03 10:01:13.988804	2018-05-03 10:01:13.988812
16	Directors	A maximum of seven members from the Locals are the Directors. The Directors are the members of the Comité Directeur.	f	2	2	2018-05-02 21:01:11.335292	2018-05-03 09:38:24.473598
32	SUCT members	The SUCT is responsible for the good functioning and development of the project during one year.	f	19	2	2018-05-03 09:57:39.269442	2018-05-03 09:58:28.795923
36	AEGEEan Speaker Team	The AEGEEan Speaker Team consists of two elected members, i.e. Editor-in-Chief and Vice-Editor-in-Chief, and one appointed Comité Directeur member.	f	21	2	2018-05-03 11:46:21.82071	2018-05-03 11:46:33.56028
45	Faces of Europe	Faces of Europe wants to collect and spread the faces and voices of people from different social, cultural and national backgrounds and to find out what ‘Europe’ means to them.	f	\N	\N	2018-05-03 14:35:41.679874	2018-05-03 14:35:41.679894
5	System Admins	Creating and modifying the system	f	2	35	2018-05-02 19:05:26.232486	2018-05-03 15:01:35.809241
34	ITC OMS Team	Administers OMS/intranet/MyAEGEE/THIS and provides support to its users	f	20	35	2018-05-03 10:11:03.389427	2018-05-03 15:00:07.284651
23	Members AEGEE-Enschede	Circle of members in Enschede. All local members should be members of this circle to apply permissions of AEGEE membership.	f	12	6	2018-05-02 21:34:37.64428	2018-05-03 15:12:06.48044
37	PRC Speaker Team	The PRC is coordinated by the Speaker Team, which consists of one Speaker, one Vice-Speaker, and an appointed Comité Directeur member.	f	22	2	2018-05-03 11:52:06.818551	2018-05-03 11:52:20.701571
39	AEGEE Day	AEGEE Day is the project celebrating the Anniversaries of our association in the means of organising various activities, which set the focus on the principles of AEGEE.	f	\N	\N	2018-05-03 11:55:35.087721	2018-05-03 11:55:35.087729
43	YVote Project Managers	Three representatives in the function of Project Manager, Financial Manager and Content Manager, whose exact responsibilities are defined in the contract.	f	24	2	2018-05-03 14:31:15.907365	2018-05-03 14:31:31.193641
50	SU30 Project Managers	Three representatives in the function of Project Manager, Financial Manager and Content Manager, whose exact responsibilities are defined in the contract.	f	27	2	2018-05-03 16:39:21.959687	2018-05-03 16:39:38.404978
52	LGBT+ Interest Group	LGBT+ Interest Group was created to raise awareness about this topic inside and outside of AEGEE, foster international debate and to provide help to the locals and members when needed.	t	\N	\N	2018-05-03 16:42:42.935041	2018-05-03 16:42:42.935051
40	Key to Europe	Key to Europe is an annual publication about AEGEE, its structures successes and general ongoings. The team is responsible for its drafting and compilation and later on also for its distribution to the Network and External Partners.	f	\N	\N	2018-05-03 11:57:04.642878	2018-05-03 11:57:04.642886
41	Policy Officers	Internally, Policy Officers support the work of Comité Directeur, Working Groups and potentially projects with the same thematic field. Externally, they represent the position of AEGEE on topics they are working on, and participate in policy-making processes.	f	\N	\N	2018-05-03 12:01:22.930704	2018-05-03 12:01:22.930728
42	EOT Project Managers	Three representatives in the function of Project Manager, Financial Manager and Content Manager, whose exact responsibilities are defined in the contract.	f	23	2	2018-05-03 12:04:08.806091	2018-05-03 12:04:24.432613
44	EAP Project Managers	Three representatives in the function of Project Manager, Financial Manager and Content Manager, whose exact responsibilities are defined in the contract.	f	25	\N	2018-05-03 14:33:56.875239	2018-05-03 14:33:56.875246
7	Members AEGEE-Dresden	Circle of members in Dresden. All local members should be members of this circle to apply permissions of AEGEE membership.	f	1	6	2018-05-02 19:49:47.533611	2018-05-03 15:11:51.921378
46	EPM Content Team and CD responsible(s)	The Content Team is appointed by the Comité Directeur. The Content Team, in cooperation with the Comité Directeur, is responsible for the preparation of the EPM.	f	26	2	2018-05-03 14:53:11.0293	2018-05-03 16:40:07.769941
51	Culture Interest Group	Are you interested in culture? Would you like to write for an international cultural website and organize international events? Do you want to deepen your engagement within the AEGEE community? Are you just curious? Don't miss the chance and join the Culture Interest Group! Visit our blog, spread your ideas, write on your favorite themes and participate in our thematic events. The aim of our Interest Group is to promote European culture in all its form.	t	\N	\N	2018-05-03 16:42:07.81129	2018-05-03 16:42:07.811298
53	Migration Interest Group	The Migration Interest GRoup (MIGR) focusses its activities on raising awareness, sharing the best practices, taking concrete initiatives, participating at Migration-related conferences, and making advocacy on the rights of Migrants	t	\N	\N	2018-05-03 16:44:09.081181	2018-05-03 16:44:09.081189
47	Workshop Leaders	Workshops serve to address any topic of interest to the EPM. They may be moderated by participants of the EPM as well as external speakers.	f	26	\N	2018-05-03 14:54:18.45195	2018-05-03 14:58:26.228956
35	General Admin circle	This is the toplevel circle for all system admin circles. It grants admins global administrative rights, but no superadministrator rights (permissions).	f	\N	\N	2018-05-03 10:12:36.185479	2018-05-03 16:12:43.072928
48	Action Meeting Facilitators	Action Meetings serve to develop the Action Agenda for the upcoming Planning Year by drafting objectives and corresponding activities. 2Action Meetings have a flexible structure, allowing participants to arrange ad hoc meetings at any time for the development of activities.	f	26	\N	2018-05-03 14:58:14.038289	2018-05-03 14:58:14.038298
49	Network Director	The Network Director might need some special privileges to add and remove locals (?)	f	2	\N	2018-05-03 15:06:47.307666	2018-05-03 15:06:47.307676
54	Politics Interest Group	The mission of the Politics Interest Group is to foster international political discussion on an academic and analytical level. The focus is be set on bringing politics closer to the members and make them active in todays society.	t	\N	\N	2018-05-03 16:45:42.970673	2018-05-03 16:45:42.970681
55	Society and Enviroment Interest Group	Society and the Environment Interest Group is there to open a space for AEGEEans to discuss and make changes inside AEGEE in order to make it more Sustainable and respectful of our selves and our planet. We are aiming at raising awareness and becoming actors of change in the environmental field. We have as an organisation the potential to be proactive in the process of change, it's up to us to make it happen.	t	\N	\N	2018-05-03 16:46:13.101978	2018-05-03 16:46:13.101985
56	SUpporters Interest Group	SUpporters Interest Group was created in autumn 2015 by SUCT as the task force for all interested members who would like to help SU project by working closely with appointed SUCT members on specific tasks, such as all kinds of designing, website support, training and representing on events, creating booklets, promotion and more. Tasks are created by SUCT and forwarded to SUpporters who then deliver the result and do not have to be involved in anything else. This IG is very task oriented and therefore every member can find whatever suits his or her needs and interests.	t	\N	\N	2018-05-03 16:47:22.074814	2018-05-03 16:51:04.401906
57	Advisory Board	The advisory board is tasked with advising the Comité Directeur in the broadest sense possible. The advisory board has no decisive power.	f	\N	\N	2018-05-03 17:02:24.366374	2018-05-03 17:02:24.366382
58	Circle of Honorary Members	Honorary Members are not "AEGEE members" and can only obtain AEGEE member rights through local membership.	f	28	\N	2018-05-03 17:07:12.429507	2018-05-03 17:07:12.429547
\.


--
-- Data for Name: join_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY join_requests (id, motivation, approved, member_id, body_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mail_confirmations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY mail_confirmations (id, url, submission_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY members (id, user_id, first_name, last_name, date_of_birth, gender, phone, seo_url, address, about_me, primary_body_id, inserted_at, updated_at) FROM stdin;
1	1	Microservice	Microservice	2010-04-17	machine	+123456789	58238624_	Europe	I am a microservice. I have a user account so the system can access itself from within, don't delete me.	\N	2018-05-02 18:01:11.526392	2018-05-02 18:01:11.526404
\.


--
-- Data for Name: password_resets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY password_resets (id, url, user_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY permissions (id, scope, action, object, description, always_assigned, inserted_at, updated_at) FROM stdin;
1	global	view	permission	View permissions available in the system	t	2018-05-02 18:01:08.259307	2018-05-02 18:01:08.259323
2	global	create	permission	Create new permission objects which haven't been in the system yet, usually only good for microservices	f	2018-05-02 18:01:08.693817	2018-05-02 18:01:08.693831
3	global	update	permission	Change permissions, should generally happen very rarely as it could break the system	f	2018-05-02 18:01:08.857515	2018-05-02 18:01:08.857525
4	global	delete	permission	Delete a permission, should generally happen very rarely as it could break the system	f	2018-05-02 18:01:09.040021	2018-05-02 18:01:09.04003
5	global	view	circle	List and view the details of any circle, excluding members data	t	2018-05-02 18:01:09.178176	2018-05-02 18:01:09.178188
6	global	create	free_circle	Create free circles	f	2018-05-02 18:01:09.337611	2018-05-02 18:01:09.33762
7	global	update	circle	Update any circle, even those that you are not in a circle_admin position in. Should only be assigned in case of an abandoned toplevel circle as circle_admins automatically get this permission	f	2018-05-02 18:01:09.460259	2018-05-02 18:01:09.460298
8	global	put_parent	circle	Assign a parent to any circle. This permission should be granted only to trustworthy persons as it is possible to assign an own circle as child to a parent circle with a lot of permissions	f	2018-05-02 18:01:09.524366	2018-05-02 18:01:09.524377
9	local	put_parent	bound_circle	Assign a parent to a bound circle. This only allows to assign parents that are in the same body as the circle to migitate permission escalations where someone with this permission could assign his own circle to one with a lot of permissions	f	2018-05-02 18:01:09.816236	2018-05-02 18:01:09.816254
10	global	delete	circle	Delete any circle, even those that you are not in a circle_admin position in. Should only be assigned in case of an abandoned toplevel circle as circle_admins automatically get this permission	f	2018-05-02 18:01:10.007163	2018-05-02 18:01:10.007173
11	global	view_members	circle	View members of any circle, even those you are not member of. Should only be given to very trusted people as this way big portions of the members database can be accessed directly	f	2018-05-02 18:01:10.164356	2018-05-02 18:01:10.164369
12	local	view_members	circle	View members of any circle in the body that you got this permission from	f	2018-05-02 18:01:10.237977	2018-05-02 18:01:10.237988
13	global	add_member	circle	Add anyone to any circle in the system, no matter if the circle is joinable or not but still respecting that bound circles can only hold members of the same body. This also allows to add yourself to any circle and thus can be used for a privilege escalation	f	2018-05-02 18:01:10.433817	2018-05-02 18:01:10.433828
14	local	add_member	circle	Add any member of the body you got this permission from to any bound circle in that body, no matter if the circle is joinable or not or if the member wants that or not. This also allows to add yourself to any circle so only give it to people who anyways have many rights in the body	f	2018-05-02 18:01:10.465159	2018-05-02 18:01:10.465173
15	global	update_members	circle	Update membership details of members of any circle, even those that you are not in a circle_admin position in or even have member status. Should never be assigned as circle_admins automatically get this permission	f	2018-05-02 18:01:10.487096	2018-05-02 18:01:10.487108
16	local	update_members	circle	Update membership details of members of any circle in the body that you got this permission from, even those that you are not in a circle_admin position in or even have member status. Should never be assigned as circle_admins automatically get this permission	f	2018-05-02 18:01:10.504472	2018-05-02 18:01:10.504482
17	global	delete_members	circle	Delete any member from any free circle, even those that you are not in a circle_admin position in or even have member status. Should never be assigned as circle_admins automatically get this permission	f	2018-05-02 18:01:10.527513	2018-05-02 18:01:10.527524
18	local	delete_members	circle	Delete any member from any circle in the body that you got this permission from, even those that you are not in a circle_admin position in or even have member status. Should never be assigned as circle_admins automatically get this permission	f	2018-05-02 18:01:10.542635	2018-05-02 18:01:10.542647
19	global	join	circle	Allows to join circles which are joinable. Non-joinable circles can never be joined	t	2018-05-02 18:01:10.562248	2018-05-02 18:01:10.562259
20	local	join	circle	Allows you to join joinable circles in the body where you got the permission from	t	2018-05-02 18:01:10.577795	2018-05-02 18:01:10.577803
21	global	create	bound_circle	Creating bound circles in any body of the system, even those you are not member in	f	2018-05-02 18:01:10.593479	2018-05-02 18:01:10.593489
22	local	create	bound_circle	Creating bound circles to the body the permission was granted in	f	2018-05-02 18:01:10.613957	2018-05-02 18:01:10.61397
23	global	put_permissions	circle	Assign permission to any circle. This is effectively superadmin permission, as a user holding this can assign all permissions in the system to a circle where he is member in	f	2018-05-02 18:01:10.629984	2018-05-02 18:01:10.630016
24	global	view	body	View body details, excluding the members list	t	2018-05-02 18:01:10.639475	2018-05-02 18:01:10.639486
25	global	create	body	Create new bodies.	f	2018-05-02 18:01:10.66725	2018-05-02 18:01:10.667261
26	global	update	body	Update any body, even those that you are not member of. Try to use the local permission instead	f	2018-05-02 18:01:10.700301	2018-05-02 18:01:10.700315
27	local	update	body	Update details of the body that you got the permission from. Might be good for boards but also allows changing the name	f	2018-05-02 18:01:10.714376	2018-05-02 18:01:10.714386
28	global	delete	body	Delete a body.	f	2018-05-02 18:01:10.731947	2018-05-02 18:01:10.73196
29	global	view_members	body	View the members of any body in the system. Be careful with assigning this permission as it means basically disclosing the complete members list to persons holding it	f	2018-05-02 18:01:10.751857	2018-05-02 18:01:10.751866
30	local	view_members	body	View the members in the body that you got that permission from	f	2018-05-02 18:01:10.767371	2018-05-02 18:01:10.767379
31	global	update_member	body	Change the data attached to a body membership in any body in the system	f	2018-05-02 18:01:10.791245	2018-05-02 18:01:10.791254
32	local	update_member	body	Change the data attached to a body membership in the body you got this permission from	f	2018-05-02 18:01:10.800297	2018-05-02 18:01:10.800306
33	global	delete_member	body	Delete the membership status of any member in any body. Use the local permission for this if possible	f	2018-05-02 18:01:10.825099	2018-05-02 18:01:10.825108
34	local	delete_member	body	Delete membership status from members in the body that you got this permission from.	f	2018-05-02 18:01:10.839352	2018-05-02 18:01:10.83936
35	global	create	join_request	Allows users to request joining a body. Without these permissions the joining body process would be disabled	t	2018-05-02 18:01:10.86134	2018-05-02 18:01:10.86135
36	local	view	join_request	View join request to the body you got this permission from	f	2018-05-02 18:01:10.889199	2018-05-02 18:01:10.889208
37	global	view	join_request	View join requests to any body in the system. This could disclose a bigger portion of the members database and thus should be assigned carefully	f	2018-05-02 18:01:10.901838	2018-05-02 18:01:10.901848
38	global	process	join_request	Process join requests in any body of the system, even those that you are not affiliated with.	f	2018-05-02 18:01:10.922848	2018-05-02 18:01:10.922856
39	local	process	join_request	Process join requests in the body that you got the permission from	f	2018-05-02 18:01:10.946336	2018-05-02 18:01:10.946348
43	local	view_full	member	View all details of any member in the body that you got this permission from	f	2018-05-02 18:01:11.017412	2018-05-02 18:01:11.017421
40	global	view	member	View all members in the system. Assign this role to trusted persons only to avoid disclosure. For local scope, use view_members:body	f	2018-05-02 18:01:10.964428	2018-05-02 18:01:10.964441
50	local	update_active	user	Allows to suspend or activate users that are member in the body that you got this permission from	f	2018-05-02 18:01:11.139682	2018-05-02 18:01:11.139692
41	local	view	member	View basic information about all members in the body. This does not allow you to perform a members listing, you might however hold the list body_memberships permission	f	2018-05-02 18:01:10.973274	2018-05-02 18:01:10.973283
51	global	view	campaign	View all campaigns in the system, no matter if active or not.	f	2018-05-02 18:01:11.149104	2018-05-02 18:01:11.149115
42	global	view_full	member	View all details of any member in the system. Assign this role to trusted persons only to avoid disclosure.	f	2018-05-02 18:01:10.992137	2018-05-02 18:01:10.992148
52	global	create	campaign	Create recruitment campaigns through which users can sign into the system.	f	2018-05-02 18:01:11.165018	2018-05-02 18:01:11.165028
44	global	create	member	Create members to the system. This is usually only assigned to the login microservice	f	2018-05-02 18:01:11.031445	2018-05-02 18:01:11.031454
54	global	delete	campaign	Delete a recruitment campaign	f	2018-05-02 18:01:11.195885	2018-05-02 18:01:11.195894
45	global	update	member	Update any member in the system. Don't assign this as any member can update his own profile anyways.	f	2018-05-02 18:01:11.05041	2018-05-02 18:01:11.05042
46	local	update	member	Update any member in the body you got this permission from. Notice that member information is global and several bodies might have the permission to access the same member. Also don't assign it when not necessary, the member can update his own profile anyways.	f	2018-05-02 18:01:11.060727	2018-05-02 18:01:11.060736
47	global	delete	user	Remove an account from the system. Don't assign this as any member can delete his own account anyways.	f	2018-05-02 18:01:11.077541	2018-05-02 18:01:11.077549
48	local	delete	user	Delete any member in your body from the system. This allows to also delete members that are in other bodies and have a quarrel in that one body with the board admin, so be careful in granting this permission. The member can delete his own profile anyways	f	2018-05-02 18:01:11.095533	2018-05-02 18:01:11.095543
49	global	update_active	user	Allows to suspend or activate any user in the system	f	2018-05-02 18:01:11.113595	2018-05-02 18:01:11.113605
53	global	update	campaign	Edit recruitment campaigns	f	2018-05-02 18:01:11.179039	2018-05-02 18:01:11.179048
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY refresh_tokens (id, token, device, user_id, inserted_at, updated_at) FROM stdin;
2	eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJPTVMiLCJleHAiOjE1MjY0OTQyMDcsImlhdCI6MTUyNTI4NDYwNywiaXNzIjoiT01TIiwianRpIjoiZGQ5NGIyODYtYTI5ZC00NzBiLTgxODEtZDA5NzgyOTcwMDI0IiwibmJmIjoxNTI1Mjg0NjA2LCJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCJ9.Xl35r5qtQ8nDWY2W54GxJtHA39XX22my5orEaCqcPbDE9BnmPmJxiduX7mLbeAPqGQUqcU3umVE5y0F1NBNALQ	Unknown device	1	2018-05-02 18:10:07.483334	2018-05-02 18:10:07.483343
3	eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJPTVMiLCJleHAiOjE1MjY0OTQyNTMsImlhdCI6MTUyNTI4NDY1MywiaXNzIjoiT01TIiwianRpIjoiMTFlYWI2YTYtNDhjMy00ZTZkLWIwODUtY2MwODc3OTBmMzQ2IiwibmJmIjoxNTI1Mjg0NjUyLCJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCJ9.azXyrmHFae5vB0nEw5lc_7zUS_hCTaUxaGj-aq3XVANM2YUFB7D6zlKMvr2_jOiO5x306LJ0CrBvDsLR3oPyuQ	Unknown device	1	2018-05-02 18:10:53.968711	2018-05-02 18:10:53.968719
4	eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJPTVMiLCJleHAiOjE1MjY0OTUwMDksImlhdCI6MTUyNTI4NTQwOSwiaXNzIjoiT01TIiwianRpIjoiMmUwNjk0ZjAtMjRhNy00ODRmLTkxZTktZjYxZGU5YTA3NTgyIiwibmJmIjoxNTI1Mjg1NDA4LCJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCJ9.6Xhqaxj-lUg_isRrb6P3lluVduFkFevzWSQZzRV8a2gTRCP2APP27aw_K_KsdmhKOj2gGPa3uZGljIUPtiQNNA	Unknown device	1	2018-05-02 18:23:29.48084	2018-05-02 18:23:29.480848
5	eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJPTVMiLCJleHAiOjE1MjY1MTE5OTIsImlhdCI6MTUyNTMwMjM5MiwiaXNzIjoiT01TIiwianRpIjoiNWIxNWQyMzItMzQwYS00NzQwLWE0MjgtMjgxYzE5NzU5OTM0IiwibmJmIjoxNTI1MzAyMzkxLCJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCJ9.Z58KhneTUyV-ADjB-WwIKnlkrp6fh5mKQFBMIcWjdlHXruY7D8Z-LyQ_ifuyhUnVzb0eaF04EJrhwoqJ9vdjlw	Unknown device	1	2018-05-02 23:06:32.756821	2018-05-02 23:06:32.756829
6	eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJPTVMiLCJleHAiOjE1MjY1Mzk0MjQsImlhdCI6MTUyNTMyOTgyNCwiaXNzIjoiT01TIiwianRpIjoiNTE4MmRjMGQtNjI0NS00ZjU5LWI3ZjgtYjAxNzliNTBiNGY2IiwibmJmIjoxNTI1MzI5ODIzLCJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCJ9.AAamGxN-itWKTSWvALn3GnHlzN5UWO3Flp-32aCCMFXTqdfy8axIu-bPVHuEGeant-_XwsdQLIDyQebgnVciVQ	Unknown device	1	2018-05-03 06:43:44.372096	2018-05-03 06:43:44.372105
7	eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJPTVMiLCJleHAiOjE1MjY1NTk1MDMsImlhdCI6MTUyNTM0OTkwMywiaXNzIjoiT01TIiwianRpIjoiY2IyZTZlMTktODkwZS00ZmFhLWEyZDUtMDgzYjUyZDljYWU5IiwibmJmIjoxNTI1MzQ5OTAyLCJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCJ9.3hiVI-r79snF7rdsM_vfBeSz8hQjt8Hp8-D00a0ju1Ivjydv3SJ-YLIEXzTjfjppltP6Tfc0lBLhNEWfWC3sdg	Unknown device	1	2018-05-03 12:18:23.973853	2018-05-03 12:18:23.973861
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY schema_migrations (version, inserted_at) FROM stdin;
20180306115011	2018-05-02 18:00:54.927095
20180307133008	2018-05-02 18:00:55.145991
20180319191422	2018-05-02 18:00:56.370043
20180328103327	2018-05-02 18:00:56.539528
20180328103629	2018-05-02 18:00:56.678547
20180328103837	2018-05-02 18:00:56.976222
20180328103952	2018-05-02 18:00:57.106812
20180331172420	2018-05-02 18:00:59.962759
20180331173040	2018-05-02 18:01:02.118094
20180331173152	2018-05-02 18:01:03.324419
20180331173536	2018-05-02 18:01:05.755164
20180348155434	2018-05-02 18:01:06.672888
20180348194940	2018-05-02 18:01:06.886192
20180358134254	2018-05-02 18:01:07.01793
\.


--
-- Data for Name: submissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY submissions (id, first_name, last_name, motivation, mail_confirmed, user_id, campaign_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY users (id, name, email, password, active, superadmin, member_id, inserted_at, updated_at) FROM stdin;
1	admin	admin@aegee.org	$2b$12$ui2a5zUwaVuItaM6u/Z/v.V7EsI1OH3B8g0Am034DSpN4XhmWn/l2	t	t	\N	2018-05-02 18:01:11.50822	2018-05-02 18:01:11.508233
\.


--
-- Name: bodies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('bodies_id_seq', 29, true);


--
-- Name: body_memberships_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('body_memberships_id_seq', 1, false);


--
-- Name: campaigns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('campaigns_id_seq', 1, true);


--
-- Name: circle_memberships_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('circle_memberships_id_seq', 1, false);


--
-- Name: circle_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('circle_permissions_id_seq', 89, true);


--
-- Name: circles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('circles_id_seq', 58, true);


--
-- Name: join_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('join_requests_id_seq', 1, false);


--
-- Name: mail_confirmations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('mail_confirmations_id_seq', 4, true);


--
-- Name: members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('members_id_seq', 1, true);


--
-- Name: password_resets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('password_resets_id_seq', 3, true);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('permissions_id_seq', 54, true);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('refresh_tokens_id_seq', 7, true);


--
-- Name: submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('submissions_id_seq', 4, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('users_id_seq', 6, true);


--
-- Name: bodies bodies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY bodies
    ADD CONSTRAINT bodies_pkey PRIMARY KEY (id);


--
-- Name: body_memberships body_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY body_memberships
    ADD CONSTRAINT body_memberships_pkey PRIMARY KEY (id);


--
-- Name: campaigns campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (id);


--
-- Name: circle_memberships circle_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY circle_memberships
    ADD CONSTRAINT circle_memberships_pkey PRIMARY KEY (id);


--
-- Name: circle_permissions circle_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY circle_permissions
    ADD CONSTRAINT circle_permissions_pkey PRIMARY KEY (id);


--
-- Name: circles circles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY circles
    ADD CONSTRAINT circles_pkey PRIMARY KEY (id);


--
-- Name: join_requests join_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY join_requests
    ADD CONSTRAINT join_requests_pkey PRIMARY KEY (id);


--
-- Name: mail_confirmations mail_confirmations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mail_confirmations
    ADD CONSTRAINT mail_confirmations_pkey PRIMARY KEY (id);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: password_resets password_resets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY password_resets
    ADD CONSTRAINT password_resets_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: body_memberships_body_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX body_memberships_body_id_index ON body_memberships USING btree (body_id);


--
-- Name: body_memberships_body_id_member_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX body_memberships_body_id_member_id_index ON body_memberships USING btree (body_id, member_id);


--
-- Name: body_memberships_member_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX body_memberships_member_id_index ON body_memberships USING btree (member_id);


--
-- Name: campaigns_autojoin_body_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX campaigns_autojoin_body_id_index ON campaigns USING btree (autojoin_body_id);


--
-- Name: campaigns_url_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX campaigns_url_index ON campaigns USING btree (url);


--
-- Name: circle_memberships_circle_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX circle_memberships_circle_id_index ON circle_memberships USING btree (circle_id);


--
-- Name: circle_memberships_circle_id_member_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX circle_memberships_circle_id_member_id_index ON circle_memberships USING btree (circle_id, member_id);


--
-- Name: circle_memberships_member_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX circle_memberships_member_id_index ON circle_memberships USING btree (member_id);


--
-- Name: circle_permissions_circle_id_permission_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX circle_permissions_circle_id_permission_id_index ON circle_permissions USING btree (circle_id, permission_id);


--
-- Name: circles_body_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX circles_body_id_index ON circles USING btree (body_id);


--
-- Name: circles_parent_circle_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX circles_parent_circle_id_index ON circles USING btree (parent_circle_id);


--
-- Name: join_requests_body_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX join_requests_body_id_index ON join_requests USING btree (body_id);


--
-- Name: join_requests_member_id_body_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX join_requests_member_id_body_id_index ON join_requests USING btree (member_id, body_id);


--
-- Name: join_requests_member_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX join_requests_member_id_index ON join_requests USING btree (member_id);


--
-- Name: mail_confirmations_submission_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX mail_confirmations_submission_id_index ON mail_confirmations USING btree (submission_id);


--
-- Name: members_primary_body_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX members_primary_body_id_index ON members USING btree (primary_body_id);


--
-- Name: members_seo_url_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX members_seo_url_index ON members USING btree (seo_url);


--
-- Name: members_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX members_user_id_index ON members USING btree (user_id);


--
-- Name: password_resets_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX password_resets_user_id_index ON password_resets USING btree (user_id);


--
-- Name: permissions_scope_action_object_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX permissions_scope_action_object_index ON permissions USING btree (scope, action, object);


--
-- Name: refresh_tokens_token_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX refresh_tokens_token_index ON refresh_tokens USING btree (token);


--
-- Name: refresh_tokens_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX refresh_tokens_user_id_index ON refresh_tokens USING btree (user_id);


--
-- Name: submissions_campaign_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX submissions_campaign_id_index ON submissions USING btree (campaign_id);


--
-- Name: submissions_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX submissions_user_id_index ON submissions USING btree (user_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_index ON users USING btree (email);


--
-- Name: users_name_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_name_index ON users USING btree (name);


--
-- Name: body_memberships body_memberships_body_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY body_memberships
    ADD CONSTRAINT body_memberships_body_id_fkey FOREIGN KEY (body_id) REFERENCES bodies(id) ON DELETE CASCADE;


--
-- Name: body_memberships body_memberships_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY body_memberships
    ADD CONSTRAINT body_memberships_member_id_fkey FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE;


--
-- Name: campaigns campaigns_autojoin_body_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaigns
    ADD CONSTRAINT campaigns_autojoin_body_id_fkey FOREIGN KEY (autojoin_body_id) REFERENCES bodies(id) ON DELETE CASCADE;


--
-- Name: circle_memberships circle_memberships_circle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY circle_memberships
    ADD CONSTRAINT circle_memberships_circle_id_fkey FOREIGN KEY (circle_id) REFERENCES circles(id) ON DELETE CASCADE;


--
-- Name: circle_memberships circle_memberships_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY circle_memberships
    ADD CONSTRAINT circle_memberships_member_id_fkey FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE;


--
-- Name: circle_permissions circle_permissions_circle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY circle_permissions
    ADD CONSTRAINT circle_permissions_circle_id_fkey FOREIGN KEY (circle_id) REFERENCES circles(id) ON DELETE CASCADE;


--
-- Name: circle_permissions circle_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY circle_permissions
    ADD CONSTRAINT circle_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE;


--
-- Name: circles circles_body_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY circles
    ADD CONSTRAINT circles_body_id_fkey FOREIGN KEY (body_id) REFERENCES bodies(id) ON DELETE CASCADE;


--
-- Name: circles circles_parent_circle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY circles
    ADD CONSTRAINT circles_parent_circle_id_fkey FOREIGN KEY (parent_circle_id) REFERENCES circles(id) ON DELETE SET NULL;


--
-- Name: join_requests join_requests_body_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY join_requests
    ADD CONSTRAINT join_requests_body_id_fkey FOREIGN KEY (body_id) REFERENCES bodies(id) ON DELETE CASCADE;


--
-- Name: join_requests join_requests_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY join_requests
    ADD CONSTRAINT join_requests_member_id_fkey FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE;


--
-- Name: mail_confirmations mail_confirmations_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mail_confirmations
    ADD CONSTRAINT mail_confirmations_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE CASCADE;


--
-- Name: members members_primary_body_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY members
    ADD CONSTRAINT members_primary_body_id_fkey FOREIGN KEY (primary_body_id) REFERENCES bodies(id) ON DELETE SET NULL;


--
-- Name: members members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY members
    ADD CONSTRAINT members_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: password_resets password_resets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY password_resets
    ADD CONSTRAINT password_resets_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: submissions submissions_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY submissions
    ADD CONSTRAINT submissions_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE SET NULL;


--
-- Name: submissions submissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY submissions
    ADD CONSTRAINT submissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\connect postgres

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- PostgreSQL database dump complete
--

\connect template1

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: template1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE template1 IS 'default template for new databases';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

