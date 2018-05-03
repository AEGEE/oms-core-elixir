--
-- PostgreSQL database cluster dump
--
-- Insert with
-- cat oms-core-elixir/dumps/dump_european_bodies.sql | docker-compose -f empty-docker-compose.yml -f oms-core-elixir/docker/docker-compose.yml exec -T postgres-oms-core-elixir psql -U postgres
-- 

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

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

SET search_path = public, pg_catalog;

--
-- Data for Name: bodies; Type: TABLE DATA; Schema: public; Owner: postgres
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE bodies DISABLE TRIGGER ALL;

INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (1, 'AEGEE-Dresden', 'info@aegee-dresden.org', 'don''t call us', 'Dresden', 'Very prehistoric antenna', 'DRE', '2018-05-02 18:01:11.553103', '2018-05-02 18:01:11.553113');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (13, 'Action Agenda Coordination Committee', 'act@aegee.org', NULL, 'Notelaarsstraat 55', 'The Action Agenda Coordination Committee (ACT) supports locals and European Bodies to implement the Action Agenda, which states the goals that we as an organisation want to achieve for our Focus Areas.', 'QAA', '2018-05-02 21:58:54.760566', '2018-05-03 08:49:24.257251');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (4, 'Juridical Commission', 'juridical@aegee.org', NULL, 'Notelaarsstraat 55', 'Since 1987 the Juridical Commission of AEGEE-Europe has been providing the whole Association with the most reliable sources of information as well as with internal legal consultancy. For all these years, the Commission has earned it''s place as the most important partner of the Comité Directeur and the Agora’s most trusted advisor.', 'XJU', '2018-05-02 20:08:21.966783', '2018-05-02 20:08:21.966792');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (5, 'Mediation Commission', 'medcom@aegee.org', NULL, 'Notelaarsstraat 55', 'The Mediation Commission (former Members Commission) acts in case a dispute occurs between members of AEGEE-Europe (locals, AEGEE-Academy), and is responsible for making decisions in these cases, occasionally leading to disciplinary sanctions against the ordinary member (local) of AEGEE-Europe. After carrying out an investigation, the Mediation Commission can suggest sanctions (including expulsion of a local from the Network) to be applied by the Comité Directeur and after by ratification of the Agora. In other words, in case there is a violation of the CIA, financial regulations, national law etc. by the ordinary member, the MedCom is activated.', 'XME', '2018-05-02 20:20:21.296668', '2018-05-02 20:20:21.296676');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (6, 'Network Commission', 'netcom@aegee.org', NULL, 'Notelaarsstraat 55', 'The Network Commission consists of up to eleven members elected by the Agora for the duration of twelve months. It’s primary tasks are to ensure the smooth functioning of the AEGEE locals that form the Network, and to enhance the internal communication both within the Network itself, and between the Network and AEGEE-Europe. Each Network Commissioner should always act in the interest of the Network as a whole, be a trusted source of information and give the best example of an active AEGEE member.', 'XNE', '2018-05-02 20:24:50.296874', '2018-05-02 20:24:50.296884');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (7, 'AEGEE-Academy', 'board@aegee-academy.org', NULL, 'Achter St.-Pieter 25, 3512HR Utrecht', 'AEGEE-Academy is the official pool of trainers of AEGEE, where we train AEGEEans in various skills that prepare them for their working life, their AEGEE life and contribute to their self-development. We provide training activities, experienced trainers and feedback on session designs for every type of local or international activity in AEGEE. We also train trainers and anyone that can benefit from knowledge on non-formal education methodologies on how to incorporate them in their activities. This way we help building a stronger network, where non-formal education is the key.', 'XIE', '2018-05-02 20:31:57.492188', '2018-05-02 20:31:57.492196');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (3, 'Audit Commission', 'audit@aegee.org', NULL, 'Notelaarsstraat 55', 'Entitled AEGEE body of financially competent members for auditing, checking, reporting, improving and investigating on the finances of AEGEE-Europe and AEGEE Locals within our Organisation.', 'XAU', '2018-05-02 19:59:32.398314', '2018-05-02 20:57:49.540424');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (22, 'Public Relations Committee', 'prc@aegee.org', NULL, 'Notelaarsstraat 55', 'Main aim of PRC is to support AEGEE-Europe and it''s locals with tasks related to Public Relations, communications, graphic design, promotion planning and journalism.', 'PRW', '2018-05-03 11:49:47.528604', '2018-05-03 11:49:47.528612');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (8, 'Events Quality Assurance Committee', 'quality.events@aegee.org', NULL, 'Notelaarsstraat 55', 'The Events Quality Assurance Committee’s role is to help and support the Locals in organising quality events. Our goal is to approve the quality and to increase the impact of the European events in AEGEE and outside of it.', 'EVC', '2018-05-02 20:48:36.199812', '2018-05-02 21:00:36.89381');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (12, 'AEGEE-Enschede', 'board@aegee-enschede.nl', '+31534321040', 'Oude Markt 24 7511 GB Enschede The Netherlands', 'AEGEE-Enschede one of the largest student associations in Enschede. There is no limit to the possibilities within AEGEE.', 'ENS', '2018-05-02 21:28:27.080883', '2018-05-02 21:28:27.080891');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (9, 'Chair Team of the Agora', 'chair@aegee.org', NULL, 'Notelaarsstraat 55', 'The Chair team is responsible for preparing and moderating the Agorae. They preside over them, take the minutes and are responsible for the IT during the events.', 'XCH', '2018-05-02 20:57:11.731766', '2018-05-02 21:46:30.370472');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (14, 'Corporate & Institutional Relations Committee', 'circ@aegee.org', NULL, 'Notelaarsstraat 55', 'The Corporate & Institutional Relations Committee (CIRC) is a supporting committee of AEGEE-Europe and was established by the Agora Enschede 2012. The tasks of the CIRC are such as  supporting the work of AEGEE-Europe and ensure its financial sustainability providing help, analyse the needs of the Network and European level, supporting the locals on fundraising issues, implementing the fundraising strategy and increase the financial resources of AEGEE-Europe. The CIRC holds an internal and external role and is entitled to act towards the stakeholders of AEGEE-Europe with permission and supervision of the Comité Directeur.', 'CRC', '2018-05-03 08:50:31.434227', '2018-05-03 08:50:43.685164');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (10, 'Civic Education Working Group', 'wg@civiceducation.eu', NULL, 'Notelaarsstraat 55', 'The Civic Education Working Group is coordinating AEGEE''s work on Civic Education. The role is to make sure AEGEE achieves it''s objectives by helping locals with the activities, delivering different workshops during AEGEE events, raising awareness for Civic Education inside and outside our association, following up on the European Citizens'' Initiative and more.', 'CEW', '2018-05-02 21:04:38.277988', '2018-05-03 09:13:48.949268');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (17, 'European Citizenship Working Group', 'ecwg@aegee.org', NULL, 'Notelaarsstraat 55', 'The European Citizenship Working Group is coordinating AEGEE''s work on European Citizenship. This Focus Area has the aim to empower young people to become active and critical European citizens by educating them on the diversity of European cultures and by enabling them to take an active role in shaping the European project.', 'ECW', '2018-05-03 09:18:03.400815', '2018-05-03 09:18:03.400824');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (11, 'AEGEE Election Observation (Project)', 'aeo@aegee.org', NULL, 'Notelaarsstraat 55', 'AEGEE Election Observation organises observation missions to elections in Europe. A typical mission lasts for 7 days and consists of 24 young European observers (any AEGEE member can apply to be an observer). During the mission, they meet politicians, institutions and youth organisations,on election day they observe the voting and vote-counting procedures on the ground. After the mission, they publish a report about the elections - and in particular about the participation of young people in these elections.', 'QEO', '2018-05-02 21:15:35.706482', '2018-05-03 13:58:37.534071');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (25, 'Eastern Partnership Project', 'eap@aegee.org', NULL, 'Notelaarsstraat 55', 'The Eastern Partnership project of AEGEE started in 2011 and since then it became more and more successful. It organises conferences, writes articles, makes interviews and generally tries to raise awareness about the Eastern European Partnership countries to help bringing them closer to the European Union.', 'QEP', '2018-05-03 14:32:37.026934', '2018-05-03 14:32:37.026942');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (26, 'European Planning Meeting', 'projects@aegee.org', NULL, 'Notelaarsstraat 55', 'The European Planning Meeting (EPM) is the annual thematic conference of AEGEE-Europe, providing a space for the Network to exchange views and ideas on the Focus Areas of the Strategic Plan and any other topic considered relevant.', 'QEC', '2018-05-03 14:51:15.551759', '2018-05-03 14:51:15.551768');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (16, 'Equal Rights Working Group', 'thedodora.giakoumelou@aegee.org', NULL, 'Notelaarsstraat 55', 'The Equal Rights Working Group is coordinating AEGEE''s work on Equal Rights. The focus area has the aim to acknowledge and tackle discrimination based on gender identity, expression and sexual orientation, promoting equity from an intersectional perspective.', 'ERW', '2018-05-03 09:11:02.575987', '2018-05-03 09:12:36.166125');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (20, 'Information Technology Committee', 'itc@aegee.org', NULL, 'Notelaarsstraat 55', 'The Information Technology Committee (ITC) is a supportive body of AEGEE-Europe. It’s primary aim is to help AEGEE with anything related to IT. The Information Technology Committee is divided in several informal Teams that act fairly independent.', 'IUG', '2018-05-03 10:00:35.286371', '2018-05-03 10:00:35.286379');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (23, 'Europe on Track Project', 'europeontrack@aegee.org', NULL, 'Notelaarsstraat 55', 'Europe on Track is a youth-led project where nine young ambassadors cross Europe with InterRail passes for one month, informing and interviewing young people about their vision of the Europe of tomorrow. In order to do so, they participate in local events bringing content and creating spaces for dialogue and discussion with a main focus that changes every year, achieving a bigger impact through a travel blog, videos and social media.', 'QET', '2018-05-03 12:03:32.888134', '2018-05-03 12:03:32.888142');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (24, 'YVote 2019 Project', 'philipp.blum@aegee-aachen.org', NULL, 'Notelaarsstraat 55', 'The Y Vote project strives to inform people in Europe, especially the youth, in order to equip them with the needed knowledge and to encourage them to be engaged in the democratic process in the future.', 'E19', '2018-05-03 14:21:44.708395', '2018-05-03 14:21:44.708403');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (18, 'Youth Development Working Group', 'ydwg@aegee.org', NULL, 'Notelaarsstraat 55', 'The Youth Development Working Group is coordinating AEGEE''s work on Youth Development. This Focus Area has the aim to provide young people with opportunities to gain transversal skills and competences that contribute to their personal and professional development.', 'YDW', '2018-05-03 09:26:59.517405', '2018-05-03 09:26:59.517413');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (2, 'Comité Directeur', 'cd@aegee.org', NULL, 'Notelaarsstraat 55, 1000 Brussel, Belgium', 'The Comité Directeur is the European Board of Directors. It administers the association and is composed of a maximum of seven members by the General Assembly for the term of one year. The Comité Directeur is vested with the widest possible powers to act in the name of the association.', 'XEU', '2018-05-02 19:03:42.916437', '2018-05-03 09:36:41.312064');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (15, 'Human Resources Committee', 'hrc@aegee.org', NULL, 'Notelaarsstraat 55', 'The mission of the Human Ressources Committee is to support and educate the Network of AEGEE in the field of Human Resources Management (HRM/HR). It coordinates the implementation of a tailored HR cycle according to the needs of AEGEE and assist any local and European Body in need of guidance. Through Internal education, we ensure that the new members who enter AEGEE receive all necessary skills and knowledge to rise inside the Network in any positions they wish to. Finally, we bring value to the AEGEE Network by providing mentoring and guidance to the locals and European Bodies, and supporting them in creating a sustainable and effective working atmosphere inside their teams.', 'HRC', '2018-05-03 09:01:01.866512', '2018-05-03 09:50:22.786819');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (19, 'Summer University Project', 'suct@aegee.org', NULL, 'Notelaarsstraat 55', 'The Summer University Project is centrally coordinated by the Summer University Coordination Team. The SUCT is a team of four AEGEE-members from different parts of Europe plus one appointed Comité Directeur member.', 'QSU', '2018-05-03 09:55:50.767773', '2018-05-03 09:57:20.089642');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (21, 'The AEGEEan Magazine Committee', 'aegeean@aegee.org', NULL, 'Notelaarsstraat 55', 'The AEGEEan is the official magazine of AEGEE. It was founded to be the place for members to access relevant news about our organisation, and to be the place for people to share their AEGEE experience: a magazine of, by, and for members of AEGEE.', 'QAE', '2018-05-03 11:43:27.889188', '2018-05-03 11:44:26.46757');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (27, '30 Years of SU Project', 'su30@aegee.org', NULL, 'Notelaarsstraat 55', 'The main aim of the 30th anniversary project is to assess how the Summer University project is currently seen and subsequently identify its present as well as future identity.', 'S30', '2018-05-03 16:38:53.307715', '2018-05-03 16:38:53.307723');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (29, 'Les Anciens', 'anciens-board-l@aegee.org', NULL, 'Europe', 'Les Anciens d’AEGEE is the alumni organisation for former AEGEE members. It organises regular events where members meet and supports AEGEE when and where possible.', 'XAN', '2018-05-03 17:16:52.596163', '2018-05-03 17:16:52.596171');
INSERT INTO bodies (id, name, email, phone, address, description, legacy_key, inserted_at, updated_at) VALUES (28, 'Honorary Members', 'president@aegee.org', NULL, 'Notelaarsstraat 55', 'Honorary Members are individuals, having performed outstanding service for the community of AEGEE-Europe, upon whom the Association desires to confer special distinction.', 'XHO', '2018-05-03 17:04:46.066781', '2018-05-03 17:04:46.06679');


ALTER TABLE bodies ENABLE TRIGGER ALL;


--
-- Data for Name: circles; Type: TABLE DATA; Schema: public; Owner: postgres
--

ALTER TABLE circles DISABLE TRIGGER ALL;

INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (3, 'IT interest group', 'IT-interested people in the system', true, NULL, NULL, '2018-05-02 18:01:11.612989', '2018-05-02 18:01:11.612998');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (4, 'Superadmins', 'This circle holds all permissions in the system and thus effectively makes you superadmin', false, NULL, NULL, '2018-05-02 18:01:11.627927', '2018-05-02 18:01:11.627939');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (1, 'Board AEGEE-Dresden', 'basically doing nothing', false, 1, 2, '2018-05-02 18:01:11.582192', '2018-05-02 18:01:11.644429');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (6, 'General members circle', 'All members of Antennae and Contact-Antennae', false, NULL, NULL, '2018-05-02 19:45:10.513283', '2018-05-02 19:45:10.513291');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (8, 'Audit Commissioners', 'Circle of Audit Commissioners', false, 3, 2, '2018-05-02 20:05:48.441287', '2018-05-02 20:06:04.464914');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (9, 'Juridical Commissioners', 'Circle of Juridical Commissioners', false, 4, 2, '2018-05-02 20:13:37.197634', '2018-05-02 20:14:58.037365');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (10, 'Mediation Commissioners', 'Circle of Mediation Commissioners', false, 5, 2, '2018-05-02 20:20:39.658759', '2018-05-02 20:21:57.353637');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (11, 'Network Commissioners', 'Circle of Network Commissioners', false, 6, 2, '2018-05-02 20:27:34.395052', '2018-05-02 20:27:49.040716');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (12, 'Board AEGEE-Academy', 'Board members of the Academy', false, 7, 2, '2018-05-02 20:32:31.132334', '2018-05-02 20:32:47.650733');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (13, 'AEGEE-Academy members', 'Members of AEGEE-Academy need to be members of an AEGEE local. (Circle should not be child of general members circle)', false, 7, NULL, '2018-05-02 20:34:42.708721', '2018-05-02 20:35:38.123146');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (14, 'EQAC Speaker Team', 'Speaker Team of the Events Quality Assurance Committee', false, 8, 2, '2018-05-02 20:50:28.21424', '2018-05-02 20:50:49.79318');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (15, 'Chairs', 'The Chair and Vice-Chair are elected by the Agora', false, 9, 2, '2018-05-02 21:00:00.875618', '2018-05-02 21:00:20.223893');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (19, 'Gender Equality Interest Group', 'The Gender Equality Interest Group creates a space for discussion and learning about issues regarding gender. We strive for equality within our network as well as outside of it, focusing on gender and taking into account other ways of discrimination from an intersectional perspective. If you are interested in organizing an activity about the topic don’t hesitate to ask us for materials.', true, NULL, NULL, '2018-05-02 21:22:21.937682', '2018-05-02 21:22:33.889603');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (20, 'Health4Youth Interest Group', '"H4Y IG stands for educating AEGEEans about health matters. Our goal is to promote a healthy lifestyle among European students and motivate them to adopt it in their lives.   What exactly do we do? Healthy SUs and other events, workshops, surveys, booklets and much more! Brainstorming Skype meetings take place once a month. Join and make AEGEE more healthy one AEGEEan at a time.', true, NULL, NULL, '2018-05-02 21:23:21.241894', '2018-05-02 21:23:21.241904');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (21, 'Language Interest Group', 'The goal of the Language Interest Group is to raise the awareness within AEGEE about the value of multilingualism, to encourage and help AEGEEans to learn more foreign languages and to discuss issues related to language policies and diversity, as well as to minority languages. By organising different projects and supporting locals in the organisation of language related activities and events, we are breaking language barriers and promoting the benefits of language learning.', true, NULL, NULL, '2018-05-02 21:23:57.658708', '2018-05-02 21:23:57.658717');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (22, 'Board AEGEE-Enschede', 'The Board can be found on weekdays between 10:00-17:00 at the Office of AEGEE-Enschede in the Pakkerij and on Tuesday and Thursday evenings in our pub Asterion.', false, 12, 2, '2018-05-02 21:30:11.002392', '2018-05-02 21:32:10.959859');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (17, 'CEWG Coordinator', 'The Coordinator is responsible for the recruitment of the Policy Officer and the other Working Group Members.', false, 10, 2, '2018-05-02 21:07:30.256859', '2018-05-02 21:32:39.758453');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (18, 'AEO Project Managers', 'Three representatives in the function of Project Manager, Financial Manager and Content Manager, whose exact responsibilities are defined in the contract.', false, 11, 2, '2018-05-02 21:21:29.771685', '2018-05-02 21:32:50.784458');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (24, 'DRINK-WISE', 'DRINKWISE is striving to explore issues related to drinking and aspects of the drinking culture that make us feel united or divided. One of the goals is also to highlight the importance of traditional drinks as part of our local culture and to promote responsible and healthy drinking habits.', true, NULL, NULL, '2018-05-02 21:36:01.710414', '2018-05-02 21:36:26.14874');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (25, 'Liasson Officers', 'The Liaison Officers are experienced AEGEE members who work with an organisation specifically assigned to them together with a board member of AEGEE-Europe in order to maximize the cooperation possibility. The Liaison Office ensures bigger capacity for AEGEE to be actively contributing to European and global processes and developments and realise concrete activities that will further strengthen AEGEEs position.', false, NULL, NULL, '2018-05-02 21:37:17.207782', '2018-05-02 21:37:17.20779');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (26, 'CIRC Speaker Team', 'The speaker team (ST) is responsible to send the open call to announce-l for new members upon internal needs and decides upon the selection of membership applications', false, 14, 2, '2018-05-03 08:52:59.792175', '2018-05-03 08:53:15.217222');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (27, 'ACT Speaker Team', 'The ACT is coordinated by the Speaker, up to two Vice-Speakers and the CD member responsible for the Action Agenda', false, 13, 2, '2018-05-03 08:55:21.364765', '2018-05-03 08:55:31.010388');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (2, 'General board circle', 'This is the toplevel circle for all boards in the system. It grants boards administrative rights for their body.', false, NULL, NULL, '2018-05-02 18:01:11.594686', '2018-05-03 08:56:02.955449');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (28, 'HRC Board', 'The HRC Board consists of two elected members and one appointed Comité Directeur member.', false, 15, 2, '2018-05-03 09:02:23.492827', '2018-05-03 09:02:47.44632');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (29, 'ECWG Coordinator', 'The Coordinator is responsible for the recruitment of the Policy Officer and the other Working Group Members.', false, 17, 2, '2018-05-03 09:22:27.90235', '2018-05-03 09:22:45.206766');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (30, 'ERWG Coordinator', 'The Coordinator is responsible for the recruitment of the Policy Officer and the other Working Group Members.', false, 16, 2, '2018-05-03 09:23:13.453221', '2018-05-03 09:23:25.732016');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (31, 'YDWG Coordinator', 'The Coordinator is responsible for the recruitment of the Policy Officer and the other Working Group Members.', false, 18, 2, '2018-05-03 09:28:24.939959', '2018-05-03 09:28:49.329461');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (33, 'ITC Board', 'The ITC Board is responsible for the coordination of the different teams', false, 20, NULL, '2018-05-03 10:01:13.988804', '2018-05-03 10:01:13.988812');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (16, 'Directors', 'A maximum of seven members from the Locals are the Directors. The Directors are the members of the Comité Directeur.', false, 2, 2, '2018-05-02 21:01:11.335292', '2018-05-03 09:38:24.473598');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (32, 'SUCT members', 'The SUCT is responsible for the good functioning and development of the project during one year.', false, 19, 2, '2018-05-03 09:57:39.269442', '2018-05-03 09:58:28.795923');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (36, 'AEGEEan Speaker Team', 'The AEGEEan Speaker Team consists of two elected members, i.e. Editor-in-Chief and Vice-Editor-in-Chief, and one appointed Comité Directeur member.', false, 21, 2, '2018-05-03 11:46:21.82071', '2018-05-03 11:46:33.56028');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (45, 'Faces of Europe', 'Faces of Europe wants to collect and spread the faces and voices of people from different social, cultural and national backgrounds and to find out what ‘Europe’ means to them.', false, NULL, NULL, '2018-05-03 14:35:41.679874', '2018-05-03 14:35:41.679894');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (5, 'System Admins', 'Creating and modifying the system', false, 2, 35, '2018-05-02 19:05:26.232486', '2018-05-03 15:01:35.809241');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (34, 'ITC OMS Team', 'Administers OMS/intranet/MyAEGEE/THIS and provides support to its users', false, 20, 35, '2018-05-03 10:11:03.389427', '2018-05-03 15:00:07.284651');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (23, 'Members AEGEE-Enschede', 'Circle of members in Enschede. All local members should be members of this circle to apply permissions of AEGEE membership.', false, 12, 6, '2018-05-02 21:34:37.64428', '2018-05-03 15:12:06.48044');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (37, 'PRC Speaker Team', 'The PRC is coordinated by the Speaker Team, which consists of one Speaker, one Vice-Speaker, and an appointed Comité Directeur member.', false, 22, 2, '2018-05-03 11:52:06.818551', '2018-05-03 11:52:20.701571');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (39, 'AEGEE Day', 'AEGEE Day is the project celebrating the Anniversaries of our association in the means of organising various activities, which set the focus on the principles of AEGEE.', false, NULL, NULL, '2018-05-03 11:55:35.087721', '2018-05-03 11:55:35.087729');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (43, 'YVote Project Managers', 'Three representatives in the function of Project Manager, Financial Manager and Content Manager, whose exact responsibilities are defined in the contract.', false, 24, 2, '2018-05-03 14:31:15.907365', '2018-05-03 14:31:31.193641');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (50, 'SU30 Project Managers', 'Three representatives in the function of Project Manager, Financial Manager and Content Manager, whose exact responsibilities are defined in the contract.', false, 27, 2, '2018-05-03 16:39:21.959687', '2018-05-03 16:39:38.404978');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (52, 'LGBT+ Interest Group', 'LGBT+ Interest Group was created to raise awareness about this topic inside and outside of AEGEE, foster international debate and to provide help to the locals and members when needed.', true, NULL, NULL, '2018-05-03 16:42:42.935041', '2018-05-03 16:42:42.935051');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (40, 'Key to Europe', 'Key to Europe is an annual publication about AEGEE, its structures successes and general ongoings. The team is responsible for its drafting and compilation and later on also for its distribution to the Network and External Partners.', false, NULL, NULL, '2018-05-03 11:57:04.642878', '2018-05-03 11:57:04.642886');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (41, 'Policy Officers', 'Internally, Policy Officers support the work of Comité Directeur, Working Groups and potentially projects with the same thematic field. Externally, they represent the position of AEGEE on topics they are working on, and participate in policy-making processes.', false, NULL, NULL, '2018-05-03 12:01:22.930704', '2018-05-03 12:01:22.930728');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (42, 'EOT Project Managers', 'Three representatives in the function of Project Manager, Financial Manager and Content Manager, whose exact responsibilities are defined in the contract.', false, 23, 2, '2018-05-03 12:04:08.806091', '2018-05-03 12:04:24.432613');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (44, 'EAP Project Managers', 'Three representatives in the function of Project Manager, Financial Manager and Content Manager, whose exact responsibilities are defined in the contract.', false, 25, NULL, '2018-05-03 14:33:56.875239', '2018-05-03 14:33:56.875246');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (7, 'Members AEGEE-Dresden', 'Circle of members in Dresden. All local members should be members of this circle to apply permissions of AEGEE membership.', false, 1, 6, '2018-05-02 19:49:47.533611', '2018-05-03 15:11:51.921378');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (46, 'EPM Content Team and CD responsible(s)', 'The Content Team is appointed by the Comité Directeur. The Content Team, in cooperation with the Comité Directeur, is responsible for the preparation of the EPM.', false, 26, 2, '2018-05-03 14:53:11.0293', '2018-05-03 16:40:07.769941');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (51, 'Culture Interest Group', 'Are you interested in culture? Would you like to write for an international cultural website and organize international events? Do you want to deepen your engagement within the AEGEE community? Are you just curious? Don''t miss the chance and join the Culture Interest Group! Visit our blog, spread your ideas, write on your favorite themes and participate in our thematic events. The aim of our Interest Group is to promote European culture in all its form.', true, NULL, NULL, '2018-05-03 16:42:07.81129', '2018-05-03 16:42:07.811298');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (53, 'Migration Interest Group', 'The Migration Interest GRoup (MIGR) focusses its activities on raising awareness, sharing the best practices, taking concrete initiatives, participating at Migration-related conferences, and making advocacy on the rights of Migrants', true, NULL, NULL, '2018-05-03 16:44:09.081181', '2018-05-03 16:44:09.081189');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (47, 'Workshop Leaders', 'Workshops serve to address any topic of interest to the EPM. They may be moderated by participants of the EPM as well as external speakers.', false, 26, NULL, '2018-05-03 14:54:18.45195', '2018-05-03 14:58:26.228956');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (35, 'General Admin circle', 'This is the toplevel circle for all system admin circles. It grants admins global administrative rights, but no superadministrator rights (permissions).', false, NULL, NULL, '2018-05-03 10:12:36.185479', '2018-05-03 16:12:43.072928');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (48, 'Action Meeting Facilitators', 'Action Meetings serve to develop the Action Agenda for the upcoming Planning Year by drafting objectives and corresponding activities. 2Action Meetings have a flexible structure, allowing participants to arrange ad hoc meetings at any time for the development of activities.', false, 26, NULL, '2018-05-03 14:58:14.038289', '2018-05-03 14:58:14.038298');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (49, 'Network Director', 'The Network Director might need some special privileges to add and remove locals (?)', false, 2, NULL, '2018-05-03 15:06:47.307666', '2018-05-03 15:06:47.307676');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (54, 'Politics Interest Group', 'The mission of the Politics Interest Group is to foster international political discussion on an academic and analytical level. The focus is be set on bringing politics closer to the members and make them active in todays society.', true, NULL, NULL, '2018-05-03 16:45:42.970673', '2018-05-03 16:45:42.970681');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (55, 'Society and Enviroment Interest Group', 'Society and the Environment Interest Group is there to open a space for AEGEEans to discuss and make changes inside AEGEE in order to make it more Sustainable and respectful of our selves and our planet. We are aiming at raising awareness and becoming actors of change in the environmental field. We have as an organisation the potential to be proactive in the process of change, it''s up to us to make it happen.', true, NULL, NULL, '2018-05-03 16:46:13.101978', '2018-05-03 16:46:13.101985');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (56, 'SUpporters Interest Group', 'SUpporters Interest Group was created in autumn 2015 by SUCT as the task force for all interested members who would like to help SU project by working closely with appointed SUCT members on specific tasks, such as all kinds of designing, website support, training and representing on events, creating booklets, promotion and more. Tasks are created by SUCT and forwarded to SUpporters who then deliver the result and do not have to be involved in anything else. This IG is very task oriented and therefore every member can find whatever suits his or her needs and interests.', true, NULL, NULL, '2018-05-03 16:47:22.074814', '2018-05-03 16:51:04.401906');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (57, 'Advisory Board', 'The advisory board is tasked with advising the Comité Directeur in the broadest sense possible. The advisory board has no decisive power.', false, NULL, NULL, '2018-05-03 17:02:24.366374', '2018-05-03 17:02:24.366382');
INSERT INTO circles (id, name, description, joinable, body_id, parent_circle_id, inserted_at, updated_at) VALUES (58, 'Circle of Honorary Members', 'Honorary Members are not "AEGEE members" and can only obtain AEGEE member rights through local membership.', false, 28, NULL, '2018-05-03 17:07:12.429507', '2018-05-03 17:07:12.429547');


ALTER TABLE circles ENABLE TRIGGER ALL;

--
-- Name: bodies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('bodies_id_seq', 29, true);


--
--
-- Name: circles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('circles_id_seq', 58, true);




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
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

