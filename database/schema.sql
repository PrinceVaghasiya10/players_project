--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

-- Started on 2026-06-12 22:26:22

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 265 (class 1255 OID 26280)
-- Name: add_individual_player(character varying, date, character varying, character varying, character varying, integer, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.add_individual_player(IN pname character varying, IN dob date, IN gender character varying, IN health_status character varying, IN medical_clearance character varying, IN college_id integer, IN sport_name character varying, IN ranking integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
  new_player_id INT;
BEGIN
  -- Step 1: Insert into Players
  INSERT INTO Players (Name, Date_of_Birth, Gender, Health_Status, Medical_Clearance)
  VALUES (pname, dob, gender, health_status, medical_clearance)
  RETURNING Player_ID INTO new_player_id;

  -- Step 2: Insert into Individual_Sport_Players
  INSERT INTO Individual_Sport_Players (Player_ID, College_ID, Sport_Name, Ranking)
  VALUES (new_player_id, college_id, sport_name, ranking);

  RAISE NOTICE '✅ New Individual Player "%" added successfully (Sport: %)', pname, sport_name;
END;
$$;


ALTER PROCEDURE public.add_individual_player(IN pname character varying, IN dob date, IN gender character varying, IN health_status character varying, IN medical_clearance character varying, IN college_id integer, IN sport_name character varying, IN ranking integer) OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 26278)
-- Name: add_new_individual_match(integer, character varying, integer, integer, integer, character varying, date, time without time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.add_new_individual_match(IN tournament_id integer, IN sport_name character varying, IN player1_id integer, IN player2_id integer, IN venue_id integer, IN match_type character varying, IN match_date date, IN start_time time without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO Individual_Sport_Matches (
    Tournament_ID,
    Sport_Name,
    Player1_ID,
    Player2_ID,
    Venue_ID,
    Match_Type,
    Match_Status,
    Date,
    Start_Time
  )
  VALUES (
    tournament_id,
    sport_name,
    player1_id,
    player2_id,
    venue_id,
    match_type,
    'Scheduled',
    match_date,
    start_time
  );

  RAISE NOTICE '✅ New individual match added: % vs % on %', player1_id, player2_id, match_date;
END;
$$;


ALTER PROCEDURE public.add_new_individual_match(IN tournament_id integer, IN sport_name character varying, IN player1_id integer, IN player2_id integer, IN venue_id integer, IN match_type character varying, IN match_date date, IN start_time time without time zone) OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 26277)
-- Name: add_new_team(character varying, integer, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.add_new_team(IN tname character varying, IN college_id integer, IN sport_name character varying, IN captain_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO Teams (Name, College_ID, Sport_Name, Captain_Name)
  VALUES (tname, college_id, sport_name, captain_name);

  RAISE NOTICE '✅ New team "%" added successfully for sport "%".', tname, sport_name;
END;
$$;


ALTER PROCEDURE public.add_new_team(IN tname character varying, IN college_id integer, IN sport_name character varying, IN captain_name character varying) OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 26279)
-- Name: add_new_team_match(integer, character varying, integer, integer, integer, character varying, date, time without time zone); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.add_new_team_match(IN tournament_id integer, IN sport_name character varying, IN team1_id integer, IN team2_id integer, IN venue_id integer, IN match_type character varying, IN match_date date, IN start_time time without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO Team_Sport_Matches (
    Tournament_ID,
    Sport_Name,
    Team1_ID,
    Team2_ID,
    Venue_ID,
    Match_Type,
    Match_Status,
    Date,
    Start_Time
  )
  VALUES (
    tournament_id,
    sport_name,
    team1_id,
    team2_id,
    venue_id,
    match_type,
    'Scheduled',
    match_date,
    start_time
  );

  RAISE NOTICE '✅ New team match added: Team % vs Team % on %', team1_id, team2_id, match_date;
END;
$$;


ALTER PROCEDURE public.add_new_team_match(IN tournament_id integer, IN sport_name character varying, IN team1_id integer, IN team2_id integer, IN venue_id integer, IN match_type character varying, IN match_date date, IN start_time time without time zone) OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 26281)
-- Name: add_team_player(character varying, date, character varying, character varying, character varying, integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.add_team_player(IN pname character varying, IN dob date, IN gender character varying, IN health_status character varying, IN medical_clearance character varying, IN team_id integer, IN p_position character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
  new_player_id INT;
BEGIN
  -- Step 1: Insert player into main Players table
  INSERT INTO Players (Name, Date_of_Birth, Gender, Health_Status, Medical_Clearance)
  VALUES (pname, dob, gender, health_status, medical_clearance)
  RETURNING Player_ID INTO new_player_id;

  -- Step 2: Validate team_id exists
  IF NOT EXISTS (SELECT 1 FROM Teams WHERE Team_ID = team_id) THEN
    RAISE EXCEPTION '❌ Invalid Team_ID: %, no such team found!', team_id;
  END IF;

  -- Step 3: Insert into Team_Sport_Players
  INSERT INTO Team_Sport_Players (Player_ID, Team_ID, Player_Position)
  VALUES (new_player_id, team_id, p_position);

  -- Step 4: Confirmation message
  RAISE NOTICE '✅ New team player "%" (ID: %) added successfully to Team_ID %.',
    pname, new_player_id, team_id;
END;
$$;


ALTER PROCEDURE public.add_team_player(IN pname character varying, IN dob date, IN gender character varying, IN health_status character varying, IN medical_clearance character varying, IN team_id integer, IN p_position character varying) OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 26273)
-- Name: get_player_stats(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_player_stats(pid integer) RETURNS TABLE(total_matches integer, total_wins integer, total_losses integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    Get_Player_Total_Matches(pid) AS Total_Matches,
    Get_Player_Total_Wins(pid) AS Total_Wins,
    (Get_Player_Total_Matches(pid) - Get_Player_Total_Wins(pid)) AS Total_Losses;
END;
$$;


ALTER FUNCTION public.get_player_stats(pid integer) OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 26271)
-- Name: get_player_total_matches(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_player_total_matches(pid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  total_individual INT := 0;
  total_team INT := 0;
BEGIN
  -- Count matches in Individual Sports
  SELECT COUNT(*) INTO total_individual
  FROM Individual_Sport_Matches im
  WHERE (im.Player1_ID = pid OR im.Player2_ID = pid) AND im.match_status = 'Finished';

  -- Count matches in Team Sports (via Team_Sport_Players)
  SELECT COUNT(*) INTO total_team
  FROM Team_Sport_Matches tm
  JOIN Team_Sport_Players tsp ON tm.Team1_ID = tsp.Team_ID OR tm.Team2_ID = tsp.Team_ID
  WHERE tsp.Player_ID = pid AND tm.match_status = 'Finished';

  -- Return total matches played
  RETURN total_individual + total_team;
END;
$$;


ALTER FUNCTION public.get_player_total_matches(pid integer) OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 26272)
-- Name: get_player_total_wins(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_player_total_wins(pid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  total_individual_wins INT := 0;
  total_team_wins INT := 0;
BEGIN
  -- 🏅 Individual sport wins
  SELECT COUNT(*) INTO total_individual_wins
  FROM Individual_Sport_Result ir
  WHERE ir.Winner_Player_ID = pid;

  -- 🏆 Team sport wins (player is in the winning team)
  SELECT COUNT(*) INTO total_team_wins
  FROM Team_Sport_Result tr
  JOIN Team_Sport_Players tsp ON tr.Winning_Team_ID = tsp.Team_ID
  WHERE tsp.Player_ID = pid;

  -- Return combined total
  RETURN total_individual_wins + total_team_wins;
END;
$$;


ALTER FUNCTION public.get_player_total_wins(pid integer) OWNER TO postgres;

--
-- TOC entry 267 (class 1255 OID 26282)
-- Name: get_referee_fairness(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_referee_fairness(ref_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  avg_rating NUMERIC;
BEGIN
  SELECT COALESCE(AVG(rating_data.Fairness_Rating), 0)
  INTO avg_rating
  FROM (
    SELECT Fairness_Rating FROM I_Match_Ref WHERE Referee_ID = ref_id
    UNION ALL
    SELECT Fairness_Rating FROM T_Match_Ref WHERE Referee_ID = ref_id
  ) AS rating_data;

  RETURN ROUND(avg_rating, 2);
END;
$$;


ALTER FUNCTION public.get_referee_fairness(ref_id integer) OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 26284)
-- Name: get_sponsor_total_contribution(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_sponsor_total_contribution(sid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  total_contribution NUMERIC;
BEGIN
  SELECT COALESCE(SUM(Contribution_Amount), 0)
  INTO total_contribution
  FROM Sponsorship_Record
  WHERE Sponsor_ID = sid;

  RETURN total_contribution;
END;
$$;


ALTER FUNCTION public.get_sponsor_total_contribution(sid integer) OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 26276)
-- Name: get_team_stats(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_team_stats(tid integer) RETURNS TABLE(total_matches integer, total_wins integer, total_losses integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    Get_Team_Total_Matches(tid) AS Total_Matches,
    Get_Team_Total_Wins(tid) AS Total_Wins,
    (Get_Team_Total_Matches(tid) - Get_Team_Total_Wins(tid)) AS Total_Losses;
END;
$$;


ALTER FUNCTION public.get_team_stats(tid integer) OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 26274)
-- Name: get_team_total_matches(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_team_total_matches(tid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  total_matches INT := 0;
BEGIN
  SELECT COUNT(*)
  INTO total_matches
  FROM Team_Sport_Matches
  WHERE (Team1_ID = tid OR Team2_ID = tid)
    AND Match_Status = 'Finished';

  RETURN total_matches;
END;
$$;


ALTER FUNCTION public.get_team_total_matches(tid integer) OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 26275)
-- Name: get_team_total_wins(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_team_total_wins(tid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  total_wins INT := 0;
BEGIN
  SELECT COUNT(*)
  INTO total_wins
  FROM Team_Sport_Result
  WHERE Winning_Team_ID = tid;

  RETURN total_wins;
END;
$$;


ALTER FUNCTION public.get_team_total_wins(tid integer) OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 26286)
-- Name: get_venue_match_counts(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_venue_match_counts(vid integer) RETURNS TABLE(total_matches integer, finished_matches integer, remaining_matches integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
  total_individual BIGINT := 0;
  total_team BIGINT := 0;
  finished_individual BIGINT := 0;
  finished_team BIGINT := 0;
BEGIN
  -- 🏅 Count all matches from Individual_Sport_Matches
  SELECT COUNT(*) INTO total_individual
  FROM Individual_Sport_Matches
  WHERE Venue_ID = vid;

  -- 🏆 Count all matches from Team_Sport_Matches
  SELECT COUNT(*) INTO total_team
  FROM Team_Sport_Matches
  WHERE Venue_ID = vid;

  -- ✅ Count finished matches from Individual_Sport_Matches
  SELECT COUNT(*) INTO finished_individual
  FROM Individual_Sport_Matches
  WHERE Venue_ID = vid AND Match_Status = 'Finished';

  -- ✅ Count finished matches from Team_Sport_Matches
  SELECT COUNT(*) INTO finished_team
  FROM Team_Sport_Matches
  WHERE Venue_ID = vid AND Match_Status = 'Finished';

  -- ✅ Return results
  RETURN QUERY
  SELECT
    (total_individual + total_team)::INT AS Total_Matches,
    (finished_individual + finished_team)::INT AS Finished_Matches,
    ((total_individual + total_team) - (finished_individual + finished_team))::INT AS Remaining_Matches;
END;
$$;


ALTER FUNCTION public.get_venue_match_counts(vid integer) OWNER TO postgres;

--
-- TOC entry 268 (class 1255 OID 26283)
-- Name: get_volunteer_rating(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_volunteer_rating(vol_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  avg_rating NUMERIC;
BEGIN
  SELECT COALESCE(AVG(rating_data.Rating), 0)
  INTO avg_rating
  FROM (
    SELECT Rating FROM I_Volunteering_Record WHERE Volunteer_ID = vol_id
    UNION ALL
    SELECT Rating FROM T_Volunteering_Record WHERE Volunteer_ID = vol_id
  ) AS rating_data;

  RETURN ROUND(avg_rating, 2);
END;
$$;


ALTER FUNCTION public.get_volunteer_rating(vol_id integer) OWNER TO postgres;

--
-- TOC entry 272 (class 1255 OID 26289)
-- Name: mark_individual_match_finished(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.mark_individual_match_finished() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE Individual_Sport_Matches
  SET Match_Status = 'Finished'
  WHERE I_Match_ID = NEW.I_Match_ID;

  RAISE NOTICE 'Individual Match % marked as Finished.', NEW.I_Match_ID;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.mark_individual_match_finished() OWNER TO postgres;

--
-- TOC entry 273 (class 1255 OID 26291)
-- Name: mark_team_match_finished(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.mark_team_match_finished() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE Team_Sport_Matches
  SET Match_Status = 'Finished'
  WHERE T_Match_ID = NEW.T_Match_ID;

  RAISE NOTICE 'Team Match % marked as Finished.', NEW.T_Match_ID;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.mark_team_match_finished() OWNER TO postgres;

--
-- TOC entry 271 (class 1255 OID 26287)
-- Name: update_player_health_on_injury(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_player_health_on_injury() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE Players
  SET Health_Status = 'Injured'
  WHERE Player_ID = NEW.Player_ID;

  RAISE NOTICE 'Player ID % marked as Injured due to new Injury_Record.', NEW.Player_ID;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_player_health_on_injury() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 18088)
-- Name: colleges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.colleges (
    college_id integer NOT NULL,
    name character varying(100) NOT NULL,
    area character varying(100),
    city character varying(100) NOT NULL,
    email character varying(100),
    dean_name character varying(100),
    establishment_year integer,
    ranking integer,
    CONSTRAINT colleges_establishment_year_check CHECK ((establishment_year > 1800)),
    CONSTRAINT colleges_ranking_check CHECK ((ranking >= 0))
);


ALTER TABLE public.colleges OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 18362)
-- Name: i_issue_record; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.i_issue_record (
    i_match_id integer NOT NULL,
    item_id integer NOT NULL,
    issue_time time without time zone NOT NULL,
    return_time time without time zone,
    issue_quantity integer,
    CONSTRAINT i_issue_record_issue_quantity_check CHECK ((issue_quantity >= 0))
);


ALTER TABLE public.i_issue_record OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 18395)
-- Name: i_match_ref; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.i_match_ref (
    i_match_id integer NOT NULL,
    referee_id integer NOT NULL,
    role character varying(50),
    fairness_rating numeric(3,2)
);


ALTER TABLE public.i_match_ref OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 18425)
-- Name: i_volunteering_record; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.i_volunteering_record (
    i_match_id integer NOT NULL,
    volunteer_id integer NOT NULL,
    role character varying(50),
    rating numeric(3,2),
    hours_worked integer
);


ALTER TABLE public.i_volunteering_record OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 18273)
-- Name: individual_sport_matches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.individual_sport_matches (
    i_match_id integer NOT NULL,
    tournament_id integer NOT NULL,
    sport_name character varying(100) NOT NULL,
    player1_id integer NOT NULL,
    player2_id integer NOT NULL,
    venue_id integer NOT NULL,
    match_type character varying(50),
    match_status character varying(50),
    date date NOT NULL,
    start_time time without time zone
);


ALTER TABLE public.individual_sport_matches OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 18107)
-- Name: individual_sport_players; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.individual_sport_players (
    player_id integer NOT NULL,
    college_id integer,
    sport_name character varying(50),
    ranking integer,
    CONSTRAINT individual_sport_players_ranking_check CHECK ((ranking >= 0))
);


ALTER TABLE public.individual_sport_players OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 18303)
-- Name: individual_sport_result; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.individual_sport_result (
    i_result_id integer NOT NULL,
    i_match_id integer NOT NULL,
    winner_player_id integer NOT NULL,
    duration time without time zone,
    scores character varying(100),
    highlights text
);


ALTER TABLE public.individual_sport_result OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 18193)
-- Name: injury_record; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.injury_record (
    player_id integer NOT NULL,
    staff_id integer NOT NULL,
    injury_date date NOT NULL,
    injury_type character varying(100),
    body_part_affected character varying(100)
);


ALTER TABLE public.injury_record OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 18233)
-- Name: inventory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory (
    item_id integer NOT NULL,
    item_name character varying(100) NOT NULL,
    purchase_date date,
    quantity integer,
    storage_location character varying(100),
    cost numeric(10,2),
    condition character varying(50),
    CONSTRAINT inventory_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE public.inventory OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 18187)
-- Name: medical_staff; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medical_staff (
    staff_id integer NOT NULL,
    name character varying(100) NOT NULL,
    qualification character varying(100),
    emergency_contact character varying(15) NOT NULL,
    specialization character varying(100),
    years_of_experience integer DEFAULT 0,
    hospital_clinic_affiliation character varying(100)
);


ALTER TABLE public.medical_staff OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 18101)
-- Name: players; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players (
    player_id integer NOT NULL,
    name character varying(100) NOT NULL,
    date_of_birth date NOT NULL,
    gender character(1),
    health_status character varying(50) NOT NULL,
    medical_clearance boolean NOT NULL,
    CONSTRAINT players_gender_check CHECK ((gender = ANY (ARRAY['M'::bpchar, 'F'::bpchar, 'O'::bpchar])))
);


ALTER TABLE public.players OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 18241)
-- Name: referees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.referees (
    referee_id integer NOT NULL,
    sport_name character varying(100) NOT NULL,
    name character varying(100) NOT NULL,
    experience integer DEFAULT 0,
    contact character varying(15),
    availability_status character varying(50)
);


ALTER TABLE public.referees OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 18208)
-- Name: sponsors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sponsors (
    sponsor_id integer NOT NULL,
    name character varying(100) NOT NULL,
    industry_type character varying(100),
    contact character varying(15)
);


ALTER TABLE public.sponsors OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 18213)
-- Name: sponsorship_record; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sponsorship_record (
    sponsor_id integer NOT NULL,
    tournament_id integer NOT NULL,
    contribution_amount numeric(10,2),
    contract_date date NOT NULL,
    sponsorship_type character varying(100)
);


ALTER TABLE public.sponsorship_record OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 18083)
-- Name: sports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sports (
    sport_name character varying(100) NOT NULL,
    sport_type character varying(50) NOT NULL
);


ALTER TABLE public.sports OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 18378)
-- Name: t_issue_record; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_issue_record (
    t_match_id integer NOT NULL,
    item_id integer NOT NULL,
    issue_time time without time zone NOT NULL,
    return_time time without time zone,
    issued_quantity integer,
    CONSTRAINT t_issue_record_issued_quantity_check CHECK ((issued_quantity >= 0))
);


ALTER TABLE public.t_issue_record OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 18410)
-- Name: t_match_ref; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_match_ref (
    t_match_id integer NOT NULL,
    referee_id integer NOT NULL,
    role character varying(50),
    fairness_rating numeric(3,2)
);


ALTER TABLE public.t_match_ref OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 18440)
-- Name: t_volunteering_record; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.t_volunteering_record (
    t_match_id integer NOT NULL,
    volunteer_id integer NOT NULL,
    role character varying(50),
    rating numeric(3,2),
    hours_worked integer
);


ALTER TABLE public.t_volunteering_record OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 18317)
-- Name: team_sport_matches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team_sport_matches (
    t_match_id integer NOT NULL,
    tournament_id integer NOT NULL,
    sport_name character varying(100) NOT NULL,
    team1_id integer NOT NULL,
    team2_id integer NOT NULL,
    venue_id integer NOT NULL,
    match_type character varying(50),
    match_status character varying(50),
    date date,
    start_time time without time zone
);


ALTER TABLE public.team_sport_matches OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 18143)
-- Name: team_sport_players; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team_sport_players (
    player_id integer NOT NULL,
    team_id integer,
    player_position character varying(50) NOT NULL
);


ALTER TABLE public.team_sport_players OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 18347)
-- Name: team_sport_result; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team_sport_result (
    t_result_id integer NOT NULL,
    t_match_id integer NOT NULL,
    winning_team_id integer NOT NULL,
    duration time without time zone,
    scores character varying(100),
    highlights text,
    motm character varying(100)
);


ALTER TABLE public.team_sport_result OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 18128)
-- Name: teams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teams (
    team_id integer NOT NULL,
    college_id integer NOT NULL,
    name character varying(100) NOT NULL,
    sport_name character varying(100) NOT NULL,
    captain_name character varying(100)
);


ALTER TABLE public.teams OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 18455)
-- Name: tournament_player; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_player (
    tournament_id integer NOT NULL,
    player_id integer NOT NULL,
    arrival_date date,
    departure_date date
);


ALTER TABLE public.tournament_player OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 18172)
-- Name: tournament_sport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_sport (
    tournament_id integer NOT NULL,
    sport_name character varying(100) NOT NULL,
    prize_money numeric(10,2)
);


ALTER TABLE public.tournament_sport OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 18470)
-- Name: tournament_teams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_teams (
    tournament_id integer NOT NULL,
    team_id integer NOT NULL,
    coach_name character varying(100) NOT NULL
);


ALTER TABLE public.tournament_teams OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 18165)
-- Name: tournaments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournaments (
    tournament_id integer NOT NULL,
    tournament_name character varying(100) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL
);


ALTER TABLE public.tournaments OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 18228)
-- Name: venues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.venues (
    venue_id integer NOT NULL,
    name character varying(100) NOT NULL,
    capacity integer,
    venue_type character varying(50),
    maintenance_cost numeric(10,2)
);


ALTER TABLE public.venues OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 18254)
-- Name: volunteer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.volunteer (
    volunteer_id integer NOT NULL,
    name character varying(100) NOT NULL,
    gender character(1),
    years_of_experience integer DEFAULT 0,
    dob date,
    contact character varying(15),
    availability_status character varying(50),
    CONSTRAINT volunteer_gender_check CHECK ((gender = ANY (ARRAY['M'::bpchar, 'F'::bpchar, 'O'::bpchar])))
);


ALTER TABLE public.volunteer OWNER TO postgres;

--
-- TOC entry 5141 (class 0 OID 18088)
-- Dependencies: 218
-- Data for Name: colleges; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.colleges (college_id, name, area, city, email, dean_name, establishment_year, ranking) FROM stdin;
1	Indian Institute of Technology Gandhinagar	Palaj	Gandhinagar	info@iitgn.ac.in	Dr. Rajat Moona	2008	1
2	Dhirubhai Ambani University	Gandhinagar	Gandhinagar	admissions@daiict.ac.in	Dr. K. S. Dasgupta	2001	2
3	Pandit Deendayal Energy University	Raisan	Gandhinagar	contact@pdeu.ac.in	Dr. S. Sundar Manoharan	2007	3
4	Sardar Vallabhbhai National Institute of Technology	Ichchhanath	Surat	info@svnit.ac.in	Dr. P. S. Joshi	1961	4
5	Gujarat Technological University	Chandkheda	Ahmedabad	registrar@gtu.ac.in	Dr. Rajul K. Gajjar	2007	5
6	L.D. College of Engineering	Navrangpura	Ahmedabad	principal@ldce.ac.in	Dr. J. P. Modh	1948	6
7	Birla Vishvakarma Mahavidyalaya	Vallabh Vidyanagar	Anand	principal@bvmengineering.ac.in	Dr. Indrajit Patel	1948	7
8	Maharaja Sayajirao University of Baroda	Sayajigunj	Vadodara	info@msubaroda.ac.in	Dr. Nikhil Bhatt	1949	8
9	Nirma University	Sarkhej-Gandhinagar Highway	Ahmedabad	info@nirmauni.ac.in	Dr. Anup Singh	2003	9
10	Charotar University of Science and Technology	Changa	Anand	info@charusat.ac.in	Dr. Rajnikant Patel	2009	10
11	Marwadi University	Rajkot-Morbi Highway	Rajkot	info@marwadiuniversity.ac.in	Dr. Y. P. Kosta	2016	11
12	Parul University	Limda	Vadodara	info@paruluniversity.ac.in	Dr. Devanshu Patel	2015	12
13	Silver Oak University	Gota	Ahmedabad	info@silveroakuni.ac.in	Dr. Shital Shah	2019	13
14	Indus University	Rancharda	Ahmedabad	info@indusuni.ac.in	Dr. Nagesh Bhandari	2012	14
15	Uka Tarsadia University	Bardoli	Surat	info@utu.ac.in	Dr. Dinesh Shah	2011	15
\.


--
-- TOC entry 5160 (class 0 OID 18362)
-- Dependencies: 237
-- Data for Name: i_issue_record; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.i_issue_record (i_match_id, item_id, issue_time, return_time, issue_quantity) FROM stdin;
1	26	08:15:00	20:30:00	4
1	27	08:15:00	20:30:00	2
2	26	09:15:00	21:00:00	4
2	28	09:15:00	21:00:00	1
3	26	10:15:00	21:00:00	4
3	30	10:15:00	21:00:00	2
4	26	08:15:00	20:00:00	4
4	27	08:15:00	20:00:00	2
5	26	09:15:00	20:00:00	4
5	28	09:15:00	20:00:00	1
6	26	10:15:00	20:00:00	4
6	30	10:15:00	20:00:00	2
7	26	13:15:00	21:00:00	4
7	27	13:15:00	21:00:00	2
8	26	14:15:00	21:00:00	4
8	30	14:15:00	21:00:00	2
9	26	15:15:00	21:30:00	4
9	28	15:15:00	21:30:00	1
10	26	08:15:00	20:00:00	4
10	27	08:15:00	20:00:00	2
11	26	09:15:00	20:00:00	4
11	28	09:15:00	20:00:00	1
12	26	10:15:00	20:00:00	4
12	30	10:15:00	20:00:00	2
13	26	13:15:00	21:30:00	4
13	28	13:15:00	21:30:00	1
14	26	14:15:00	21:30:00	4
14	30	14:15:00	21:30:00	2
15	26	17:15:00	21:45:00	6
15	27	17:15:00	21:45:00	2
16	31	08:45:00	20:30:00	4
16	32	08:45:00	20:30:00	3
17	31	09:45:00	21:00:00	4
17	33	09:45:00	21:00:00	1
18	31	10:45:00	21:00:00	4
18	35	10:45:00	21:00:00	2
19	31	08:45:00	20:00:00	4
19	32	08:45:00	20:00:00	3
20	31	09:45:00	20:00:00	4
20	35	09:45:00	20:00:00	2
21	31	10:45:00	20:00:00	4
21	33	10:45:00	20:00:00	1
22	31	13:45:00	21:30:00	4
22	32	13:45:00	21:30:00	3
23	31	14:45:00	21:30:00	4
23	35	14:45:00	21:30:00	2
24	31	15:45:00	21:30:00	4
24	33	15:45:00	21:30:00	1
25	31	08:45:00	21:00:00	4
25	32	08:45:00	21:00:00	3
26	31	09:45:00	21:00:00	4
26	35	09:45:00	21:00:00	2
27	31	10:45:00	21:00:00	4
27	33	10:45:00	21:00:00	1
28	31	13:45:00	21:30:00	4
28	32	13:45:00	21:30:00	3
29	31	14:45:00	21:30:00	4
29	35	14:45:00	21:30:00	2
30	31	16:15:00	21:45:00	4
30	33	16:15:00	21:45:00	1
31	46	11:15:00	21:00:00	2
31	47	11:15:00	21:00:00	4
32	46	12:15:00	21:00:00	2
32	48	12:15:00	21:00:00	4
33	46	13:15:00	21:00:00	2
33	49	13:15:00	21:00:00	3
34	46	11:15:00	21:00:00	2
34	47	11:15:00	21:00:00	4
35	46	12:15:00	21:00:00	2
35	48	12:15:00	21:00:00	4
36	46	13:15:00	21:00:00	2
36	49	13:15:00	21:00:00	3
37	46	15:15:00	21:30:00	2
37	47	15:15:00	21:30:00	4
38	46	16:15:00	21:30:00	2
38	48	16:15:00	21:30:00	4
39	46	17:15:00	21:30:00	2
39	49	17:15:00	21:30:00	3
40	46	11:15:00	21:00:00	2
40	47	11:15:00	21:00:00	4
41	46	12:15:00	21:00:00	2
41	48	12:15:00	21:00:00	4
42	46	13:15:00	21:00:00	2
42	49	13:15:00	21:00:00	3
43	46	15:15:00	21:30:00	2
43	47	15:15:00	21:30:00	4
44	46	16:15:00	21:30:00	2
44	48	16:15:00	21:30:00	4
45	46	09:15:00	21:45:00	3
45	49	09:15:00	21:45:00	3
46	41	14:15:00	21:00:00	4
46	42	14:15:00	21:00:00	4
47	41	15:15:00	21:00:00	4
47	43	15:15:00	21:00:00	2
48	41	16:15:00	21:00:00	4
48	44	16:15:00	21:00:00	5
49	41	14:15:00	21:00:00	4
49	42	14:15:00	21:00:00	4
50	41	15:15:00	21:00:00	4
50	43	15:15:00	21:00:00	2
51	41	16:15:00	21:00:00	4
51	44	16:15:00	21:00:00	5
52	41	18:15:00	21:30:00	4
52	42	18:15:00	21:30:00	4
53	41	19:15:00	21:30:00	4
53	43	19:15:00	21:30:00	2
54	41	14:15:00	21:00:00	4
54	44	14:15:00	21:00:00	5
55	41	15:15:00	21:00:00	4
55	42	15:15:00	21:00:00	4
56	41	16:15:00	21:00:00	4
56	43	16:15:00	21:00:00	2
57	41	17:15:00	21:00:00	4
57	44	17:15:00	21:00:00	5
58	41	08:15:00	21:00:00	4
58	43	08:15:00	21:00:00	2
59	41	09:15:00	21:00:00	4
59	44	09:15:00	21:00:00	5
60	41	11:15:00	21:45:00	6
60	45	11:15:00	21:45:00	2
61	36	17:15:00	21:00:00	2
61	37	17:15:00	21:00:00	4
62	36	18:15:00	21:00:00	2
62	38	18:15:00	21:00:00	4
63	36	19:15:00	21:00:00	2
63	39	19:15:00	21:00:00	1
64	36	17:15:00	21:00:00	2
64	37	17:15:00	21:00:00	4
65	36	18:15:00	21:00:00	2
65	38	18:15:00	21:00:00	4
66	36	19:15:00	21:00:00	2
66	39	19:15:00	21:00:00	1
67	36	17:15:00	21:30:00	2
67	37	17:15:00	21:30:00	4
68	36	18:15:00	21:30:00	2
68	38	18:15:00	21:30:00	4
69	36	19:15:00	21:30:00	2
69	39	19:15:00	21:30:00	1
70	36	08:45:00	21:00:00	2
70	37	08:45:00	21:00:00	4
71	36	09:45:00	21:00:00	2
71	38	09:45:00	21:00:00	4
72	36	10:45:00	21:00:00	2
72	39	10:45:00	21:00:00	1
73	36	13:45:00	21:30:00	2
73	37	13:45:00	21:30:00	4
74	36	14:45:00	21:30:00	2
74	38	14:45:00	21:30:00	4
75	36	17:45:00	21:45:00	2
75	40	17:45:00	21:45:00	1
76	26	08:15:00	20:30:00	4
76	27	08:15:00	20:30:00	2
77	26	09:15:00	21:00:00	4
77	28	09:15:00	21:00:00	1
78	26	10:15:00	21:00:00	4
78	30	10:15:00	21:00:00	2
79	26	08:15:00	20:00:00	4
79	27	08:15:00	20:00:00	2
80	26	09:15:00	20:00:00	4
80	28	09:15:00	20:00:00	1
81	26	10:15:00	20:00:00	4
81	30	10:15:00	20:00:00	2
82	26	13:15:00	21:00:00	4
82	27	13:15:00	21:00:00	2
83	26	14:15:00	21:00:00	4
83	28	14:15:00	21:00:00	1
84	26	15:15:00	21:30:00	4
84	30	15:15:00	21:30:00	2
85	26	08:15:00	20:00:00	4
85	27	08:15:00	20:00:00	2
86	26	09:15:00	20:00:00	4
86	28	09:15:00	20:00:00	1
87	26	10:15:00	20:00:00	4
87	30	10:15:00	20:00:00	2
88	26	13:15:00	21:30:00	4
88	28	13:15:00	21:30:00	1
89	26	14:15:00	21:30:00	4
89	30	14:15:00	21:30:00	2
90	26	16:15:00	21:45:00	6
90	27	16:15:00	21:45:00	2
91	31	08:45:00	20:30:00	4
91	32	08:45:00	20:30:00	3
92	31	09:45:00	21:00:00	4
92	33	09:45:00	21:00:00	1
93	31	10:45:00	21:00:00	4
93	35	10:45:00	21:00:00	2
94	31	08:45:00	20:00:00	4
94	32	08:45:00	20:00:00	3
95	31	09:45:00	20:00:00	4
95	35	09:45:00	20:00:00	2
96	31	10:45:00	20:00:00	4
96	33	10:45:00	20:00:00	1
97	31	13:45:00	21:30:00	4
97	32	13:45:00	21:30:00	3
98	31	14:45:00	21:30:00	4
98	35	14:45:00	21:30:00	2
99	31	15:45:00	21:30:00	4
99	33	15:45:00	21:30:00	1
100	31	08:45:00	21:00:00	4
100	32	08:45:00	21:00:00	3
101	31	09:45:00	21:00:00	4
101	35	09:45:00	21:00:00	2
102	31	10:45:00	21:00:00	4
102	33	10:45:00	21:00:00	1
103	31	13:45:00	21:30:00	4
103	32	13:45:00	21:30:00	3
104	31	14:45:00	21:30:00	4
104	35	14:45:00	21:30:00	2
105	31	16:15:00	21:45:00	4
105	33	16:15:00	21:45:00	1
106	46	11:15:00	21:00:00	2
106	47	11:15:00	21:00:00	4
107	46	12:15:00	21:00:00	2
107	48	12:15:00	21:00:00	4
108	46	13:15:00	21:00:00	2
108	49	13:15:00	21:00:00	3
109	46	11:15:00	21:00:00	2
109	47	11:15:00	21:00:00	4
110	46	12:15:00	21:00:00	2
110	48	12:15:00	21:00:00	4
111	46	13:15:00	21:00:00	2
111	49	13:15:00	21:00:00	3
112	46	15:15:00	21:30:00	2
112	47	15:15:00	21:30:00	4
113	46	16:15:00	21:30:00	2
113	48	16:15:00	21:30:00	4
114	46	17:15:00	21:30:00	2
114	49	17:15:00	21:30:00	3
115	46	11:15:00	21:00:00	2
115	47	11:15:00	21:00:00	4
116	46	12:15:00	21:00:00	2
116	48	12:15:00	21:00:00	4
117	46	13:15:00	21:00:00	2
117	49	13:15:00	21:00:00	3
118	46	15:15:00	21:30:00	2
118	47	15:15:00	21:30:00	4
119	46	16:15:00	21:30:00	2
119	48	16:15:00	21:30:00	4
120	46	09:15:00	21:45:00	3
120	49	09:15:00	21:45:00	3
121	41	14:15:00	21:00:00	4
121	42	14:15:00	21:00:00	4
122	41	15:15:00	21:00:00	4
122	43	15:15:00	21:00:00	2
123	41	16:15:00	21:00:00	4
123	44	16:15:00	21:00:00	5
124	41	14:15:00	21:00:00	4
124	42	14:15:00	21:00:00	4
125	41	15:15:00	21:00:00	4
125	43	15:15:00	21:00:00	2
126	41	16:15:00	21:00:00	4
126	44	16:15:00	21:00:00	5
127	41	18:15:00	21:30:00	4
127	42	18:15:00	21:30:00	4
128	41	19:15:00	21:30:00	4
128	43	19:15:00	21:30:00	2
129	41	14:15:00	21:00:00	4
129	44	14:15:00	21:00:00	5
130	41	15:15:00	21:00:00	4
130	42	15:15:00	21:00:00	4
131	41	16:15:00	21:00:00	4
131	43	16:15:00	21:00:00	2
132	41	17:15:00	21:00:00	4
132	44	17:15:00	21:00:00	5
133	41	08:15:00	21:00:00	4
133	43	08:15:00	21:00:00	2
134	41	09:15:00	21:00:00	4
134	44	09:15:00	21:00:00	5
135	41	11:15:00	21:45:00	6
135	45	11:15:00	21:45:00	2
136	36	17:15:00	21:00:00	2
136	37	17:15:00	21:00:00	4
137	36	18:15:00	21:00:00	2
137	38	18:15:00	21:00:00	4
138	36	19:15:00	21:00:00	2
138	39	19:15:00	21:00:00	1
139	36	17:15:00	21:00:00	2
139	37	17:15:00	21:00:00	4
140	36	18:15:00	21:00:00	2
140	38	18:15:00	21:00:00	4
141	36	19:15:00	21:00:00	2
141	39	19:15:00	21:00:00	1
142	36	17:15:00	21:30:00	2
142	37	17:15:00	21:30:00	4
143	36	18:15:00	21:30:00	2
143	38	18:15:00	21:30:00	4
144	36	19:15:00	21:30:00	2
144	39	19:15:00	21:30:00	1
145	36	08:45:00	21:00:00	2
145	37	08:45:00	21:00:00	4
146	36	09:45:00	21:00:00	2
146	38	09:45:00	21:00:00	4
147	36	10:45:00	21:00:00	2
147	39	10:45:00	21:00:00	1
148	36	13:45:00	21:30:00	2
148	37	13:45:00	21:30:00	4
149	36	14:45:00	21:30:00	2
149	38	14:45:00	21:30:00	4
150	36	17:45:00	21:45:00	2
150	40	17:45:00	21:45:00	1
151	26	08:15:00	20:30:00	4
151	27	08:15:00	20:30:00	2
152	26	09:15:00	21:00:00	4
152	28	09:15:00	21:00:00	1
153	26	10:15:00	21:00:00	4
153	30	10:15:00	21:00:00	2
154	26	08:15:00	20:00:00	4
154	27	08:15:00	20:00:00	2
155	26	09:15:00	20:00:00	4
155	28	09:15:00	20:00:00	1
156	26	10:15:00	20:00:00	4
156	30	10:15:00	20:00:00	2
157	26	13:15:00	21:00:00	4
157	27	13:15:00	21:00:00	2
158	26	14:15:00	21:00:00	4
158	28	14:15:00	21:00:00	1
159	26	15:15:00	21:30:00	4
159	30	15:15:00	21:30:00	2
160	26	08:15:00	20:00:00	4
160	27	08:15:00	20:00:00	2
161	26	09:15:00	20:00:00	4
161	28	09:15:00	20:00:00	1
162	26	10:15:00	20:00:00	4
162	30	10:15:00	20:00:00	2
163	26	13:15:00	21:30:00	4
163	28	13:15:00	21:30:00	1
164	26	14:15:00	21:30:00	4
164	30	14:15:00	21:30:00	2
165	26	16:15:00	21:45:00	6
165	27	16:15:00	21:45:00	2
166	31	08:45:00	20:30:00	4
166	32	08:45:00	20:30:00	3
167	31	09:45:00	21:00:00	4
167	33	09:45:00	21:00:00	1
168	31	10:45:00	21:00:00	4
168	35	10:45:00	21:00:00	2
169	31	08:45:00	20:00:00	4
169	32	08:45:00	20:00:00	3
170	31	09:45:00	20:00:00	4
170	35	09:45:00	20:00:00	2
171	31	10:45:00	20:00:00	4
171	33	10:45:00	20:00:00	1
172	31	13:45:00	21:30:00	4
172	32	13:45:00	21:30:00	3
173	31	14:45:00	21:30:00	4
173	35	14:45:00	21:30:00	2
174	31	15:45:00	21:30:00	4
174	33	15:45:00	21:30:00	1
175	31	08:45:00	21:00:00	4
175	32	08:45:00	21:00:00	3
176	31	09:45:00	21:00:00	4
176	35	09:45:00	21:00:00	2
177	31	10:45:00	21:00:00	4
177	33	10:45:00	21:00:00	1
178	31	13:45:00	21:30:00	4
178	32	13:45:00	21:30:00	3
179	31	14:45:00	21:30:00	4
179	35	14:45:00	21:30:00	2
180	31	16:15:00	21:45:00	4
180	33	16:15:00	21:45:00	1
181	46	11:15:00	21:00:00	2
181	47	11:15:00	21:00:00	4
182	46	12:15:00	21:00:00	2
182	48	12:15:00	21:00:00	4
183	46	13:15:00	21:00:00	2
183	49	13:15:00	21:00:00	3
184	46	11:15:00	21:00:00	2
184	47	11:15:00	21:00:00	4
185	46	12:15:00	21:00:00	2
185	48	12:15:00	21:00:00	4
186	46	13:15:00	21:00:00	2
186	49	13:15:00	21:00:00	3
187	46	15:15:00	21:30:00	2
187	47	15:15:00	21:30:00	4
188	46	16:15:00	21:30:00	2
188	48	16:15:00	21:30:00	4
189	46	17:15:00	21:30:00	2
189	49	17:15:00	21:30:00	3
190	46	11:15:00	21:00:00	2
190	47	11:15:00	21:00:00	4
191	46	12:15:00	21:00:00	2
191	48	12:15:00	21:00:00	4
192	46	13:15:00	21:00:00	2
192	49	13:15:00	21:00:00	3
193	46	15:15:00	21:30:00	2
193	47	15:15:00	21:30:00	4
194	46	16:15:00	21:30:00	2
194	48	16:15:00	21:30:00	4
195	46	09:15:00	21:45:00	3
195	49	09:15:00	21:45:00	3
196	41	14:15:00	21:00:00	4
196	42	14:15:00	21:00:00	4
197	41	15:15:00	21:00:00	4
197	43	15:15:00	21:00:00	2
198	41	16:15:00	21:00:00	4
198	44	16:15:00	21:00:00	5
199	41	14:15:00	21:00:00	4
199	42	14:15:00	21:00:00	4
200	41	15:15:00	21:00:00	4
200	43	15:15:00	21:00:00	2
201	41	16:15:00	21:00:00	4
201	44	16:15:00	21:00:00	5
202	41	18:15:00	21:30:00	4
202	42	18:15:00	21:30:00	4
203	41	19:15:00	21:30:00	4
203	43	19:15:00	21:30:00	2
204	41	14:15:00	21:00:00	4
204	44	14:15:00	21:00:00	5
205	41	15:15:00	21:00:00	4
205	42	15:15:00	21:00:00	4
206	41	16:15:00	21:00:00	4
206	43	16:15:00	21:00:00	2
207	41	17:15:00	21:00:00	4
207	44	17:15:00	21:00:00	5
208	41	08:15:00	21:00:00	4
208	43	08:15:00	21:00:00	2
209	41	09:15:00	21:00:00	4
209	44	09:15:00	21:00:00	5
210	41	11:15:00	21:45:00	6
210	45	11:15:00	21:45:00	2
211	36	17:15:00	21:00:00	2
211	37	17:15:00	21:00:00	4
212	36	18:15:00	21:00:00	2
212	38	18:15:00	21:00:00	4
213	36	19:15:00	21:00:00	2
213	39	19:15:00	21:00:00	1
214	36	17:15:00	21:00:00	2
214	37	17:15:00	21:00:00	4
215	36	18:15:00	21:00:00	2
215	38	18:15:00	21:00:00	4
216	36	19:15:00	21:00:00	2
216	39	19:15:00	21:00:00	1
217	36	17:15:00	21:30:00	2
217	37	17:15:00	21:30:00	4
218	36	18:15:00	21:30:00	2
218	38	18:15:00	21:30:00	4
219	36	19:15:00	21:30:00	2
219	39	19:15:00	21:30:00	1
220	36	08:45:00	21:00:00	2
220	37	08:45:00	21:00:00	4
221	36	09:45:00	21:00:00	2
221	38	09:45:00	21:00:00	4
222	36	10:45:00	21:00:00	2
222	39	10:45:00	21:00:00	1
223	36	13:45:00	21:30:00	2
223	37	13:45:00	21:30:00	4
224	36	14:45:00	21:30:00	2
224	38	14:45:00	21:30:00	4
225	36	17:45:00	21:45:00	2
225	40	17:45:00	21:45:00	1
\.


--
-- TOC entry 5162 (class 0 OID 18395)
-- Dependencies: 239
-- Data for Name: i_match_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.i_match_ref (i_match_id, referee_id, role, fairness_rating) FROM stdin;
1	51	Chair Umpire	9.50
1	52	Service Judge	9.10
2	53	Chair Umpire	9.20
2	54	Service Judge	8.90
3	55	Chair Umpire	9.40
3	51	Service Judge	9.00
4	52	Chair Umpire	9.30
4	53	Service Judge	9.00
5	54	Chair Umpire	9.10
5	55	Service Judge	8.80
6	51	Chair Umpire	9.50
6	52	Service Judge	9.20
7	53	Chair Umpire	9.30
7	54	Service Judge	9.00
8	55	Chair Umpire	9.20
8	51	Service Judge	9.10
9	52	Chair Umpire	9.30
9	53	Service Judge	9.00
10	54	Chair Umpire	9.10
10	55	Service Judge	8.90
11	51	Chair Umpire	9.40
11	52	Service Judge	9.00
12	53	Chair Umpire	9.20
12	54	Service Judge	8.90
13	55	Chair Umpire	9.30
13	51	Service Judge	9.00
14	52	Chair Umpire	9.40
14	53	Service Judge	9.10
15	54	Chair Umpire	9.30
15	55	Service Judge	9.00
16	56	Chair Umpire	9.50
16	57	Line Umpire	9.10
17	58	Chair Umpire	9.30
17	59	Line Umpire	9.00
18	60	Chair Umpire	9.40
18	56	Line Umpire	9.10
19	57	Chair Umpire	9.20
19	58	Line Umpire	8.90
20	59	Chair Umpire	9.40
20	60	Line Umpire	9.10
21	56	Chair Umpire	9.50
21	57	Line Umpire	9.00
22	58	Chair Umpire	9.30
22	59	Line Umpire	9.10
23	60	Chair Umpire	9.20
23	56	Line Umpire	8.90
24	57	Chair Umpire	9.30
24	58	Line Umpire	9.00
25	59	Chair Umpire	9.50
25	60	Line Umpire	9.10
26	56	Chair Umpire	9.30
26	57	Line Umpire	8.90
27	58	Chair Umpire	9.20
27	59	Line Umpire	9.00
28	60	Chair Umpire	9.40
28	56	Line Umpire	9.10
29	57	Chair Umpire	9.50
29	58	Line Umpire	9.10
30	59	Chair Umpire	9.30
30	60	Line Umpire	8.90
31	68	Main Referee	9.20
32	69	Main Referee	9.10
33	70	Main Referee	8.90
34	68	Main Referee	9.30
35	69	Main Referee	9.00
36	70	Main Referee	8.80
37	68	Main Referee	9.40
38	69	Main Referee	9.10
39	70	Main Referee	9.20
40	68	Main Referee	9.00
41	69	Main Referee	9.10
42	70	Main Referee	8.90
43	68	Main Referee	9.30
44	69	Main Referee	9.00
45	70	Main Referee	9.10
46	65	Chief Arbiter	9.60
47	66	Chief Arbiter	9.40
48	67	Chief Arbiter	9.20
49	65	Chief Arbiter	9.50
50	66	Chief Arbiter	9.30
51	67	Chief Arbiter	9.10
52	65	Chief Arbiter	9.60
53	66	Chief Arbiter	9.20
54	67	Chief Arbiter	9.30
55	65	Chief Arbiter	9.40
56	66	Chief Arbiter	9.10
57	67	Chief Arbiter	9.50
58	65	Chief Arbiter	9.30
59	66	Chief Arbiter	9.40
60	67	Chief Arbiter	9.20
61	61	Match Referee	9.40
61	62	Assistant Umpire	9.00
62	63	Match Referee	9.20
62	64	Assistant Umpire	8.90
63	61	Match Referee	9.50
63	62	Assistant Umpire	9.10
64	63	Match Referee	9.30
64	64	Assistant Umpire	9.00
65	61	Match Referee	9.40
65	62	Assistant Umpire	9.00
66	63	Match Referee	9.10
66	64	Assistant Umpire	8.80
67	61	Match Referee	9.30
67	62	Assistant Umpire	9.00
68	63	Match Referee	9.20
68	64	Assistant Umpire	9.00
69	61	Match Referee	9.40
69	62	Assistant Umpire	9.10
70	63	Match Referee	9.50
70	64	Assistant Umpire	9.00
71	61	Match Referee	9.20
71	62	Assistant Umpire	8.90
72	63	Match Referee	9.30
72	64	Assistant Umpire	9.00
73	61	Match Referee	9.40
73	62	Assistant Umpire	9.00
74	63	Match Referee	9.30
74	64	Assistant Umpire	8.90
75	61	Match Referee	9.50
75	62	Assistant Umpire	9.10
76	51	Chair Umpire	9.40
76	52	Service Judge	9.10
77	53	Chair Umpire	9.20
77	54	Service Judge	8.90
78	55	Chair Umpire	9.30
78	51	Service Judge	9.00
79	52	Chair Umpire	9.50
79	53	Service Judge	9.10
80	54	Chair Umpire	9.20
80	55	Service Judge	9.00
81	51	Chair Umpire	9.60
81	52	Service Judge	9.20
82	53	Chair Umpire	9.30
82	54	Service Judge	9.00
83	55	Chair Umpire	9.10
83	51	Service Judge	8.90
84	52	Chair Umpire	9.40
84	53	Service Judge	9.10
85	54	Chair Umpire	9.30
85	55	Service Judge	8.90
86	51	Chair Umpire	9.40
86	52	Service Judge	9.00
87	53	Chair Umpire	9.20
87	54	Service Judge	8.80
88	55	Chair Umpire	9.50
88	51	Service Judge	9.00
89	52	Chair Umpire	9.30
89	53	Service Judge	9.00
90	54	Chair Umpire	9.40
90	55	Service Judge	9.10
91	56	Chair Umpire	9.50
91	57	Line Umpire	9.20
92	58	Chair Umpire	9.40
92	59	Line Umpire	9.00
93	60	Chair Umpire	9.30
93	56	Line Umpire	8.90
94	57	Chair Umpire	9.50
94	58	Line Umpire	9.20
95	59	Chair Umpire	9.10
95	60	Line Umpire	8.90
96	56	Chair Umpire	9.60
96	57	Line Umpire	9.10
97	58	Chair Umpire	9.30
97	59	Line Umpire	9.00
98	60	Chair Umpire	9.20
98	56	Line Umpire	8.90
99	57	Chair Umpire	9.30
99	58	Line Umpire	9.10
100	59	Chair Umpire	9.40
100	60	Line Umpire	9.00
101	56	Chair Umpire	9.50
101	57	Line Umpire	9.20
102	58	Chair Umpire	9.40
102	59	Line Umpire	8.90
103	60	Chair Umpire	9.30
103	56	Line Umpire	9.00
104	57	Chair Umpire	9.40
104	58	Line Umpire	9.10
105	59	Chair Umpire	9.50
105	60	Line Umpire	9.20
106	68	Main Referee	9.20
107	69	Main Referee	9.00
108	70	Main Referee	8.90
109	68	Main Referee	9.30
110	69	Main Referee	9.10
111	70	Main Referee	8.80
112	68	Main Referee	9.40
113	69	Main Referee	9.10
114	70	Main Referee	9.00
115	68	Main Referee	9.30
116	69	Main Referee	9.10
117	70	Main Referee	8.90
118	68	Main Referee	9.50
119	69	Main Referee	9.20
120	70	Main Referee	9.00
121	65	Chief Arbiter	9.60
122	66	Chief Arbiter	9.40
123	67	Chief Arbiter	9.20
124	65	Chief Arbiter	9.50
125	66	Chief Arbiter	9.30
126	67	Chief Arbiter	9.10
127	65	Chief Arbiter	9.40
128	66	Chief Arbiter	9.30
129	67	Chief Arbiter	9.20
130	65	Chief Arbiter	9.50
131	66	Chief Arbiter	9.30
132	67	Chief Arbiter	9.10
133	65	Chief Arbiter	9.40
134	66	Chief Arbiter	9.20
135	67	Chief Arbiter	9.30
136	61	Match Referee	9.50
136	62	Assistant Umpire	9.10
137	63	Match Referee	9.30
137	64	Assistant Umpire	8.90
138	61	Match Referee	9.40
138	62	Assistant Umpire	9.00
139	63	Match Referee	9.50
139	64	Assistant Umpire	9.10
140	61	Match Referee	9.30
140	62	Assistant Umpire	9.00
141	63	Match Referee	9.40
141	64	Assistant Umpire	9.00
142	61	Match Referee	9.50
142	62	Assistant Umpire	9.10
143	63	Match Referee	9.30
143	64	Assistant Umpire	9.00
144	61	Match Referee	9.40
144	62	Assistant Umpire	9.00
145	63	Match Referee	9.30
145	64	Assistant Umpire	8.90
146	61	Match Referee	9.50
146	62	Assistant Umpire	9.10
147	63	Match Referee	9.40
147	64	Assistant Umpire	9.00
148	61	Match Referee	9.50
148	62	Assistant Umpire	9.10
149	63	Match Referee	9.30
149	64	Assistant Umpire	8.90
150	61	Match Referee	9.40
150	62	Assistant Umpire	9.00
151	51	Chair Umpire	9.50
151	52	Service Judge	9.10
152	53	Chair Umpire	9.30
152	54	Service Judge	9.00
153	55	Chair Umpire	9.40
153	51	Service Judge	9.00
154	52	Chair Umpire	9.50
154	53	Service Judge	9.10
155	54	Chair Umpire	9.30
155	55	Service Judge	8.90
156	51	Chair Umpire	9.60
156	52	Service Judge	9.20
157	53	Chair Umpire	9.40
157	54	Service Judge	9.00
158	55	Chair Umpire	9.50
158	51	Service Judge	9.10
159	52	Chair Umpire	9.40
159	53	Service Judge	9.00
160	54	Chair Umpire	9.20
160	55	Service Judge	9.00
161	51	Chair Umpire	9.30
161	52	Service Judge	8.90
162	53	Chair Umpire	9.50
162	54	Service Judge	9.10
163	55	Chair Umpire	9.40
163	51	Service Judge	9.00
164	52	Chair Umpire	9.50
164	53	Service Judge	9.10
165	54	Chair Umpire	9.30
165	55	Service Judge	8.90
166	56	Chair Umpire	9.50
166	57	Line Umpire	9.10
167	58	Chair Umpire	9.30
167	59	Line Umpire	8.90
168	60	Chair Umpire	9.40
168	56	Line Umpire	9.00
169	57	Chair Umpire	9.50
169	58	Line Umpire	9.10
170	59	Chair Umpire	9.30
170	60	Line Umpire	9.00
171	56	Chair Umpire	9.60
171	57	Line Umpire	9.20
172	58	Chair Umpire	9.40
172	59	Line Umpire	9.00
173	60	Chair Umpire	9.30
173	56	Line Umpire	9.10
174	57	Chair Umpire	9.40
174	58	Line Umpire	9.10
175	59	Chair Umpire	9.20
175	60	Line Umpire	9.00
176	56	Chair Umpire	9.50
176	57	Line Umpire	9.10
177	58	Chair Umpire	9.30
177	59	Line Umpire	9.00
178	60	Chair Umpire	9.40
178	56	Line Umpire	9.10
179	57	Chair Umpire	9.50
179	58	Line Umpire	9.20
180	59	Chair Umpire	9.30
180	60	Line Umpire	8.90
181	68	Main Referee	9.30
182	69	Main Referee	9.10
183	70	Main Referee	9.00
184	68	Main Referee	9.40
185	69	Main Referee	9.10
186	70	Main Referee	8.90
187	68	Main Referee	9.50
188	69	Main Referee	9.30
189	70	Main Referee	9.10
190	68	Main Referee	9.40
191	69	Main Referee	9.20
192	70	Main Referee	8.90
193	68	Main Referee	9.50
194	69	Main Referee	9.30
195	70	Main Referee	9.10
196	65	Chief Arbiter	9.60
197	66	Chief Arbiter	9.40
198	67	Chief Arbiter	9.20
199	65	Chief Arbiter	9.50
200	66	Chief Arbiter	9.30
201	67	Chief Arbiter	9.10
202	65	Chief Arbiter	9.40
203	66	Chief Arbiter	9.30
204	67	Chief Arbiter	9.20
205	65	Chief Arbiter	9.50
206	66	Chief Arbiter	9.40
207	67	Chief Arbiter	9.20
208	65	Chief Arbiter	9.60
209	66	Chief Arbiter	9.40
210	67	Chief Arbiter	9.30
211	61	Match Referee	9.40
211	62	Assistant Umpire	9.00
212	63	Match Referee	9.30
212	64	Assistant Umpire	8.90
213	61	Match Referee	9.50
213	62	Assistant Umpire	9.10
214	63	Match Referee	9.40
214	64	Assistant Umpire	9.00
215	61	Match Referee	9.50
215	62	Assistant Umpire	9.10
216	63	Match Referee	9.30
216	64	Assistant Umpire	8.90
217	61	Match Referee	9.40
217	62	Assistant Umpire	9.00
218	63	Match Referee	9.30
218	64	Assistant Umpire	8.90
219	61	Match Referee	9.50
219	62	Assistant Umpire	9.10
220	63	Match Referee	9.40
220	64	Assistant Umpire	9.00
221	61	Match Referee	9.50
221	62	Assistant Umpire	9.10
222	63	Match Referee	9.30
222	64	Assistant Umpire	8.90
223	61	Match Referee	9.40
223	62	Assistant Umpire	9.00
224	63	Match Referee	9.50
224	64	Assistant Umpire	9.10
225	61	Match Referee	9.30
225	62	Assistant Umpire	8.90
\.


--
-- TOC entry 5164 (class 0 OID 18425)
-- Dependencies: 241
-- Data for Name: i_volunteering_record; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.i_volunteering_record (i_match_id, volunteer_id, role, rating, hours_worked) FROM stdin;
1	1	Court Manager	9.50	6
1	2	Scorer	9.20	6
1	3	Line Judge	9.30	6
1	4	Shuttle Distributor	9.10	6
2	1	Court Manager	9.40	6
2	2	Scorer	9.10	6
2	3	Line Judge	9.20	6
2	4	Shuttle Distributor	9.00	6
3	1	Court Manager	9.50	6
3	2	Scorer	9.20	6
3	3	Line Judge	9.30	6
3	4	Shuttle Distributor	9.10	6
4	1	Court Manager	9.40	6
4	2	Scorer	9.30	6
4	3	Line Judge	9.30	6
4	4	Shuttle Distributor	9.10	6
5	1	Court Manager	9.50	6
5	2	Scorer	9.30	6
5	3	Line Judge	9.40	6
5	4	Shuttle Distributor	9.20	6
6	1	Court Manager	9.50	6
6	2	Scorer	9.30	6
6	3	Line Judge	9.30	6
6	4	Shuttle Distributor	9.20	6
7	1	Court Manager	9.40	6
7	2	Scorer	9.20	6
7	3	Line Judge	9.30	6
7	4	Shuttle Distributor	9.10	6
8	1	Court Manager	9.50	6
8	2	Scorer	9.20	6
8	3	Line Judge	9.40	6
8	4	Shuttle Distributor	9.30	6
9	1	Court Manager	9.50	6
9	2	Scorer	9.20	6
9	3	Line Judge	9.40	6
9	4	Shuttle Distributor	9.20	6
10	1	Court Manager	9.60	6
10	2	Scorer	9.30	6
10	3	Line Judge	9.40	6
10	4	Shuttle Distributor	9.30	6
11	1	Court Manager	9.40	6
11	2	Scorer	9.30	6
11	3	Line Judge	9.30	6
11	4	Shuttle Distributor	9.20	6
12	1	Court Manager	9.50	6
12	2	Scorer	9.30	6
12	3	Line Judge	9.40	6
12	4	Shuttle Distributor	9.30	6
13	1	Court Manager	9.60	6
13	2	Scorer	9.30	6
13	3	Line Judge	9.40	6
13	4	Shuttle Distributor	9.30	6
14	1	Court Manager	9.60	6
14	2	Scorer	9.40	6
14	3	Line Judge	9.40	6
14	4	Shuttle Distributor	9.40	6
15	1	Court Manager	9.70	6
15	2	Scorer	9.50	6
15	3	Line Judge	9.50	6
15	4	Shuttle Distributor	9.40	6
16	5	Ball Collector	9.40	6
16	6	Scorekeeper	9.20	6
16	7	Net Assistant	9.30	6
16	8	Umpire Assistant	9.10	6
16	9	Match Recorder	9.40	6
17	5	Ball Collector	9.40	6
17	6	Scorekeeper	9.30	6
17	7	Net Assistant	9.30	6
17	8	Umpire Assistant	9.20	6
17	9	Match Recorder	9.30	6
18	5	Ball Collector	9.50	6
18	6	Scorekeeper	9.30	6
18	7	Net Assistant	9.40	6
18	8	Umpire Assistant	9.20	6
18	9	Match Recorder	9.40	6
19	5	Ball Collector	9.50	6
19	6	Scorekeeper	9.40	6
19	7	Net Assistant	9.30	6
19	8	Umpire Assistant	9.30	6
19	9	Match Recorder	9.40	6
20	5	Ball Collector	9.40	6
20	6	Scorekeeper	9.20	6
20	7	Net Assistant	9.30	6
20	8	Umpire Assistant	9.10	6
20	9	Match Recorder	9.30	6
21	5	Ball Collector	9.40	6
21	6	Scorekeeper	9.20	6
21	7	Net Assistant	9.30	6
21	8	Umpire Assistant	9.10	6
21	9	Match Recorder	9.30	6
22	5	Ball Collector	9.50	6
22	6	Scorekeeper	9.30	6
22	7	Net Assistant	9.40	6
22	8	Umpire Assistant	9.20	6
22	9	Match Recorder	9.50	6
23	5	Ball Collector	9.50	6
23	6	Scorekeeper	9.30	6
23	7	Net Assistant	9.40	6
23	8	Umpire Assistant	9.30	6
23	9	Match Recorder	9.40	6
24	5	Ball Collector	9.50	6
24	6	Scorekeeper	9.40	6
24	7	Net Assistant	9.40	6
24	8	Umpire Assistant	9.30	6
24	9	Match Recorder	9.40	6
25	5	Ball Collector	9.50	6
25	6	Scorekeeper	9.40	6
25	7	Net Assistant	9.40	6
25	8	Umpire Assistant	9.30	6
25	9	Match Recorder	9.40	6
26	5	Ball Collector	9.60	6
26	6	Scorekeeper	9.40	6
26	7	Net Assistant	9.40	6
26	8	Umpire Assistant	9.30	6
26	9	Match Recorder	9.50	6
27	5	Ball Collector	9.50	6
27	6	Scorekeeper	9.30	6
27	7	Net Assistant	9.40	6
27	8	Umpire Assistant	9.20	6
27	9	Match Recorder	9.40	6
28	5	Ball Collector	9.60	6
28	6	Scorekeeper	9.40	6
28	7	Net Assistant	9.40	6
28	8	Umpire Assistant	9.30	6
28	9	Match Recorder	9.50	6
29	5	Ball Collector	9.60	6
29	6	Scorekeeper	9.40	6
29	7	Net Assistant	9.40	6
29	8	Umpire Assistant	9.40	6
29	9	Match Recorder	9.50	6
30	5	Ball Collector	9.70	6
30	6	Scorekeeper	9.50	6
30	7	Net Assistant	9.50	6
30	8	Umpire Assistant	9.40	6
30	9	Match Recorder	9.60	6
31	10	Board Setup	9.40	4
31	11	Score Announcer	9.10	4
31	12	Coin Refiller	9.20	4
32	10	Board Setup	9.40	4
32	11	Score Announcer	9.10	4
32	12	Coin Refiller	9.20	4
33	10	Board Setup	9.50	4
33	11	Score Announcer	9.20	4
33	12	Coin Refiller	9.30	4
34	10	Board Setup	9.50	4
34	11	Score Announcer	9.20	4
34	12	Coin Refiller	9.30	4
35	10	Board Setup	9.50	4
35	11	Score Announcer	9.30	4
35	12	Coin Refiller	9.30	4
36	10	Board Setup	9.50	4
36	11	Score Announcer	9.30	4
36	12	Coin Refiller	9.30	4
37	10	Board Setup	9.50	4
37	11	Score Announcer	9.30	4
37	12	Coin Refiller	9.30	4
38	10	Board Setup	9.40	4
38	11	Score Announcer	9.20	4
38	12	Coin Refiller	9.30	4
39	10	Board Setup	9.40	4
39	11	Score Announcer	9.10	4
39	12	Coin Refiller	9.20	4
40	10	Board Setup	9.40	4
40	11	Score Announcer	9.10	4
40	12	Coin Refiller	9.20	4
41	10	Board Setup	9.50	4
41	11	Score Announcer	9.20	4
41	12	Coin Refiller	9.30	4
42	10	Board Setup	9.50	4
42	11	Score Announcer	9.30	4
42	12	Coin Refiller	9.30	4
43	10	Board Setup	9.60	4
43	11	Score Announcer	9.30	4
43	12	Coin Refiller	9.30	4
44	10	Board Setup	9.60	4
44	11	Score Announcer	9.30	4
44	12	Coin Refiller	9.40	4
45	10	Board Setup	9.70	4
45	11	Score Announcer	9.40	4
45	12	Coin Refiller	9.40	4
46	13	Timekeeper	9.40	5
46	14	Arbiter Assistant	9.30	5
46	15	Score Recorder	9.20	5
47	13	Timekeeper	9.40	5
47	14	Arbiter Assistant	9.30	5
47	15	Score Recorder	9.30	5
48	13	Timekeeper	9.40	5
48	14	Arbiter Assistant	9.20	5
48	15	Score Recorder	9.30	5
49	13	Timekeeper	9.50	5
49	14	Arbiter Assistant	9.30	5
49	15	Score Recorder	9.30	5
50	13	Timekeeper	9.50	5
50	14	Arbiter Assistant	9.30	5
50	15	Score Recorder	9.40	5
51	13	Timekeeper	9.50	5
51	14	Arbiter Assistant	9.30	5
51	15	Score Recorder	9.40	5
52	13	Timekeeper	9.50	5
52	14	Arbiter Assistant	9.30	5
52	15	Score Recorder	9.40	5
53	13	Timekeeper	9.50	5
53	14	Arbiter Assistant	9.40	5
53	15	Score Recorder	9.40	5
54	13	Timekeeper	9.60	5
54	14	Arbiter Assistant	9.40	5
54	15	Score Recorder	9.40	5
55	13	Timekeeper	9.50	5
55	14	Arbiter Assistant	9.30	5
55	15	Score Recorder	9.40	5
56	13	Timekeeper	9.50	5
56	14	Arbiter Assistant	9.30	5
56	15	Score Recorder	9.40	5
57	13	Timekeeper	9.50	5
57	14	Arbiter Assistant	9.40	5
57	15	Score Recorder	9.40	5
58	13	Timekeeper	9.60	5
58	14	Arbiter Assistant	9.40	5
58	15	Score Recorder	9.50	5
59	13	Timekeeper	9.60	5
59	14	Arbiter Assistant	9.40	5
59	15	Score Recorder	9.40	5
60	13	Timekeeper	9.70	5
60	14	Arbiter Assistant	9.50	5
60	15	Score Recorder	9.50	5
61	16	Table Manager	9.50	5
61	17	Ball Feeder	9.20	5
61	18	Scorer	9.30	5
61	19	Equipment Handler	9.10	5
62	16	Table Manager	9.40	5
62	17	Ball Feeder	9.20	5
62	18	Scorer	9.30	5
62	19	Equipment Handler	9.10	5
63	16	Table Manager	9.50	5
63	17	Ball Feeder	9.30	5
63	18	Scorer	9.40	5
63	19	Equipment Handler	9.20	5
64	16	Table Manager	9.50	5
64	17	Ball Feeder	9.30	5
64	18	Scorer	9.40	5
64	19	Equipment Handler	9.20	5
65	16	Table Manager	9.50	5
65	17	Ball Feeder	9.30	5
65	18	Scorer	9.40	5
65	19	Equipment Handler	9.30	5
66	16	Table Manager	9.50	5
66	17	Ball Feeder	9.30	5
66	18	Scorer	9.40	5
66	19	Equipment Handler	9.30	5
67	16	Table Manager	9.50	5
67	17	Ball Feeder	9.30	5
67	18	Scorer	9.40	5
67	19	Equipment Handler	9.30	5
68	16	Table Manager	9.50	5
68	17	Ball Feeder	9.30	5
68	18	Scorer	9.40	5
68	19	Equipment Handler	9.30	5
69	16	Table Manager	9.50	5
69	17	Ball Feeder	9.30	5
69	18	Scorer	9.40	5
69	19	Equipment Handler	9.30	5
70	16	Table Manager	9.50	5
70	17	Ball Feeder	9.30	5
70	18	Scorer	9.40	5
70	19	Equipment Handler	9.30	5
71	16	Table Manager	9.60	5
71	17	Ball Feeder	9.40	5
71	18	Scorer	9.50	5
71	19	Equipment Handler	9.40	5
72	16	Table Manager	9.60	5
72	17	Ball Feeder	9.40	5
72	18	Scorer	9.50	5
72	19	Equipment Handler	9.40	5
73	16	Table Manager	9.60	5
73	17	Ball Feeder	9.40	5
73	18	Scorer	9.50	5
73	19	Equipment Handler	9.40	5
74	16	Table Manager	9.60	5
74	17	Ball Feeder	9.40	5
74	18	Scorer	9.50	5
74	19	Equipment Handler	9.40	5
75	16	Table Manager	9.70	5
75	17	Ball Feeder	9.50	5
75	18	Scorer	9.50	5
75	19	Equipment Handler	9.40	5
76	20	Court Manager	9.50	6
76	21	Scorer	9.30	6
76	22	Line Judge	9.20	6
76	23	Shuttle Distributor	9.10	6
77	20	Court Manager	9.50	6
77	21	Scorer	9.30	6
77	22	Line Judge	9.30	6
77	23	Shuttle Distributor	9.20	6
78	20	Court Manager	9.60	6
78	21	Scorer	9.40	6
78	22	Line Judge	9.30	6
78	23	Shuttle Distributor	9.30	6
79	20	Court Manager	9.50	6
79	21	Scorer	9.30	6
79	22	Line Judge	9.30	6
79	23	Shuttle Distributor	9.20	6
80	20	Court Manager	9.60	6
80	21	Scorer	9.40	6
80	22	Line Judge	9.40	6
80	23	Shuttle Distributor	9.30	6
81	20	Court Manager	9.60	6
81	21	Scorer	9.40	6
81	22	Line Judge	9.40	6
81	23	Shuttle Distributor	9.30	6
82	20	Court Manager	9.50	6
82	21	Scorer	9.30	6
82	22	Line Judge	9.30	6
82	23	Shuttle Distributor	9.20	6
83	20	Court Manager	9.60	6
83	21	Scorer	9.40	6
83	22	Line Judge	9.40	6
83	23	Shuttle Distributor	9.30	6
84	20	Court Manager	9.60	6
84	21	Scorer	9.40	6
84	22	Line Judge	9.40	6
84	23	Shuttle Distributor	9.30	6
85	20	Court Manager	9.60	6
85	21	Scorer	9.40	6
85	22	Line Judge	9.40	6
85	23	Shuttle Distributor	9.30	6
86	20	Court Manager	9.70	6
86	21	Scorer	9.50	6
86	22	Line Judge	9.50	6
86	23	Shuttle Distributor	9.40	6
87	20	Court Manager	9.60	6
87	21	Scorer	9.40	6
87	22	Line Judge	9.40	6
87	23	Shuttle Distributor	9.30	6
88	20	Court Manager	9.70	6
88	21	Scorer	9.50	6
88	22	Line Judge	9.40	6
88	23	Shuttle Distributor	9.40	6
89	20	Court Manager	9.70	6
89	21	Scorer	9.50	6
89	22	Line Judge	9.40	6
89	23	Shuttle Distributor	9.40	6
90	20	Court Manager	9.80	6
90	21	Scorer	9.60	6
90	22	Line Judge	9.50	6
90	23	Shuttle Distributor	9.40	6
91	24	Ball Collector	9.40	6
91	25	Scorekeeper	9.30	6
91	26	Net Assistant	9.30	6
91	27	Umpire Assistant	9.20	6
91	28	Match Recorder	9.40	6
92	24	Ball Collector	9.40	6
92	25	Scorekeeper	9.30	6
92	26	Net Assistant	9.40	6
92	27	Umpire Assistant	9.20	6
92	28	Match Recorder	9.40	6
93	24	Ball Collector	9.50	6
93	25	Scorekeeper	9.40	6
93	26	Net Assistant	9.40	6
93	27	Umpire Assistant	9.30	6
93	28	Match Recorder	9.50	6
94	24	Ball Collector	9.50	6
94	25	Scorekeeper	9.40	6
94	26	Net Assistant	9.40	6
94	27	Umpire Assistant	9.30	6
94	28	Match Recorder	9.40	6
95	24	Ball Collector	9.40	6
95	25	Scorekeeper	9.30	6
95	26	Net Assistant	9.30	6
95	27	Umpire Assistant	9.20	6
95	28	Match Recorder	9.30	6
96	24	Ball Collector	9.50	6
96	25	Scorekeeper	9.30	6
96	26	Net Assistant	9.40	6
96	27	Umpire Assistant	9.30	6
96	28	Match Recorder	9.40	6
97	24	Ball Collector	9.50	6
97	25	Scorekeeper	9.40	6
97	26	Net Assistant	9.40	6
97	27	Umpire Assistant	9.30	6
97	28	Match Recorder	9.40	6
98	24	Ball Collector	9.60	6
98	25	Scorekeeper	9.40	6
98	26	Net Assistant	9.40	6
98	27	Umpire Assistant	9.40	6
98	28	Match Recorder	9.50	6
99	24	Ball Collector	9.50	6
99	25	Scorekeeper	9.40	6
99	26	Net Assistant	9.40	6
99	27	Umpire Assistant	9.40	6
99	28	Match Recorder	9.40	6
100	24	Ball Collector	9.50	6
100	25	Scorekeeper	9.40	6
100	26	Net Assistant	9.40	6
100	27	Umpire Assistant	9.30	6
100	28	Match Recorder	9.40	6
101	24	Ball Collector	9.60	6
101	25	Scorekeeper	9.50	6
101	26	Net Assistant	9.50	6
101	27	Umpire Assistant	9.40	6
101	28	Match Recorder	9.50	6
102	24	Ball Collector	9.60	6
102	25	Scorekeeper	9.40	6
102	26	Net Assistant	9.40	6
102	27	Umpire Assistant	9.40	6
102	28	Match Recorder	9.50	6
103	24	Ball Collector	9.60	6
103	25	Scorekeeper	9.40	6
103	26	Net Assistant	9.50	6
103	27	Umpire Assistant	9.40	6
103	28	Match Recorder	9.60	6
104	24	Ball Collector	9.70	6
104	25	Scorekeeper	9.50	6
104	26	Net Assistant	9.50	6
104	27	Umpire Assistant	9.50	6
104	28	Match Recorder	9.60	6
105	24	Ball Collector	9.70	6
105	25	Scorekeeper	9.50	6
105	26	Net Assistant	9.50	6
105	27	Umpire Assistant	9.40	6
105	28	Match Recorder	9.60	6
106	29	Board Setup	9.40	4
106	30	Score Announcer	9.20	4
106	31	Coin Refiller	9.20	4
107	29	Board Setup	9.40	4
107	30	Score Announcer	9.20	4
107	31	Coin Refiller	9.30	4
108	29	Board Setup	9.50	4
108	30	Score Announcer	9.30	4
108	31	Coin Refiller	9.30	4
109	29	Board Setup	9.50	4
109	30	Score Announcer	9.30	4
109	31	Coin Refiller	9.30	4
110	29	Board Setup	9.50	4
110	30	Score Announcer	9.30	4
110	31	Coin Refiller	9.40	4
111	29	Board Setup	9.50	4
111	30	Score Announcer	9.30	4
111	31	Coin Refiller	9.30	4
112	29	Board Setup	9.50	4
112	30	Score Announcer	9.30	4
112	31	Coin Refiller	9.30	4
113	29	Board Setup	9.60	4
113	30	Score Announcer	9.40	4
113	31	Coin Refiller	9.40	4
114	29	Board Setup	9.60	4
114	30	Score Announcer	9.40	4
114	31	Coin Refiller	9.40	4
115	29	Board Setup	9.60	4
115	30	Score Announcer	9.40	4
115	31	Coin Refiller	9.40	4
116	29	Board Setup	9.60	4
116	30	Score Announcer	9.40	4
116	31	Coin Refiller	9.40	4
117	29	Board Setup	9.70	4
117	30	Score Announcer	9.50	4
117	31	Coin Refiller	9.50	4
118	29	Board Setup	9.70	4
118	30	Score Announcer	9.50	4
118	31	Coin Refiller	9.50	4
119	29	Board Setup	9.70	4
119	30	Score Announcer	9.50	4
119	31	Coin Refiller	9.50	4
120	29	Board Setup	9.80	4
120	30	Score Announcer	9.60	4
120	31	Coin Refiller	9.60	4
121	32	Timekeeper	9.40	5
121	33	Arbiter Assistant	9.30	5
121	34	Score Recorder	9.30	5
122	32	Timekeeper	9.50	5
122	33	Arbiter Assistant	9.30	5
122	34	Score Recorder	9.30	5
123	32	Timekeeper	9.50	5
123	33	Arbiter Assistant	9.40	5
123	34	Score Recorder	9.30	5
124	32	Timekeeper	9.50	5
124	33	Arbiter Assistant	9.40	5
124	34	Score Recorder	9.30	5
125	32	Timekeeper	9.50	5
125	33	Arbiter Assistant	9.40	5
125	34	Score Recorder	9.40	5
126	32	Timekeeper	9.60	5
126	33	Arbiter Assistant	9.40	5
126	34	Score Recorder	9.40	5
127	32	Timekeeper	9.60	5
127	33	Arbiter Assistant	9.40	5
127	34	Score Recorder	9.40	5
128	32	Timekeeper	9.60	5
128	33	Arbiter Assistant	9.50	5
128	34	Score Recorder	9.40	5
129	32	Timekeeper	9.60	5
129	33	Arbiter Assistant	9.50	5
129	34	Score Recorder	9.40	5
130	32	Timekeeper	9.60	5
130	33	Arbiter Assistant	9.50	5
130	34	Score Recorder	9.40	5
131	32	Timekeeper	9.70	5
131	33	Arbiter Assistant	9.50	5
131	34	Score Recorder	9.50	5
132	32	Timekeeper	9.70	5
132	33	Arbiter Assistant	9.50	5
132	34	Score Recorder	9.50	5
133	32	Timekeeper	9.70	5
133	33	Arbiter Assistant	9.50	5
133	34	Score Recorder	9.50	5
134	32	Timekeeper	9.70	5
134	33	Arbiter Assistant	9.50	5
134	34	Score Recorder	9.50	5
135	32	Timekeeper	9.80	5
135	33	Arbiter Assistant	9.60	5
135	34	Score Recorder	9.60	5
136	35	Table Manager	9.50	5
136	36	Ball Feeder	9.30	5
136	37	Scorer	9.30	5
136	38	Equipment Handler	9.20	5
137	35	Table Manager	9.50	5
137	36	Ball Feeder	9.30	5
137	37	Scorer	9.40	5
137	38	Equipment Handler	9.30	5
138	35	Table Manager	9.60	5
138	36	Ball Feeder	9.40	5
138	37	Scorer	9.40	5
138	38	Equipment Handler	9.30	5
139	39	Table Manager	9.50	5
139	40	Ball Feeder	9.30	5
139	1	Scorer	9.30	5
139	2	Equipment Handler	9.20	5
140	39	Table Manager	9.50	5
140	40	Ball Feeder	9.30	5
140	1	Scorer	9.30	5
140	2	Equipment Handler	9.20	5
141	39	Table Manager	9.60	5
141	40	Ball Feeder	9.40	5
141	1	Scorer	9.40	5
141	2	Equipment Handler	9.30	5
142	39	Table Manager	9.60	5
142	40	Ball Feeder	9.40	5
142	1	Scorer	9.40	5
142	2	Equipment Handler	9.30	5
143	39	Table Manager	9.60	5
143	40	Ball Feeder	9.40	5
143	1	Scorer	9.40	5
143	2	Equipment Handler	9.30	5
144	39	Table Manager	9.60	5
144	40	Ball Feeder	9.40	5
144	1	Scorer	9.40	5
144	2	Equipment Handler	9.30	5
145	39	Table Manager	9.60	5
145	40	Ball Feeder	9.40	5
145	1	Scorer	9.40	5
145	2	Equipment Handler	9.30	5
146	39	Table Manager	9.70	5
146	40	Ball Feeder	9.50	5
146	1	Scorer	9.50	5
146	2	Equipment Handler	9.40	5
147	39	Table Manager	9.70	5
147	40	Ball Feeder	9.50	5
147	1	Scorer	9.50	5
147	2	Equipment Handler	9.40	5
148	39	Table Manager	9.70	5
148	40	Ball Feeder	9.50	5
148	1	Scorer	9.50	5
148	2	Equipment Handler	9.40	5
149	39	Table Manager	9.70	5
149	40	Ball Feeder	9.50	5
149	1	Scorer	9.50	5
149	2	Equipment Handler	9.40	5
150	39	Table Manager	9.80	5
150	40	Ball Feeder	9.50	5
150	1	Scorer	9.60	5
150	2	Equipment Handler	9.50	5
151	3	Court Manager	9.60	6
151	4	Scorer	9.40	6
151	5	Line Judge	9.40	6
151	6	Shuttle Distributor	9.30	6
152	3	Court Manager	9.60	6
152	4	Scorer	9.40	6
152	5	Line Judge	9.40	6
152	6	Shuttle Distributor	9.30	6
153	3	Court Manager	9.70	6
153	4	Scorer	9.50	6
153	5	Line Judge	9.50	6
153	6	Shuttle Distributor	9.40	6
154	3	Court Manager	9.70	6
154	4	Scorer	9.50	6
154	5	Line Judge	9.50	6
154	6	Shuttle Distributor	9.40	6
155	3	Court Manager	9.70	6
155	4	Scorer	9.50	6
155	5	Line Judge	9.50	6
155	6	Shuttle Distributor	9.40	6
156	3	Court Manager	9.70	6
156	4	Scorer	9.50	6
156	5	Line Judge	9.50	6
156	6	Shuttle Distributor	9.40	6
157	3	Court Manager	9.80	6
157	4	Scorer	9.50	6
157	5	Line Judge	9.60	6
157	6	Shuttle Distributor	9.50	6
158	3	Court Manager	9.80	6
158	4	Scorer	9.60	6
158	5	Line Judge	9.60	6
158	6	Shuttle Distributor	9.50	6
159	3	Court Manager	9.80	6
159	4	Scorer	9.60	6
159	5	Line Judge	9.60	6
159	6	Shuttle Distributor	9.50	6
160	3	Court Manager	9.80	6
160	4	Scorer	9.60	6
160	5	Line Judge	9.60	6
160	6	Shuttle Distributor	9.50	6
161	3	Court Manager	9.80	6
161	4	Scorer	9.60	6
161	5	Line Judge	9.60	6
161	6	Shuttle Distributor	9.50	6
162	3	Court Manager	9.80	6
162	4	Scorer	9.60	6
162	5	Line Judge	9.60	6
162	6	Shuttle Distributor	9.50	6
163	3	Court Manager	9.90	6
163	4	Scorer	9.70	6
163	5	Line Judge	9.60	6
163	6	Shuttle Distributor	9.60	6
164	3	Court Manager	9.90	6
164	4	Scorer	9.70	6
164	5	Line Judge	9.60	6
164	6	Shuttle Distributor	9.60	6
165	3	Court Manager	9.90	6
165	4	Scorer	9.70	6
165	5	Line Judge	9.60	6
165	6	Shuttle Distributor	9.60	6
166	7	Ball Collector	9.60	6
166	8	Scorekeeper	9.50	6
166	9	Net Assistant	9.40	6
166	10	Umpire Assistant	9.40	6
166	11	Match Recorder	9.50	6
167	7	Ball Collector	9.60	6
167	8	Scorekeeper	9.50	6
167	9	Net Assistant	9.40	6
167	10	Umpire Assistant	9.40	6
167	11	Match Recorder	9.50	6
168	7	Ball Collector	9.70	6
168	8	Scorekeeper	9.50	6
168	9	Net Assistant	9.50	6
168	10	Umpire Assistant	9.50	6
168	11	Match Recorder	9.60	6
169	7	Ball Collector	9.70	6
169	8	Scorekeeper	9.50	6
169	9	Net Assistant	9.50	6
169	10	Umpire Assistant	9.50	6
169	11	Match Recorder	9.60	6
170	7	Ball Collector	9.70	6
170	8	Scorekeeper	9.50	6
170	9	Net Assistant	9.50	6
170	10	Umpire Assistant	9.50	6
170	11	Match Recorder	9.60	6
171	7	Ball Collector	9.70	6
171	8	Scorekeeper	9.50	6
171	9	Net Assistant	9.50	6
171	10	Umpire Assistant	9.50	6
171	11	Match Recorder	9.60	6
172	7	Ball Collector	9.80	6
172	8	Scorekeeper	9.60	6
172	9	Net Assistant	9.50	6
172	10	Umpire Assistant	9.50	6
172	11	Match Recorder	9.60	6
173	7	Ball Collector	9.80	6
173	8	Scorekeeper	9.60	6
173	9	Net Assistant	9.50	6
173	10	Umpire Assistant	9.50	6
173	11	Match Recorder	9.60	6
174	7	Ball Collector	9.80	6
174	8	Scorekeeper	9.60	6
174	9	Net Assistant	9.50	6
174	10	Umpire Assistant	9.50	6
174	11	Match Recorder	9.70	6
175	7	Ball Collector	9.80	6
175	8	Scorekeeper	9.60	6
175	9	Net Assistant	9.50	6
175	10	Umpire Assistant	9.50	6
175	11	Match Recorder	9.70	6
176	7	Ball Collector	9.80	6
176	8	Scorekeeper	9.60	6
176	9	Net Assistant	9.50	6
176	10	Umpire Assistant	9.50	6
176	11	Match Recorder	9.70	6
177	7	Ball Collector	9.80	6
177	8	Scorekeeper	9.60	6
177	9	Net Assistant	9.50	6
177	10	Umpire Assistant	9.50	6
177	11	Match Recorder	9.70	6
178	7	Ball Collector	9.90	6
178	8	Scorekeeper	9.70	6
178	9	Net Assistant	9.60	6
178	10	Umpire Assistant	9.50	6
178	11	Match Recorder	9.70	6
179	7	Ball Collector	9.90	6
179	8	Scorekeeper	9.70	6
179	9	Net Assistant	9.60	6
179	10	Umpire Assistant	9.50	6
179	11	Match Recorder	9.80	6
180	7	Ball Collector	9.90	6
180	8	Scorekeeper	9.70	6
180	9	Net Assistant	9.60	6
180	10	Umpire Assistant	9.60	6
180	11	Match Recorder	9.80	6
181	12	Board Setup	9.50	4
181	13	Score Announcer	9.30	4
181	14	Coin Refiller	9.30	4
182	12	Board Setup	9.50	4
182	13	Score Announcer	9.30	4
182	14	Coin Refiller	9.30	4
183	12	Board Setup	9.60	4
183	13	Score Announcer	9.40	4
183	14	Coin Refiller	9.40	4
184	12	Board Setup	9.60	4
184	13	Score Announcer	9.40	4
184	14	Coin Refiller	9.40	4
185	12	Board Setup	9.60	4
185	13	Score Announcer	9.40	4
185	14	Coin Refiller	9.40	4
186	12	Board Setup	9.60	4
186	13	Score Announcer	9.40	4
186	14	Coin Refiller	9.40	4
187	12	Board Setup	9.60	4
187	13	Score Announcer	9.40	4
187	14	Coin Refiller	9.40	4
188	12	Board Setup	9.70	4
188	13	Score Announcer	9.50	4
188	14	Coin Refiller	9.50	4
189	12	Board Setup	9.70	4
189	13	Score Announcer	9.50	4
189	14	Coin Refiller	9.50	4
190	12	Board Setup	9.70	4
190	13	Score Announcer	9.50	4
190	14	Coin Refiller	9.50	4
191	12	Board Setup	9.80	4
191	13	Score Announcer	9.50	4
191	14	Coin Refiller	9.50	4
192	12	Board Setup	9.80	4
192	13	Score Announcer	9.50	4
192	14	Coin Refiller	9.50	4
193	12	Board Setup	9.80	4
193	13	Score Announcer	9.60	4
193	14	Coin Refiller	9.60	4
194	12	Board Setup	9.80	4
194	13	Score Announcer	9.60	4
194	14	Coin Refiller	9.60	4
195	12	Board Setup	9.90	4
195	13	Score Announcer	9.60	4
195	14	Coin Refiller	9.60	4
196	15	Timekeeper	9.60	5
196	16	Arbiter Assistant	9.50	5
196	17	Score Recorder	9.50	5
197	15	Timekeeper	9.60	5
197	16	Arbiter Assistant	9.50	5
197	17	Score Recorder	9.50	5
198	15	Timekeeper	9.70	5
198	16	Arbiter Assistant	9.60	5
198	17	Score Recorder	9.50	5
199	15	Timekeeper	9.70	5
199	16	Arbiter Assistant	9.60	5
199	17	Score Recorder	9.60	5
200	15	Timekeeper	9.70	5
200	16	Arbiter Assistant	9.60	5
200	17	Score Recorder	9.60	5
201	15	Timekeeper	9.70	5
201	16	Arbiter Assistant	9.60	5
201	17	Score Recorder	9.60	5
202	15	Timekeeper	9.70	5
202	16	Arbiter Assistant	9.60	5
202	17	Score Recorder	9.60	5
203	15	Timekeeper	9.80	5
203	16	Arbiter Assistant	9.60	5
203	17	Score Recorder	9.60	5
204	15	Timekeeper	9.80	5
204	16	Arbiter Assistant	9.60	5
204	17	Score Recorder	9.60	5
205	15	Timekeeper	9.80	5
205	16	Arbiter Assistant	9.60	5
205	17	Score Recorder	9.60	5
206	15	Timekeeper	9.80	5
206	16	Arbiter Assistant	9.60	5
206	17	Score Recorder	9.60	5
207	15	Timekeeper	9.90	5
207	16	Arbiter Assistant	9.70	5
207	17	Score Recorder	9.60	5
208	15	Timekeeper	9.90	5
208	16	Arbiter Assistant	9.70	5
208	17	Score Recorder	9.60	5
209	15	Timekeeper	9.90	5
209	16	Arbiter Assistant	9.70	5
209	17	Score Recorder	9.60	5
210	15	Timekeeper	9.90	5
210	16	Arbiter Assistant	9.70	5
210	17	Score Recorder	9.60	5
211	18	Table Manager	9.60	5
211	19	Ball Feeder	9.50	5
211	20	Scorer	9.40	5
211	21	Equipment Handler	9.40	5
212	18	Table Manager	9.60	5
212	19	Ball Feeder	9.50	5
212	20	Scorer	9.40	5
212	21	Equipment Handler	9.40	5
213	18	Table Manager	9.70	5
213	19	Ball Feeder	9.50	5
213	20	Scorer	9.40	5
213	21	Equipment Handler	9.40	5
214	18	Table Manager	9.70	5
214	19	Ball Feeder	9.50	5
214	20	Scorer	9.40	5
214	21	Equipment Handler	9.40	5
215	18	Table Manager	9.70	5
215	19	Ball Feeder	9.50	5
215	20	Scorer	9.40	5
215	21	Equipment Handler	9.40	5
216	18	Table Manager	9.80	5
216	19	Ball Feeder	9.50	5
216	20	Scorer	9.50	5
216	21	Equipment Handler	9.50	5
217	18	Table Manager	9.80	5
217	19	Ball Feeder	9.50	5
217	20	Scorer	9.50	5
217	21	Equipment Handler	9.50	5
218	18	Table Manager	9.80	5
218	19	Ball Feeder	9.60	5
218	20	Scorer	9.50	5
218	21	Equipment Handler	9.50	5
219	18	Table Manager	9.80	5
219	19	Ball Feeder	9.60	5
219	20	Scorer	9.50	5
219	21	Equipment Handler	9.50	5
220	18	Table Manager	9.80	5
220	19	Ball Feeder	9.60	5
220	20	Scorer	9.50	5
220	21	Equipment Handler	9.50	5
221	18	Table Manager	9.90	5
221	19	Ball Feeder	9.60	5
221	20	Scorer	9.50	5
221	21	Equipment Handler	9.50	5
222	18	Table Manager	9.90	5
222	19	Ball Feeder	9.60	5
222	20	Scorer	9.60	5
222	21	Equipment Handler	9.60	5
223	18	Table Manager	9.90	5
223	19	Ball Feeder	9.60	5
223	20	Scorer	9.60	5
223	21	Equipment Handler	9.60	5
224	18	Table Manager	9.90	5
224	19	Ball Feeder	9.60	5
224	20	Scorer	9.60	5
224	21	Equipment Handler	9.60	5
225	18	Table Manager	9.90	5
225	19	Ball Feeder	9.60	5
225	20	Scorer	9.60	5
225	21	Equipment Handler	9.60	5
\.


--
-- TOC entry 5156 (class 0 OID 18273)
-- Dependencies: 233
-- Data for Name: individual_sport_matches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.individual_sport_matches (i_match_id, tournament_id, sport_name, player1_id, player2_id, venue_id, match_type, match_status, date, start_time) FROM stdin;
1	1	Badminton	1	2	11	Group Stage	Finished	2022-11-02	09:00:00
2	1	Badminton	1	3	11	Group Stage	Finished	2022-11-02	10:00:00
3	1	Badminton	1	4	11	Group Stage	Finished	2022-11-02	11:00:00
4	1	Badminton	2	3	12	Group Stage	Finished	2022-11-03	09:00:00
5	1	Badminton	2	4	12	Group Stage	Finished	2022-11-03	10:00:00
6	1	Badminton	3	4	12	Group Stage	Finished	2022-11-03	11:00:00
7	1	Badminton	5	6	11	Group Stage	Finished	2022-11-03	14:00:00
8	1	Badminton	5	7	11	Group Stage	Finished	2022-11-03	15:00:00
9	1	Badminton	5	8	11	Group Stage	Finished	2022-11-03	16:00:00
10	1	Badminton	6	7	12	Group Stage	Finished	2022-11-04	09:00:00
11	1	Badminton	6	8	12	Group Stage	Finished	2022-11-04	10:00:00
12	1	Badminton	7	8	12	Group Stage	Finished	2022-11-04	11:00:00
13	1	Badminton	1	6	11	Semi-Final	Finished	2022-11-04	14:00:00
14	1	Badminton	5	2	12	Semi-Final	Finished	2022-11-04	15:00:00
15	1	Badminton	1	2	21	Final	Finished	2022-11-05	18:00:00
16	1	Tennis	9	10	13	Group Stage	Finished	2022-11-02	09:30:00
17	1	Tennis	9	11	13	Group Stage	Finished	2022-11-02	10:30:00
18	1	Tennis	9	12	13	Group Stage	Finished	2022-11-02	11:30:00
19	1	Tennis	10	11	14	Group Stage	Finished	2022-11-03	09:30:00
20	1	Tennis	10	12	14	Group Stage	Finished	2022-11-03	10:30:00
21	1	Tennis	11	12	14	Group Stage	Finished	2022-11-03	11:30:00
22	1	Tennis	13	14	13	Group Stage	Finished	2022-11-03	14:30:00
23	1	Tennis	13	15	13	Group Stage	Finished	2022-11-03	15:30:00
24	1	Tennis	13	16	13	Group Stage	Finished	2022-11-03	16:30:00
25	1	Tennis	14	15	14	Group Stage	Finished	2022-11-04	09:30:00
26	1	Tennis	14	16	14	Group Stage	Finished	2022-11-04	10:30:00
27	1	Tennis	15	16	14	Group Stage	Finished	2022-11-04	11:30:00
28	1	Tennis	9	14	13	Semi-Final	Finished	2022-11-04	14:30:00
29	1	Tennis	13	10	14	Semi-Final	Finished	2022-11-04	15:30:00
30	1	Tennis	9	10	21	Final	Finished	2022-11-05	17:00:00
31	1	Carrom	17	18	19	Group Stage	Finished	2022-11-02	12:00:00
32	1	Carrom	17	19	19	Group Stage	Finished	2022-11-02	13:00:00
33	1	Carrom	17	20	19	Group Stage	Finished	2022-11-02	14:00:00
34	1	Carrom	18	19	20	Group Stage	Finished	2022-11-03	12:00:00
35	1	Carrom	18	20	20	Group Stage	Finished	2022-11-03	13:00:00
36	1	Carrom	19	20	20	Group Stage	Finished	2022-11-03	14:00:00
37	1	Carrom	21	22	19	Group Stage	Finished	2022-11-03	16:00:00
38	1	Carrom	21	23	19	Group Stage	Finished	2022-11-03	17:00:00
39	1	Carrom	21	24	19	Group Stage	Finished	2022-11-03	18:00:00
40	1	Carrom	22	23	20	Group Stage	Finished	2022-11-04	12:00:00
41	1	Carrom	22	24	20	Group Stage	Finished	2022-11-04	13:00:00
42	1	Carrom	23	24	20	Group Stage	Finished	2022-11-04	14:00:00
43	1	Carrom	17	22	19	Semi-Final	Finished	2022-11-04	16:00:00
44	1	Carrom	21	18	20	Semi-Final	Finished	2022-11-04	17:00:00
45	1	Carrom	17	18	21	Final	Finished	2022-11-05	10:00:00
46	1	Chess	25	26	17	Group Stage	Finished	2022-11-02	15:00:00
47	1	Chess	25	27	17	Group Stage	Finished	2022-11-02	16:00:00
48	1	Chess	25	28	17	Group Stage	Finished	2022-11-02	17:00:00
49	1	Chess	26	27	18	Group Stage	Finished	2022-11-03	15:00:00
50	1	Chess	26	28	18	Group Stage	Finished	2022-11-03	16:00:00
51	1	Chess	27	28	18	Group Stage	Finished	2022-11-03	17:00:00
52	1	Chess	29	30	17	Group Stage	Finished	2022-11-03	19:00:00
53	1	Chess	29	31	17	Group Stage	Finished	2022-11-03	20:00:00
54	1	Chess	29	32	17	Group Stage	Finished	2022-11-04	15:00:00
55	1	Chess	30	31	18	Group Stage	Finished	2022-11-04	16:00:00
56	1	Chess	30	32	18	Group Stage	Finished	2022-11-04	17:00:00
57	1	Chess	31	32	18	Group Stage	Finished	2022-11-04	18:00:00
58	1	Chess	25	30	17	Semi-Final	Finished	2022-11-05	09:00:00
59	1	Chess	29	26	18	Semi-Final	Finished	2022-11-05	10:00:00
60	1	Chess	25	26	21	Final	Finished	2022-11-05	12:00:00
61	1	Table Tennis	33	34	15	Group Stage	Finished	2022-11-02	18:00:00
62	1	Table Tennis	33	35	15	Group Stage	Finished	2022-11-02	19:00:00
63	1	Table Tennis	33	36	15	Group Stage	Finished	2022-11-02	20:00:00
64	1	Table Tennis	34	35	16	Group Stage	Finished	2022-11-03	18:00:00
65	1	Table Tennis	34	36	16	Group Stage	Finished	2022-11-03	19:00:00
66	1	Table Tennis	35	36	16	Group Stage	Finished	2022-11-03	20:00:00
67	1	Table Tennis	37	38	15	Group Stage	Finished	2022-11-04	18:00:00
68	1	Table Tennis	37	39	15	Group Stage	Finished	2022-11-04	19:00:00
69	1	Table Tennis	37	40	15	Group Stage	Finished	2022-11-04	20:00:00
70	1	Table Tennis	38	39	16	Group Stage	Finished	2022-11-05	09:30:00
71	1	Table Tennis	38	40	16	Group Stage	Finished	2022-11-05	10:30:00
72	1	Table Tennis	39	40	16	Group Stage	Finished	2022-11-05	11:30:00
73	1	Table Tennis	33	38	15	Semi-Final	Finished	2022-11-05	14:30:00
74	1	Table Tennis	37	34	16	Semi-Final	Finished	2022-11-05	15:30:00
75	1	Table Tennis	33	34	21	Final	Finished	2022-11-05	18:30:00
76	2	Badminton	1	2	11	Group Stage	Finished	2023-10-25	09:00:00
77	2	Badminton	1	3	11	Group Stage	Finished	2023-10-25	10:00:00
78	2	Badminton	1	4	11	Group Stage	Finished	2023-10-25	11:00:00
79	2	Badminton	2	3	12	Group Stage	Finished	2023-10-26	09:00:00
80	2	Badminton	2	4	12	Group Stage	Finished	2023-10-26	10:00:00
81	2	Badminton	3	4	12	Group Stage	Finished	2023-10-26	11:00:00
82	2	Badminton	5	6	11	Group Stage	Finished	2023-10-26	14:00:00
83	2	Badminton	5	7	11	Group Stage	Finished	2023-10-26	15:00:00
84	2	Badminton	5	8	11	Group Stage	Finished	2023-10-26	16:00:00
85	2	Badminton	6	7	12	Group Stage	Finished	2023-10-27	09:00:00
86	2	Badminton	6	8	12	Group Stage	Finished	2023-10-27	10:00:00
87	2	Badminton	7	8	12	Group Stage	Finished	2023-10-27	11:00:00
88	2	Badminton	1	6	11	Semi-Final	Finished	2023-10-27	14:00:00
89	2	Badminton	5	2	12	Semi-Final	Finished	2023-10-27	15:00:00
90	2	Badminton	1	2	21	Final	Finished	2023-10-28	17:00:00
91	2	Tennis	9	10	13	Group Stage	Finished	2023-10-25	09:30:00
92	2	Tennis	9	11	13	Group Stage	Finished	2023-10-25	10:30:00
93	2	Tennis	9	12	13	Group Stage	Finished	2023-10-25	11:30:00
94	2	Tennis	10	11	14	Group Stage	Finished	2023-10-26	09:30:00
95	2	Tennis	10	12	14	Group Stage	Finished	2023-10-26	10:30:00
96	2	Tennis	11	12	14	Group Stage	Finished	2023-10-26	11:30:00
97	2	Tennis	13	14	13	Group Stage	Finished	2023-10-26	14:30:00
98	2	Tennis	13	15	13	Group Stage	Finished	2023-10-26	15:30:00
99	2	Tennis	13	16	13	Group Stage	Finished	2023-10-26	16:30:00
100	2	Tennis	14	15	14	Group Stage	Finished	2023-10-27	09:30:00
101	2	Tennis	14	16	14	Group Stage	Finished	2023-10-27	10:30:00
102	2	Tennis	15	16	14	Group Stage	Finished	2023-10-27	11:30:00
103	2	Tennis	9	14	13	Semi-Final	Finished	2023-10-27	14:30:00
104	2	Tennis	13	10	14	Semi-Final	Finished	2023-10-27	15:30:00
105	2	Tennis	9	10	21	Final	Finished	2023-10-28	17:00:00
106	2	Carrom	17	18	19	Group Stage	Finished	2023-10-25	12:00:00
107	2	Carrom	17	19	19	Group Stage	Finished	2023-10-25	13:00:00
108	2	Carrom	17	20	19	Group Stage	Finished	2023-10-25	14:00:00
109	2	Carrom	18	19	20	Group Stage	Finished	2023-10-26	12:00:00
110	2	Carrom	18	20	20	Group Stage	Finished	2023-10-26	13:00:00
111	2	Carrom	19	20	20	Group Stage	Finished	2023-10-26	14:00:00
112	2	Carrom	21	22	19	Group Stage	Finished	2023-10-26	16:00:00
113	2	Carrom	21	23	19	Group Stage	Finished	2023-10-26	17:00:00
114	2	Carrom	21	24	19	Group Stage	Finished	2023-10-26	18:00:00
115	2	Carrom	22	23	20	Group Stage	Finished	2023-10-27	12:00:00
116	2	Carrom	22	24	20	Group Stage	Finished	2023-10-27	13:00:00
117	2	Carrom	23	24	20	Group Stage	Finished	2023-10-27	14:00:00
118	2	Carrom	17	22	19	Semi-Final	Finished	2023-10-27	16:00:00
119	2	Carrom	21	18	20	Semi-Final	Finished	2023-10-27	17:00:00
120	2	Carrom	17	18	21	Final	Finished	2023-10-28	10:00:00
121	2	Chess	25	26	17	Group Stage	Finished	2023-10-25	15:00:00
122	2	Chess	25	27	17	Group Stage	Finished	2023-10-25	16:00:00
123	2	Chess	25	28	17	Group Stage	Finished	2023-10-25	17:00:00
124	2	Chess	26	27	18	Group Stage	Finished	2023-10-26	15:00:00
125	2	Chess	26	28	18	Group Stage	Finished	2023-10-26	16:00:00
126	2	Chess	27	28	18	Group Stage	Finished	2023-10-26	17:00:00
127	2	Chess	29	30	17	Group Stage	Finished	2023-10-26	19:00:00
128	2	Chess	29	31	17	Group Stage	Finished	2023-10-26	20:00:00
129	2	Chess	29	32	17	Group Stage	Finished	2023-10-27	15:00:00
130	2	Chess	30	31	18	Group Stage	Finished	2023-10-27	16:00:00
131	2	Chess	30	32	18	Group Stage	Finished	2023-10-27	17:00:00
132	2	Chess	31	32	18	Group Stage	Finished	2023-10-27	18:00:00
133	2	Chess	25	30	17	Semi-Final	Finished	2023-10-28	09:00:00
134	2	Chess	29	26	18	Semi-Final	Finished	2023-10-28	10:00:00
135	2	Chess	25	26	21	Final	Finished	2023-10-28	12:00:00
136	2	Table Tennis	33	34	15	Group Stage	Finished	2023-10-25	18:00:00
137	2	Table Tennis	33	35	15	Group Stage	Finished	2023-10-25	19:00:00
138	2	Table Tennis	33	36	15	Group Stage	Finished	2023-10-25	20:00:00
139	2	Table Tennis	34	35	16	Group Stage	Finished	2023-10-26	18:00:00
140	2	Table Tennis	34	36	16	Group Stage	Finished	2023-10-26	19:00:00
141	2	Table Tennis	35	36	16	Group Stage	Finished	2023-10-26	20:00:00
142	2	Table Tennis	37	38	15	Group Stage	Finished	2023-10-27	18:00:00
143	2	Table Tennis	37	39	15	Group Stage	Finished	2023-10-27	19:00:00
144	2	Table Tennis	37	40	15	Group Stage	Finished	2023-10-27	20:00:00
145	2	Table Tennis	38	39	16	Group Stage	Finished	2023-10-28	09:30:00
146	2	Table Tennis	38	40	16	Group Stage	Finished	2023-10-28	10:30:00
147	2	Table Tennis	39	40	16	Group Stage	Finished	2023-10-28	11:30:00
148	2	Table Tennis	33	38	15	Semi-Final	Finished	2023-10-28	14:30:00
149	2	Table Tennis	37	34	16	Semi-Final	Finished	2023-10-28	15:30:00
150	2	Table Tennis	33	34	21	Final	Finished	2023-10-28	18:30:00
151	3	Badminton	1	2	11	Group Stage	Finished	2024-11-06	09:00:00
152	3	Badminton	1	3	11	Group Stage	Finished	2024-11-06	10:00:00
153	3	Badminton	1	4	11	Group Stage	Finished	2024-11-06	11:00:00
154	3	Badminton	2	3	12	Group Stage	Finished	2024-11-07	09:00:00
155	3	Badminton	2	4	12	Group Stage	Finished	2024-11-07	10:00:00
156	3	Badminton	3	4	12	Group Stage	Finished	2024-11-07	11:00:00
157	3	Badminton	5	6	11	Group Stage	Finished	2024-11-07	14:00:00
158	3	Badminton	5	7	11	Group Stage	Finished	2024-11-07	15:00:00
159	3	Badminton	5	8	11	Group Stage	Finished	2024-11-07	16:00:00
160	3	Badminton	6	7	12	Group Stage	Finished	2024-11-08	09:00:00
161	3	Badminton	6	8	12	Group Stage	Finished	2024-11-08	10:00:00
162	3	Badminton	7	8	12	Group Stage	Finished	2024-11-08	11:00:00
163	3	Badminton	1	6	11	Semi-Final	Finished	2024-11-08	14:00:00
164	3	Badminton	5	3	12	Semi-Final	Finished	2024-11-08	15:00:00
165	3	Badminton	1	3	21	Final	Finished	2024-11-09	17:00:00
166	3	Tennis	9	10	13	Group Stage	Finished	2024-11-06	09:30:00
167	3	Tennis	9	11	13	Group Stage	Finished	2024-11-06	10:30:00
168	3	Tennis	9	12	13	Group Stage	Finished	2024-11-06	11:30:00
169	3	Tennis	10	11	14	Group Stage	Finished	2024-11-07	09:30:00
170	3	Tennis	10	12	14	Group Stage	Finished	2024-11-07	10:30:00
171	3	Tennis	11	12	14	Group Stage	Finished	2024-11-07	11:30:00
172	3	Tennis	13	14	13	Group Stage	Finished	2024-11-07	14:30:00
173	3	Tennis	13	15	13	Group Stage	Finished	2024-11-07	15:30:00
174	3	Tennis	13	16	13	Group Stage	Finished	2024-11-07	16:30:00
175	3	Tennis	14	15	14	Group Stage	Finished	2024-11-08	09:30:00
176	3	Tennis	14	16	14	Group Stage	Finished	2024-11-08	10:30:00
177	3	Tennis	15	16	14	Group Stage	Finished	2024-11-08	11:30:00
178	3	Tennis	9	14	13	Semi-Final	Finished	2024-11-08	14:30:00
179	3	Tennis	13	11	14	Semi-Final	Finished	2024-11-08	15:30:00
180	3	Tennis	9	11	21	Final	Finished	2024-11-09	17:00:00
181	3	Carrom	17	18	19	Group Stage	Finished	2024-11-06	12:00:00
182	3	Carrom	17	19	19	Group Stage	Finished	2024-11-06	13:00:00
183	3	Carrom	17	20	19	Group Stage	Finished	2024-11-06	14:00:00
184	3	Carrom	18	19	20	Group Stage	Finished	2024-11-07	12:00:00
185	3	Carrom	18	20	20	Group Stage	Finished	2024-11-07	13:00:00
186	3	Carrom	19	20	20	Group Stage	Finished	2024-11-07	14:00:00
187	3	Carrom	21	22	19	Group Stage	Finished	2024-11-07	16:00:00
188	3	Carrom	21	23	19	Group Stage	Finished	2024-11-07	17:00:00
189	3	Carrom	21	24	19	Group Stage	Finished	2024-11-07	18:00:00
190	3	Carrom	22	23	20	Group Stage	Finished	2024-11-08	12:00:00
191	3	Carrom	22	24	20	Group Stage	Finished	2024-11-08	13:00:00
192	3	Carrom	23	24	20	Group Stage	Finished	2024-11-08	14:00:00
193	3	Carrom	17	22	19	Semi-Final	Finished	2024-11-08	16:00:00
194	3	Carrom	21	19	20	Semi-Final	Finished	2024-11-08	17:00:00
195	3	Carrom	17	19	21	Final	Finished	2024-11-09	10:00:00
196	3	Chess	25	26	17	Group Stage	Finished	2024-11-06	15:00:00
197	3	Chess	25	27	17	Group Stage	Finished	2024-11-06	16:00:00
198	3	Chess	25	28	17	Group Stage	Finished	2024-11-06	17:00:00
199	3	Chess	26	27	18	Group Stage	Finished	2024-11-07	15:00:00
200	3	Chess	26	28	18	Group Stage	Finished	2024-11-07	16:00:00
201	3	Chess	27	28	18	Group Stage	Finished	2024-11-07	17:00:00
202	3	Chess	29	30	17	Group Stage	Finished	2024-11-07	19:00:00
203	3	Chess	29	31	17	Group Stage	Finished	2024-11-07	20:00:00
204	3	Chess	29	32	17	Group Stage	Finished	2024-11-08	15:00:00
205	3	Chess	30	31	18	Group Stage	Finished	2024-11-08	16:00:00
206	3	Chess	30	32	18	Group Stage	Finished	2024-11-08	17:00:00
207	3	Chess	31	32	18	Group Stage	Finished	2024-11-08	18:00:00
208	3	Chess	25	30	17	Semi-Final	Finished	2024-11-09	09:00:00
209	3	Chess	29	27	18	Semi-Final	Finished	2024-11-09	10:00:00
210	3	Chess	25	27	21	Final	Finished	2024-11-09	12:00:00
211	3	Table Tennis	33	34	15	Group Stage	Finished	2024-11-06	18:00:00
212	3	Table Tennis	33	35	15	Group Stage	Finished	2024-11-06	19:00:00
213	3	Table Tennis	33	36	15	Group Stage	Finished	2024-11-06	20:00:00
214	3	Table Tennis	34	35	16	Group Stage	Finished	2024-11-07	18:00:00
215	3	Table Tennis	34	36	16	Group Stage	Finished	2024-11-07	19:00:00
216	3	Table Tennis	35	36	16	Group Stage	Finished	2024-11-07	20:00:00
217	3	Table Tennis	37	38	15	Group Stage	Finished	2024-11-08	18:00:00
218	3	Table Tennis	37	39	15	Group Stage	Finished	2024-11-08	19:00:00
219	3	Table Tennis	37	40	15	Group Stage	Finished	2024-11-08	20:00:00
220	3	Table Tennis	38	39	16	Group Stage	Finished	2024-11-09	09:30:00
221	3	Table Tennis	38	40	16	Group Stage	Finished	2024-11-09	10:30:00
222	3	Table Tennis	39	40	16	Group Stage	Finished	2024-11-09	11:30:00
223	3	Table Tennis	33	38	15	Semi-Final	Finished	2024-11-09	14:30:00
224	3	Table Tennis	37	35	16	Semi-Final	Finished	2024-11-09	15:30:00
225	3	Table Tennis	33	35	21	Final	Finished	2024-11-09	18:30:00
226	4	Badminton	1	2	11	Group Stage	Scheduled	2025-11-05	09:00:00
227	4	Badminton	1	3	11	Group Stage	Scheduled	2025-11-05	10:00:00
228	4	Badminton	1	4	11	Group Stage	Scheduled	2025-11-05	11:00:00
229	4	Badminton	2	3	12	Group Stage	Scheduled	2025-11-06	09:00:00
230	4	Badminton	2	4	12	Group Stage	Scheduled	2025-11-06	10:00:00
231	4	Badminton	3	4	12	Group Stage	Scheduled	2025-11-06	11:00:00
232	4	Badminton	5	6	11	Group Stage	Scheduled	2025-11-06	14:00:00
233	4	Badminton	5	7	11	Group Stage	Scheduled	2025-11-06	15:00:00
234	4	Badminton	5	8	11	Group Stage	Scheduled	2025-11-06	16:00:00
235	4	Badminton	6	7	12	Group Stage	Scheduled	2025-11-07	09:00:00
236	4	Badminton	6	8	12	Group Stage	Scheduled	2025-11-07	10:00:00
237	4	Badminton	7	8	12	Group Stage	Scheduled	2025-11-07	11:00:00
238	4	Tennis	9	10	13	Group Stage	Scheduled	2025-11-05	09:30:00
239	4	Tennis	9	11	13	Group Stage	Scheduled	2025-11-05	10:30:00
240	4	Tennis	9	12	13	Group Stage	Scheduled	2025-11-05	11:30:00
241	4	Tennis	10	11	14	Group Stage	Scheduled	2025-11-06	09:30:00
242	4	Tennis	10	12	14	Group Stage	Scheduled	2025-11-06	10:30:00
243	4	Tennis	11	12	14	Group Stage	Scheduled	2025-11-06	11:30:00
244	4	Tennis	13	14	13	Group Stage	Scheduled	2025-11-06	14:30:00
245	4	Tennis	13	15	13	Group Stage	Scheduled	2025-11-06	15:30:00
246	4	Tennis	13	16	13	Group Stage	Scheduled	2025-11-06	16:30:00
247	4	Tennis	14	15	14	Group Stage	Scheduled	2025-11-07	09:30:00
248	4	Tennis	14	16	14	Group Stage	Scheduled	2025-11-07	10:30:00
249	4	Tennis	15	16	14	Group Stage	Scheduled	2025-11-07	11:30:00
250	4	Carrom	17	18	19	Group Stage	Scheduled	2025-11-05	12:00:00
251	4	Carrom	17	19	19	Group Stage	Scheduled	2025-11-05	13:00:00
252	4	Carrom	17	20	19	Group Stage	Scheduled	2025-11-05	14:00:00
253	4	Carrom	18	19	20	Group Stage	Scheduled	2025-11-06	12:00:00
254	4	Carrom	18	20	20	Group Stage	Scheduled	2025-11-06	13:00:00
255	4	Carrom	19	20	20	Group Stage	Scheduled	2025-11-06	14:00:00
256	4	Carrom	21	22	19	Group Stage	Scheduled	2025-11-06	16:00:00
257	4	Carrom	21	23	19	Group Stage	Scheduled	2025-11-06	17:00:00
258	4	Carrom	21	24	19	Group Stage	Scheduled	2025-11-06	18:00:00
259	4	Carrom	22	23	20	Group Stage	Scheduled	2025-11-07	12:00:00
260	4	Carrom	22	24	20	Group Stage	Scheduled	2025-11-07	13:00:00
261	4	Carrom	23	24	20	Group Stage	Scheduled	2025-11-07	14:00:00
262	4	Chess	25	26	17	Group Stage	Scheduled	2025-11-05	15:00:00
263	4	Chess	25	27	17	Group Stage	Scheduled	2025-11-05	16:00:00
264	4	Chess	25	28	17	Group Stage	Scheduled	2025-11-05	17:00:00
265	4	Chess	26	27	18	Group Stage	Scheduled	2025-11-06	15:00:00
266	4	Chess	26	28	18	Group Stage	Scheduled	2025-11-06	16:00:00
267	4	Chess	27	28	18	Group Stage	Scheduled	2025-11-06	17:00:00
268	4	Chess	29	30	17	Group Stage	Scheduled	2025-11-06	19:00:00
269	4	Chess	29	31	17	Group Stage	Scheduled	2025-11-06	20:00:00
270	4	Chess	29	32	17	Group Stage	Scheduled	2025-11-07	15:00:00
271	4	Chess	30	31	18	Group Stage	Scheduled	2025-11-07	16:00:00
272	4	Chess	30	32	18	Group Stage	Scheduled	2025-11-07	17:00:00
273	4	Chess	31	32	18	Group Stage	Scheduled	2025-11-07	18:00:00
274	4	Table Tennis	33	34	15	Group Stage	Scheduled	2025-11-05	18:00:00
275	4	Table Tennis	33	35	15	Group Stage	Scheduled	2025-11-05	19:00:00
276	4	Table Tennis	33	36	15	Group Stage	Scheduled	2025-11-05	20:00:00
277	4	Table Tennis	34	35	16	Group Stage	Scheduled	2025-11-06	18:00:00
278	4	Table Tennis	34	36	16	Group Stage	Scheduled	2025-11-06	19:00:00
279	4	Table Tennis	35	36	16	Group Stage	Scheduled	2025-11-06	20:00:00
280	4	Table Tennis	37	38	15	Group Stage	Scheduled	2025-11-07	18:00:00
281	4	Table Tennis	37	39	15	Group Stage	Scheduled	2025-11-07	19:00:00
282	4	Table Tennis	37	40	15	Group Stage	Scheduled	2025-11-07	20:00:00
283	4	Table Tennis	38	39	16	Group Stage	Scheduled	2025-11-08	09:30:00
284	4	Table Tennis	38	40	16	Group Stage	Scheduled	2025-11-08	10:30:00
285	4	Table Tennis	39	40	16	Group Stage	Scheduled	2025-11-08	11:30:00
\.


--
-- TOC entry 5143 (class 0 OID 18107)
-- Dependencies: 220
-- Data for Name: individual_sport_players; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.individual_sport_players (player_id, college_id, sport_name, ranking) FROM stdin;
1	1	Badminton	1
2	2	Badminton	2
3	3	Badminton	3
4	4	Badminton	4
5	5	Badminton	5
6	6	Badminton	6
7	7	Badminton	7
8	8	Badminton	8
9	9	Tennis	1
10	10	Tennis	2
11	11	Tennis	3
12	12	Tennis	4
13	13	Tennis	5
14	14	Tennis	6
15	15	Tennis	7
16	1	Tennis	8
17	2	Carrom	1
18	3	Carrom	2
19	4	Carrom	3
20	5	Carrom	4
21	6	Carrom	5
22	7	Carrom	6
23	8	Carrom	7
24	9	Carrom	8
25	10	Chess	1
26	11	Chess	2
27	12	Chess	3
28	13	Chess	4
29	14	Chess	5
30	15	Chess	6
31	1	Chess	7
32	2	Chess	8
33	3	Table Tennis	1
34	4	Table Tennis	2
35	5	Table Tennis	3
36	6	Table Tennis	4
37	7	Table Tennis	5
38	8	Table Tennis	6
39	9	Table Tennis	7
40	10	Table Tennis	8
\.


--
-- TOC entry 5157 (class 0 OID 18303)
-- Dependencies: 234
-- Data for Name: individual_sport_result; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.individual_sport_result (i_result_id, i_match_id, winner_player_id, duration, scores, highlights) FROM stdin;
1	1	1	00:40:00	21-17,21-15	Strong start
2	2	1	00:39:00	21-19,21-17	Dominant performance
3	3	1	00:41:00	21-18,21-14	Smooth rallies
4	4	2	00:38:00	21-17,21-16	Good fightback
5	5	2	00:42:00	21-19,21-18	Consistent smashes
6	6	3	00:40:00	21-18,21-17	Steady footwork
7	7	5	00:39:00	21-15,21-16	Strong net play
8	8	5	00:41:00	21-19,21-17	Powerful serves
9	9	5	00:38:00	21-18,21-15	Sharp smashes
10	10	6	00:40:00	21-17,21-16	Quick exchanges
11	11	6	00:42:00	21-19,21-18	Close finish
12	12	7	00:41:00	21-18,21-17	Controlled win
13	13	1	00:45:00	21-17,21-18	Semi-final win
14	14	2	00:46:00	21-19,21-17	Semi-final domination
15	15	1	00:48:00	22-20,21-18	Champion: Player 1
16	16	9	02:01:00	6-3,6-4	Strong baseline
17	17	9	02:03:00	6-4,6-4	Solid serves
18	18	9	02:00:00	6-3,6-3	Confident strokes
19	19	10	01:58:00	6-4,6-3	Net precision
20	20	10	02:01:00	6-3,6-4	Aggressive play
21	21	11	02:05:00	6-4,7-5	Strong finish
22	22	13	02:07:00	6-3,6-2	Early domination
23	23	13	02:06:00	6-2,6-3	Consistent returns
24	24	13	02:04:00	6-4,6-2	Steady forehands
25	25	14	02:00:00	6-4,6-3	Fast reactions
26	26	14	02:03:00	6-3,6-2	Smart placement
27	27	15	02:06:00	6-3,7-5	Quick volleys
28	28	9	02:08:00	6-4,7-5	Semi-final victory
29	29	10	02:10:00	6-3,6-4	Semi-final clean sweep
30	30	9	02:15:00	7-5,6-3	Champion: Player 9
31	31	17	00:29:00	3-0	Clean start
32	32	17	00:30:00	3-1	Accurate play
33	33	17	00:28:00	3-0	Quick shots
34	34	18	00:29:00	3-2	Close finish
35	35	18	00:30:00	3-1	Good flicks
36	36	19	00:28:00	3-1	Sharp control
37	37	21	00:30:00	3-1	Consistent accuracy
38	38	21	00:31:00	3-0	Clean carroms
39	39	21	00:28:00	3-1	Nice angles
40	40	22	00:29:00	3-2	Good finish
41	41	22	00:30:00	3-1	Smart attack
42	42	23	00:31:00	3-1	Controlled pocketing
43	43	17	00:32:00	3-1	Semi-final win
44	44	18	00:33:00	3-0	Semi-final easy
45	45	17	00:34:00	3-1	Champion: Player 17
46	46	25	01:20:00	1-0	Strong control
47	47	25	01:25:00	1-0	Tactical dominance
48	48	25	01:23:00	1-0	Midgame attack
49	49	26	01:18:00	1-0	Good positional play
50	50	26	01:15:00	1-0	Sharp knight fork
51	51	27	01:19:00	1-0	Quick victory
52	52	29	01:17:00	1-0	Accurate defense
53	53	29	01:16:00	1-0	Clean conversion
54	54	29	01:20:00	1-0	Endgame precision
55	55	30	01:18:00	1-0	Steady win
56	56	30	01:22:00	1-0	Pawn structure control
57	57	31	01:21:00	1-0	Smart endgame
58	58	25	01:30:00	1-0	Semi-final solid
59	59	26	01:32:00	1-0	Semi-final quick
60	60	25	01:35:00	1-0	Champion: Player 25
61	61	33	00:35:00	3-1	Good start
62	62	33	00:37:00	3-0	Fast play
63	63	33	00:36:00	3-1	Tight rally
64	64	34	00:38:00	3-1	Smart counter
65	65	34	00:37:00	3-0	Powerful serve
66	66	35	00:40:00	3-2	Balanced match
67	67	37	00:33:00	3-0	Clean win
68	68	37	00:34:00	3-1	Sharp forehands
69	69	37	00:35:00	3-1	Well executed
70	70	38	00:36:00	3-2	Long rallies
71	71	38	00:35:00	3-1	Good defense
72	72	39	00:37:00	3-2	Close finish
73	73	33	00:39:00	3-1	Semi-final win
74	74	34	00:38:00	3-0	Semi-final clean
75	75	33	00:41:00	3-0	Champion: Player 33
76	76	1	00:40:00	21-17,21-15	Quick opener
77	77	1	00:42:00	21-18,21-16	Aggressive start
78	78	1	00:38:00	21-15,21-17	Consistent rallies
79	79	2	00:41:00	21-19,21-18	Good control
80	80	2	00:40:00	21-17,21-16	Sharp cross shots
81	81	3	00:35:00	21-19,21-18	Decent footwork
82	82	5	00:39:00	21-18,21-14	Good net play
83	83	5	00:37:00	21-15,21-13	Solid serves
84	84	5	00:40:00	21-19,21-18	Clean shots
85	85	6	00:41:00	21-18,21-17	Well-timed smashes
86	86	6	00:43:00	21-19,21-19	Close contest
87	87	7	00:42:00	21-18,21-15	Good comeback
88	88	1	00:44:00	21-17,21-18	Semi-final upset
89	89	2	00:45:00	21-19,21-17	Semi-final win
90	90	2	00:48:00	22-20,21-18	Champion: Player 2
91	91	9	02:01:00	6-3,6-4	Strong baseline
92	92	9	02:03:00	6-4,6-4	Dominant serve
93	93	9	02:00:00	6-3,6-3	Great accuracy
94	94	10	01:56:00	6-4,6-2	Solid net play
95	95	10	01:59:00	6-4,6-3	Sharp returns
96	96	11	02:02:00	6-3,7-5	Tight match
97	97	13	02:05:00	6-3,6-2	Controlled start
98	98	13	02:04:00	6-2,6-3	Strong serves
99	99	13	02:00:00	6-4,6-2	Backhand excellence
100	100	14	02:03:00	6-4,6-3	Good returns
101	101	14	01:59:00	6-3,6-2	Composed play
102	102	15	02:06:00	6-3,7-5	Long rallies
103	103	9	02:09:00	6-4,7-6	Close semi
104	104	10	02:10:00	6-3,6-4	Strong semi
105	105	10	02:15:00	7-5,6-4	Champion: Player 10
106	106	17	00:30:00	3-0	Quick finish
107	107	17	00:32:00	3-1	Smooth flicks
108	108	17	00:28:00	3-2	Tight corners
109	109	18	00:29:00	3-0	Controlled play
110	110	18	00:27:00	3-1	Nice carroms
111	111	19	00:26:00	3-0	One-sided game
112	112	21	00:31:00	3-1	Clean strikes
113	113	21	00:30:00	3-2	Patient control
114	114	21	00:29:00	3-1	Good pocketing
115	115	22	00:28:00	3-0	Straightforward
116	116	22	00:30:00	3-2	Neck-to-neck
117	117	23	00:32:00	3-1	Clean win
118	118	17	00:34:00	3-2	Semi-final win
119	119	18	00:33:00	3-1	Semi-final dominance
120	120	18	00:36:00	3-1	Champion: Player 18
121	121	25	01:30:00	1-0	Endgame precision
122	122	25	01:20:00	1-0	Calculated play
123	123	25	01:25:00	1-0	Strong opening
124	124	26	01:15:00	1-0	Ruy Lopez defense
125	125	26	01:10:00	1-0	Aggressive midgame
126	126	27	01:22:00	1-0	Endgame advantage
127	127	29	01:18:00	1-0	Quick finish
128	128	29	01:17:00	1-0	Tactical attack
129	129	29	01:21:00	1-0	Positional control
130	130	30	01:14:00	1-0	Long grind
131	131	30	01:12:00	1-0	Balanced midgame
132	132	31	01:15:00	1-0	Sharp exchange
133	133	25	01:30:00	1-0	Semi-final 1
134	134	26	01:28:00	1-0	Semi-final 2
135	135	26	01:35:00	1-0	Champion: Player 26
136	136	33	00:35:00	3-1	Strong start
137	137	33	00:37:00	3-0	Fast serves
138	138	33	00:36:00	3-1	Good control
139	139	34	00:39:00	3-1	High intensity
140	140	34	00:37:00	3-0	Quick reflex
141	141	35	00:40:00	3-2	Balanced attack
142	142	37	00:33:00	3-0	Perfect start
143	143	37	00:34:00	3-1	Consistent spin
144	144	37	00:35:00	3-1	Good defense
145	145	38	00:34:00	3-2	Close finish
146	146	38	00:36:00	3-1	Powerful finish
147	147	39	00:37:00	3-2	Close contest
148	148	33	00:39:00	3-2	Semi 1 victory
149	149	34	00:38:00	3-1	Semi 2 win
150	150	34	00:42:00	3-1	Champion: Player 34
151	151	1	00:40:00	21-17,21-16	Solid start
152	152	1	00:38:00	21-18,21-14	Early lead
153	153	1	00:42:00	21-16,21-15	Precise play
154	154	3	00:41:00	21-19,21-17	Controlled serves
155	155	2	00:40:00	21-18,21-16	Good drops
156	156	3	00:39:00	21-15,21-14	Sharp smashes
157	157	5	00:43:00	21-18,21-15	Tight game
158	158	5	00:42:00	21-19,21-18	Good rallying
159	159	5	00:40:00	21-18,21-17	Aggressive finish
160	160	6	00:39:00	21-15,21-13	Clean points
161	161	6	00:38:00	21-17,21-16	Comfortable win
162	162	7	00:37:00	21-18,21-15	Quick play
163	163	1	00:44:00	21-17,21-18	Semi-final win
164	164	3	00:46:00	21-19,21-17	Semi-final comeback
165	165	3	00:48:00	22-20,21-19	Champion: Player 3
166	166	9	02:03:00	6-4,6-4	Strong serves
167	167	9	02:05:00	6-3,6-3	Good consistency
168	168	9	02:00:00	6-4,6-3	Early win
169	169	11	01:56:00	6-3,6-2	Smart volley
170	170	10	01:59:00	6-3,6-4	Composed play
171	171	11	02:04:00	6-4,7-5	Tight finish
172	172	13	02:06:00	6-3,6-2	Aggressive start
173	173	13	02:05:00	6-3,6-4	Clean forehands
174	174	13	02:04:00	6-2,6-3	Quick control
175	175	14	02:00:00	6-4,6-4	Balanced game
176	176	14	02:03:00	6-3,6-4	Dominant
177	177	15	02:02:00	6-3,6-4	Smooth progression
178	178	9	02:06:00	6-4,7-5	Semi win
179	179	11	02:08:00	6-3,6-2	Semi steady
180	180	11	02:20:00	7-5,6-3	Champion: Player 11
181	181	17	00:30:00	3-0	Clean win
182	182	17	00:28:00	3-1	Sharp flick
183	183	17	00:29:00	3-2	Good control
184	184	19	00:30:00	3-0	Steady play
185	185	18	00:31:00	3-1	Compact form
186	186	19	00:28:00	3-1	Smooth carroms
187	187	21	00:32:00	3-1	Great touch
188	188	21	00:31:00	3-0	Perfect start
189	189	21	00:30:00	3-2	Close match
190	190	22	00:29:00	3-1	Good angles
191	191	22	00:28:00	3-2	Late rally
192	192	23	00:27:00	3-1	Quick result
193	193	17	00:34:00	3-2	Semi win
194	194	19	00:33:00	3-1	Semi control
195	195	19	00:36:00	3-1	Champion: Player 19
196	196	25	01:30:00	1-0	Precise
197	197	25	01:25:00	1-0	Quick tactics
198	198	25	01:22:00	1-0	Sharp opening
199	199	27	01:20:00	1-0	Ruy Lopez prep
200	200	26	01:18:00	1-0	Aggressive attack
201	201	27	01:21:00	1-0	Excellent control
202	202	29	01:16:00	1-0	Clean execution
203	203	29	01:15:00	1-0	Endgame accuracy
204	204	29	01:14:00	1-0	Long grind
205	205	30	01:12:00	1-0	Close call
206	206	30	01:13:00	1-0	Tactical vision
207	207	31	01:15:00	1-0	Quick mate
208	208	25	01:32:00	1-0	Semi 1 win
209	209	27	01:33:00	1-0	Semi 2 control
210	210	27	01:36:00	1-0	Champion: Player 27
211	211	33	00:36:00	3-1	Good start
212	212	33	00:35:00	3-0	Sharp rallies
213	213	33	00:38:00	3-1	Consistent serves
214	214	34	00:37:00	3-2	Strong attack
215	215	34	00:38:00	3-1	Fast exchange
216	216	35	00:39:00	3-1	Clean return
217	217	37	00:33:00	3-1	Good placement
218	218	37	00:34:00	3-0	Smooth win
219	219	37	00:35:00	3-1	Tense points
220	220	38	00:36:00	3-2	Balanced
221	221	38	00:35:00	3-1	Precise shots
222	222	39	00:37:00	3-2	Close set
223	223	33	00:41:00	3-2	Semi 1 win
224	224	35	00:42:00	3-1	Semi 2 dominant
225	225	35	00:45:00	3-1	Champion: Player 35
\.


--
-- TOC entry 5149 (class 0 OID 18193)
-- Dependencies: 226
-- Data for Name: injury_record; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.injury_record (player_id, staff_id, injury_date, injury_type, body_part_affected) FROM stdin;
5	2	2022-11-02	Muscle Strain	Leg
14	7	2022-11-02	Ankle Twist	Ankle
21	3	2022-11-02	Wrist Sprain	Wrist
36	10	2022-11-03	Shoulder Dislocation	Shoulder
45	6	2022-11-03	Hamstring Pull	Leg
59	12	2022-11-03	Fracture	Arm
63	14	2022-11-04	Knee Injury	Knee
78	1	2022-11-04	Ankle Sprain	Ankle
85	4	2022-11-04	Wrist Pain	Wrist
92	8	2022-11-05	Muscle Tear	Leg
103	5	2022-11-05	Back Pain	Back
116	11	2022-11-05	Neck Strain	Neck
123	9	2022-11-06	Shoulder Strain	Shoulder
130	13	2022-11-06	Leg Cramps	Leg
142	2	2022-11-03	Elbow Strain	Elbow
151	7	2022-11-03	Groin Pull	Groin
165	4	2022-11-04	Muscle Strain	Thigh
172	6	2022-11-04	Fracture	Wrist
181	10	2022-11-05	Knee Injury	Knee
193	9	2022-11-05	Ankle Sprain	Ankle
204	3	2022-11-06	Hamstring Pull	Leg
217	15	2022-11-06	Shoulder Dislocation	Shoulder
226	18	2022-11-06	Wrist Sprain	Wrist
233	20	2022-11-04	Back Pain	Back
245	23	2022-11-04	Neck Strain	Neck
253	25	2022-11-05	Knee Injury	Knee
261	22	2022-11-05	Muscle Tear	Leg
274	19	2022-11-05	Elbow Strain	Elbow
283	17	2022-11-06	Ankle Twist	Ankle
295	8	2022-11-06	Leg Sprain	Leg
6	3	2023-10-25	Fracture	Arm
15	11	2023-10-25	Knee Injury	Knee
28	12	2023-10-25	Shoulder Strain	Shoulder
39	4	2023-10-25	Hamstring Pull	Leg
52	5	2023-10-26	Elbow Strain	Elbow
67	9	2023-10-26	Muscle Tear	Leg
75	7	2023-10-26	Back Pain	Back
89	1	2023-10-26	Ankle Sprain	Ankle
98	10	2023-10-26	Neck Strain	Neck
102	6	2023-10-26	Groin Pull	Groin
118	13	2023-10-27	Shoulder Injury	Shoulder
126	19	2023-10-27	Wrist Fracture	Wrist
135	14	2023-10-27	Leg Cramps	Leg
144	18	2023-10-27	Muscle Strain	Thigh
153	15	2023-10-27	Fracture	Arm
161	16	2023-10-28	Ankle Twist	Ankle
168	17	2023-10-28	Elbow Sprain	Elbow
176	20	2023-10-28	Shoulder Dislocation	Shoulder
183	21	2023-10-28	Knee Injury	Knee
191	22	2023-10-28	Wrist Strain	Wrist
203	24	2023-10-29	Neck Strain	Neck
214	25	2023-10-29	Back Pain	Back
222	27	2023-10-29	Muscle Tear	Leg
234	29	2023-10-27	Fracture	Wrist
241	28	2023-10-28	Elbow Strain	Elbow
256	30	2023-10-28	Knee Injury	Knee
263	32	2023-10-28	Shoulder Strain	Shoulder
272	33	2023-10-28	Leg Sprain	Leg
281	35	2023-10-29	Back Pain	Back
289	36	2023-10-29	Neck Pain	Neck
297	38	2023-10-29	Muscle Tear	Leg
304	40	2023-10-29	Wrist Sprain	Wrist
312	42	2023-10-28	Elbow Injury	Elbow
319	43	2023-10-28	Shoulder Injury	Shoulder
326	45	2023-10-29	Fracture	Arm
3	4	2024-11-06	Wrist Sprain	Wrist
12	8	2024-11-06	Ankle Sprain	Ankle
24	11	2024-11-06	Knee Injury	Knee
32	6	2024-11-07	Shoulder Strain	Shoulder
41	10	2024-11-07	Fracture	Arm
53	12	2024-11-07	Neck Strain	Neck
64	13	2024-11-07	Hamstring Pull	Leg
73	15	2024-11-07	Muscle Tear	Leg
82	14	2024-11-08	Knee Injury	Knee
94	9	2024-11-08	Elbow Strain	Elbow
107	5	2024-11-08	Shoulder Dislocation	Shoulder
115	7	2024-11-08	Back Pain	Back
124	2	2024-11-08	Groin Pull	Groin
133	3	2024-11-09	Muscle Strain	Thigh
141	16	2024-11-09	Ankle Twist	Ankle
149	17	2024-11-09	Wrist Fracture	Wrist
157	19	2024-11-09	Shoulder Injury	Shoulder
164	20	2024-11-09	Elbow Injury	Elbow
170	21	2024-11-10	Back Pain	Back
182	22	2024-11-10	Neck Pain	Neck
190	24	2024-11-10	Muscle Tear	Leg
198	26	2024-11-10	Knee Injury	Knee
206	28	2024-11-10	Hamstring Pull	Leg
213	29	2024-11-10	Fracture	Arm
220	31	2024-11-10	Shoulder Strain	Shoulder
228	32	2024-11-09	Ankle Sprain	Ankle
236	34	2024-11-09	Wrist Sprain	Wrist
244	35	2024-11-09	Knee Injury	Knee
252	36	2024-11-09	Muscle Tear	Leg
260	37	2024-11-09	Back Pain	Back
268	38	2024-11-09	Neck Strain	Neck
276	39	2024-11-10	Ankle Twist	Ankle
284	40	2024-11-10	Hamstring Pull	Leg
292	41	2024-11-10	Fracture	Arm
300	42	2024-11-10	Wrist Pain	Wrist
308	43	2024-11-10	Muscle Tear	Leg
316	44	2024-11-09	Elbow Injury	Elbow
324	46	2024-11-09	Knee Injury	Knee
332	47	2024-11-09	Shoulder Injury	Shoulder
340	48	2024-11-09	Muscle Strain	Leg
348	49	2024-11-09	Back Pain	Back
356	50	2024-11-09	Fracture	Arm
364	2	2024-11-09	Elbow Strain	Elbow
368	3	2024-11-10	Ankle Sprain	Ankle
\.


--
-- TOC entry 5153 (class 0 OID 18233)
-- Dependencies: 230
-- Data for Name: inventory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory (item_id, item_name, purchase_date, quantity, storage_location, cost, condition) FROM stdin;
1	Cricket Bat	2022-01-10	40	Cricket Store Room A	2500.00	New
2	Cricket Ball	2022-02-05	200	Cricket Store Room A	450.00	Good
3	Cricket Pads	2022-03-15	60	Cricket Store Room B	1800.00	New
4	Cricket Gloves	2022-04-10	70	Cricket Store Room B	1200.00	Good
5	Cricket Helmets	2022-06-20	40	Cricket Store Room C	2200.00	New
6	Football	2022-05-05	150	Football Store Room A	900.00	Good
7	Football Nets	2022-06-18	30	Football Store Room B	2500.00	New
8	Goalkeeper Gloves	2022-08-12	25	Football Store Room B	1500.00	Good
9	Corner Flags	2022-09-01	20	Football Store Room C	800.00	Good
10	Training Cones	2023-01-10	120	Football Store Room C	300.00	New
11	Basketball	2022-11-05	100	Basketball Court Storage	850.00	New
12	Basketball Nets	2023-02-15	30	Basketball Court Storage	650.00	Good
13	Scoreboard	2023-03-12	5	Basketball Arena Storage	15000.00	Good
14	Whistles	2023-04-25	50	Basketball Arena Storage	250.00	New
15	Team Bibs	2023-05-05	60	Basketball Arena Storage	400.00	Good
16	Volleyball	2023-02-10	120	Volleyball Store Room	700.00	New
17	Volleyball Nets	2023-03-05	25	Volleyball Store Room	1800.00	Good
18	Court Marking Tape	2023-05-25	40	Volleyball Store Room	200.00	Good
19	Referee Stand	2023-06-14	8	Volleyball Store Room	8500.00	Good
20	Training Mats	2023-07-10	30	Volleyball Store Room	1200.00	Good
21	Kabaddi Mats	2023-08-15	50	Kabaddi Arena Storage	2500.00	New
22	Scoreboard - Kabaddi	2023-09-05	6	Kabaddi Arena Storage	14000.00	Good
23	Referee Whistles	2023-09-20	40	Kabaddi Arena Storage	250.00	New
24	Boundary Ropes	2023-10-10	15	Kabaddi Arena Storage	1800.00	Good
25	Medical Kit - Kabaddi	2023-11-01	10	Kabaddi Arena Storage	4500.00	New
26	Badminton Racquet	2024-01-05	100	Badminton Court Storage	1800.00	New
27	Shuttlecock Tubes	2024-02-12	80	Badminton Court Storage	450.00	Good
28	Badminton Nets	2024-03-03	20	Badminton Court Storage	950.00	Good
29	Court Shoes	2024-03-20	50	Badminton Equipment Room	2500.00	New
30	Grip Tape Rolls	2024-04-10	60	Badminton Equipment Room	200.00	Good
31	Tennis Racquet	2024-03-22	60	Tennis Arena Storage	2800.00	New
32	Tennis Balls (Pack)	2024-04-08	200	Tennis Arena Storage	500.00	Good
33	Tennis Nets	2024-05-10	15	Tennis Arena Storage	1600.00	Good
34	Umpire Chairs	2024-05-25	5	Tennis Arena Storage	7000.00	Good
35	Ball Hopper	2024-06-15	20	Tennis Arena Storage	1200.00	New
36	Table Tennis Table	2024-07-02	10	TT Hall Storage	20000.00	New
37	TT Bat	2024-07-20	80	TT Hall Storage	700.00	Good
38	TT Balls Pack	2024-08-05	100	TT Hall Storage	250.00	Good
39	TT Nets	2024-08-25	25	TT Hall Storage	450.00	New
40	Scoreboard - TT	2024-09-10	5	TT Hall Storage	9000.00	Good
41	Chess Boards	2024-10-01	80	Chess Room Storage	900.00	New
42	Chess Pieces Set	2024-10-15	80	Chess Room Storage	600.00	Good
43	Digital Chess Clocks	2024-11-01	20	Chess Room Storage	2500.00	Good
44	Score Sheets	2024-11-10	200	Chess Room Storage	150.00	New
45	Table Stands	2024-12-02	40	Chess Room Storage	1200.00	Good
46	Carrom Boards	2025-01-10	40	Carrom Center Storage	2500.00	New
47	Carrom Coins Sets	2025-02-05	100	Carrom Center Storage	350.00	Good
48	Strikers	2025-03-08	80	Carrom Center Storage	200.00	Good
49	Carrom Powder	2025-04-15	60	Carrom Center Storage	120.00	New
50	Scoreboard - Carrom	2025-05-10	5	Carrom Center Storage	8500.00	Good
\.


--
-- TOC entry 5148 (class 0 OID 18187)
-- Dependencies: 225
-- Data for Name: medical_staff; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medical_staff (staff_id, name, qualification, emergency_contact, specialization, years_of_experience, hospital_clinic_affiliation) FROM stdin;
1	Dr. Ramesh Patel	MBBS, MD	9876543210	Sports Medicine	18	Apollo Hospital, Ahmedabad
2	Dr. Meena Shah	BPT, MPT	9898012345	Physiotherapist	10	Sterling Hospital, Vadodara
3	Dr. Amit Desai	MBBS, MS (Ortho)	9723456789	Orthopedic Specialist	15	Civil Hospital, Surat
4	Dr. Priya Joshi	BPT	9823456712	Rehabilitation Therapist	7	Sunshine Physio Care, Rajkot
5	Dr. Karan Mehta	MBBS	9923456781	General Physician	5	CareWell Clinic, Gandhinagar
6	Dr. Sneha Reddy	BPT, MPT	9812345670	Sports Physiotherapist	8	KIMS Hospital, Ahmedabad
7	Dr. Rajesh Shah	MBBS, MD (Ortho)	9876012345	Orthopedic Surgeon	20	Zydus Hospital, Ahmedabad
8	Dr. Anjali Trivedi	BSc Nursing	9900123456	Sports Nurse	6	Apollo Clinic, Baroda
9	Dr. Dhruv Chauhan	MBBS, MD	9765432189	Sports Physician	12	Pulse Hospital, Rajkot
10	Dr. Kavita Nair	BPT	9898123765	Rehabilitation Specialist	9	BodyCare Rehab Center, Surat
11	Dr. Harsh Patel	MBBS	9912345678	Emergency Medicine	4	LifeCare Hospital, Ahmedabad
12	Dr. Nidhi Desai	BPT, MPT	9845012345	Sports Physiotherapist	11	Unity Health Clinic, Vadodara
13	Dr. Arjun Raval	MBBS, MD (Gen Med)	9821012345	General Physician	14	City Hospital, Anand
14	Dr. Mitesh Joshi	MBBS, MS (Ortho)	9867012345	Orthopedic Surgeon	19	Global Hospital, Ahmedabad
15	Dr. Krupa Shah	BPT	9977012345	Physiotherapist	5	Wellness Physio Center, Gandhinagar
16	Dr. Anil Mehta	MBBS, MD	9898412765	Sports Medicine	17	Zydus Care Hospital, Rajkot
17	Dr. Ritu Desai	BSc Nursing	9844012345	Sports Nurse	8	Sterling Hospital, Vadodara
18	Dr. Suresh Nair	MBBS, MD	9811112345	Emergency Medicine	13	Sunshine Hospital, Surat
19	Dr. Aayushi Trivedi	BPT, MPT	9899912345	Physiotherapist	9	Apollo Rehab Center, Ahmedabad
20	Dr. Vijay Patel	MBBS	9876598712	General Physician	6	Shalby Hospital, Ahmedabad
21	Dr. Rajni Shah	MBBS, MS (Ortho)	9898123450	Orthopedic Specialist	16	Nirmal Hospital, Surat
22	Dr. Ketan Chauhan	BPT	9867213456	Sports Physiotherapist	7	CareFit Physio Clinic, Baroda
23	Dr. Isha Mehta	MBBS	9888012345	Emergency Medicine	5	Global Care, Gandhinagar
24	Dr. Harish Joshi	MBBS, MD	9877012345	Sports Medicine	18	Apollo Sports Unit, Ahmedabad
25	Dr. Rachit Patel	BPT	9812341200	Physiotherapist	4	FlexiMove Clinic, Anand
26	Dr. Pooja Desai	MBBS	9898981234	General Physician	3	Pulse Health Center, Vadodara
27	Dr. Sagar Reddy	MBBS, MD (Ortho)	9812223344	Orthopedic Specialist	21	Medilink Hospital, Ahmedabad
28	Dr. Aarti Shah	BPT, MPT	9845098765	Rehabilitation Specialist	9	Elite Physio, Rajkot
29	Dr. Nirav Patel	MBBS	9923451234	Emergency Medicine	10	Apollo Hospital, Ahmedabad
30	Dr. Sonali Trivedi	BSc Nursing	9876000012	Sports Nurse	7	Civil Hospital, Ahmedabad
31	Dr. Jay Mehta	MBBS	9812312345	Sports Physician	6	Pulse Fitness Hospital, Surat
32	Dr. Neha Joshi	BPT	9833312345	Physiotherapist	5	VitalCare Rehab, Gandhinagar
33	Dr. Ritesh Shah	MBBS, MD	9812343210	Sports Medicine	14	Sterling Hospital, Baroda
34	Dr. Aarav Desai	MBBS, MS (Ortho)	9821011111	Orthopedic Surgeon	17	Zydus Hospital, Ahmedabad
35	Dr. Tanishka Patel	BPT, MPT	9876543100	Sports Physiotherapist	8	Wellness Care, Surat
36	Dr. Manish Reddy	MBBS	9812333122	General Physician	12	Apollo Clinic, Baroda
37	Dr. Diya Shah	BPT	9821209876	Rehabilitation Therapist	6	MoveWell Rehab, Ahmedabad
38	Dr. Vivek Mehta	MBBS	9810045612	Sports Medicine	20	Pulse Hospital, Rajkot
39	Dr. Shruti Iyer	BPT, MPT	9833344444	Physiotherapist	10	CareFit Clinic, Gandhinagar
40	Dr. Harshal Patel	MBBS	9850098765	Emergency Medicine	5	Unity Health Hospital, Vadodara
41	Dr. Rupal Shah	BPT	9822012345	Sports Physiotherapist	7	FlexiCare Clinic, Ahmedabad
42	Dr. Yash Chauhan	MBBS, MD	9813409876	Sports Medicine	15	Apollo Sports Unit, Baroda
43	Dr. Snehal Mehta	BPT	9898043210	Rehabilitation Specialist	9	Vital Health Center, Surat
44	Dr. Gaurav Reddy	MBBS, MS (Ortho)	9821054321	Orthopedic Specialist	11	Medicity Hospital, Rajkot
45	Dr. Rina Patel	BPT	9812233445	Physiotherapist	6	WellFit Clinic, Ahmedabad
46	Dr. Nirmal Joshi	MBBS	9844076543	General Physician	8	Sterling Hospital, Gandhinagar
47	Dr. Kavya Shah	BPT	9812234567	Sports Physiotherapist	5	Apollo Clinic, Baroda
48	Dr. Chirag Mehta	MBBS, MD (Ortho)	9876001122	Orthopedic Surgeon	19	Global Hospital, Ahmedabad
49	Dr. Payal Desai	BPT, MPT	9821133344	Rehabilitation Therapist	9	Sunshine Physio Center, Rajkot
50	Dr. Kunal Raval	MBBS	9819998888	Emergency Medicine	7	Zydus Hospital, Ahmedabad
\.


--
-- TOC entry 5142 (class 0 OID 18101)
-- Dependencies: 219
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.players (player_id, name, date_of_birth, gender, health_status, medical_clearance) FROM stdin;
1	Aarav Patel	2003-05-12	M	Fit	t
2	Isha Desai	2004-02-18	F	Fit	t
3	Rohan Shah	2002-09-08	M	Recovering	t
4	Meera Joshi	2005-01-25	F	Fit	t
5	Nikhil Reddy	2003-07-14	M	Injured	f
6	Kavya Mehta	2004-11-20	F	Fit	t
7	Ankit Parmar	2001-12-05	M	Fit	t
8	Priya Solanki	2002-08-09	F	Fit	t
9	Devansh Patel	2002-03-22	M	Fit	t
10	Riya Shah	2003-09-17	F	Fit	t
11	Amit Joshi	2001-06-19	M	Fit	t
12	Sneha Patel	2004-10-15	F	Recovering	t
13	Manav Trivedi	2003-01-07	M	Fit	t
14	Ananya Iyer	2004-04-09	F	Injured	f
15	Jay Mehta	2002-12-11	M	Fit	t
16	Krupa Shah	2005-02-10	F	Fit	t
17	Raj Shah	2003-03-18	M	Fit	t
18	Diya Patel	2004-09-21	F	Fit	t
19	Karan Mehta	2002-11-13	M	Recovering	t
20	Roshni Desai	2005-01-22	F	Fit	t
21	Arjun Nair	2003-07-28	M	Fit	t
22	Kriti Patel	2002-06-17	F	Fit	t
23	Siddharth Rao	2001-10-09	M	Injured	f
24	Janhvi Bhatt	2004-05-25	F	Fit	t
25	Yash Patel	2004-03-03	M	Fit	t
26	Nidhi Mehta	2005-08-15	F	Fit	t
27	Vivek Shah	2003-11-27	M	Recovering	t
28	Kajal Iyer	2002-07-19	F	Fit	t
29	Hitesh Desai	2004-02-11	M	Fit	t
30	Surbhi Nair	2003-10-12	F	Fit	t
31	Akash Reddy	2001-09-10	M	Fit	t
32	Pooja Trivedi	2005-06-14	F	Fit	t
33	Amit Bhatia	2002-12-28	M	Fit	t
34	Ritika Shah	2003-03-09	F	Fit	t
35	Chirag Patel	2004-11-10	M	Fit	t
36	Bhavika Mehta	2002-02-04	F	Recovering	t
37	Parth Trivedi	2003-05-23	M	Fit	t
38	Komal Joshi	2005-09-17	F	Fit	t
39	Dhruv Shah	2001-07-21	M	Fit	t
40	Shruti Desai	2002-10-29	F	Injured	f
41	Rohan Patel	2003-04-12	M	Fit	t
42	Manav Shah	2002-08-23	M	Fit	t
43	Jay Mehta	2004-02-15	M	Fit	t
44	Nikhil Joshi	2003-06-09	M	Recovering	t
45	Aniket Raval	2001-10-18	M	Fit	t
46	Dhruv Desai	2002-05-21	M	Fit	t
47	Vivek Chauhan	2003-11-02	M	Fit	t
48	Parth Iyer	2004-07-25	M	Injured	f
49	Hardik Patel	2003-09-06	M	Fit	t
50	Tanish Reddy	2004-01-29	M	Fit	t
51	Ritesh Bhatt	2002-03-13	M	Fit	t
52	Kunal Mehta	2003-10-17	M	Fit	t
53	Amit Shah	2004-05-14	M	Fit	t
54	Rahul Joshi	2002-09-03	M	Fit	t
55	Vijay Patel	2003-12-25	M	Fit	t
56	Sanjay Nair	2004-02-06	M	Recovering	t
57	Yash Reddy	2001-07-18	M	Fit	t
58	Neel Solanki	2002-11-29	M	Fit	t
59	Chirag Desai	2003-06-10	M	Injured	f
60	Harsh Parmar	2003-08-22	M	Fit	t
61	Ravi Shah	2004-03-09	M	Fit	t
62	Arjun Mehta	2002-01-20	M	Fit	t
63	Anshul Patel	2003-05-10	M	Fit	t
64	Vimal Joshi	2004-09-14	M	Fit	t
65	Rohit Nair	2001-11-03	M	Recovering	t
66	Siddharth Shah	2002-07-19	M	Fit	t
67	Raj Mehta	2003-02-27	M	Fit	t
68	Aarav Chauhan	2004-10-05	M	Fit	t
69	Bhavesh Trivedi	2002-06-09	M	Fit	t
70	Ketan Raval	2003-08-23	M	Injured	f
71	Nirav Shah	2004-03-15	M	Fit	t
72	Deep Patel	2002-12-01	M	Fit	t
73	Manish Iyer	2003-04-17	M	Fit	t
74	Pratik Patel	2002-10-08	M	Fit	t
75	Yuvraj Shah	2003-09-12	M	Fit	t
76	Rajan Mehta	2004-06-02	M	Fit	t
77	Dhaval Reddy	2001-08-22	M	Recovering	t
78	Amit Desai	2003-12-13	M	Fit	t
79	Rohit Trivedi	2004-01-05	M	Fit	t
80	Tushar Joshi	2002-03-18	M	Fit	t
81	Akash Parmar	2003-07-20	M	Fit	t
82	Nitesh Shah	2004-11-28	M	Injured	f
83	Rachit Patel	2002-09-14	M	Fit	t
84	Mihir Iyer	2003-04-24	M	Fit	t
85	Himanshu Patel	2004-08-19	M	Fit	t
86	Ajay Shah	2002-05-26	M	Fit	t
87	Rahil Mehta	2003-11-07	M	Fit	t
88	Kishan Desai	2001-06-16	M	Fit	t
89	Vatsal Reddy	2003-09-20	M	Recovering	t
90	Pranav Shah	2002-02-18	M	Fit	t
91	Darshan Patel	2004-12-22	M	Fit	t
92	Rupesh Nair	2003-03-27	M	Fit	t
93	Jay Parmar	2004-10-11	M	Fit	t
94	Aditya Trivedi	2003-07-03	M	Fit	t
95	Harsh Vora	2004-09-08	M	Fit	t
96	Tapan Patel	2002-06-23	M	Fit	t
97	Ravi Desai	2003-09-04	M	Fit	t
98	Manish Shah	2004-05-18	M	Fit	t
99	Aayush Mehta	2002-07-27	M	Fit	t
100	Hitesh Joshi	2003-03-02	M	Fit	t
101	Karan Patel	2004-02-12	M	Recovering	t
102	Niranjan Shah	2001-09-29	M	Fit	t
103	Mitesh Iyer	2002-12-19	M	Fit	t
104	Parth Mehta	2003-10-07	M	Fit	t
105	Ramesh Chauhan	2004-06-16	M	Fit	t
106	Tushar Raval	2002-11-14	M	Fit	t
107	Amit Patel	2003-01-22	M	Fit	t
108	Sahil Desai	2002-09-25	M	Fit	t
109	Kishor Mehta	2004-04-10	M	Fit	t
110	Anil Shah	2003-05-30	M	Fit	t
111	Uday Patel	2001-11-28	M	Fit	t
112	Mihir Reddy	2004-08-06	M	Recovering	t
113	Rahul Joshi	2003-03-16	M	Fit	t
114	Jay Shah	2004-02-04	M	Fit	t
115	Karan Nair	2002-10-13	M	Fit	t
116	Darsh Mehta	2003-09-20	M	Fit	t
117	Vivek Trivedi	2004-12-01	M	Fit	t
118	Raj Shah	2003-06-17	M	Fit	t
119	Prakash Mehta	2004-07-23	M	Fit	t
120	Rakesh Patel	2002-10-02	M	Fit	t
121	Ajay Nair	2003-08-04	M	Fit	t
122	Deepak Joshi	2004-05-14	M	Recovering	t
123	Ansh Mehta	2002-03-06	M	Fit	t
124	Naman Shah	2003-02-11	M	Fit	t
125	Yash Chauhan	2004-04-26	M	Fit	t
126	Suresh Patel	2001-09-29	M	Injured	f
127	Tejas Reddy	2002-11-20	M	Fit	t
128	Rohit Trivedi	2003-01-10	M	Fit	t
129	Rohit Patel	2002-04-18	M	Fit	t
130	Vivek Shah	2003-09-11	M	Fit	t
131	Hardik Joshi	2001-11-25	M	Fit	t
132	Manan Desai	2003-06-15	M	Recovering	t
133	Krunal Mehta	2002-01-09	M	Fit	t
134	Amit Raval	2004-07-24	M	Fit	t
135	Jignesh Nair	2002-03-22	M	Injured	f
136	Saurabh Shah	2003-05-19	M	Fit	t
137	Nikhil Trivedi	2004-08-10	M	Fit	t
138	Parth Iyer	2003-12-06	M	Fit	t
139	Rajat Bhatt	2002-10-02	M	Fit	t
140	Ramesh Patel	2003-02-15	M	Fit	t
141	Dev Joshi	2002-07-12	M	Fit	t
142	Ketan Shah	2001-10-21	M	Recovering	t
143	Ajay Mehta	2004-05-26	M	Fit	t
144	Arjun Reddy	2003-01-09	M	Fit	t
145	Sagar Desai	2002-11-18	M	Fit	t
146	Harsh Chauhan	2004-03-03	M	Injured	f
147	Yuvraj Patel	2003-09-17	M	Fit	t
148	Rohan Trivedi	2004-06-08	M	Fit	t
149	Dhruv Shah	2002-02-19	M	Fit	t
150	Vatsal Nair	2001-12-30	M	Fit	t
151	Chirag Mehta	2002-03-28	M	Fit	t
152	Tushar Patel	2004-09-20	M	Fit	t
153	Siddharth Shah	2003-11-14	M	Fit	t
154	Aakash Desai	2001-08-03	M	Recovering	t
155	Rahil Joshi	2003-06-01	M	Fit	t
156	Nirav Reddy	2002-01-25	M	Fit	t
157	Rajan Trivedi	2004-05-09	M	Fit	t
158	Yash Chauhan	2003-04-02	M	Fit	t
159	Paresh Mehta	2002-10-29	M	Injured	f
160	Amit Bhatt	2004-07-13	M	Fit	t
161	Anuj Nair	2003-12-21	M	Fit	t
162	Dhaval Patel	2003-01-09	M	Fit	t
163	Mihir Shah	2002-08-10	M	Fit	t
164	Rakesh Joshi	2004-02-17	M	Fit	t
165	Aayush Desai	2003-09-27	M	Recovering	t
166	Jay Mehta	2002-11-04	M	Fit	t
167	Kishan Trivedi	2003-06-16	M	Fit	t
168	Bhargav Patel	2004-01-21	M	Fit	t
169	Harsh Raval	2001-10-14	M	Fit	t
170	Ankit Iyer	2003-07-29	M	Fit	t
171	Tejas Shah	2002-05-07	M	Fit	t
172	Karan Mehta	2004-03-10	M	Fit	t
173	Nilesh Patel	2003-11-11	M	Fit	t
174	Deep Desai	2004-01-06	M	Fit	t
175	Ankur Shah	2002-09-03	M	Fit	t
176	Sahil Mehta	2003-02-15	M	Recovering	t
177	Hitesh Reddy	2001-07-22	M	Fit	t
178	Rajat Joshi	2003-05-18	M	Fit	t
179	Mitesh Trivedi	2004-10-09	M	Injured	f
180	Krunal Chauhan	2002-12-25	M	Fit	t
181	Amit Bhatt	2003-04-30	M	Fit	t
182	Jay Parmar	2002-02-03	M	Fit	t
183	Raj Mehta	2004-09-27	M	Fit	t
184	Rakesh Patel	2003-10-13	M	Fit	t
185	Rohit Shah	2002-06-02	M	Fit	t
186	Kunal Joshi	2004-03-14	M	Fit	t
187	Manish Mehta	2003-12-08	M	Fit	t
188	Ritesh Desai	2002-05-25	M	Fit	t
189	Yogesh Nair	2001-09-10	M	Fit	t
190	Viral Trivedi	2003-04-11	M	Recovering	t
191	Niraj Shah	2004-02-18	M	Fit	t
192	Ketan Patel	2003-08-22	M	Fit	t
193	Dev Mehta	2002-07-05	M	Injured	f
194	Aarav Chauhan	2003-01-29	M	Fit	t
195	Pratik Shah	2002-09-21	M	Fit	t
196	Ajay Patel	2003-05-18	M	Fit	t
197	Rohit Mehta	2004-08-12	M	Fit	t
198	Darshan Joshi	2003-04-14	M	Recovering	t
199	Suresh Reddy	2001-12-23	M	Fit	t
200	Deepak Desai	2004-06-07	M	Fit	t
201	Tejas Nair	2002-11-05	M	Fit	t
202	Rohan Chauhan	2003-03-08	M	Fit	t
203	Vivek Mehta	2004-09-26	M	Fit	t
204	Krishan Shah	2002-02-11	M	Fit	t
205	Harshit Patel	2003-07-01	M	Fit	t
206	Yash Patel	2003-10-09	M	Fit	t
207	Neel Desai	2004-01-22	M	Fit	t
208	Ravi Shah	2002-11-18	M	Fit	t
209	Himanshu Mehta	2003-06-11	M	Recovering	t
210	Ankit Joshi	2004-05-24	M	Fit	t
211	Nihar Raval	2003-09-02	M	Fit	t
212	Mihir Chauhan	2001-10-30	M	Fit	t
213	Rahul Nair	2004-08-17	M	Fit	t
214	Amit Patel	2003-07-23	M	Injured	f
215	Tapan Shah	2002-03-01	M	Fit	t
216	Rajesh Trivedi	2003-12-15	M	Fit	t
217	Rohit Mehta	2003-05-14	M	Fit	t
218	Dhruv Shah	2002-07-10	M	Fit	t
219	Aarav Patel	2004-09-23	M	Fit	t
220	Krunal Joshi	2003-11-05	M	Recovering	t
221	Manav Reddy	2002-02-18	M	Fit	t
222	Ankit Desai	2003-01-13	M	Fit	t
223	Vishal Mehta	2002-06-21	M	Fit	t
224	Nikhil Shah	2004-03-16	M	Injured	f
225	Suresh Patel	2003-08-30	M	Fit	t
226	Arjun Nair	2002-10-09	M	Fit	t
227	Jay Parmar	2004-04-08	M	Fit	t
228	Yash Trivedi	2003-12-02	M	Fit	t
229	Ritesh Shah	2002-01-29	M	Fit	t
230	Harsh Chauhan	2003-07-17	M	Fit	t
231	Kishan Patel	2004-05-06	M	Recovering	t
232	Neel Joshi	2003-09-10	M	Fit	t
233	Amit Mehta	2002-03-14	M	Fit	t
234	Tejas Shah	2004-11-11	M	Fit	t
235	Vatsal Desai	2003-10-03	M	Fit	t
236	Himanshu Raval	2002-05-15	M	Fit	t
237	Raj Shah	2003-04-22	M	Fit	t
238	Rohan Patel	2002-12-27	M	Fit	t
239	Nirav Mehta	2004-06-12	M	Recovering	t
240	Deepak Iyer	2003-07-25	M	Fit	t
241	Vivek Reddy	2002-09-08	M	Fit	t
242	Aakash Desai	2003-05-21	M	Fit	t
243	Hitesh Patel	2002-08-16	M	Fit	t
244	Rahul Shah	2004-01-09	M	Fit	t
245	Karan Mehta	2003-06-03	M	Injured	f
246	Tushar Raval	2002-11-20	M	Fit	t
247	Sanjay Joshi	2004-04-01	M	Fit	t
248	Darsh Patel	2002-10-27	M	Fit	t
249	Anil Shah	2003-03-18	M	Fit	t
250	Harsh Mehta	2004-08-05	M	Fit	t
251	Pratik Trivedi	2002-09-14	M	Fit	t
252	Amit Chauhan	2003-06-06	M	Fit	t
253	Mitesh Shah	2004-07-24	M	Recovering	t
254	Yash Patel	2002-05-08	M	Fit	t
255	Paresh Desai	2003-11-12	M	Fit	t
256	Niranjan Mehta	2004-02-03	M	Fit	t
257	Karan Patel	2003-04-10	M	Fit	t
258	Rohit Shah	2002-07-18	M	Fit	t
259	Vivek Mehta	2004-01-12	M	Fit	t
260	Nikhil Joshi	2003-11-03	M	Recovering	t
261	Amit Desai	2002-02-26	M	Fit	t
262	Jay Reddy	2003-06-14	M	Fit	t
263	Anil Iyer	2004-05-23	M	Fit	t
264	Manav Chauhan	2003-08-19	M	Fit	t
265	Dhruv Patel	2004-04-22	M	Fit	t
266	Kishan Mehta	2002-10-15	M	Fit	t
267	Ajay Shah	2003-05-27	M	Fit	t
268	Ritesh Trivedi	2002-12-09	M	Recovering	t
269	Hitesh Raval	2004-03-16	M	Fit	t
270	Yash Nair	2003-09-29	M	Fit	t
271	Tejas Joshi	2002-06-20	M	Fit	t
272	Rahil Patel	2003-07-09	M	Fit	t
273	Harsh Desai	2004-11-22	M	Fit	t
274	Rohan Mehta	2003-01-17	M	Injured	f
275	Kunal Shah	2002-08-04	M	Fit	t
276	Aayush Bhatt	2003-10-25	M	Fit	t
277	Mihir Trivedi	2004-02-13	M	Fit	t
278	Sanjay Patel	2003-12-10	M	Fit	t
279	Jay Mehta	2002-11-09	M	Fit	t
280	Ravi Desai	2003-04-01	M	Fit	t
281	Ankur Shah	2004-05-18	M	Fit	t
282	Darsh Reddy	2003-02-14	M	Recovering	t
283	Neel Chauhan	2002-09-26	M	Fit	t
284	Paresh Trivedi	2004-06-07	M	Fit	t
285	Pratik Joshi	2003-03-09	M	Fit	t
286	Rupesh Patel	2002-07-15	M	Fit	t
287	Manish Shah	2004-08-12	M	Fit	t
288	Harshit Mehta	2003-10-19	M	Fit	t
289	Anshul Desai	2002-05-08	M	Fit	t
290	Bhavesh Nair	2003-09-20	M	Recovering	t
291	Raj Trivedi	2004-01-05	M	Fit	t
292	Amit Patel	2003-02-22	M	Fit	t
293	Deep Shah	2004-07-03	M	Fit	t
294	Nirav Mehta	2002-09-09	M	Fit	t
295	Yash Joshi	2003-06-24	M	Fit	t
296	Krishan Desai	2004-10-20	M	Injured	f
297	Sagar Reddy	2003-05-30	M	Fit	t
298	Tapan Iyer	2002-12-13	M	Fit	t
299	Nikhil Patel	2003-11-07	M	Fit	t
300	Tejas Shah	2004-02-25	M	Fit	t
301	Rakesh Mehta	2002-03-04	M	Fit	t
302	Viral Joshi	2003-08-15	M	Fit	t
303	Suresh Desai	2004-04-28	M	Recovering	t
304	Aarav Reddy	2003-01-31	M	Fit	t
305	Nihar Trivedi	2002-05-22	M	Fit	t
306	Ravi Shah	2004-09-09	M	Fit	t
307	Darshan Patel	2003-03-16	M	Fit	t
308	Himanshu Mehta	2002-10-27	M	Fit	t
309	Ketan Joshi	2003-07-02	M	Fit	t
310	Ajay Raval	2004-06-19	M	Recovering	t
311	Mitesh Chauhan	2003-08-11	M	Fit	t
312	Niranjan Shah	2002-04-15	M	Fit	t
313	Rakesh Patel	2002-09-11	M	Fit	t
314	Amit Shah	2003-03-24	M	Fit	t
315	Jay Mehta	2004-01-17	M	Fit	t
316	Manav Joshi	2002-06-28	M	Recovering	t
317	Darshan Reddy	2003-11-08	M	Fit	t
318	Tushar Desai	2004-04-19	M	Fit	t
319	Parth Nair	2003-07-09	M	Fit	t
320	Nikhil Patel	2003-02-12	M	Fit	t
321	Vatsal Mehta	2002-10-06	M	Fit	t
322	Chirag Shah	2003-08-17	M	Fit	t
323	Rohan Desai	2004-03-21	M	Fit	t
324	Sagar Raval	2002-07-10	M	Fit	t
325	Pratik Chauhan	2003-12-19	M	Recovering	t
326	Tejas Trivedi	2004-05-08	M	Fit	t
327	Rahul Patel	2002-09-13	M	Fit	t
328	Manish Shah	2003-11-30	M	Fit	t
329	Deep Joshi	2004-06-09	M	Fit	t
330	Anil Mehta	2003-05-12	M	Injured	f
331	Rupesh Desai	2002-03-15	M	Fit	t
332	Aarav Trivedi	2004-02-04	M	Fit	t
333	Harsh Reddy	2003-08-21	M	Fit	t
334	Nirav Patel	2003-07-23	M	Fit	t
335	Rohit Shah	2002-04-25	M	Fit	t
336	Vivek Mehta	2003-10-28	M	Recovering	t
337	Jay Chauhan	2004-03-02	M	Fit	t
338	Hardik Desai	2003-12-07	M	Fit	t
339	Mitesh Joshi	2002-11-19	M	Fit	t
340	Kishan Reddy	2004-05-13	M	Fit	t
341	Dhruv Shah	2003-02-27	M	Fit	t
342	Rajan Mehta	2002-06-22	M	Fit	t
343	Rahil Patel	2004-09-30	M	Fit	t
344	Suresh Joshi	2003-04-14	M	Fit	t
345	Aniket Desai	2002-12-08	M	Recovering	t
346	Yash Trivedi	2004-01-20	M	Fit	t
347	Rupen Nair	2003-07-26	M	Fit	t
348	Tapan Patel	2002-03-18	M	Fit	t
349	Viral Shah	2003-11-03	M	Fit	t
350	Harshit Mehta	2004-02-09	M	Fit	t
351	Ajay Desai	2003-08-14	M	Fit	t
352	Paresh Reddy	2002-10-29	M	Fit	t
353	Neel Trivedi	2004-04-01	M	Recovering	t
354	Anup Iyer	2003-06-06	M	Fit	t
355	Sanjay Patel	2003-09-10	M	Fit	t
356	Anshul Shah	2002-05-23	M	Fit	t
357	Rohit Joshi	2004-03-25	M	Fit	t
358	Hitesh Mehta	2003-07-05	M	Fit	t
359	Vivek Desai	2002-11-11	M	Recovering	t
360	Jay Reddy	2004-06-16	M	Fit	t
361	Ketan Chauhan	2003-01-31	M	Fit	t
362	Nilesh Patel	2003-02-14	M	Fit	t
363	Rajan Shah	2002-10-08	M	Fit	t
364	Yash Mehta	2004-08-26	M	Fit	t
365	Amit Joshi	2003-05-30	M	Fit	t
366	Darsh Desai	2002-12-28	M	Recovering	t
367	Mihir Raval	2003-09-02	M	Fit	t
368	Rajesh Trivedi	2004-01-15	M	Fit	t
\.


--
-- TOC entry 5154 (class 0 OID 18241)
-- Dependencies: 231
-- Data for Name: referees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.referees (referee_id, sport_name, name, experience, contact, availability_status) FROM stdin;
1	Cricket	Ramesh Iyer	12	9876500001	Available
2	Cricket	Sanjay Patel	10	9876500002	Available
3	Cricket	Manoj Deshmukh	8	9876500003	On Duty
4	Cricket	Vikram Rao	6	9876500004	Available
5	Cricket	Kiran Mehta	7	9876500005	On Leave
6	Cricket	Amit Purohit	9	9876500006	Available
7	Cricket	Rajiv Nair	11	9876500007	Available
8	Cricket	Anil Gupta	13	9876500008	Available
9	Cricket	Rohit Chawla	10	9876500009	On Duty
10	Cricket	Sumit Sharma	8	9876500010	Available
11	Cricket	Arun Sinha	5	9876500011	Available
12	Cricket	Deepak Jain	6	9876500012	On Duty
13	Cricket	Hemant Joshi	9	9876500013	Available
14	Cricket	Suresh Bhat	4	9876500014	Available
15	Cricket	Vivek Desai	7	9876500015	On Leave
16	Football	Ajay Nair	12	9876500016	Available
17	Football	Rohit Singh	10	9876500017	On Duty
18	Football	Kunal Sharma	9	9876500018	Available
19	Football	Deepak Reddy	11	9876500019	Available
20	Football	Sagar Deshmukh	7	9876500020	On Leave
21	Football	Mahesh Iyer	10	9876500021	Available
22	Football	Nitin Joshi	8	9876500022	On Duty
23	Football	Karan Shah	6	9876500023	Available
24	Football	Jignesh Patel	9	9876500024	Available
25	Football	Aakash Raina	5	9876500025	On Leave
26	Football	Ramesh Kulkarni	12	9876500026	Available
27	Football	Tejas Bhatt	8	9876500027	Available
28	Football	Vikrant Shetty	10	9876500028	On Duty
29	Football	Siddharth Rao	7	9876500029	Available
30	Football	Pranav Mehta	4	9876500030	Available
31	Basketball	Amit Nair	9	9876500031	Available
32	Basketball	Ravi Desai	8	9876500032	On Duty
33	Basketball	Nilesh Trivedi	7	9876500033	Available
34	Basketball	Piyush Shah	10	9876500034	Available
35	Basketball	Jay Mehta	6	9876500035	Available
36	Basketball	Dhruv Patel	5	9876500036	On Leave
37	Basketball	Aditya Reddy	4	9876500037	Available
38	Basketball	Hardik Joshi	3	9876500038	Available
39	Volleyball	Naveen Iyer	8	9876500039	Available
40	Volleyball	Ravi Kumar	7	9876500040	Available
41	Volleyball	Paresh Patel	9	9876500041	On Duty
42	Volleyball	Vinay Deshmukh	6	9876500042	Available
43	Volleyball	Yogesh Joshi	5	9876500043	On Leave
44	Volleyball	Chetan Shah	4	9876500044	Available
45	Kabaddi	Ramesh Rathod	10	9876500045	Available
46	Kabaddi	Suresh Meena	8	9876500046	On Duty
47	Kabaddi	Narendra Chauhan	9	9876500047	Available
48	Kabaddi	Pratap Naik	6	9876500048	Available
49	Kabaddi	Bhavesh Solanki	7	9876500049	Available
50	Kabaddi	Ajit Verma	5	9876500050	On Leave
51	Badminton	Kartik Patel	8	9876500051	Available
52	Badminton	Priyank Shah	7	9876500052	Available
53	Badminton	Snehal Deshmukh	6	9876500053	On Duty
54	Badminton	Manan Trivedi	5	9876500054	Available
55	Badminton	Vishal Iyer	9	9876500055	Available
56	Tennis	Ravi Shankar	10	9876500056	Available
57	Tennis	Nishant Desai	8	9876500057	Available
58	Tennis	Deep Shah	7	9876500058	On Duty
59	Tennis	Ananya Mehta	5	9876500059	Available
60	Tennis	Parth Trivedi	6	9876500060	Available
61	Table Tennis	Mehul Shah	7	9876500061	Available
62	Table Tennis	Aarav Iyer	5	9876500062	On Duty
63	Table Tennis	Nisha Deshmukh	6	9876500063	Available
64	Table Tennis	Chirag Patel	4	9876500064	Available
65	Chess	Rohini Nair	10	9876500065	Available
66	Chess	Sanjana Mehta	6	9876500066	On Duty
67	Chess	Keshav Joshi	8	9876500067	Available
68	Carrom	Ravi Parmar	5	9876500068	Available
69	Carrom	Ritesh Shah	4	9876500069	Available
70	Carrom	Sneha Patel	6	9876500070	On Duty
\.


--
-- TOC entry 5150 (class 0 OID 18208)
-- Dependencies: 227
-- Data for Name: sponsors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sponsors (sponsor_id, name, industry_type, contact) FROM stdin;
1	Adidas India Pvt. Ltd.	Sportswear	9876543210
2	Nike India	Sportswear	9812345678
3	Puma Sports India	Sportswear	9823456789
4	Decathlon India	Sports Equipment	9898012345
5	Hero MotoCorp	Automobile	9900123456
6	HDFC Bank	Banking & Finance	9912345678
7	ICICI Bank	Banking & Finance	9923456780
8	Reliance Industries	Conglomerate	9934567890
9	Tata Motors	Automobile	9945678901
10	Coca-Cola India	Beverages	9956789012
11	PepsiCo India	Beverages	9967890123
12	Amul	Dairy Products	9978901234
13	Parle Agro	Food & Beverages	9989012345
14	Red Bull India	Energy Drinks	9897123456
15	BYJU’S	EdTech	9876012345
16	Unacademy	EdTech	9811223344
17	Zydus Lifesciences	Healthcare	9822334455
18	Apollo Hospitals	Healthcare	9833445566
19	Sterling Hospitals	Healthcare	9844556677
20	Sony Sports Network	Media & Broadcasting	9855667788
21	Star Sports	Media & Broadcasting	9866778899
22	Jio Platforms	Telecom	9877889900
23	Airtel India	Telecom	9888990011
24	Infosys Foundation	IT & CSR	9899001122
25	Wipro Technologies	IT & CSR	9810012233
26	OYO Rooms	Hospitality	9821123344
27	MakeMyTrip	Travel & Hospitality	9832234455
28	Asian Paints	Consumer Goods	9843345566
29	Godrej Group	Consumer Goods	9854456677
30	HP India	Technology	9865567788
\.


--
-- TOC entry 5151 (class 0 OID 18213)
-- Dependencies: 228
-- Data for Name: sponsorship_record; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sponsorship_record (sponsor_id, tournament_id, contribution_amount, contract_date, sponsorship_type) FROM stdin;
1	1	500000.00	2022-09-28	Title Sponsor
2	1	300000.00	2022-09-30	Associate Sponsor
3	1	250000.00	2022-09-25	Official Kit Partner
4	1	150000.00	2022-09-26	Equipment Partner
5	1	200000.00	2022-09-29	Automobile Partner
6	1	180000.00	2022-09-27	Financial Partner
7	1	160000.00	2022-09-25	Banking Partner
8	1	500000.00	2022-09-28	Platinum Sponsor
9	1	250000.00	2022-09-27	Gold Sponsor
10	1	200000.00	2022-09-26	Beverage Partner
11	1	180000.00	2022-09-30	Refreshment Partner
12	1	120000.00	2022-09-28	Food Partner
13	1	130000.00	2022-09-29	Nutrition Partner
14	1	140000.00	2022-09-25	Energy Drink Partner
15	1	100000.00	2022-09-26	Education Partner
16	1	90000.00	2022-09-27	Learning Partner
17	1	160000.00	2022-09-30	Healthcare Partner
18	1	170000.00	2022-09-29	Medical Partner
19	1	150000.00	2022-09-28	Health Partner
20	1	180000.00	2022-09-26	Media Partner
21	1	170000.00	2022-09-25	Broadcast Partner
22	1	190000.00	2022-09-27	Telecom Partner
23	1	175000.00	2022-09-29	Connectivity Partner
24	1	120000.00	2022-09-30	CSR Partner
25	1	110000.00	2022-09-28	Technology Partner
1	2	550000.00	2023-09-20	Title Sponsor
2	2	320000.00	2023-09-22	Associate Sponsor
3	2	270000.00	2023-09-19	Official Kit Partner
4	2	180000.00	2023-09-21	Equipment Partner
5	2	220000.00	2023-09-18	Automobile Partner
6	2	200000.00	2023-09-23	Financial Partner
7	2	190000.00	2023-09-19	Banking Partner
8	2	520000.00	2023-09-22	Platinum Sponsor
9	2	260000.00	2023-09-20	Gold Sponsor
10	2	230000.00	2023-09-18	Beverage Partner
11	2	190000.00	2023-09-21	Refreshment Partner
12	2	130000.00	2023-09-23	Food Partner
13	2	150000.00	2023-09-20	Nutrition Partner
14	2	160000.00	2023-09-21	Energy Drink Partner
15	2	110000.00	2023-09-22	Education Partner
16	2	95000.00	2023-09-23	Learning Partner
17	2	180000.00	2023-09-19	Healthcare Partner
18	2	190000.00	2023-09-18	Medical Partner
19	2	170000.00	2023-09-22	Health Partner
20	2	200000.00	2023-09-23	Media Partner
21	2	190000.00	2023-09-19	Broadcast Partner
22	2	210000.00	2023-09-20	Telecom Partner
23	2	185000.00	2023-09-21	Connectivity Partner
24	2	140000.00	2023-09-22	CSR Partner
25	2	120000.00	2023-09-23	Technology Partner
26	2	100000.00	2023-09-19	Hospitality Partner
27	2	95000.00	2023-09-23	Travel Partner
28	2	130000.00	2023-09-22	Paint Partner
1	3	600000.00	2024-10-01	Title Sponsor
2	3	340000.00	2024-10-02	Associate Sponsor
3	3	280000.00	2024-09-30	Official Kit Partner
4	3	200000.00	2024-10-03	Equipment Partner
5	3	250000.00	2024-09-30	Automobile Partner
6	3	210000.00	2024-10-04	Financial Partner
7	3	200000.00	2024-09-29	Banking Partner
8	3	540000.00	2024-10-02	Platinum Sponsor
9	3	280000.00	2024-10-03	Gold Sponsor
10	3	240000.00	2024-10-01	Beverage Partner
11	3	200000.00	2024-10-01	Refreshment Partner
12	3	150000.00	2024-10-02	Food Partner
13	3	160000.00	2024-09-30	Nutrition Partner
14	3	180000.00	2024-10-01	Energy Drink Partner
15	3	130000.00	2024-10-03	Education Partner
16	3	110000.00	2024-10-02	Learning Partner
17	3	190000.00	2024-09-30	Healthcare Partner
18	3	210000.00	2024-10-01	Medical Partner
19	3	190000.00	2024-10-02	Health Partner
20	3	210000.00	2024-10-03	Media Partner
21	3	200000.00	2024-10-02	Broadcast Partner
22	3	220000.00	2024-10-03	Telecom Partner
23	3	200000.00	2024-10-03	Connectivity Partner
24	3	150000.00	2024-09-30	CSR Partner
25	3	130000.00	2024-10-02	Technology Partner
26	3	110000.00	2024-10-03	Hospitality Partner
27	3	120000.00	2024-09-29	Travel Partner
28	3	140000.00	2024-10-02	Paint Partner
29	3	125000.00	2024-09-29	Consumer Partner
30	3	150000.00	2024-10-01	IT Partner
1	4	650000.00	2025-10-01	Title Sponsor
2	4	360000.00	2025-10-02	Associate Sponsor
3	4	300000.00	2025-09-30	Official Kit Partner
4	4	210000.00	2025-10-02	Equipment Partner
5	4	260000.00	2025-09-29	Automobile Partner
6	4	220000.00	2025-10-03	Financial Partner
7	4	210000.00	2025-09-30	Banking Partner
8	4	560000.00	2025-10-02	Platinum Sponsor
9	4	300000.00	2025-10-03	Gold Sponsor
10	4	250000.00	2025-09-29	Beverage Partner
11	4	210000.00	2025-10-01	Refreshment Partner
12	4	160000.00	2025-10-02	Food Partner
13	4	170000.00	2025-09-29	Nutrition Partner
14	4	200000.00	2025-09-30	Energy Drink Partner
15	4	150000.00	2025-10-01	Education Partner
16	4	120000.00	2025-10-03	Learning Partner
17	4	200000.00	2025-09-30	Healthcare Partner
18	4	220000.00	2025-10-02	Medical Partner
19	4	200000.00	2025-10-01	Health Partner
20	4	230000.00	2025-10-03	Media Partner
21	4	220000.00	2025-10-02	Broadcast Partner
22	4	240000.00	2025-09-30	Telecom Partner
23	4	210000.00	2025-09-29	Connectivity Partner
24	4	160000.00	2025-10-01	CSR Partner
25	4	140000.00	2025-10-02	Technology Partner
26	4	130000.00	2025-09-29	Hospitality Partner
27	4	150000.00	2025-09-30	Travel Partner
28	4	160000.00	2025-10-02	Paint Partner
29	4	170000.00	2025-09-29	Consumer Partner
30	4	180000.00	2025-10-03	IT Partner
\.


--
-- TOC entry 5140 (class 0 OID 18083)
-- Dependencies: 217
-- Data for Name: sports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sports (sport_name, sport_type) FROM stdin;
Badminton	Individual
Tennis	Individual
Table Tennis	Individual
Chess	Individual
Carrom	Individual
Football	Team
Cricket	Team
Basketball	Team
Volleyball	Team
Kabaddi	Team
\.


--
-- TOC entry 5161 (class 0 OID 18378)
-- Dependencies: 238
-- Data for Name: t_issue_record; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_issue_record (t_match_id, item_id, issue_time, return_time, issued_quantity) FROM stdin;
1	1	08:15:00	20:45:00	10
1	2	08:15:00	20:45:00	8
1	3	08:15:00	20:45:00	6
2	1	13:45:00	21:00:00	10
2	2	13:45:00	21:00:00	8
2	4	13:45:00	21:00:00	4
3	1	08:15:00	21:00:00	10
3	2	08:15:00	21:00:00	8
3	5	08:15:00	21:00:00	4
4	1	13:45:00	21:00:00	10
4	2	13:45:00	21:00:00	8
4	4	13:45:00	21:00:00	4
5	1	08:15:00	20:45:00	10
5	2	08:15:00	20:45:00	8
5	3	08:15:00	20:45:00	6
6	1	13:45:00	21:00:00	10
6	2	13:45:00	21:00:00	8
6	4	13:45:00	21:00:00	4
7	1	08:15:00	20:45:00	10
7	2	08:15:00	20:45:00	8
7	5	08:15:00	20:45:00	4
8	1	13:45:00	21:00:00	10
8	2	13:45:00	21:00:00	8
8	3	13:45:00	21:00:00	6
9	1	08:15:00	20:45:00	10
9	2	08:15:00	20:45:00	8
9	4	08:15:00	20:45:00	4
10	1	13:45:00	21:00:00	10
10	2	13:45:00	21:00:00	8
10	5	13:45:00	21:00:00	4
11	1	08:15:00	20:45:00	10
11	2	08:15:00	20:45:00	8
11	3	08:15:00	20:45:00	6
12	1	13:45:00	21:00:00	10
12	2	13:45:00	21:00:00	8
12	4	13:45:00	21:00:00	4
13	1	08:15:00	20:45:00	12
13	2	08:15:00	20:45:00	10
13	5	08:15:00	20:45:00	5
14	1	13:45:00	21:15:00	12
14	2	13:45:00	21:15:00	10
14	3	13:45:00	21:15:00	5
15	1	08:15:00	21:30:00	12
15	2	08:15:00	21:30:00	10
15	4	08:15:00	21:30:00	5
16	6	08:45:00	20:45:00	6
16	7	08:45:00	20:45:00	2
16	10	08:45:00	20:45:00	20
17	6	11:00:00	21:00:00	6
17	9	11:00:00	21:00:00	4
17	10	11:00:00	21:00:00	20
18	6	13:00:00	21:00:00	6
18	8	13:00:00	21:00:00	2
18	9	13:00:00	21:00:00	4
19	6	08:45:00	20:45:00	6
19	7	08:45:00	20:45:00	2
19	10	08:45:00	20:45:00	20
20	6	11:00:00	21:00:00	6
20	8	11:00:00	21:00:00	2
20	9	11:00:00	21:00:00	4
21	6	13:00:00	21:00:00	6
21	7	13:00:00	21:00:00	2
21	10	13:00:00	21:00:00	20
22	6	08:45:00	20:45:00	6
22	7	08:45:00	20:45:00	2
22	9	08:45:00	20:45:00	4
23	6	10:45:00	21:00:00	6
23	8	10:45:00	21:00:00	2
23	10	10:45:00	21:00:00	20
24	6	12:45:00	21:00:00	6
24	9	12:45:00	21:00:00	4
24	10	12:45:00	21:00:00	20
25	6	15:00:00	21:30:00	6
25	7	15:00:00	21:30:00	2
25	10	15:00:00	21:30:00	20
26	6	17:00:00	21:45:00	6
26	8	17:00:00	21:45:00	2
26	9	17:00:00	21:45:00	4
27	6	19:00:00	21:45:00	6
27	7	19:00:00	21:45:00	2
27	10	19:00:00	21:45:00	20
28	6	09:15:00	21:15:00	8
28	7	09:15:00	21:15:00	3
28	8	09:15:00	21:15:00	2
29	6	12:15:00	21:15:00	8
29	7	12:15:00	21:15:00	3
29	9	12:15:00	21:15:00	4
30	6	15:15:00	21:30:00	8
30	7	15:15:00	21:30:00	3
30	10	15:15:00	21:30:00	25
31	11	08:15:00	20:45:00	6
31	12	08:15:00	20:45:00	2
31	15	08:15:00	20:45:00	10
32	11	09:45:00	21:00:00	6
32	14	09:45:00	21:00:00	2
32	15	09:45:00	21:00:00	10
33	11	11:15:00	21:00:00	6
33	13	11:15:00	21:00:00	1
33	15	11:15:00	21:00:00	10
34	11	08:15:00	20:45:00	6
34	12	08:15:00	20:45:00	2
34	14	08:15:00	20:45:00	2
35	11	09:45:00	21:00:00	6
35	15	09:45:00	21:00:00	10
35	13	09:45:00	21:00:00	1
36	11	11:15:00	21:00:00	6
36	14	11:15:00	21:00:00	2
36	15	11:15:00	21:00:00	10
37	11	08:15:00	20:45:00	6
37	12	08:15:00	20:45:00	2
37	15	08:15:00	20:45:00	10
38	11	09:45:00	21:00:00	6
38	14	09:45:00	21:00:00	2
38	13	09:45:00	21:00:00	1
39	11	11:15:00	21:00:00	6
39	15	11:15:00	21:00:00	10
39	12	11:15:00	21:00:00	2
40	11	13:00:00	21:00:00	6
40	14	13:00:00	21:00:00	2
40	15	13:00:00	21:00:00	10
41	11	14:30:00	21:30:00	6
41	13	14:30:00	21:30:00	1
41	15	14:30:00	21:30:00	10
42	11	16:00:00	21:45:00	6
42	14	16:00:00	21:45:00	2
42	15	16:00:00	21:45:00	10
43	11	08:15:00	21:00:00	8
43	12	08:15:00	21:00:00	2
43	15	08:15:00	21:00:00	12
44	11	10:15:00	21:15:00	8
44	13	10:15:00	21:15:00	1
44	15	10:15:00	21:15:00	12
45	11	13:15:00	21:30:00	8
45	12	13:15:00	21:30:00	2
45	13	13:15:00	21:30:00	1
46	16	08:15:00	20:45:00	4
46	17	08:15:00	20:45:00	2
46	18	08:15:00	20:45:00	4
47	16	09:30:00	21:00:00	4
47	19	09:30:00	21:00:00	1
47	18	09:30:00	21:00:00	4
48	16	10:45:00	21:00:00	4
48	17	10:45:00	21:00:00	2
48	20	10:45:00	21:00:00	2
49	16	08:15:00	20:45:00	4
49	17	08:15:00	20:45:00	2
49	18	08:15:00	20:45:00	4
50	16	09:30:00	21:00:00	4
50	20	09:30:00	21:00:00	2
50	18	09:30:00	21:00:00	4
51	16	10:45:00	21:00:00	4
51	19	10:45:00	21:00:00	1
51	18	10:45:00	21:00:00	4
52	16	08:15:00	20:45:00	4
52	17	08:15:00	20:45:00	2
52	18	08:15:00	20:45:00	4
53	16	09:30:00	21:00:00	4
53	20	09:30:00	21:00:00	2
53	18	09:30:00	21:00:00	4
54	16	10:45:00	21:00:00	4
54	17	10:45:00	21:00:00	2
54	19	10:45:00	21:00:00	1
55	16	12:00:00	21:15:00	4
55	18	12:00:00	21:15:00	4
55	20	12:00:00	21:15:00	2
56	16	13:15:00	21:15:00	4
56	19	13:15:00	21:15:00	1
56	18	13:15:00	21:15:00	4
57	16	14:30:00	21:30:00	4
57	17	14:30:00	21:30:00	2
57	20	14:30:00	21:30:00	2
58	16	08:15:00	21:00:00	6
58	17	08:15:00	21:00:00	2
58	18	08:15:00	21:00:00	4
59	16	09:45:00	21:15:00	6
59	19	09:45:00	21:15:00	1
59	20	09:45:00	21:15:00	3
60	16	12:00:00	21:30:00	6
60	17	12:00:00	21:30:00	2
60	18	12:00:00	21:30:00	4
61	21	08:15:00	20:45:00	3
61	23	08:15:00	20:45:00	2
61	25	08:15:00	20:45:00	1
62	21	09:15:00	21:00:00	3
62	24	09:15:00	21:00:00	1
62	25	09:15:00	21:00:00	1
63	21	10:15:00	21:00:00	3
63	22	10:15:00	21:00:00	1
63	23	10:15:00	21:00:00	2
64	21	08:15:00	20:45:00	3
64	24	08:15:00	20:45:00	1
64	25	08:15:00	20:45:00	1
65	21	09:15:00	21:00:00	3
65	22	09:15:00	21:00:00	1
65	23	09:15:00	21:00:00	2
66	21	10:15:00	21:00:00	3
66	24	10:15:00	21:00:00	1
66	25	10:15:00	21:00:00	1
67	21	08:15:00	20:45:00	3
67	23	08:15:00	20:45:00	2
67	24	08:15:00	20:45:00	1
68	21	09:15:00	21:00:00	3
68	22	09:15:00	21:00:00	1
68	25	09:15:00	21:00:00	1
69	21	10:15:00	21:00:00	3
69	23	10:15:00	21:00:00	2
69	25	10:15:00	21:00:00	1
70	21	11:15:00	21:15:00	3
70	22	11:15:00	21:15:00	1
70	24	11:15:00	21:15:00	1
71	21	12:15:00	21:15:00	3
71	23	12:15:00	21:15:00	2
71	25	12:15:00	21:15:00	1
72	21	13:15:00	21:30:00	3
72	24	13:15:00	21:30:00	1
72	25	13:15:00	21:30:00	1
73	21	08:15:00	21:00:00	4
73	22	08:15:00	21:00:00	1
73	23	08:15:00	21:00:00	2
74	21	09:15:00	21:15:00	4
74	24	09:15:00	21:15:00	1
74	25	09:15:00	21:15:00	1
75	21	11:15:00	21:30:00	4
75	22	11:15:00	21:30:00	1
75	25	11:15:00	21:30:00	1
76	1	08:15:00	20:45:00	10
76	2	08:15:00	20:45:00	8
76	3	08:15:00	20:45:00	6
77	1	13:45:00	21:00:00	10
77	2	13:45:00	21:00:00	8
77	4	13:45:00	21:00:00	4
78	1	08:15:00	21:00:00	10
78	2	08:15:00	21:00:00	8
78	5	08:15:00	21:00:00	4
79	1	13:45:00	21:00:00	10
79	2	13:45:00	21:00:00	8
79	4	13:45:00	21:00:00	4
80	1	08:15:00	20:45:00	10
80	2	08:15:00	20:45:00	8
80	3	08:15:00	20:45:00	6
81	1	13:45:00	21:00:00	10
81	2	13:45:00	21:00:00	8
81	4	13:45:00	21:00:00	4
82	1	08:15:00	20:45:00	10
82	2	08:15:00	20:45:00	8
82	5	08:15:00	20:45:00	4
83	1	13:45:00	21:00:00	10
83	2	13:45:00	21:00:00	8
83	3	13:45:00	21:00:00	6
84	1	08:15:00	20:45:00	10
84	2	08:15:00	20:45:00	8
84	4	08:15:00	20:45:00	4
85	1	13:45:00	21:00:00	10
85	2	13:45:00	21:00:00	8
85	5	13:45:00	21:00:00	4
86	1	08:15:00	20:45:00	10
86	2	08:15:00	20:45:00	8
86	3	08:15:00	20:45:00	6
87	1	13:45:00	21:00:00	10
87	2	13:45:00	21:00:00	8
87	4	13:45:00	21:00:00	4
88	1	08:15:00	20:45:00	12
88	2	08:15:00	20:45:00	10
88	5	08:15:00	20:45:00	5
89	1	13:45:00	21:15:00	12
89	2	13:45:00	21:15:00	10
89	3	13:45:00	21:15:00	5
90	1	08:15:00	21:30:00	12
90	2	08:15:00	21:30:00	10
90	4	08:15:00	21:30:00	5
91	6	08:45:00	20:45:00	6
91	7	08:45:00	20:45:00	2
91	10	08:45:00	20:45:00	20
92	6	11:00:00	21:00:00	6
92	9	11:00:00	21:00:00	4
92	10	11:00:00	21:00:00	20
93	6	13:00:00	21:00:00	6
93	8	13:00:00	21:00:00	2
93	9	13:00:00	21:00:00	4
94	6	08:45:00	20:45:00	6
94	7	08:45:00	20:45:00	2
94	10	08:45:00	20:45:00	20
95	6	11:00:00	21:00:00	6
95	8	11:00:00	21:00:00	2
95	9	11:00:00	21:00:00	4
96	6	13:00:00	21:00:00	6
96	7	13:00:00	21:00:00	2
96	10	13:00:00	21:00:00	20
97	6	08:45:00	20:45:00	6
97	7	08:45:00	20:45:00	2
97	9	08:45:00	20:45:00	4
98	6	10:45:00	21:00:00	6
98	8	10:45:00	21:00:00	2
98	10	10:45:00	21:00:00	20
99	6	12:45:00	21:00:00	6
99	9	12:45:00	21:00:00	4
99	10	12:45:00	21:00:00	20
100	6	15:00:00	21:30:00	6
100	7	15:00:00	21:30:00	2
100	10	15:00:00	21:30:00	20
101	6	17:00:00	21:45:00	6
101	8	17:00:00	21:45:00	2
101	9	17:00:00	21:45:00	4
102	6	19:00:00	21:45:00	6
102	7	19:00:00	21:45:00	2
102	10	19:00:00	21:45:00	20
103	6	09:15:00	21:15:00	8
103	7	09:15:00	21:15:00	3
103	8	09:15:00	21:15:00	2
104	6	12:15:00	21:15:00	8
104	7	12:15:00	21:15:00	3
104	9	12:15:00	21:15:00	4
105	6	15:15:00	21:30:00	8
105	7	15:15:00	21:30:00	3
105	10	15:15:00	21:30:00	25
106	11	08:15:00	20:45:00	6
106	12	08:15:00	20:45:00	2
106	15	08:15:00	20:45:00	10
107	11	09:45:00	21:00:00	6
107	14	09:45:00	21:00:00	2
107	15	09:45:00	21:00:00	10
108	11	11:15:00	21:00:00	6
108	13	11:15:00	21:00:00	1
108	15	11:15:00	21:00:00	10
109	11	08:15:00	20:45:00	6
109	12	08:15:00	20:45:00	2
109	14	08:15:00	20:45:00	2
110	11	09:45:00	21:00:00	6
110	15	09:45:00	21:00:00	10
110	13	09:45:00	21:00:00	1
111	11	11:15:00	21:00:00	6
111	14	11:15:00	21:00:00	2
111	15	11:15:00	21:00:00	10
112	11	08:15:00	20:45:00	6
112	12	08:15:00	20:45:00	2
112	15	08:15:00	20:45:00	10
113	11	09:45:00	21:00:00	6
113	14	09:45:00	21:00:00	2
113	13	09:45:00	21:00:00	1
114	11	11:15:00	21:00:00	6
114	15	11:15:00	21:00:00	10
114	12	11:15:00	21:00:00	2
115	11	13:00:00	21:00:00	6
115	14	13:00:00	21:00:00	2
115	15	13:00:00	21:00:00	10
116	11	14:30:00	21:30:00	6
116	13	14:30:00	21:30:00	1
116	15	14:30:00	21:30:00	10
117	11	16:00:00	21:45:00	6
117	14	16:00:00	21:45:00	2
117	15	16:00:00	21:45:00	10
118	11	08:15:00	21:00:00	8
118	12	08:15:00	21:00:00	2
118	15	08:15:00	21:00:00	12
119	11	10:15:00	21:15:00	8
119	13	10:15:00	21:15:00	1
119	15	10:15:00	21:15:00	12
120	11	13:15:00	21:30:00	8
120	12	13:15:00	21:30:00	2
120	13	13:15:00	21:30:00	1
121	16	08:15:00	20:45:00	4
121	17	08:15:00	20:45:00	2
121	18	08:15:00	20:45:00	4
122	16	09:30:00	21:00:00	4
122	19	09:30:00	21:00:00	1
122	18	09:30:00	21:00:00	4
123	16	10:45:00	21:00:00	4
123	17	10:45:00	21:00:00	2
123	20	10:45:00	21:00:00	2
124	16	08:15:00	20:45:00	4
124	17	08:15:00	20:45:00	2
124	18	08:15:00	20:45:00	4
125	16	09:30:00	21:00:00	4
125	20	09:30:00	21:00:00	2
125	18	09:30:00	21:00:00	4
126	16	10:45:00	21:00:00	4
126	19	10:45:00	21:00:00	1
126	18	10:45:00	21:00:00	4
127	16	08:15:00	20:45:00	4
127	17	08:15:00	20:45:00	2
127	18	08:15:00	20:45:00	4
128	16	09:30:00	21:00:00	4
128	20	09:30:00	21:00:00	2
128	18	09:30:00	21:00:00	4
129	16	10:45:00	21:00:00	4
129	17	10:45:00	21:00:00	2
129	19	10:45:00	21:00:00	1
130	16	12:00:00	21:15:00	4
130	18	12:00:00	21:15:00	4
130	20	12:00:00	21:15:00	2
131	16	13:15:00	21:15:00	4
131	19	13:15:00	21:15:00	1
131	18	13:15:00	21:15:00	4
132	16	14:30:00	21:30:00	4
132	17	14:30:00	21:30:00	2
132	20	14:30:00	21:30:00	2
133	16	08:15:00	21:00:00	6
133	17	08:15:00	21:00:00	2
133	18	08:15:00	21:00:00	4
134	16	09:45:00	21:15:00	6
134	19	09:45:00	21:15:00	1
134	20	09:45:00	21:15:00	3
135	16	12:00:00	21:30:00	6
135	17	12:00:00	21:30:00	2
135	18	12:00:00	21:30:00	4
136	21	08:15:00	20:45:00	3
136	23	08:15:00	20:45:00	2
136	25	08:15:00	20:45:00	1
137	21	09:15:00	21:00:00	3
137	24	09:15:00	21:00:00	1
137	25	09:15:00	21:00:00	1
138	21	10:15:00	21:00:00	3
138	22	10:15:00	21:00:00	1
138	23	10:15:00	21:00:00	2
139	21	08:15:00	20:45:00	3
139	24	08:15:00	20:45:00	1
139	25	08:15:00	20:45:00	1
140	21	09:15:00	21:00:00	3
140	22	09:15:00	21:00:00	1
140	23	09:15:00	21:00:00	2
141	21	10:15:00	21:00:00	3
141	24	10:15:00	21:00:00	1
141	25	10:15:00	21:00:00	1
142	21	08:15:00	20:45:00	3
142	23	08:15:00	20:45:00	2
142	24	08:15:00	20:45:00	1
143	21	09:15:00	21:00:00	3
143	22	09:15:00	21:00:00	1
143	25	09:15:00	21:00:00	1
144	21	10:15:00	21:00:00	3
144	23	10:15:00	21:00:00	2
144	25	10:15:00	21:00:00	1
145	21	11:15:00	21:15:00	3
145	22	11:15:00	21:15:00	1
145	24	11:15:00	21:15:00	1
146	21	12:15:00	21:15:00	3
146	23	12:15:00	21:15:00	2
146	25	12:15:00	21:15:00	1
147	21	13:15:00	21:30:00	3
147	24	13:15:00	21:30:00	1
147	25	13:15:00	21:30:00	1
148	21	08:15:00	21:00:00	4
148	22	08:15:00	21:00:00	1
148	23	08:15:00	21:00:00	2
149	21	09:15:00	21:15:00	4
149	24	09:15:00	21:15:00	1
149	25	09:15:00	21:15:00	1
150	21	11:15:00	21:30:00	4
150	22	11:15:00	21:30:00	1
150	25	11:15:00	21:30:00	1
151	1	08:15:00	20:45:00	10
151	2	08:15:00	20:45:00	8
151	3	08:15:00	20:45:00	6
152	1	13:45:00	21:00:00	10
152	2	13:45:00	21:00:00	8
152	4	13:45:00	21:00:00	4
153	1	08:15:00	21:00:00	10
153	2	08:15:00	21:00:00	8
153	5	08:15:00	21:00:00	4
154	1	13:45:00	21:00:00	10
154	2	13:45:00	21:00:00	8
154	4	13:45:00	21:00:00	4
155	1	08:15:00	20:45:00	10
155	2	08:15:00	20:45:00	8
155	3	08:15:00	20:45:00	6
156	1	13:45:00	21:00:00	10
156	2	13:45:00	21:00:00	8
156	4	13:45:00	21:00:00	4
157	1	08:15:00	20:45:00	10
157	2	08:15:00	20:45:00	8
157	5	08:15:00	20:45:00	4
158	1	13:45:00	21:00:00	10
158	2	13:45:00	21:00:00	8
158	3	13:45:00	21:00:00	6
159	1	08:15:00	20:45:00	10
159	2	08:15:00	20:45:00	8
159	4	08:15:00	20:45:00	4
160	1	13:45:00	21:00:00	10
160	2	13:45:00	21:00:00	8
160	5	13:45:00	21:00:00	4
161	1	08:15:00	20:45:00	10
161	2	08:15:00	20:45:00	8
161	3	08:15:00	20:45:00	6
162	1	13:45:00	21:00:00	10
162	2	13:45:00	21:00:00	8
162	4	13:45:00	21:00:00	4
163	1	08:15:00	20:45:00	12
163	2	08:15:00	20:45:00	10
163	5	08:15:00	20:45:00	5
164	1	13:45:00	21:15:00	12
164	2	13:45:00	21:15:00	10
164	3	13:45:00	21:15:00	5
165	1	08:15:00	21:30:00	12
165	2	08:15:00	21:30:00	10
165	4	08:15:00	21:30:00	5
166	6	08:45:00	20:45:00	6
166	7	08:45:00	20:45:00	2
166	10	08:45:00	20:45:00	20
167	6	11:00:00	21:00:00	6
167	9	11:00:00	21:00:00	4
167	10	11:00:00	21:00:00	20
168	6	13:00:00	21:00:00	6
168	8	13:00:00	21:00:00	2
168	9	13:00:00	21:00:00	4
169	6	08:45:00	20:45:00	6
169	7	08:45:00	20:45:00	2
169	10	08:45:00	20:45:00	20
170	6	11:00:00	21:00:00	6
170	8	11:00:00	21:00:00	2
170	9	11:00:00	21:00:00	4
171	6	13:00:00	21:00:00	6
171	7	13:00:00	21:00:00	2
171	10	13:00:00	21:00:00	20
172	6	08:45:00	20:45:00	6
172	7	08:45:00	20:45:00	2
172	9	08:45:00	20:45:00	4
173	6	10:45:00	21:00:00	6
173	8	10:45:00	21:00:00	2
173	10	10:45:00	21:00:00	20
174	6	12:45:00	21:00:00	6
174	9	12:45:00	21:00:00	4
174	10	12:45:00	21:00:00	20
175	6	15:00:00	21:30:00	6
175	7	15:00:00	21:30:00	2
175	10	15:00:00	21:30:00	20
176	6	17:00:00	21:45:00	6
176	8	17:00:00	21:45:00	2
176	9	17:00:00	21:45:00	4
177	6	19:00:00	21:45:00	6
177	7	19:00:00	21:45:00	2
177	10	19:00:00	21:45:00	20
178	6	09:15:00	21:15:00	8
178	7	09:15:00	21:15:00	3
178	8	09:15:00	21:15:00	2
179	6	12:15:00	21:15:00	8
179	7	12:15:00	21:15:00	3
179	9	12:15:00	21:15:00	4
180	6	15:15:00	21:30:00	8
180	7	15:15:00	21:30:00	3
180	10	15:15:00	21:30:00	25
181	11	08:15:00	20:45:00	6
181	12	08:15:00	20:45:00	2
181	15	08:15:00	20:45:00	10
182	11	09:45:00	21:00:00	6
182	14	09:45:00	21:00:00	2
182	15	09:45:00	21:00:00	10
183	11	11:15:00	21:00:00	6
183	13	11:15:00	21:00:00	1
183	15	11:15:00	21:00:00	10
184	11	08:15:00	20:45:00	6
184	12	08:15:00	20:45:00	2
184	14	08:15:00	20:45:00	2
185	11	09:45:00	21:00:00	6
185	15	09:45:00	21:00:00	10
185	13	09:45:00	21:00:00	1
186	11	11:15:00	21:00:00	6
186	14	11:15:00	21:00:00	2
186	15	11:15:00	21:00:00	10
187	11	08:15:00	20:45:00	6
187	12	08:15:00	20:45:00	2
187	15	08:15:00	20:45:00	10
188	11	09:45:00	21:00:00	6
188	14	09:45:00	21:00:00	2
188	13	09:45:00	21:00:00	1
189	11	11:15:00	21:00:00	6
189	15	11:15:00	21:00:00	10
189	12	11:15:00	21:00:00	2
190	11	13:00:00	21:00:00	6
190	14	13:00:00	21:00:00	2
190	15	13:00:00	21:00:00	10
191	11	14:30:00	21:30:00	6
191	13	14:30:00	21:30:00	1
191	15	14:30:00	21:30:00	10
192	11	16:00:00	21:45:00	6
192	14	16:00:00	21:45:00	2
192	15	16:00:00	21:45:00	10
193	11	08:15:00	21:00:00	8
193	12	08:15:00	21:00:00	2
193	15	08:15:00	21:00:00	12
194	11	10:15:00	21:15:00	8
194	13	10:15:00	21:15:00	1
194	15	10:15:00	21:15:00	12
195	11	13:15:00	21:30:00	8
195	12	13:15:00	21:30:00	2
195	13	13:15:00	21:30:00	1
196	16	08:15:00	20:45:00	4
196	17	08:15:00	20:45:00	2
196	18	08:15:00	20:45:00	4
197	16	09:30:00	21:00:00	4
197	19	09:30:00	21:00:00	1
197	18	09:30:00	21:00:00	4
198	16	10:45:00	21:00:00	4
198	17	10:45:00	21:00:00	2
198	20	10:45:00	21:00:00	2
199	16	08:15:00	20:45:00	4
199	17	08:15:00	20:45:00	2
199	18	08:15:00	20:45:00	4
200	16	09:30:00	21:00:00	4
200	20	09:30:00	21:00:00	2
200	18	09:30:00	21:00:00	4
201	16	10:45:00	21:00:00	4
201	19	10:45:00	21:00:00	1
201	18	10:45:00	21:00:00	4
202	16	08:15:00	20:45:00	4
202	17	08:15:00	20:45:00	2
202	18	08:15:00	20:45:00	4
203	16	09:30:00	21:00:00	4
203	20	09:30:00	21:00:00	2
203	18	09:30:00	21:00:00	4
204	16	10:45:00	21:00:00	4
204	17	10:45:00	21:00:00	2
204	19	10:45:00	21:00:00	1
205	16	12:00:00	21:15:00	4
205	18	12:00:00	21:15:00	4
205	20	12:00:00	21:15:00	2
206	16	13:15:00	21:15:00	4
206	19	13:15:00	21:15:00	1
206	18	13:15:00	21:15:00	4
207	16	14:30:00	21:30:00	4
207	17	14:30:00	21:30:00	2
207	20	14:30:00	21:30:00	2
208	16	08:15:00	21:00:00	6
208	17	08:15:00	21:00:00	2
208	18	08:15:00	21:00:00	4
209	16	09:45:00	21:15:00	6
209	19	09:45:00	21:15:00	1
209	20	09:45:00	21:15:00	3
210	16	12:00:00	21:30:00	6
210	17	12:00:00	21:30:00	2
210	18	12:00:00	21:30:00	4
211	21	08:15:00	20:45:00	3
211	23	08:15:00	20:45:00	2
211	25	08:15:00	20:45:00	1
212	21	09:15:00	21:00:00	3
212	24	09:15:00	21:00:00	1
212	25	09:15:00	21:00:00	1
213	21	10:15:00	21:00:00	3
213	22	10:15:00	21:00:00	1
213	23	10:15:00	21:00:00	2
214	21	08:15:00	20:45:00	3
214	24	08:15:00	20:45:00	1
214	25	08:15:00	20:45:00	1
215	21	09:15:00	21:00:00	3
215	22	09:15:00	21:00:00	1
215	23	09:15:00	21:00:00	2
216	21	10:15:00	21:00:00	3
216	24	10:15:00	21:00:00	1
216	25	10:15:00	21:00:00	1
217	21	08:15:00	20:45:00	3
217	23	08:15:00	20:45:00	2
217	24	08:15:00	20:45:00	1
218	21	09:15:00	21:00:00	3
218	22	09:15:00	21:00:00	1
218	25	09:15:00	21:00:00	1
219	21	10:15:00	21:00:00	3
219	23	10:15:00	21:00:00	2
219	25	10:15:00	21:00:00	1
220	21	11:15:00	21:15:00	3
220	22	11:15:00	21:15:00	1
220	24	11:15:00	21:15:00	1
221	21	12:15:00	21:15:00	3
221	23	12:15:00	21:15:00	2
221	25	12:15:00	21:15:00	1
222	21	13:15:00	21:30:00	3
222	24	13:15:00	21:30:00	1
222	25	13:15:00	21:30:00	1
223	21	08:15:00	21:00:00	4
223	22	08:15:00	21:00:00	1
223	23	08:15:00	21:00:00	2
224	21	09:15:00	21:15:00	4
224	24	09:15:00	21:15:00	1
224	25	09:15:00	21:15:00	1
225	21	11:15:00	21:30:00	4
225	22	11:15:00	21:30:00	1
225	25	11:15:00	21:30:00	1
\.


--
-- TOC entry 5163 (class 0 OID 18410)
-- Dependencies: 240
-- Data for Name: t_match_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_match_ref (t_match_id, referee_id, role, fairness_rating) FROM stdin;
1	1	Main Umpire	9.40
1	2	Leg Umpire	9.10
1	3	Square Umpire	9.00
2	4	Main Umpire	9.30
2	5	Leg Umpire	9.00
2	6	Square Umpire	9.20
3	7	Main Umpire	9.40
3	8	Leg Umpire	9.10
3	9	Square Umpire	9.00
4	10	Main Umpire	9.50
4	11	Leg Umpire	9.20
4	12	Square Umpire	9.10
5	13	Main Umpire	9.60
5	14	Leg Umpire	9.30
5	15	Square Umpire	9.00
6	1	Main Umpire	9.50
6	2	Leg Umpire	9.20
6	3	Square Umpire	9.10
7	4	Main Umpire	9.40
7	5	Leg Umpire	9.10
7	6	Square Umpire	9.20
8	7	Main Umpire	9.60
8	8	Leg Umpire	9.30
8	9	Square Umpire	9.10
9	10	Main Umpire	9.50
9	11	Leg Umpire	9.20
9	12	Square Umpire	9.10
10	13	Main Umpire	9.60
10	14	Leg Umpire	9.40
10	15	Square Umpire	9.20
11	1	Main Umpire	9.50
11	2	Leg Umpire	9.30
11	3	Square Umpire	9.10
12	4	Main Umpire	9.60
12	5	Leg Umpire	9.40
12	6	Square Umpire	9.20
13	7	Main Umpire	9.70
13	8	Leg Umpire	9.50
13	9	Square Umpire	9.30
14	10	Main Umpire	9.60
14	11	Leg Umpire	9.40
14	12	Square Umpire	9.20
15	13	Main Umpire	9.70
15	14	Leg Umpire	9.50
15	15	Square Umpire	9.30
16	16	Main Referee	9.40
16	17	Line Referee 1	9.10
16	18	Line Referee 2	9.00
16	19	Fourth Official	9.20
17	20	Main Referee	9.30
17	21	Line Referee 1	9.00
17	22	Line Referee 2	8.90
17	23	Fourth Official	9.10
18	24	Main Referee	9.50
18	25	Line Referee 1	9.20
18	26	Line Referee 2	9.00
18	27	Fourth Official	9.30
19	28	Main Referee	9.40
19	29	Line Referee 1	9.10
19	30	Line Referee 2	9.00
19	16	Fourth Official	9.20
20	17	Main Referee	9.50
20	18	Line Referee 1	9.20
20	19	Line Referee 2	9.00
20	20	Fourth Official	9.10
21	21	Main Referee	9.40
21	22	Line Referee 1	9.00
21	23	Line Referee 2	9.00
21	24	Fourth Official	9.10
22	25	Main Referee	9.50
22	26	Line Referee 1	9.20
22	27	Line Referee 2	9.00
22	28	Fourth Official	9.30
23	29	Main Referee	9.40
23	30	Line Referee 1	9.10
23	16	Line Referee 2	9.00
23	17	Fourth Official	9.20
24	18	Main Referee	9.50
24	19	Line Referee 1	9.20
24	20	Line Referee 2	9.00
24	21	Fourth Official	9.30
25	22	Main Referee	9.40
25	23	Line Referee 1	9.00
25	24	Line Referee 2	9.00
25	25	Fourth Official	9.10
26	26	Main Referee	9.60
26	27	Line Referee 1	9.20
26	28	Line Referee 2	9.00
26	29	Fourth Official	9.30
27	30	Main Referee	9.50
27	16	Line Referee 1	9.20
27	17	Line Referee 2	9.10
27	18	Fourth Official	9.30
28	19	Main Referee	9.60
28	20	Line Referee 1	9.30
28	21	Line Referee 2	9.10
28	22	Fourth Official	9.40
29	23	Main Referee	9.50
29	24	Line Referee 1	9.20
29	25	Line Referee 2	9.00
29	26	Fourth Official	9.30
30	27	Main Referee	9.60
30	28	Line Referee 1	9.30
30	29	Line Referee 2	9.10
30	30	Fourth Official	9.40
31	31	Lead Referee	9.40
31	32	Assistant Referee	9.00
32	33	Lead Referee	9.50
32	34	Assistant Referee	9.20
33	35	Lead Referee	9.30
33	36	Assistant Referee	9.00
34	37	Lead Referee	9.40
34	38	Assistant Referee	9.10
35	31	Lead Referee	9.50
35	32	Assistant Referee	9.20
36	33	Lead Referee	9.40
36	34	Assistant Referee	9.10
37	35	Lead Referee	9.30
37	36	Assistant Referee	9.00
38	37	Lead Referee	9.40
38	38	Assistant Referee	9.10
39	31	Lead Referee	9.50
39	32	Assistant Referee	9.20
40	33	Lead Referee	9.40
40	34	Assistant Referee	9.10
41	35	Lead Referee	9.30
41	36	Assistant Referee	9.00
42	37	Lead Referee	9.40
42	38	Assistant Referee	9.10
43	31	Lead Referee	9.60
43	32	Assistant Referee	9.20
44	33	Lead Referee	9.50
44	34	Assistant Referee	9.10
45	35	Lead Referee	9.40
45	36	Assistant Referee	9.00
46	39	First Referee	9.40
46	40	Second Referee	9.00
47	41	First Referee	9.30
47	42	Second Referee	9.10
48	43	First Referee	9.50
48	44	Second Referee	9.20
49	39	First Referee	9.40
49	40	Second Referee	9.10
50	41	First Referee	9.30
50	42	Second Referee	9.00
51	43	First Referee	9.50
51	44	Second Referee	9.20
52	39	First Referee	9.40
52	40	Second Referee	9.10
53	41	First Referee	9.30
53	42	Second Referee	9.00
54	43	First Referee	9.50
54	44	Second Referee	9.20
55	39	First Referee	9.40
55	40	Second Referee	9.10
56	41	First Referee	9.30
56	42	Second Referee	9.00
57	43	First Referee	9.50
57	44	Second Referee	9.20
58	39	First Referee	9.40
58	40	Second Referee	9.10
59	41	First Referee	9.50
59	42	Second Referee	9.20
60	43	First Referee	9.60
60	44	Second Referee	9.30
61	45	On-field Referee	9.30
61	46	Line Referee	9.00
62	47	On-field Referee	9.20
62	48	Line Referee	8.90
63	49	On-field Referee	9.40
63	50	Line Referee	9.10
64	45	On-field Referee	9.50
64	46	Line Referee	9.20
65	47	On-field Referee	9.30
65	48	Line Referee	9.00
66	49	On-field Referee	9.40
66	50	Line Referee	9.10
67	45	On-field Referee	9.50
67	46	Line Referee	9.20
68	47	On-field Referee	9.30
68	48	Line Referee	9.10
69	49	On-field Referee	9.40
69	50	Line Referee	9.10
70	45	On-field Referee	9.50
70	46	Line Referee	9.20
71	47	On-field Referee	9.30
71	48	Line Referee	9.00
72	49	On-field Referee	9.40
72	50	Line Referee	9.10
73	45	On-field Referee	9.60
73	46	Line Referee	9.30
74	47	On-field Referee	9.50
74	48	Line Referee	9.20
75	49	On-field Referee	9.40
75	50	Line Referee	9.10
76	1	Main Umpire	9.50
76	2	Leg Umpire	9.10
76	3	Square Umpire	9.00
77	4	Main Umpire	9.40
77	5	Leg Umpire	9.00
77	6	Square Umpire	9.20
78	7	Main Umpire	9.60
78	8	Leg Umpire	9.20
78	9	Square Umpire	9.10
79	10	Main Umpire	9.50
79	11	Leg Umpire	9.30
79	12	Square Umpire	9.00
80	13	Main Umpire	9.40
80	14	Leg Umpire	9.20
80	15	Square Umpire	9.00
81	1	Main Umpire	9.50
81	2	Leg Umpire	9.10
81	3	Square Umpire	9.00
82	4	Main Umpire	9.40
82	5	Leg Umpire	9.20
82	6	Square Umpire	9.10
83	7	Main Umpire	9.60
83	8	Leg Umpire	9.30
83	9	Square Umpire	9.10
84	10	Main Umpire	9.50
84	11	Leg Umpire	9.20
84	12	Square Umpire	9.00
85	13	Main Umpire	9.40
85	14	Leg Umpire	9.10
85	15	Square Umpire	9.00
86	1	Main Umpire	9.50
86	2	Leg Umpire	9.30
86	3	Square Umpire	9.10
87	4	Main Umpire	9.60
87	5	Leg Umpire	9.40
87	6	Square Umpire	9.20
88	7	Main Umpire	9.70
88	8	Leg Umpire	9.50
88	9	Square Umpire	9.30
89	10	Main Umpire	9.60
89	11	Leg Umpire	9.40
89	12	Square Umpire	9.20
90	13	Main Umpire	9.70
90	14	Leg Umpire	9.50
90	15	Square Umpire	9.30
91	16	Main Referee	9.40
91	17	Line Referee 1	9.10
91	18	Line Referee 2	9.00
91	19	Fourth Official	9.20
92	20	Main Referee	9.30
92	21	Line Referee 1	9.00
92	22	Line Referee 2	8.90
92	23	Fourth Official	9.10
93	24	Main Referee	9.50
93	25	Line Referee 1	9.20
93	26	Line Referee 2	9.00
93	27	Fourth Official	9.30
94	28	Main Referee	9.40
94	29	Line Referee 1	9.10
94	30	Line Referee 2	9.00
94	16	Fourth Official	9.20
95	17	Main Referee	9.50
95	18	Line Referee 1	9.20
95	19	Line Referee 2	9.00
95	20	Fourth Official	9.10
96	21	Main Referee	9.40
96	22	Line Referee 1	9.00
96	23	Line Referee 2	9.00
96	24	Fourth Official	9.10
97	25	Main Referee	9.50
97	26	Line Referee 1	9.20
97	27	Line Referee 2	9.00
97	28	Fourth Official	9.30
98	29	Main Referee	9.40
98	30	Line Referee 1	9.10
98	16	Line Referee 2	9.00
98	17	Fourth Official	9.20
99	18	Main Referee	9.50
99	19	Line Referee 1	9.20
99	20	Line Referee 2	9.00
99	21	Fourth Official	9.30
100	22	Main Referee	9.40
100	23	Line Referee 1	9.00
100	24	Line Referee 2	9.00
100	25	Fourth Official	9.10
101	26	Main Referee	9.60
101	27	Line Referee 1	9.20
101	28	Line Referee 2	9.00
101	29	Fourth Official	9.30
102	30	Main Referee	9.50
102	16	Line Referee 1	9.20
102	17	Line Referee 2	9.10
102	18	Fourth Official	9.30
103	19	Main Referee	9.60
103	20	Line Referee 1	9.30
103	21	Line Referee 2	9.10
103	22	Fourth Official	9.40
104	23	Main Referee	9.50
104	24	Line Referee 1	9.20
104	25	Line Referee 2	9.00
104	26	Fourth Official	9.30
105	27	Main Referee	9.60
105	28	Line Referee 1	9.30
105	29	Line Referee 2	9.10
105	30	Fourth Official	9.40
106	31	Lead Referee	9.40
106	32	Assistant Referee	9.00
107	33	Lead Referee	9.50
107	34	Assistant Referee	9.20
108	35	Lead Referee	9.30
108	36	Assistant Referee	9.00
109	37	Lead Referee	9.40
109	38	Assistant Referee	9.10
110	31	Lead Referee	9.50
110	32	Assistant Referee	9.20
111	33	Lead Referee	9.40
111	34	Assistant Referee	9.10
112	35	Lead Referee	9.30
112	36	Assistant Referee	9.00
113	37	Lead Referee	9.40
113	38	Assistant Referee	9.10
114	31	Lead Referee	9.50
114	32	Assistant Referee	9.20
115	33	Lead Referee	9.40
115	34	Assistant Referee	9.10
116	35	Lead Referee	9.30
116	36	Assistant Referee	9.00
117	37	Lead Referee	9.40
117	38	Assistant Referee	9.10
118	31	Lead Referee	9.60
118	32	Assistant Referee	9.20
119	33	Lead Referee	9.50
119	34	Assistant Referee	9.10
120	35	Lead Referee	9.40
120	36	Assistant Referee	9.00
121	39	First Referee	9.40
121	40	Second Referee	9.00
122	41	First Referee	9.30
122	42	Second Referee	9.10
123	43	First Referee	9.50
123	44	Second Referee	9.20
124	39	First Referee	9.40
124	40	Second Referee	9.10
125	41	First Referee	9.30
125	42	Second Referee	9.00
126	43	First Referee	9.50
126	44	Second Referee	9.20
127	39	First Referee	9.40
127	40	Second Referee	9.10
128	41	First Referee	9.30
128	42	Second Referee	9.00
129	43	First Referee	9.50
129	44	Second Referee	9.20
130	39	First Referee	9.40
130	40	Second Referee	9.10
131	41	First Referee	9.30
131	42	Second Referee	9.00
132	43	First Referee	9.50
132	44	Second Referee	9.20
133	39	First Referee	9.50
133	40	Second Referee	9.20
134	41	First Referee	9.60
134	42	Second Referee	9.30
135	43	First Referee	9.50
135	44	Second Referee	9.10
136	45	On-field Referee	9.30
136	46	Line Referee	9.00
137	47	On-field Referee	9.20
137	48	Line Referee	8.90
138	49	On-field Referee	9.40
138	50	Line Referee	9.10
139	45	On-field Referee	9.50
139	46	Line Referee	9.20
140	47	On-field Referee	9.30
140	48	Line Referee	9.00
141	49	On-field Referee	9.40
141	50	Line Referee	9.10
142	45	On-field Referee	9.50
142	46	Line Referee	9.20
143	47	On-field Referee	9.30
143	48	Line Referee	9.10
144	49	On-field Referee	9.40
144	50	Line Referee	9.10
145	45	On-field Referee	9.50
145	46	Line Referee	9.20
146	47	On-field Referee	9.30
146	48	Line Referee	9.00
147	49	On-field Referee	9.40
147	50	Line Referee	9.10
148	45	On-field Referee	9.60
148	46	Line Referee	9.30
149	47	On-field Referee	9.50
149	48	Line Referee	9.20
150	49	On-field Referee	9.40
150	50	Line Referee	9.10
151	1	Main Umpire	9.50
151	2	Leg Umpire	9.10
151	3	Square Umpire	9.00
152	4	Main Umpire	9.40
152	5	Leg Umpire	9.00
152	6	Square Umpire	9.20
153	7	Main Umpire	9.60
153	8	Leg Umpire	9.20
153	9	Square Umpire	9.10
154	10	Main Umpire	9.50
154	11	Leg Umpire	9.30
154	12	Square Umpire	9.00
155	13	Main Umpire	9.40
155	14	Leg Umpire	9.20
155	15	Square Umpire	9.00
156	1	Main Umpire	9.50
156	2	Leg Umpire	9.10
156	3	Square Umpire	9.00
157	4	Main Umpire	9.40
157	5	Leg Umpire	9.20
157	6	Square Umpire	9.10
158	7	Main Umpire	9.60
158	8	Leg Umpire	9.30
158	9	Square Umpire	9.10
159	10	Main Umpire	9.50
159	11	Leg Umpire	9.20
159	12	Square Umpire	9.00
160	13	Main Umpire	9.40
160	14	Leg Umpire	9.10
160	15	Square Umpire	9.00
161	1	Main Umpire	9.50
161	2	Leg Umpire	9.30
161	3	Square Umpire	9.10
162	4	Main Umpire	9.60
162	5	Leg Umpire	9.40
162	6	Square Umpire	9.20
163	7	Main Umpire	9.70
163	8	Leg Umpire	9.50
163	9	Square Umpire	9.30
164	10	Main Umpire	9.60
164	11	Leg Umpire	9.40
164	12	Square Umpire	9.20
165	13	Main Umpire	9.70
165	14	Leg Umpire	9.50
165	15	Square Umpire	9.30
166	16	Main Referee	9.40
166	17	Line Referee 1	9.10
166	18	Line Referee 2	9.00
166	19	Fourth Official	9.20
167	20	Main Referee	9.30
167	21	Line Referee 1	9.00
167	22	Line Referee 2	8.90
167	23	Fourth Official	9.10
168	24	Main Referee	9.50
168	25	Line Referee 1	9.20
168	26	Line Referee 2	9.00
168	27	Fourth Official	9.30
169	28	Main Referee	9.40
169	29	Line Referee 1	9.10
169	30	Line Referee 2	9.00
169	16	Fourth Official	9.20
170	17	Main Referee	9.50
170	18	Line Referee 1	9.20
170	19	Line Referee 2	9.00
170	20	Fourth Official	9.10
171	21	Main Referee	9.40
171	22	Line Referee 1	9.00
171	23	Line Referee 2	9.00
171	24	Fourth Official	9.10
172	25	Main Referee	9.50
172	26	Line Referee 1	9.20
172	27	Line Referee 2	9.00
172	28	Fourth Official	9.30
173	29	Main Referee	9.40
173	30	Line Referee 1	9.10
173	16	Line Referee 2	9.00
173	17	Fourth Official	9.20
174	18	Main Referee	9.50
174	19	Line Referee 1	9.20
174	20	Line Referee 2	9.00
174	21	Fourth Official	9.30
175	22	Main Referee	9.40
175	23	Line Referee 1	9.00
175	24	Line Referee 2	9.00
175	25	Fourth Official	9.10
176	26	Main Referee	9.60
176	27	Line Referee 1	9.20
176	28	Line Referee 2	9.00
176	29	Fourth Official	9.30
177	30	Main Referee	9.50
177	16	Line Referee 1	9.20
177	17	Line Referee 2	9.10
177	18	Fourth Official	9.30
178	19	Main Referee	9.60
178	20	Line Referee 1	9.30
178	21	Line Referee 2	9.10
178	22	Fourth Official	9.40
179	23	Main Referee	9.50
179	24	Line Referee 1	9.20
179	25	Line Referee 2	9.00
179	26	Fourth Official	9.30
180	27	Main Referee	9.60
180	28	Line Referee 1	9.30
180	29	Line Referee 2	9.10
180	30	Fourth Official	9.40
181	31	Lead Referee	9.40
181	32	Assistant Referee	9.00
182	33	Lead Referee	9.50
182	34	Assistant Referee	9.20
183	35	Lead Referee	9.30
183	36	Assistant Referee	9.00
184	37	Lead Referee	9.40
184	38	Assistant Referee	9.10
185	31	Lead Referee	9.50
185	32	Assistant Referee	9.20
186	33	Lead Referee	9.40
186	34	Assistant Referee	9.10
187	35	Lead Referee	9.30
187	36	Assistant Referee	9.00
188	37	Lead Referee	9.40
188	38	Assistant Referee	9.10
189	31	Lead Referee	9.50
189	32	Assistant Referee	9.20
190	33	Lead Referee	9.40
190	34	Assistant Referee	9.10
191	35	Lead Referee	9.30
191	36	Assistant Referee	9.00
192	37	Lead Referee	9.40
192	38	Assistant Referee	9.10
193	31	Lead Referee	9.60
193	32	Assistant Referee	9.20
194	33	Lead Referee	9.50
194	34	Assistant Referee	9.10
195	35	Lead Referee	9.40
195	36	Assistant Referee	9.00
196	39	First Referee	9.40
196	40	Second Referee	9.00
197	41	First Referee	9.30
197	42	Second Referee	9.10
198	43	First Referee	9.50
198	44	Second Referee	9.20
199	39	First Referee	9.40
199	40	Second Referee	9.10
200	41	First Referee	9.30
200	42	Second Referee	9.00
201	43	First Referee	9.50
201	44	Second Referee	9.20
202	39	First Referee	9.40
202	40	Second Referee	9.10
203	41	First Referee	9.30
203	42	Second Referee	9.00
204	43	First Referee	9.50
204	44	Second Referee	9.20
205	39	First Referee	9.40
205	40	Second Referee	9.10
206	41	First Referee	9.30
206	42	Second Referee	9.00
207	43	First Referee	9.50
207	44	Second Referee	9.20
208	39	First Referee	9.50
208	40	Second Referee	9.20
209	41	First Referee	9.60
209	42	Second Referee	9.30
210	43	First Referee	9.50
210	44	Second Referee	9.10
211	45	On-field Referee	9.30
211	46	Line Referee	9.00
212	47	On-field Referee	9.20
212	48	Line Referee	8.90
213	49	On-field Referee	9.40
213	50	Line Referee	9.10
214	45	On-field Referee	9.50
214	46	Line Referee	9.20
215	47	On-field Referee	9.30
215	48	Line Referee	9.00
216	49	On-field Referee	9.40
216	50	Line Referee	9.10
217	45	On-field Referee	9.50
217	46	Line Referee	9.20
218	47	On-field Referee	9.30
218	48	Line Referee	9.10
219	49	On-field Referee	9.40
219	50	Line Referee	9.10
220	45	On-field Referee	9.50
220	46	Line Referee	9.20
221	47	On-field Referee	9.30
221	48	Line Referee	9.00
222	49	On-field Referee	9.40
222	50	Line Referee	9.10
223	45	On-field Referee	9.60
223	46	Line Referee	9.30
224	47	On-field Referee	9.50
224	48	Line Referee	9.20
225	49	On-field Referee	9.40
225	50	Line Referee	9.10
\.


--
-- TOC entry 5165 (class 0 OID 18440)
-- Dependencies: 242
-- Data for Name: t_volunteering_record; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.t_volunteering_record (t_match_id, volunteer_id, role, rating, hours_worked) FROM stdin;
1	41	Scorer Assistant	9.50	8
1	42	Cameraperson	9.40	8
1	43	Ground Staff	9.50	8
1	44	Drinks & Logistics	9.40	8
1	45	Team Liaison	9.60	8
2	41	Scorer Assistant	9.50	8
2	42	Cameraperson	9.40	8
2	43	Ground Staff	9.50	8
2	44	Drinks & Logistics	9.40	8
2	45	Team Liaison	9.60	8
3	41	Scorer Assistant	9.50	8
3	42	Cameraperson	9.40	8
3	43	Ground Staff	9.50	8
3	44	Drinks & Logistics	9.40	8
3	45	Team Liaison	9.60	8
4	41	Scorer Assistant	9.60	8
4	42	Cameraperson	9.50	8
4	43	Ground Staff	9.60	8
4	44	Drinks & Logistics	9.50	8
4	45	Team Liaison	9.60	8
5	41	Scorer Assistant	9.60	8
5	42	Cameraperson	9.50	8
5	43	Ground Staff	9.60	8
5	44	Drinks & Logistics	9.50	8
5	45	Team Liaison	9.60	8
6	41	Scorer Assistant	9.60	8
6	42	Cameraperson	9.50	8
6	43	Ground Staff	9.60	8
6	44	Drinks & Logistics	9.50	8
6	45	Team Liaison	9.60	8
7	41	Scorer Assistant	9.70	8
7	42	Cameraperson	9.50	8
7	43	Ground Staff	9.60	8
7	44	Drinks & Logistics	9.50	8
7	45	Team Liaison	9.70	8
8	41	Scorer Assistant	9.70	8
8	42	Cameraperson	9.50	8
8	43	Ground Staff	9.60	8
8	44	Drinks & Logistics	9.50	8
8	45	Team Liaison	9.70	8
9	41	Scorer Assistant	9.70	8
9	42	Cameraperson	9.50	8
9	43	Ground Staff	9.60	8
9	44	Drinks & Logistics	9.50	8
9	45	Team Liaison	9.70	8
10	41	Scorer Assistant	9.80	8
10	42	Cameraperson	9.60	8
10	43	Ground Staff	9.70	8
10	44	Drinks & Logistics	9.60	8
10	45	Team Liaison	9.80	8
11	41	Scorer Assistant	9.80	8
11	42	Cameraperson	9.60	8
11	43	Ground Staff	9.70	8
11	44	Drinks & Logistics	9.60	8
11	45	Team Liaison	9.80	8
12	41	Scorer Assistant	9.80	8
12	42	Cameraperson	9.60	8
12	43	Ground Staff	9.70	8
12	44	Drinks & Logistics	9.60	8
12	45	Team Liaison	9.80	8
13	41	Scorer Assistant	9.80	8
13	42	Cameraperson	9.60	8
13	43	Ground Staff	9.70	8
13	44	Drinks & Logistics	9.60	8
13	45	Team Liaison	9.80	8
14	41	Scorer Assistant	9.80	8
14	42	Cameraperson	9.60	8
14	43	Ground Staff	9.70	8
14	44	Drinks & Logistics	9.60	8
14	45	Team Liaison	9.80	8
15	41	Scorer Assistant	9.90	8
15	42	Cameraperson	9.70	8
15	43	Ground Staff	9.80	8
15	44	Drinks & Logistics	9.70	8
15	45	Team Liaison	9.90	8
16	46	Field Assistant	9.40	6
16	47	Medic	9.30	6
16	48	Equipment Handler	9.40	6
16	49	Substitution Coordinator	9.30	6
16	50	Announcer	9.40	6
17	46	Field Assistant	9.40	6
17	47	Medic	9.30	6
17	48	Equipment Handler	9.40	6
17	49	Substitution Coordinator	9.30	6
17	50	Announcer	9.40	6
18	46	Field Assistant	9.50	6
18	47	Medic	9.40	6
18	48	Equipment Handler	9.50	6
18	49	Substitution Coordinator	9.40	6
18	50	Announcer	9.50	6
19	46	Field Assistant	9.50	6
19	47	Medic	9.40	6
19	48	Equipment Handler	9.50	6
19	49	Substitution Coordinator	9.40	6
19	50	Announcer	9.50	6
20	46	Field Assistant	9.60	6
20	47	Medic	9.40	6
20	48	Equipment Handler	9.50	6
20	49	Substitution Coordinator	9.40	6
20	50	Announcer	9.50	6
21	46	Field Assistant	9.60	6
21	47	Medic	9.40	6
21	48	Equipment Handler	9.50	6
21	49	Substitution Coordinator	9.40	6
21	50	Announcer	9.50	6
22	46	Field Assistant	9.60	6
22	47	Medic	9.40	6
22	48	Equipment Handler	9.50	6
22	49	Substitution Coordinator	9.40	6
22	50	Announcer	9.50	6
23	46	Field Assistant	9.60	6
23	47	Medic	9.40	6
23	48	Equipment Handler	9.50	6
23	49	Substitution Coordinator	9.40	6
23	50	Announcer	9.50	6
24	46	Field Assistant	9.70	6
24	47	Medic	9.50	6
24	48	Equipment Handler	9.60	6
24	49	Substitution Coordinator	9.50	6
24	50	Announcer	9.60	6
25	46	Field Assistant	9.70	6
25	47	Medic	9.50	6
25	48	Equipment Handler	9.60	6
25	49	Substitution Coordinator	9.50	6
25	50	Announcer	9.60	6
26	46	Field Assistant	9.70	6
26	47	Medic	9.50	6
26	48	Equipment Handler	9.60	6
26	49	Substitution Coordinator	9.50	6
26	50	Announcer	9.60	6
27	46	Field Assistant	9.70	6
27	47	Medic	9.50	6
27	48	Equipment Handler	9.60	6
27	49	Substitution Coordinator	9.50	6
27	50	Announcer	9.60	6
28	46	Field Assistant	9.80	6
28	47	Medic	9.60	6
28	48	Equipment Handler	9.70	6
28	49	Substitution Coordinator	9.60	6
28	50	Announcer	9.70	6
29	46	Field Assistant	9.80	6
29	47	Medic	9.60	6
29	48	Equipment Handler	9.70	6
29	49	Substitution Coordinator	9.60	6
29	50	Announcer	9.70	6
30	46	Field Assistant	9.90	6
30	47	Medic	9.70	6
30	48	Equipment Handler	9.80	6
30	49	Substitution Coordinator	9.70	6
30	50	Announcer	9.80	6
31	51	Scoreboard Operator	9.40	5
31	52	Medic	9.30	5
31	53	Equipment Staff	9.50	5
31	54	Announcer	9.40	5
32	51	Scoreboard Operator	9.40	5
32	52	Medic	9.30	5
32	53	Equipment Staff	9.50	5
32	54	Announcer	9.40	5
33	51	Scoreboard Operator	9.50	5
33	52	Medic	9.40	5
33	53	Equipment Staff	9.50	5
33	54	Announcer	9.50	5
34	51	Scoreboard Operator	9.50	5
34	52	Medic	9.40	5
34	53	Equipment Staff	9.60	5
34	54	Announcer	9.50	5
35	51	Scoreboard Operator	9.50	5
35	52	Medic	9.40	5
35	53	Equipment Staff	9.60	5
35	54	Announcer	9.50	5
36	51	Scoreboard Operator	9.60	5
36	52	Medic	9.50	5
36	53	Equipment Staff	9.60	5
36	54	Announcer	9.50	5
37	51	Scoreboard Operator	9.60	5
37	52	Medic	9.50	5
37	53	Equipment Staff	9.60	5
37	54	Announcer	9.60	5
38	51	Scoreboard Operator	9.60	5
38	52	Medic	9.50	5
38	53	Equipment Staff	9.60	5
38	54	Announcer	9.60	5
39	51	Scoreboard Operator	9.60	5
39	52	Medic	9.50	5
39	53	Equipment Staff	9.60	5
39	54	Announcer	9.60	5
40	51	Scoreboard Operator	9.60	5
40	52	Medic	9.50	5
40	53	Equipment Staff	9.60	5
40	54	Announcer	9.60	5
41	51	Scoreboard Operator	9.70	5
41	52	Medic	9.50	5
41	53	Equipment Staff	9.70	5
41	54	Announcer	9.60	5
42	51	Scoreboard Operator	9.70	5
42	52	Medic	9.60	5
42	53	Equipment Staff	9.70	5
42	54	Announcer	9.70	5
43	51	Scoreboard Operator	9.80	5
43	52	Medic	9.70	5
43	53	Equipment Staff	9.80	5
43	54	Announcer	9.80	5
44	51	Scoreboard Operator	9.80	5
44	52	Medic	9.70	5
44	53	Equipment Staff	9.80	5
44	54	Announcer	9.80	5
45	51	Scoreboard Operator	9.90	5
45	52	Medic	9.80	5
45	53	Equipment Staff	9.90	5
45	54	Announcer	9.90	5
46	55	Ball Retriever	9.40	5
46	56	Medic	9.30	5
46	57	Equipment Setup	9.40	5
46	58	Score Recorder	9.40	5
47	55	Ball Retriever	9.40	5
47	56	Medic	9.30	5
47	57	Equipment Setup	9.40	5
47	58	Score Recorder	9.40	5
48	55	Ball Retriever	9.50	5
48	56	Medic	9.40	5
48	57	Equipment Setup	9.50	5
48	58	Score Recorder	9.50	5
49	55	Ball Retriever	9.50	5
49	56	Medic	9.40	5
49	57	Equipment Setup	9.50	5
49	58	Score Recorder	9.50	5
50	55	Ball Retriever	9.60	5
50	56	Medic	9.40	5
50	57	Equipment Setup	9.60	5
50	58	Score Recorder	9.60	5
51	55	Ball Retriever	9.60	5
51	56	Medic	9.50	5
51	57	Equipment Setup	9.60	5
51	58	Score Recorder	9.60	5
52	55	Ball Retriever	9.60	5
52	56	Medic	9.50	5
52	57	Equipment Setup	9.60	5
52	58	Score Recorder	9.60	5
53	55	Ball Retriever	9.60	5
53	56	Medic	9.50	5
53	57	Equipment Setup	9.60	5
53	58	Score Recorder	9.60	5
54	55	Ball Retriever	9.70	5
54	56	Medic	9.60	5
54	57	Equipment Setup	9.70	5
54	58	Score Recorder	9.70	5
55	55	Ball Retriever	9.70	5
55	56	Medic	9.60	5
55	57	Equipment Setup	9.70	5
55	58	Score Recorder	9.70	5
56	55	Ball Retriever	9.70	5
56	56	Medic	9.60	5
56	57	Equipment Setup	9.70	5
56	58	Score Recorder	9.70	5
57	55	Ball Retriever	9.70	5
57	56	Medic	9.60	5
57	57	Equipment Setup	9.70	5
57	58	Score Recorder	9.70	5
58	55	Ball Retriever	9.80	5
58	56	Medic	9.70	5
58	57	Equipment Setup	9.80	5
58	58	Score Recorder	9.80	5
59	55	Ball Retriever	9.80	5
59	56	Medic	9.70	5
59	57	Equipment Setup	9.80	5
59	58	Score Recorder	9.80	5
60	55	Ball Retriever	9.90	5
60	56	Medic	9.80	5
60	57	Equipment Setup	9.90	5
60	58	Score Recorder	9.90	5
61	59	Mat Cleaner	9.40	4
61	60	Medic	9.30	4
61	61	Score Recorder	9.40	4
61	62	Logistics Support	9.30	4
62	59	Mat Cleaner	9.40	4
62	60	Medic	9.30	4
62	61	Score Recorder	9.40	4
62	62	Logistics Support	9.30	4
63	59	Mat Cleaner	9.50	4
63	60	Medic	9.40	4
63	61	Score Recorder	9.50	4
63	62	Logistics Support	9.40	4
64	59	Mat Cleaner	9.50	4
64	60	Medic	9.40	4
64	61	Score Recorder	9.50	4
64	62	Logistics Support	9.40	4
65	59	Mat Cleaner	9.50	4
65	60	Medic	9.40	4
65	61	Score Recorder	9.50	4
65	62	Logistics Support	9.40	4
66	59	Mat Cleaner	9.50	4
66	60	Medic	9.40	4
66	61	Score Recorder	9.50	4
66	62	Logistics Support	9.40	4
67	59	Mat Cleaner	9.60	4
67	60	Medic	9.50	4
67	61	Score Recorder	9.60	4
67	62	Logistics Support	9.50	4
68	59	Mat Cleaner	9.60	4
68	60	Medic	9.50	4
68	61	Score Recorder	9.60	4
68	62	Logistics Support	9.50	4
69	59	Mat Cleaner	9.60	4
69	60	Medic	9.50	4
69	61	Score Recorder	9.60	4
69	62	Logistics Support	9.50	4
70	59	Mat Cleaner	9.60	4
70	60	Medic	9.50	4
70	61	Score Recorder	9.60	4
70	62	Logistics Support	9.50	4
71	59	Mat Cleaner	9.70	4
71	60	Medic	9.60	4
71	61	Score Recorder	9.70	4
71	62	Logistics Support	9.60	4
72	59	Mat Cleaner	9.70	4
72	60	Medic	9.60	4
72	61	Score Recorder	9.70	4
72	62	Logistics Support	9.60	4
73	59	Mat Cleaner	9.80	4
73	60	Medic	9.70	4
73	61	Score Recorder	9.80	4
73	62	Logistics Support	9.70	4
74	59	Mat Cleaner	9.80	4
74	60	Medic	9.70	4
74	61	Score Recorder	9.80	4
74	62	Logistics Support	9.70	4
75	59	Mat Cleaner	9.90	4
75	60	Medic	9.80	4
75	61	Score Recorder	9.90	4
75	62	Logistics Support	9.80	4
76	63	Scorer Assistant	9.50	8
76	64	Cameraperson	9.40	8
76	65	Ground Staff	9.50	8
76	66	Drinks & Logistics	9.40	8
76	67	Team Liaison	9.50	8
77	63	Scorer Assistant	9.50	8
77	64	Cameraperson	9.40	8
77	65	Ground Staff	9.50	8
77	66	Drinks & Logistics	9.40	8
77	67	Team Liaison	9.50	8
78	63	Scorer Assistant	9.50	8
78	64	Cameraperson	9.40	8
78	65	Ground Staff	9.50	8
78	66	Drinks & Logistics	9.40	8
78	67	Team Liaison	9.60	8
79	63	Scorer Assistant	9.60	8
79	64	Cameraperson	9.50	8
79	65	Ground Staff	9.60	8
79	66	Drinks & Logistics	9.50	8
79	67	Team Liaison	9.60	8
80	63	Scorer Assistant	9.60	8
80	64	Cameraperson	9.50	8
80	65	Ground Staff	9.60	8
80	66	Drinks & Logistics	9.50	8
80	67	Team Liaison	9.60	8
81	63	Scorer Assistant	9.60	8
81	64	Cameraperson	9.50	8
81	65	Ground Staff	9.60	8
81	66	Drinks & Logistics	9.50	8
81	67	Team Liaison	9.60	8
82	63	Scorer Assistant	9.70	8
82	64	Cameraperson	9.50	8
82	65	Ground Staff	9.70	8
82	66	Drinks & Logistics	9.60	8
82	67	Team Liaison	9.70	8
83	63	Scorer Assistant	9.70	8
83	64	Cameraperson	9.50	8
83	65	Ground Staff	9.70	8
83	66	Drinks & Logistics	9.60	8
83	67	Team Liaison	9.70	8
84	63	Scorer Assistant	9.70	8
84	64	Cameraperson	9.50	8
84	65	Ground Staff	9.70	8
84	66	Drinks & Logistics	9.60	8
84	67	Team Liaison	9.70	8
85	63	Scorer Assistant	9.80	8
85	64	Cameraperson	9.60	8
85	65	Ground Staff	9.80	8
85	66	Drinks & Logistics	9.70	8
85	67	Team Liaison	9.80	8
86	63	Scorer Assistant	9.80	8
86	64	Cameraperson	9.60	8
86	65	Ground Staff	9.80	8
86	66	Drinks & Logistics	9.70	8
86	67	Team Liaison	9.80	8
87	63	Scorer Assistant	9.80	8
87	64	Cameraperson	9.60	8
87	65	Ground Staff	9.80	8
87	66	Drinks & Logistics	9.70	8
87	67	Team Liaison	9.80	8
88	63	Scorer Assistant	9.80	8
88	64	Cameraperson	9.60	8
88	65	Ground Staff	9.80	8
88	66	Drinks & Logistics	9.70	8
88	67	Team Liaison	9.80	8
89	63	Scorer Assistant	9.80	8
89	64	Cameraperson	9.60	8
89	65	Ground Staff	9.80	8
89	66	Drinks & Logistics	9.70	8
89	67	Team Liaison	9.80	8
90	63	Scorer Assistant	9.90	8
90	64	Cameraperson	9.70	8
90	65	Ground Staff	9.90	8
90	66	Drinks & Logistics	9.80	8
90	67	Team Liaison	9.90	8
91	68	Field Assistant	9.40	6
91	69	Medic	9.30	6
91	70	Equipment Handler	9.40	6
91	71	Substitution Coordinator	9.30	6
91	72	Announcer	9.40	6
92	68	Field Assistant	9.40	6
92	69	Medic	9.30	6
92	70	Equipment Handler	9.40	6
92	71	Substitution Coordinator	9.30	6
92	72	Announcer	9.40	6
93	68	Field Assistant	9.50	6
93	69	Medic	9.40	6
93	70	Equipment Handler	9.50	6
93	71	Substitution Coordinator	9.40	6
93	72	Announcer	9.50	6
94	68	Field Assistant	9.50	6
94	69	Medic	9.40	6
94	70	Equipment Handler	9.50	6
94	71	Substitution Coordinator	9.40	6
94	72	Announcer	9.50	6
95	68	Field Assistant	9.60	6
95	69	Medic	9.50	6
95	70	Equipment Handler	9.60	6
95	71	Substitution Coordinator	9.50	6
95	72	Announcer	9.60	6
96	68	Field Assistant	9.60	6
96	69	Medic	9.50	6
96	70	Equipment Handler	9.60	6
96	71	Substitution Coordinator	9.50	6
96	72	Announcer	9.60	6
97	68	Field Assistant	9.60	6
97	69	Medic	9.50	6
97	70	Equipment Handler	9.60	6
97	71	Substitution Coordinator	9.50	6
97	72	Announcer	9.60	6
98	68	Field Assistant	9.60	6
98	69	Medic	9.50	6
98	70	Equipment Handler	9.60	6
98	71	Substitution Coordinator	9.50	6
98	72	Announcer	9.60	6
99	68	Field Assistant	9.70	6
99	69	Medic	9.60	6
99	70	Equipment Handler	9.70	6
99	71	Substitution Coordinator	9.60	6
99	72	Announcer	9.70	6
100	68	Field Assistant	9.70	6
100	69	Medic	9.60	6
100	70	Equipment Handler	9.70	6
100	71	Substitution Coordinator	9.60	6
100	72	Announcer	9.70	6
101	68	Field Assistant	9.70	6
101	69	Medic	9.60	6
101	70	Equipment Handler	9.70	6
101	71	Substitution Coordinator	9.60	6
101	72	Announcer	9.70	6
102	68	Field Assistant	9.70	6
102	69	Medic	9.60	6
102	70	Equipment Handler	9.70	6
102	71	Substitution Coordinator	9.60	6
102	72	Announcer	9.70	6
103	68	Field Assistant	9.80	6
103	69	Medic	9.70	6
103	70	Equipment Handler	9.80	6
103	71	Substitution Coordinator	9.70	6
103	72	Announcer	9.80	6
104	68	Field Assistant	9.80	6
104	69	Medic	9.70	6
104	70	Equipment Handler	9.80	6
104	71	Substitution Coordinator	9.70	6
104	72	Announcer	9.80	6
105	68	Field Assistant	9.90	6
105	69	Medic	9.80	6
105	70	Equipment Handler	9.90	6
105	71	Substitution Coordinator	9.80	6
105	72	Announcer	9.90	6
106	73	Scoreboard Operator	9.40	5
106	74	Medic	9.30	5
106	75	Equipment Staff	9.40	5
106	76	Announcer	9.40	5
107	73	Scoreboard Operator	9.40	5
107	74	Medic	9.30	5
107	75	Equipment Staff	9.40	5
107	76	Announcer	9.40	5
108	73	Scoreboard Operator	9.50	5
108	74	Medic	9.40	5
108	75	Equipment Staff	9.50	5
108	76	Announcer	9.50	5
109	73	Scoreboard Operator	9.50	5
109	74	Medic	9.40	5
109	75	Equipment Staff	9.50	5
109	76	Announcer	9.50	5
110	73	Scoreboard Operator	9.60	5
110	74	Medic	9.50	5
110	75	Equipment Staff	9.60	5
110	76	Announcer	9.60	5
111	73	Scoreboard Operator	9.60	5
111	74	Medic	9.50	5
111	75	Equipment Staff	9.60	5
111	76	Announcer	9.60	5
112	73	Scoreboard Operator	9.60	5
112	74	Medic	9.50	5
112	75	Equipment Staff	9.60	5
112	76	Announcer	9.60	5
113	73	Scoreboard Operator	9.60	5
113	74	Medic	9.50	5
113	75	Equipment Staff	9.60	5
113	76	Announcer	9.60	5
114	73	Scoreboard Operator	9.70	5
114	74	Medic	9.60	5
114	75	Equipment Staff	9.70	5
114	76	Announcer	9.70	5
115	73	Scoreboard Operator	9.70	5
115	74	Medic	9.60	5
115	75	Equipment Staff	9.70	5
115	76	Announcer	9.70	5
116	73	Scoreboard Operator	9.70	5
116	74	Medic	9.60	5
116	75	Equipment Staff	9.70	5
116	76	Announcer	9.70	5
117	73	Scoreboard Operator	9.70	5
117	74	Medic	9.60	5
117	75	Equipment Staff	9.70	5
117	76	Announcer	9.70	5
118	73	Scoreboard Operator	9.80	5
118	74	Medic	9.70	5
118	75	Equipment Staff	9.80	5
118	76	Announcer	9.80	5
119	73	Scoreboard Operator	9.80	5
119	74	Medic	9.70	5
119	75	Equipment Staff	9.80	5
119	76	Announcer	9.80	5
120	73	Scoreboard Operator	9.90	5
120	74	Medic	9.80	5
120	75	Equipment Staff	9.90	5
120	76	Announcer	9.90	5
121	77	Ball Retriever	9.40	5
121	78	Medic	9.30	5
121	79	Equipment Setup	9.40	5
121	80	Score Recorder	9.40	5
122	77	Ball Retriever	9.40	5
122	78	Medic	9.30	5
122	79	Equipment Setup	9.40	5
122	80	Score Recorder	9.40	5
123	77	Ball Retriever	9.50	5
123	78	Medic	9.40	5
123	79	Equipment Setup	9.50	5
123	80	Score Recorder	9.50	5
124	77	Ball Retriever	9.50	5
124	78	Medic	9.40	5
124	79	Equipment Setup	9.50	5
124	80	Score Recorder	9.50	5
125	77	Ball Retriever	9.60	5
125	78	Medic	9.50	5
125	79	Equipment Setup	9.60	5
125	80	Score Recorder	9.60	5
126	77	Ball Retriever	9.60	5
126	78	Medic	9.50	5
126	79	Equipment Setup	9.60	5
126	80	Score Recorder	9.60	5
127	77	Ball Retriever	9.60	5
127	78	Medic	9.50	5
127	79	Equipment Setup	9.60	5
127	80	Score Recorder	9.60	5
128	77	Ball Retriever	9.60	5
128	78	Medic	9.50	5
128	79	Equipment Setup	9.60	5
128	80	Score Recorder	9.60	5
129	77	Ball Retriever	9.70	5
129	78	Medic	9.60	5
129	79	Equipment Setup	9.70	5
129	80	Score Recorder	9.70	5
130	77	Ball Retriever	9.70	5
130	78	Medic	9.60	5
130	79	Equipment Setup	9.70	5
130	80	Score Recorder	9.70	5
131	77	Ball Retriever	9.70	5
131	78	Medic	9.60	5
131	79	Equipment Setup	9.70	5
131	80	Score Recorder	9.70	5
132	77	Ball Retriever	9.70	5
132	78	Medic	9.60	5
132	79	Equipment Setup	9.70	5
132	80	Score Recorder	9.70	5
133	77	Ball Retriever	9.80	5
133	78	Medic	9.70	5
133	79	Equipment Setup	9.80	5
133	80	Score Recorder	9.80	5
134	77	Ball Retriever	9.80	5
134	78	Medic	9.70	5
134	79	Equipment Setup	9.80	5
134	80	Score Recorder	9.80	5
135	77	Ball Retriever	9.90	5
135	78	Medic	9.80	5
135	79	Equipment Setup	9.90	5
135	80	Score Recorder	9.90	5
136	81	Mat Cleaner	9.40	4
136	82	Medic	9.30	4
136	83	Score Recorder	9.40	4
136	84	Logistics Support	9.30	4
137	81	Mat Cleaner	9.40	4
137	82	Medic	9.30	4
137	83	Score Recorder	9.40	4
137	84	Logistics Support	9.30	4
138	81	Mat Cleaner	9.50	4
138	82	Medic	9.40	4
138	83	Score Recorder	9.50	4
138	84	Logistics Support	9.40	4
139	81	Mat Cleaner	9.50	4
139	82	Medic	9.40	4
139	83	Score Recorder	9.50	4
139	84	Logistics Support	9.40	4
140	81	Mat Cleaner	9.50	4
140	82	Medic	9.40	4
140	83	Score Recorder	9.50	4
140	84	Logistics Support	9.40	4
141	81	Mat Cleaner	9.60	4
141	82	Medic	9.50	4
141	83	Score Recorder	9.60	4
141	84	Logistics Support	9.50	4
142	81	Mat Cleaner	9.60	4
142	82	Medic	9.50	4
142	83	Score Recorder	9.60	4
142	84	Logistics Support	9.50	4
143	81	Mat Cleaner	9.60	4
143	82	Medic	9.50	4
143	83	Score Recorder	9.60	4
143	84	Logistics Support	9.50	4
144	81	Mat Cleaner	9.60	4
144	82	Medic	9.50	4
144	83	Score Recorder	9.60	4
144	84	Logistics Support	9.50	4
145	81	Mat Cleaner	9.70	4
145	82	Medic	9.60	4
145	83	Score Recorder	9.70	4
145	84	Logistics Support	9.60	4
146	81	Mat Cleaner	9.70	4
146	82	Medic	9.60	4
146	83	Score Recorder	9.70	4
146	84	Logistics Support	9.60	4
147	81	Mat Cleaner	9.70	4
147	82	Medic	9.60	4
147	83	Score Recorder	9.70	4
147	84	Logistics Support	9.60	4
148	81	Mat Cleaner	9.80	4
148	82	Medic	9.70	4
148	83	Score Recorder	9.80	4
148	84	Logistics Support	9.70	4
149	81	Mat Cleaner	9.80	4
149	82	Medic	9.70	4
149	83	Score Recorder	9.80	4
149	84	Logistics Support	9.70	4
150	81	Mat Cleaner	9.90	4
150	82	Medic	9.80	4
150	83	Score Recorder	9.90	4
150	84	Logistics Support	9.80	4
151	85	Scoreboard Operator	9.30	8
151	86	Cameraperson	9.20	8
151	87	Medic	9.40	8
151	88	Ground Staff	9.30	8
151	89	Logistics Assistant	9.30	8
152	85	Scoreboard Operator	9.30	8
152	86	Cameraperson	9.20	8
152	87	Medic	9.40	8
152	88	Ground Staff	9.30	8
152	89	Logistics Assistant	9.30	8
153	85	Scoreboard Operator	9.40	8
153	86	Cameraperson	9.30	8
153	87	Medic	9.50	8
153	88	Ground Staff	9.40	8
153	89	Logistics Assistant	9.40	8
154	85	Scoreboard Operator	9.40	8
154	86	Cameraperson	9.30	8
154	87	Medic	9.50	8
154	88	Ground Staff	9.40	8
154	89	Logistics Assistant	9.40	8
155	85	Scoreboard Operator	9.50	8
155	86	Cameraperson	9.40	8
155	87	Medic	9.60	8
155	88	Ground Staff	9.50	8
155	89	Logistics Assistant	9.50	8
156	85	Scoreboard Operator	9.50	8
156	86	Cameraperson	9.40	8
156	87	Medic	9.60	8
156	88	Ground Staff	9.50	8
156	89	Logistics Assistant	9.50	8
157	85	Scoreboard Operator	9.50	8
157	86	Cameraperson	9.40	8
157	87	Medic	9.60	8
157	88	Ground Staff	9.50	8
157	89	Logistics Assistant	9.50	8
158	85	Scoreboard Operator	9.50	8
158	86	Cameraperson	9.40	8
158	87	Medic	9.60	8
158	88	Ground Staff	9.50	8
158	89	Logistics Assistant	9.50	8
159	85	Scoreboard Operator	9.60	8
159	86	Cameraperson	9.50	8
159	87	Medic	9.70	8
159	88	Ground Staff	9.60	8
159	89	Logistics Assistant	9.60	8
160	85	Scoreboard Operator	9.60	8
160	86	Cameraperson	9.50	8
160	87	Medic	9.70	8
160	88	Ground Staff	9.60	8
160	89	Logistics Assistant	9.60	8
161	85	Scoreboard Operator	9.60	8
161	86	Cameraperson	9.50	8
161	87	Medic	9.70	8
161	88	Ground Staff	9.60	8
161	89	Logistics Assistant	9.60	8
162	85	Scoreboard Operator	9.70	8
162	86	Cameraperson	9.60	8
162	87	Medic	9.80	8
162	88	Ground Staff	9.70	8
162	89	Logistics Assistant	9.70	8
163	85	Scoreboard Operator	9.70	8
163	86	Cameraperson	9.60	8
163	87	Medic	9.80	8
163	88	Ground Staff	9.70	8
163	89	Logistics Assistant	9.70	8
164	85	Scoreboard Operator	9.80	8
164	86	Cameraperson	9.70	8
164	87	Medic	9.90	8
164	88	Ground Staff	9.80	8
164	89	Logistics Assistant	9.80	8
165	85	Scoreboard Operator	9.80	8
165	86	Cameraperson	9.70	8
165	87	Medic	9.90	8
165	88	Ground Staff	9.80	8
165	89	Logistics Assistant	9.80	8
166	90	Field Assistant	9.30	6
166	91	Medic	9.20	6
166	92	Equipment Handler	9.30	6
166	93	Team Liaison	9.20	6
166	94	Announcer	9.30	6
167	90	Field Assistant	9.30	6
167	91	Medic	9.20	6
167	92	Equipment Handler	9.30	6
167	93	Team Liaison	9.20	6
167	94	Announcer	9.30	6
168	90	Field Assistant	9.40	6
168	91	Medic	9.30	6
168	92	Equipment Handler	9.40	6
168	93	Team Liaison	9.30	6
168	94	Announcer	9.40	6
169	90	Field Assistant	9.40	6
169	91	Medic	9.30	6
169	92	Equipment Handler	9.40	6
169	93	Team Liaison	9.30	6
169	94	Announcer	9.40	6
170	90	Field Assistant	9.50	6
170	91	Medic	9.40	6
170	92	Equipment Handler	9.50	6
170	93	Team Liaison	9.40	6
170	94	Announcer	9.50	6
171	90	Field Assistant	9.50	6
171	91	Medic	9.40	6
171	92	Equipment Handler	9.50	6
171	93	Team Liaison	9.40	6
171	94	Announcer	9.50	6
172	90	Field Assistant	9.60	6
172	91	Medic	9.50	6
172	92	Equipment Handler	9.60	6
172	93	Team Liaison	9.50	6
172	94	Announcer	9.60	6
173	90	Field Assistant	9.60	6
173	91	Medic	9.50	6
173	92	Equipment Handler	9.60	6
173	93	Team Liaison	9.50	6
173	94	Announcer	9.60	6
174	90	Field Assistant	9.60	6
174	91	Medic	9.50	6
174	92	Equipment Handler	9.60	6
174	93	Team Liaison	9.50	6
174	94	Announcer	9.60	6
175	90	Field Assistant	9.60	6
175	91	Medic	9.50	6
175	92	Equipment Handler	9.60	6
175	93	Team Liaison	9.50	6
175	94	Announcer	9.60	6
176	90	Field Assistant	9.70	6
176	91	Medic	9.60	6
176	92	Equipment Handler	9.70	6
176	93	Team Liaison	9.60	6
176	94	Announcer	9.70	6
177	90	Field Assistant	9.70	6
177	91	Medic	9.60	6
177	92	Equipment Handler	9.70	6
177	93	Team Liaison	9.60	6
177	94	Announcer	9.70	6
178	90	Field Assistant	9.80	6
178	91	Medic	9.70	6
178	92	Equipment Handler	9.80	6
178	93	Team Liaison	9.70	6
178	94	Announcer	9.80	6
179	90	Field Assistant	9.80	6
179	91	Medic	9.70	6
179	92	Equipment Handler	9.80	6
179	93	Team Liaison	9.70	6
179	94	Announcer	9.80	6
180	90	Field Assistant	9.90	6
180	91	Medic	9.80	6
180	92	Equipment Handler	9.90	6
180	93	Team Liaison	9.80	6
180	94	Announcer	9.90	6
181	95	Scoreboard Operator	9.20	5
181	96	Timekeeper	9.10	5
181	97	Medic	9.20	5
181	98	Equipment Handler	9.10	5
182	95	Scoreboard Operator	9.20	5
182	96	Timekeeper	9.10	5
182	97	Medic	9.20	5
182	98	Equipment Handler	9.10	5
183	95	Scoreboard Operator	9.30	5
183	96	Timekeeper	9.20	5
183	97	Medic	9.30	5
183	98	Equipment Handler	9.20	5
184	95	Scoreboard Operator	9.30	5
184	96	Timekeeper	9.20	5
184	97	Medic	9.30	5
184	98	Equipment Handler	9.20	5
185	95	Scoreboard Operator	9.40	5
185	96	Timekeeper	9.30	5
185	97	Medic	9.40	5
185	98	Equipment Handler	9.30	5
186	95	Scoreboard Operator	9.40	5
186	96	Timekeeper	9.30	5
186	97	Medic	9.40	5
186	98	Equipment Handler	9.30	5
187	95	Scoreboard Operator	9.50	5
187	96	Timekeeper	9.40	5
187	97	Medic	9.50	5
187	98	Equipment Handler	9.40	5
188	95	Scoreboard Operator	9.50	5
188	96	Timekeeper	9.40	5
188	97	Medic	9.50	5
188	98	Equipment Handler	9.40	5
189	95	Scoreboard Operator	9.60	5
189	96	Timekeeper	9.50	5
189	97	Medic	9.60	5
189	98	Equipment Handler	9.50	5
190	95	Scoreboard Operator	9.60	5
190	96	Timekeeper	9.50	5
190	97	Medic	9.60	5
190	98	Equipment Handler	9.50	5
191	95	Scoreboard Operator	9.60	5
191	96	Timekeeper	9.50	5
191	97	Medic	9.60	5
191	98	Equipment Handler	9.50	5
192	95	Scoreboard Operator	9.70	5
192	96	Timekeeper	9.60	5
192	97	Medic	9.70	5
192	98	Equipment Handler	9.60	5
193	95	Scoreboard Operator	9.70	5
193	96	Timekeeper	9.60	5
193	97	Medic	9.70	5
193	98	Equipment Handler	9.60	5
194	95	Scoreboard Operator	9.80	5
194	96	Timekeeper	9.70	5
194	97	Medic	9.80	5
194	98	Equipment Handler	9.70	5
195	95	Scoreboard Operator	9.80	5
195	96	Timekeeper	9.70	5
195	97	Medic	9.80	5
195	98	Equipment Handler	9.70	5
196	99	Score Recorder	9.20	4
196	100	Medic	9.10	4
196	41	Net Assistant	9.20	4
196	42	Ball Retriever	9.10	4
197	99	Score Recorder	9.20	4
197	100	Medic	9.10	4
197	41	Net Assistant	9.20	4
197	42	Ball Retriever	9.10	4
198	99	Score Recorder	9.30	4
198	100	Medic	9.20	4
198	41	Net Assistant	9.30	4
198	42	Ball Retriever	9.20	4
199	99	Score Recorder	9.30	4
199	100	Medic	9.20	4
199	41	Net Assistant	9.30	4
199	42	Ball Retriever	9.20	4
200	99	Score Recorder	9.40	4
200	100	Medic	9.30	4
200	41	Net Assistant	9.40	4
200	42	Ball Retriever	9.30	4
201	99	Score Recorder	9.40	4
201	100	Medic	9.30	4
201	41	Net Assistant	9.40	4
201	42	Ball Retriever	9.30	4
202	99	Score Recorder	9.50	4
202	100	Medic	9.40	4
202	41	Net Assistant	9.50	4
202	42	Ball Retriever	9.40	4
203	99	Score Recorder	9.50	4
203	100	Medic	9.40	4
203	41	Net Assistant	9.50	4
203	42	Ball Retriever	9.40	4
204	99	Score Recorder	9.60	4
204	100	Medic	9.50	4
204	41	Net Assistant	9.60	4
204	42	Ball Retriever	9.50	4
205	99	Score Recorder	9.60	4
205	100	Medic	9.50	4
205	41	Net Assistant	9.60	4
205	42	Ball Retriever	9.50	4
206	99	Score Recorder	9.60	4
206	100	Medic	9.50	4
206	41	Net Assistant	9.60	4
206	42	Ball Retriever	9.50	4
207	99	Score Recorder	9.70	4
207	100	Medic	9.60	4
207	41	Net Assistant	9.70	4
207	42	Ball Retriever	9.60	4
208	99	Score Recorder	9.70	4
208	100	Medic	9.60	4
208	41	Net Assistant	9.70	4
208	42	Ball Retriever	9.60	4
209	99	Score Recorder	9.80	4
209	100	Medic	9.70	4
209	41	Net Assistant	9.80	4
209	42	Ball Retriever	9.70	4
210	99	Score Recorder	9.80	4
210	100	Medic	9.70	4
210	41	Net Assistant	9.80	4
210	42	Ball Retriever	9.70	4
211	43	Scorekeeper	9.20	4
211	44	Medic	9.10	4
211	45	Boundary Staff	9.20	4
211	46	Player Liaison	9.10	4
212	43	Scorekeeper	9.20	4
212	44	Medic	9.10	4
212	45	Boundary Staff	9.20	4
212	46	Player Liaison	9.10	4
213	43	Scorekeeper	9.30	4
213	44	Medic	9.20	4
213	45	Boundary Staff	9.30	4
213	46	Player Liaison	9.20	4
214	43	Scorekeeper	9.30	4
214	44	Medic	9.20	4
214	45	Boundary Staff	9.30	4
214	46	Player Liaison	9.20	4
215	43	Scorekeeper	9.40	4
215	44	Medic	9.30	4
215	45	Boundary Staff	9.40	4
215	46	Player Liaison	9.30	4
216	43	Scorekeeper	9.40	4
216	44	Medic	9.30	4
216	45	Boundary Staff	9.40	4
216	46	Player Liaison	9.30	4
217	43	Scorekeeper	9.50	4
217	44	Medic	9.40	4
217	45	Boundary Staff	9.50	4
217	46	Player Liaison	9.40	4
218	43	Scorekeeper	9.50	4
218	44	Medic	9.40	4
218	45	Boundary Staff	9.50	4
218	46	Player Liaison	9.40	4
219	43	Scorekeeper	9.60	4
219	44	Medic	9.50	4
219	45	Boundary Staff	9.60	4
219	46	Player Liaison	9.50	4
220	43	Scorekeeper	9.60	4
220	44	Medic	9.50	4
220	45	Boundary Staff	9.60	4
220	46	Player Liaison	9.50	4
221	43	Scorekeeper	9.60	4
221	44	Medic	9.50	4
221	45	Boundary Staff	9.60	4
221	46	Player Liaison	9.50	4
222	43	Scorekeeper	9.70	4
222	44	Medic	9.60	4
222	45	Boundary Staff	9.70	4
222	46	Player Liaison	9.60	4
223	43	Scorekeeper	9.70	4
223	44	Medic	9.60	4
223	45	Boundary Staff	9.70	4
223	46	Player Liaison	9.60	4
224	43	Scorekeeper	9.80	4
224	44	Medic	9.70	4
224	45	Boundary Staff	9.80	4
224	46	Player Liaison	9.70	4
225	43	Scorekeeper	9.80	4
225	44	Medic	9.70	4
225	45	Boundary Staff	9.80	4
225	46	Player Liaison	9.70	4
\.


--
-- TOC entry 5158 (class 0 OID 18317)
-- Dependencies: 235
-- Data for Name: team_sport_matches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.team_sport_matches (t_match_id, tournament_id, sport_name, team1_id, team2_id, venue_id, match_type, match_status, date, start_time) FROM stdin;
1	1	Cricket	9	10	1	Group Stage	Finished	2022-11-02	09:00:00
2	1	Cricket	9	11	1	Group Stage	Finished	2022-11-02	14:30:00
3	1	Cricket	9	12	2	Group Stage	Finished	2022-11-03	09:00:00
4	1	Cricket	10	11	2	Group Stage	Finished	2022-11-03	14:30:00
5	1	Cricket	10	12	1	Group Stage	Finished	2022-11-04	09:00:00
6	1	Cricket	11	12	1	Group Stage	Finished	2022-11-04	14:30:00
7	1	Cricket	13	14	2	Group Stage	Finished	2022-11-02	09:00:00
8	1	Cricket	13	15	2	Group Stage	Finished	2022-11-02	14:30:00
9	1	Cricket	13	16	1	Group Stage	Finished	2022-11-03	09:00:00
10	1	Cricket	14	15	1	Group Stage	Finished	2022-11-03	14:30:00
11	1	Cricket	14	16	2	Group Stage	Finished	2022-11-04	09:00:00
12	1	Cricket	15	16	2	Group Stage	Finished	2022-11-04	14:30:00
13	1	Cricket	9	14	1	Semi-Final	Finished	2022-11-05	09:00:00
14	1	Cricket	13	10	2	Semi-Final	Finished	2022-11-05	14:30:00
15	1	Cricket	9	10	1	Final	Finished	2022-11-06	10:00:00
16	1	Football	1	2	3	Group Stage	Finished	2022-11-02	09:30:00
17	1	Football	1	3	3	Group Stage	Finished	2022-11-02	11:30:00
18	1	Football	1	4	4	Group Stage	Finished	2022-11-02	13:30:00
19	1	Football	2	3	3	Group Stage	Finished	2022-11-03	09:30:00
20	1	Football	2	4	4	Group Stage	Finished	2022-11-03	11:30:00
21	1	Football	3	4	3	Group Stage	Finished	2022-11-03	13:30:00
22	1	Football	5	6	4	Group Stage	Finished	2022-11-04	09:30:00
23	1	Football	5	7	3	Group Stage	Finished	2022-11-04	11:30:00
24	1	Football	5	8	4	Group Stage	Finished	2022-11-04	13:30:00
25	1	Football	6	7	3	Group Stage	Finished	2022-11-04	15:30:00
26	1	Football	6	8	4	Group Stage	Finished	2022-11-04	17:30:00
27	1	Football	7	8	3	Group Stage	Finished	2022-11-04	19:30:00
28	1	Football	1	6	3	Semi-Final	Finished	2022-11-05	10:00:00
29	1	Football	5	2	4	Semi-Final	Finished	2022-11-05	13:00:00
30	1	Football	1	2	3	Final	Finished	2022-11-06	16:00:00
31	1	Basketball	17	18	5	Group Stage	Finished	2022-11-02	09:00:00
32	1	Basketball	17	19	5	Group Stage	Finished	2022-11-02	10:30:00
33	1	Basketball	17	20	6	Group Stage	Finished	2022-11-02	12:00:00
34	1	Basketball	18	19	6	Group Stage	Finished	2022-11-03	09:00:00
35	1	Basketball	18	20	5	Group Stage	Finished	2022-11-03	10:30:00
36	1	Basketball	19	20	6	Group Stage	Finished	2022-11-03	12:00:00
37	1	Basketball	21	22	5	Group Stage	Finished	2022-11-04	09:00:00
38	1	Basketball	21	23	6	Group Stage	Finished	2022-11-04	10:30:00
39	1	Basketball	21	24	6	Group Stage	Finished	2022-11-04	12:00:00
40	1	Basketball	22	23	5	Group Stage	Finished	2022-11-04	13:30:00
41	1	Basketball	22	24	6	Group Stage	Finished	2022-11-04	15:00:00
42	1	Basketball	23	24	5	Group Stage	Finished	2022-11-04	16:30:00
43	1	Basketball	17	22	5	Semi-Final	Finished	2022-11-05	09:00:00
44	1	Basketball	21	18	6	Semi-Final	Finished	2022-11-05	11:00:00
45	1	Basketball	17	18	5	Final	Finished	2022-11-06	14:00:00
46	1	Volleyball	25	26	7	Group Stage	Finished	2022-11-02	09:00:00
47	1	Volleyball	25	27	7	Group Stage	Finished	2022-11-02	10:15:00
48	1	Volleyball	25	28	8	Group Stage	Finished	2022-11-02	11:30:00
49	1	Volleyball	26	27	8	Group Stage	Finished	2022-11-03	09:00:00
50	1	Volleyball	26	28	7	Group Stage	Finished	2022-11-03	10:15:00
51	1	Volleyball	27	28	8	Group Stage	Finished	2022-11-03	11:30:00
52	1	Volleyball	29	30	7	Group Stage	Finished	2022-11-04	09:00:00
53	1	Volleyball	29	31	8	Group Stage	Finished	2022-11-04	10:15:00
54	1	Volleyball	29	32	8	Group Stage	Finished	2022-11-04	11:30:00
55	1	Volleyball	30	31	7	Group Stage	Finished	2022-11-04	12:45:00
56	1	Volleyball	30	32	8	Group Stage	Finished	2022-11-04	14:00:00
57	1	Volleyball	31	32	7	Group Stage	Finished	2022-11-04	15:15:00
58	1	Volleyball	25	30	7	Semi-Final	Finished	2022-11-05	09:00:00
59	1	Volleyball	29	26	8	Semi-Final	Finished	2022-11-05	10:30:00
60	1	Volleyball	25	26	7	Final	Finished	2022-11-06	13:00:00
61	1	Kabaddi	33	34	9	Group Stage	Finished	2022-11-02	09:00:00
62	1	Kabaddi	33	35	9	Group Stage	Finished	2022-11-02	10:00:00
63	1	Kabaddi	33	36	10	Group Stage	Finished	2022-11-02	11:00:00
64	1	Kabaddi	34	35	9	Group Stage	Finished	2022-11-03	09:00:00
65	1	Kabaddi	34	36	9	Group Stage	Finished	2022-11-03	10:00:00
66	1	Kabaddi	35	36	10	Group Stage	Finished	2022-11-03	11:00:00
67	1	Kabaddi	37	38	9	Group Stage	Finished	2022-11-04	09:00:00
68	1	Kabaddi	37	39	9	Group Stage	Finished	2022-11-04	10:00:00
69	1	Kabaddi	37	40	10	Group Stage	Finished	2022-11-04	11:00:00
70	1	Kabaddi	38	39	10	Group Stage	Finished	2022-11-04	12:00:00
71	1	Kabaddi	38	40	9	Group Stage	Finished	2022-11-04	13:00:00
72	1	Kabaddi	39	40	9	Group Stage	Finished	2022-11-04	14:00:00
73	1	Kabaddi	33	38	9	Semi-Final	Finished	2022-11-05	09:00:00
74	1	Kabaddi	37	34	10	Semi-Final	Finished	2022-11-05	10:00:00
75	1	Kabaddi	33	34	9	Final	Finished	2022-11-06	12:00:00
76	2	Cricket	9	10	1	Group Stage	Finished	2023-10-25	09:00:00
77	2	Cricket	9	11	1	Group Stage	Finished	2023-10-25	14:30:00
78	2	Cricket	9	12	2	Group Stage	Finished	2023-10-26	09:00:00
79	2	Cricket	10	11	2	Group Stage	Finished	2023-10-26	14:30:00
80	2	Cricket	10	12	1	Group Stage	Finished	2023-10-27	09:00:00
81	2	Cricket	11	12	1	Group Stage	Finished	2023-10-27	14:30:00
82	2	Cricket	13	14	2	Group Stage	Finished	2023-10-25	09:00:00
83	2	Cricket	13	15	2	Group Stage	Finished	2023-10-25	14:30:00
84	2	Cricket	13	16	1	Group Stage	Finished	2023-10-26	09:00:00
85	2	Cricket	14	15	1	Group Stage	Finished	2023-10-26	14:30:00
86	2	Cricket	14	16	2	Group Stage	Finished	2023-10-27	09:00:00
87	2	Cricket	15	16	2	Group Stage	Finished	2023-10-27	14:30:00
88	2	Cricket	9	14	1	Semi-Final	Finished	2023-10-28	09:00:00
89	2	Cricket	13	10	2	Semi-Final	Finished	2023-10-28	14:30:00
90	2	Cricket	9	10	1	Final	Finished	2023-10-29	10:00:00
91	2	Football	1	2	3	Group Stage	Finished	2023-10-25	09:30:00
92	2	Football	1	3	3	Group Stage	Finished	2023-10-25	11:30:00
93	2	Football	1	4	4	Group Stage	Finished	2023-10-25	13:30:00
94	2	Football	2	3	3	Group Stage	Finished	2023-10-26	09:30:00
95	2	Football	2	4	4	Group Stage	Finished	2023-10-26	11:30:00
96	2	Football	3	4	3	Group Stage	Finished	2023-10-26	13:30:00
97	2	Football	5	6	4	Group Stage	Finished	2023-10-27	09:30:00
98	2	Football	5	7	3	Group Stage	Finished	2023-10-27	11:30:00
99	2	Football	5	8	4	Group Stage	Finished	2023-10-27	13:30:00
100	2	Football	6	7	3	Group Stage	Finished	2023-10-27	15:30:00
101	2	Football	6	8	4	Group Stage	Finished	2023-10-27	17:30:00
102	2	Football	7	8	3	Group Stage	Finished	2023-10-27	19:30:00
103	2	Football	1	6	3	Semi-Final	Finished	2023-10-28	10:00:00
104	2	Football	5	2	4	Semi-Final	Finished	2023-10-28	13:00:00
105	2	Football	1	2	3	Final	Finished	2023-10-29	16:00:00
106	2	Basketball	17	18	5	Group Stage	Finished	2023-10-25	09:00:00
107	2	Basketball	17	19	5	Group Stage	Finished	2023-10-25	10:30:00
108	2	Basketball	17	20	6	Group Stage	Finished	2023-10-25	12:00:00
109	2	Basketball	18	19	6	Group Stage	Finished	2023-10-26	09:00:00
110	2	Basketball	18	20	5	Group Stage	Finished	2023-10-26	10:30:00
111	2	Basketball	19	20	6	Group Stage	Finished	2023-10-26	12:00:00
112	2	Basketball	21	22	5	Group Stage	Finished	2023-10-27	09:00:00
113	2	Basketball	21	23	6	Group Stage	Finished	2023-10-27	10:30:00
114	2	Basketball	21	24	6	Group Stage	Finished	2023-10-27	12:00:00
115	2	Basketball	22	23	5	Group Stage	Finished	2023-10-27	13:30:00
116	2	Basketball	22	24	6	Group Stage	Finished	2023-10-27	15:00:00
117	2	Basketball	23	24	5	Group Stage	Finished	2023-10-27	16:30:00
118	2	Basketball	17	22	5	Semi-Final	Finished	2023-10-28	09:00:00
119	2	Basketball	21	18	6	Semi-Final	Finished	2023-10-28	11:00:00
120	2	Basketball	17	18	5	Final	Finished	2023-10-29	14:00:00
121	2	Volleyball	25	26	7	Group Stage	Finished	2023-10-25	09:00:00
122	2	Volleyball	25	27	7	Group Stage	Finished	2023-10-25	10:15:00
123	2	Volleyball	25	28	8	Group Stage	Finished	2023-10-25	11:30:00
124	2	Volleyball	26	27	8	Group Stage	Finished	2023-10-26	09:00:00
125	2	Volleyball	26	28	7	Group Stage	Finished	2023-10-26	10:15:00
126	2	Volleyball	27	28	8	Group Stage	Finished	2023-10-26	11:30:00
127	2	Volleyball	29	30	7	Group Stage	Finished	2023-10-27	09:00:00
128	2	Volleyball	29	31	8	Group Stage	Finished	2023-10-27	10:15:00
129	2	Volleyball	29	32	8	Group Stage	Finished	2023-10-27	11:30:00
130	2	Volleyball	30	31	7	Group Stage	Finished	2023-10-27	12:45:00
131	2	Volleyball	30	32	8	Group Stage	Finished	2023-10-27	14:00:00
132	2	Volleyball	31	32	7	Group Stage	Finished	2023-10-27	15:15:00
133	2	Volleyball	25	30	7	Semi-Final	Finished	2023-10-28	09:00:00
134	2	Volleyball	29	26	8	Semi-Final	Finished	2023-10-28	10:30:00
135	2	Volleyball	25	26	7	Final	Finished	2023-10-29	13:00:00
136	2	Kabaddi	33	34	9	Group Stage	Finished	2023-10-25	09:00:00
137	2	Kabaddi	33	35	9	Group Stage	Finished	2023-10-25	10:00:00
138	2	Kabaddi	33	36	10	Group Stage	Finished	2023-10-25	11:00:00
139	2	Kabaddi	34	35	9	Group Stage	Finished	2023-10-26	09:00:00
140	2	Kabaddi	34	36	9	Group Stage	Finished	2023-10-26	10:00:00
141	2	Kabaddi	35	36	10	Group Stage	Finished	2023-10-26	11:00:00
142	2	Kabaddi	37	38	9	Group Stage	Finished	2023-10-27	09:00:00
143	2	Kabaddi	37	39	9	Group Stage	Finished	2023-10-27	10:00:00
144	2	Kabaddi	37	40	10	Group Stage	Finished	2023-10-27	11:00:00
145	2	Kabaddi	38	39	10	Group Stage	Finished	2023-10-27	12:00:00
146	2	Kabaddi	38	40	9	Group Stage	Finished	2023-10-27	13:00:00
147	2	Kabaddi	39	40	9	Group Stage	Finished	2023-10-27	14:00:00
148	2	Kabaddi	33	38	9	Semi-Final	Finished	2023-10-28	09:00:00
149	2	Kabaddi	37	34	10	Semi-Final	Finished	2023-10-28	10:00:00
150	2	Kabaddi	33	34	9	Final	Finished	2023-10-29	12:00:00
151	3	Cricket	9	10	1	Group Stage	Finished	2024-11-06	09:00:00
152	3	Cricket	9	11	1	Group Stage	Finished	2024-11-06	14:30:00
153	3	Cricket	9	12	2	Group Stage	Finished	2024-11-07	09:00:00
154	3	Cricket	10	11	2	Group Stage	Finished	2024-11-07	14:30:00
155	3	Cricket	10	12	1	Group Stage	Finished	2024-11-08	09:00:00
156	3	Cricket	11	12	1	Group Stage	Finished	2024-11-08	14:30:00
157	3	Cricket	13	14	2	Group Stage	Finished	2024-11-06	09:00:00
158	3	Cricket	13	15	2	Group Stage	Finished	2024-11-06	14:30:00
159	3	Cricket	13	16	1	Group Stage	Finished	2024-11-07	09:00:00
160	3	Cricket	14	15	1	Group Stage	Finished	2024-11-07	14:30:00
161	3	Cricket	14	16	2	Group Stage	Finished	2024-11-08	09:00:00
162	3	Cricket	15	16	2	Group Stage	Finished	2024-11-08	14:30:00
163	3	Cricket	9	14	1	Semi-Final	Finished	2024-11-09	09:00:00
164	3	Cricket	13	11	2	Semi-Final	Finished	2024-11-09	14:30:00
165	3	Cricket	9	11	1	Final	Finished	2024-11-10	10:00:00
166	3	Football	1	2	3	Group Stage	Finished	2024-11-06	09:30:00
167	3	Football	1	3	3	Group Stage	Finished	2024-11-06	11:30:00
168	3	Football	1	4	4	Group Stage	Finished	2024-11-06	13:30:00
169	3	Football	2	3	3	Group Stage	Finished	2024-11-07	09:30:00
170	3	Football	2	4	4	Group Stage	Finished	2024-11-07	11:30:00
171	3	Football	3	4	3	Group Stage	Finished	2024-11-07	13:30:00
172	3	Football	5	6	4	Group Stage	Finished	2024-11-08	09:30:00
173	3	Football	5	7	3	Group Stage	Finished	2024-11-08	11:30:00
174	3	Football	5	8	4	Group Stage	Finished	2024-11-08	13:30:00
175	3	Football	6	7	3	Group Stage	Finished	2024-11-08	15:30:00
176	3	Football	6	8	4	Group Stage	Finished	2024-11-08	17:30:00
177	3	Football	7	8	3	Group Stage	Finished	2024-11-08	19:30:00
178	3	Football	1	6	3	Semi-Final	Finished	2024-11-09	10:00:00
179	3	Football	5	3	4	Semi-Final	Finished	2024-11-09	13:00:00
180	3	Football	1	3	3	Final	Finished	2024-11-10	16:00:00
181	3	Basketball	17	18	5	Group Stage	Finished	2024-11-06	09:00:00
182	3	Basketball	17	19	5	Group Stage	Finished	2024-11-06	10:30:00
183	3	Basketball	17	20	6	Group Stage	Finished	2024-11-06	12:00:00
184	3	Basketball	18	19	6	Group Stage	Finished	2024-11-07	09:00:00
185	3	Basketball	18	20	5	Group Stage	Finished	2024-11-07	10:30:00
186	3	Basketball	19	20	6	Group Stage	Finished	2024-11-07	12:00:00
187	3	Basketball	21	22	5	Group Stage	Finished	2024-11-08	09:00:00
188	3	Basketball	21	23	6	Group Stage	Finished	2024-11-08	10:30:00
189	3	Basketball	21	24	6	Group Stage	Finished	2024-11-08	12:00:00
190	3	Basketball	22	23	5	Group Stage	Finished	2024-11-08	13:30:00
191	3	Basketball	22	24	6	Group Stage	Finished	2024-11-08	15:00:00
192	3	Basketball	23	24	5	Group Stage	Finished	2024-11-08	16:30:00
193	3	Basketball	17	22	5	Semi-Final	Finished	2024-11-09	09:00:00
194	3	Basketball	21	19	6	Semi-Final	Finished	2024-11-09	11:00:00
195	3	Basketball	17	19	5	Final	Finished	2024-11-10	14:00:00
196	3	Volleyball	25	26	7	Group Stage	Finished	2024-11-06	09:00:00
197	3	Volleyball	25	27	7	Group Stage	Finished	2024-11-06	10:15:00
198	3	Volleyball	25	28	8	Group Stage	Finished	2024-11-06	11:30:00
199	3	Volleyball	26	27	8	Group Stage	Finished	2024-11-07	09:00:00
200	3	Volleyball	26	28	7	Group Stage	Finished	2024-11-07	10:15:00
201	3	Volleyball	27	28	8	Group Stage	Finished	2024-11-07	11:30:00
202	3	Volleyball	29	30	7	Group Stage	Finished	2024-11-08	09:00:00
203	3	Volleyball	29	31	8	Group Stage	Finished	2024-11-08	10:15:00
204	3	Volleyball	29	32	8	Group Stage	Finished	2024-11-08	11:30:00
205	3	Volleyball	30	31	7	Group Stage	Finished	2024-11-08	12:45:00
206	3	Volleyball	30	32	8	Group Stage	Finished	2024-11-08	14:00:00
207	3	Volleyball	31	32	7	Group Stage	Finished	2024-11-08	15:15:00
208	3	Volleyball	25	30	7	Semi-Final	Finished	2024-11-09	09:00:00
209	3	Volleyball	29	27	8	Semi-Final	Finished	2024-11-09	10:30:00
210	3	Volleyball	25	27	7	Final	Finished	2024-11-10	13:00:00
211	3	Kabaddi	33	34	9	Group Stage	Finished	2024-11-06	09:00:00
212	3	Kabaddi	33	35	9	Group Stage	Finished	2024-11-06	10:00:00
213	3	Kabaddi	33	36	10	Group Stage	Finished	2024-11-06	11:00:00
214	3	Kabaddi	34	35	9	Group Stage	Finished	2024-11-07	09:00:00
215	3	Kabaddi	34	36	9	Group Stage	Finished	2024-11-07	10:00:00
216	3	Kabaddi	35	36	10	Group Stage	Finished	2024-11-07	11:00:00
217	3	Kabaddi	37	38	9	Group Stage	Finished	2024-11-08	09:00:00
218	3	Kabaddi	37	39	9	Group Stage	Finished	2024-11-08	10:00:00
219	3	Kabaddi	37	40	10	Group Stage	Finished	2024-11-08	11:00:00
220	3	Kabaddi	38	39	10	Group Stage	Finished	2024-11-08	12:00:00
221	3	Kabaddi	38	40	9	Group Stage	Finished	2024-11-08	13:00:00
222	3	Kabaddi	39	40	9	Group Stage	Finished	2024-11-08	14:00:00
223	3	Kabaddi	33	38	9	Semi-Final	Finished	2024-11-09	09:00:00
224	3	Kabaddi	37	35	10	Semi-Final	Finished	2024-11-09	10:00:00
225	3	Kabaddi	33	35	9	Final	Finished	2024-11-10	12:00:00
226	4	Cricket	9	10	1	Group Stage	Scheduled	2025-11-05	09:00:00
227	4	Cricket	9	11	1	Group Stage	Scheduled	2025-11-05	14:30:00
228	4	Cricket	9	12	2	Group Stage	Scheduled	2025-11-06	09:00:00
229	4	Cricket	10	11	2	Group Stage	Scheduled	2025-11-06	14:30:00
230	4	Cricket	10	12	1	Group Stage	Scheduled	2025-11-07	09:00:00
231	4	Cricket	11	12	1	Group Stage	Scheduled	2025-11-07	14:30:00
232	4	Cricket	13	14	2	Group Stage	Scheduled	2025-11-05	09:00:00
233	4	Cricket	13	15	2	Group Stage	Scheduled	2025-11-05	14:30:00
234	4	Cricket	13	16	1	Group Stage	Scheduled	2025-11-06	09:00:00
235	4	Cricket	14	15	1	Group Stage	Scheduled	2025-11-06	14:30:00
236	4	Cricket	14	16	2	Group Stage	Scheduled	2025-11-07	09:00:00
237	4	Cricket	15	16	2	Group Stage	Scheduled	2025-11-07	14:30:00
238	4	Football	1	2	3	Group Stage	Scheduled	2025-11-05	09:30:00
239	4	Football	1	3	3	Group Stage	Scheduled	2025-11-05	11:30:00
240	4	Football	1	4	4	Group Stage	Scheduled	2025-11-05	13:30:00
241	4	Football	2	3	3	Group Stage	Scheduled	2025-11-06	09:30:00
242	4	Football	2	4	4	Group Stage	Scheduled	2025-11-06	11:30:00
243	4	Football	3	4	3	Group Stage	Scheduled	2025-11-06	13:30:00
244	4	Football	5	6	4	Group Stage	Scheduled	2025-11-07	09:30:00
245	4	Football	5	7	3	Group Stage	Scheduled	2025-11-07	11:30:00
246	4	Football	5	8	4	Group Stage	Scheduled	2025-11-07	13:30:00
247	4	Football	6	7	3	Group Stage	Scheduled	2025-11-08	09:30:00
248	4	Football	6	8	4	Group Stage	Scheduled	2025-11-08	11:30:00
249	4	Football	7	8	3	Group Stage	Scheduled	2025-11-08	13:30:00
250	4	Basketball	17	18	5	Group Stage	Scheduled	2025-11-05	09:00:00
251	4	Basketball	17	19	5	Group Stage	Scheduled	2025-11-05	10:30:00
252	4	Basketball	17	20	6	Group Stage	Scheduled	2025-11-05	12:00:00
253	4	Basketball	18	19	6	Group Stage	Scheduled	2025-11-06	09:00:00
254	4	Basketball	18	20	5	Group Stage	Scheduled	2025-11-06	10:30:00
255	4	Basketball	19	20	6	Group Stage	Scheduled	2025-11-06	12:00:00
256	4	Basketball	21	22	5	Group Stage	Scheduled	2025-11-07	09:00:00
257	4	Basketball	21	23	6	Group Stage	Scheduled	2025-11-07	10:30:00
258	4	Basketball	21	24	6	Group Stage	Scheduled	2025-11-07	12:00:00
259	4	Basketball	22	23	5	Group Stage	Scheduled	2025-11-08	09:00:00
260	4	Basketball	22	24	6	Group Stage	Scheduled	2025-11-08	10:30:00
261	4	Basketball	23	24	5	Group Stage	Scheduled	2025-11-08	12:00:00
262	4	Volleyball	25	26	7	Group Stage	Scheduled	2025-11-05	09:00:00
263	4	Volleyball	25	27	7	Group Stage	Scheduled	2025-11-05	10:15:00
264	4	Volleyball	25	28	8	Group Stage	Scheduled	2025-11-05	11:30:00
265	4	Volleyball	26	27	8	Group Stage	Scheduled	2025-11-06	09:00:00
266	4	Volleyball	26	28	7	Group Stage	Scheduled	2025-11-06	10:15:00
267	4	Volleyball	27	28	8	Group Stage	Scheduled	2025-11-06	11:30:00
268	4	Volleyball	29	30	7	Group Stage	Scheduled	2025-11-07	09:00:00
269	4	Volleyball	29	31	8	Group Stage	Scheduled	2025-11-07	10:15:00
270	4	Volleyball	29	32	8	Group Stage	Scheduled	2025-11-07	11:30:00
271	4	Volleyball	30	31	7	Group Stage	Scheduled	2025-11-08	09:00:00
272	4	Volleyball	30	32	8	Group Stage	Scheduled	2025-11-08	10:15:00
273	4	Volleyball	31	32	7	Group Stage	Scheduled	2025-11-08	11:30:00
274	4	Kabaddi	33	34	9	Group Stage	Scheduled	2025-11-05	09:00:00
275	4	Kabaddi	33	35	9	Group Stage	Scheduled	2025-11-05	10:00:00
276	4	Kabaddi	33	36	10	Group Stage	Scheduled	2025-11-05	11:00:00
277	4	Kabaddi	34	35	9	Group Stage	Scheduled	2025-11-06	09:00:00
278	4	Kabaddi	34	36	9	Group Stage	Scheduled	2025-11-06	10:00:00
279	4	Kabaddi	35	36	10	Group Stage	Scheduled	2025-11-06	11:00:00
280	4	Kabaddi	37	38	9	Group Stage	Scheduled	2025-11-07	09:00:00
281	4	Kabaddi	37	39	9	Group Stage	Scheduled	2025-11-07	10:00:00
282	4	Kabaddi	37	40	10	Group Stage	Scheduled	2025-11-07	11:00:00
283	4	Kabaddi	38	39	10	Group Stage	Scheduled	2025-11-08	09:00:00
284	4	Kabaddi	38	40	9	Group Stage	Scheduled	2025-11-08	10:00:00
285	4	Kabaddi	39	40	9	Group Stage	Scheduled	2025-11-08	11:00:00
\.


--
-- TOC entry 5145 (class 0 OID 18143)
-- Dependencies: 222
-- Data for Name: team_sport_players; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.team_sport_players (player_id, team_id, player_position) FROM stdin;
41	1	Goalkeeper
42	1	Defender
43	1	Defender
44	1	Midfielder
45	1	Midfielder
46	1	Midfielder
47	1	Forward
48	1	Forward
49	1	Forward
50	1	Winger
51	1	Winger
52	2	Goalkeeper
53	2	Defender
54	2	Defender
55	2	Midfielder
56	2	Midfielder
57	2	Midfielder
58	2	Forward
59	2	Forward
60	2	Forward
61	2	Winger
62	2	Winger
63	3	Goalkeeper
64	3	Defender
65	3	Defender
66	3	Midfielder
67	3	Midfielder
68	3	Midfielder
69	3	Forward
70	3	Forward
71	3	Forward
72	3	Winger
73	3	Winger
74	4	Goalkeeper
75	4	Defender
76	4	Defender
77	4	Midfielder
78	4	Midfielder
79	4	Midfielder
80	4	Forward
81	4	Forward
82	4	Forward
83	4	Winger
84	4	Winger
85	5	Goalkeeper
86	5	Defender
87	5	Defender
88	5	Midfielder
89	5	Midfielder
90	5	Midfielder
91	5	Forward
92	5	Forward
93	5	Forward
94	5	Winger
95	5	Winger
96	6	Goalkeeper
97	6	Defender
98	6	Defender
99	6	Midfielder
100	6	Midfielder
101	6	Midfielder
102	6	Forward
103	6	Forward
104	6	Forward
105	6	Winger
106	6	Winger
107	7	Goalkeeper
108	7	Defender
109	7	Defender
110	7	Midfielder
111	7	Midfielder
112	7	Midfielder
113	7	Forward
114	7	Forward
115	7	Forward
116	7	Winger
117	7	Winger
118	8	Goalkeeper
119	8	Defender
120	8	Defender
121	8	Midfielder
122	8	Midfielder
123	8	Midfielder
124	8	Forward
125	8	Forward
126	8	Forward
127	8	Winger
128	8	Winger
129	9	Batsman
130	9	Batsman
131	9	Bowler
132	9	Bowler
133	9	All-Rounder
134	9	Wicket-Keeper
135	9	Captain
136	9	Batsman
137	9	Bowler
138	9	All-Rounder
139	9	Substitute
140	10	Batsman
141	10	Batsman
142	10	Bowler
143	10	Bowler
144	10	All-Rounder
145	10	Wicket-Keeper
146	10	Captain
147	10	Batsman
148	10	Bowler
149	10	All-Rounder
150	10	Substitute
151	11	Batsman
152	11	Batsman
153	11	Bowler
154	11	Bowler
155	11	All-Rounder
156	11	Wicket-Keeper
157	11	Captain
158	11	Batsman
159	11	Bowler
160	11	All-Rounder
161	11	Substitute
162	12	Batsman
163	12	Batsman
164	12	Bowler
165	12	Bowler
166	12	All-Rounder
167	12	Wicket-Keeper
168	12	Captain
169	12	Batsman
170	12	Bowler
171	12	All-Rounder
172	12	Substitute
173	13	Batsman
174	13	Batsman
175	13	Bowler
176	13	Bowler
177	13	All-Rounder
178	13	Wicket-Keeper
179	13	Captain
180	13	Batsman
181	13	Bowler
182	13	All-Rounder
183	13	Substitute
184	14	Batsman
185	14	Batsman
186	14	Bowler
187	14	Bowler
188	14	All-Rounder
189	14	Wicket-Keeper
190	14	Captain
191	14	Batsman
192	14	Bowler
193	14	All-Rounder
194	14	Substitute
195	15	Batsman
196	15	Batsman
197	15	Bowler
198	15	Bowler
199	15	All-Rounder
200	15	Wicket-Keeper
201	15	Captain
202	15	Batsman
203	15	Bowler
204	15	All-Rounder
205	15	Substitute
206	16	Batsman
207	16	Batsman
208	16	Bowler
209	16	Bowler
210	16	All-Rounder
211	16	Wicket-Keeper
212	16	Captain
213	16	Batsman
214	16	Bowler
215	16	All-Rounder
216	16	Substitute
217	17	Point Guard
218	17	Shooting Guard
219	17	Small Forward
220	17	Power Forward
221	17	Center
222	18	Point Guard
223	18	Shooting Guard
224	18	Small Forward
225	18	Power Forward
226	18	Center
227	19	Point Guard
228	19	Shooting Guard
229	19	Small Forward
230	19	Power Forward
231	19	Center
232	20	Point Guard
233	20	Shooting Guard
234	20	Small Forward
235	20	Power Forward
236	20	Center
237	21	Point Guard
238	21	Shooting Guard
239	21	Small Forward
240	21	Power Forward
241	21	Center
242	22	Point Guard
243	22	Shooting Guard
244	22	Small Forward
245	22	Power Forward
246	22	Center
247	23	Point Guard
248	23	Shooting Guard
249	23	Small Forward
250	23	Power Forward
251	23	Center
252	24	Point Guard
253	24	Shooting Guard
254	24	Small Forward
255	24	Power Forward
256	24	Center
257	25	Setter
258	25	Outside Hitter
259	25	Middle Blocker
260	25	Opposite Hitter
261	25	Libero
262	25	Defensive Specialist
263	25	Substitute
264	26	Setter
265	26	Outside Hitter
266	26	Middle Blocker
267	26	Opposite Hitter
268	26	Libero
269	26	Defensive Specialist
270	26	Substitute
271	27	Setter
272	27	Outside Hitter
273	27	Middle Blocker
274	27	Opposite Hitter
275	27	Libero
276	27	Defensive Specialist
277	27	Substitute
278	28	Setter
279	28	Outside Hitter
280	28	Middle Blocker
281	28	Opposite Hitter
282	28	Libero
283	28	Defensive Specialist
284	28	Substitute
285	29	Setter
286	29	Outside Hitter
287	29	Middle Blocker
288	29	Opposite Hitter
289	29	Libero
290	29	Defensive Specialist
291	29	Substitute
292	30	Setter
293	30	Outside Hitter
294	30	Middle Blocker
295	30	Opposite Hitter
296	30	Libero
297	30	Defensive Specialist
298	30	Substitute
299	31	Setter
300	31	Outside Hitter
301	31	Middle Blocker
302	31	Opposite Hitter
303	31	Libero
304	31	Defensive Specialist
305	31	Substitute
306	32	Setter
307	32	Outside Hitter
308	32	Middle Blocker
309	32	Opposite Hitter
310	32	Libero
311	32	Defensive Specialist
312	32	Substitute
313	33	Captain
314	33	Raider
315	33	Raider
316	33	Defender
317	33	Defender
318	33	All-Rounder
319	33	Substitute
320	34	Captain
321	34	Raider
322	34	Raider
323	34	Defender
324	34	Defender
325	34	All-Rounder
326	34	Substitute
327	35	Captain
328	35	Raider
329	35	Raider
330	35	Defender
331	35	Defender
332	35	All-Rounder
333	35	Substitute
334	36	Captain
335	36	Raider
336	36	Raider
337	36	Defender
338	36	Defender
339	36	All-Rounder
340	36	Substitute
341	37	Captain
342	37	Raider
343	37	Raider
344	37	Defender
345	37	Defender
346	37	All-Rounder
347	37	Substitute
348	38	Captain
349	38	Raider
350	38	Raider
351	38	Defender
352	38	Defender
353	38	All-Rounder
354	38	Substitute
355	39	Captain
356	39	Raider
357	39	Raider
358	39	Defender
359	39	Defender
360	39	All-Rounder
361	39	Substitute
362	40	Captain
363	40	Raider
364	40	Raider
365	40	Defender
366	40	Defender
367	40	All-Rounder
368	40	Substitute
\.


--
-- TOC entry 5159 (class 0 OID 18347)
-- Dependencies: 236
-- Data for Name: team_sport_result; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.team_sport_result (t_result_id, t_match_id, winning_team_id, duration, scores, highlights, motm) FROM stdin;
1	1	9	06:00:00	245/8 – 220/9	Strong batting display by Team9	Rohit Patel
2	2	9	06:30:00	275/6 – 260/9	Close finish, disciplined bowling	Kunal Mehta
3	3	9	05:45:00	310/7 – 280/10	Century by opener secured win	Vivek Shah
4	4	10	06:00:00	240/9 – 220/8	Good lower order contribution	Suresh Iyer
5	5	10	06:15:00	300/7 – 275/9	Consistent top-order performance	Naman Joshi
6	6	11	06:00:00	250/9 – 220/10	Bowling attack dominated middle overs	Harsh Vora
7	7	13	06:00:00	270/8 – 240/10	All-round effort from Team13	Amit Chauhan
8	8	13	06:30:00	290/9 – 260/8	Tight bowling in last overs	Deepak Desai
9	9	13	06:00:00	300/7 – 270/9	Strong finish from tailenders	Nirav Shah
10	10	14	06:00:00	265/8 – 260/9	Nail-biting last over thriller	Vikas Reddy
11	11	14	06:15:00	310/8 – 280/10	Explosive batting in death overs	Harish Patel
12	12	15	06:00:00	285/7 – 275/10	Excellent fielding effort by Team15	Anuj Yadav
13	13	9	06:30:00	280/7 – 260/9	Team9 dominated chase confidently	Aarav Trivedi
14	14	10	06:45:00	295/7 – 290/10	Close semi-final battle	Rahul Mehta
15	15	9	07:00:00	305/8 – 270/9	Team9 crowned champions	Jay Patel
16	16	1	02:00:00	3 – 1	Dominant start for Team1	Amit Rana
17	17	1	02:00:00	2 – 0	Clean sheet secured	Nikhil Joshi
18	18	1	02:15:00	4 – 2	High-scoring encounter	Ravi Singh
19	19	2	02:00:00	3 – 1	Solid midfield control	Rahul Desai
20	20	2	02:00:00	2 – 0	Easy win with good defense	Mihir Parmar
21	21	3	02:00:00	2 – 1	Late goal sealed win	Parth Mehta
22	22	5	02:00:00	3 – 2	Quick counterattacks worked well	Vivek Shah
23	23	5	02:00:00	2 – 1	Goal in 89th minute	Ishan Bhatt
24	24	5	02:00:00	4 – 2	Offensive masterclass	Rajesh Nair
25	25	6	02:00:00	2 – 0	Clean defense performance	Harshil Mehta
26	26	6	02:00:00	3 – 1	Clinical finishing	Karan Patel
27	27	7	02:00:00	2 – 0	Strong defensive hold	Pratik Chauhan
28	28	1	02:10:00	3 – 1	Semi-final win for favorites	Yash Patel
29	29	2	02:15:00	2 – 0	Dominant possession win	Aakash Reddy
30	30	1	02:30:00	2 – 1	Champions after intense final	Manan Trivedi
31	31	17	01:15:00	78 – 65	Great 3-point accuracy	Dev Patel
32	32	17	01:20:00	80 – 62	Strong transition offense	Aayush Rana
33	33	17	01:15:00	77 – 69	Team17 remains unbeaten	Harsh Chauhan
34	34	18	01:10:00	72 – 68	Close game till last minute	Tejas Mehta
35	35	18	01:20:00	75 – 70	Strong defense	Sahil Joshi
36	36	19	01:15:00	68 – 60	Aggressive start paid off	Ravi Kumar
37	37	21	01:10:00	70 – 63	Team21 dominated boards	Pranav Patel
38	38	21	01:20:00	74 – 66	Fast-paced match	Meet Shah
39	39	21	01:15:00	80 – 71	Top scorer led the way	Dhruv Desai
40	40	22	01:10:00	72 – 69	Overtime thriller	Yug Joshi
41	41	22	01:20:00	75 – 71	Clutch free throws	Chirag Mehta
42	42	23	01:15:00	70 – 68	Defensive battle	Ritesh Iyer
43	43	17	01:20:00	78 – 69	Team17 stormed into final	Aryan Desai
44	44	18	01:20:00	74 – 70	Upset win in semi-final	Rohan Patel
45	45	17	01:25:00	81 – 73	Team17 wins championship	Dev Mehta
46	46	25	01:10:00	3 – 1	Excellent serves by captain	Rakesh Shah
47	47	25	01:00:00	3 – 0	Straight set win	Aditya Patel
48	48	25	01:15:00	3 – 2	Tight five-setter win	Darshan Mehta
49	49	26	01:00:00	3 – 1	Dominant blocking	Parth Shah
50	50	26	01:15:00	3 – 2	Hard-fought victory	Yuvraj Joshi
51	51	27	01:10:00	3 – 1	Composed team effort	Akash Reddy
52	52	29	01:00:00	3 – 1	Solid teamwork	Rohit Patel
53	53	29	01:10:00	3 – 2	Narrow escape win	Kishan Mehta
54	54	29	01:00:00	3 – 0	Clean sweep	Vijay Nair
55	55	30	01:10:00	3 – 1	Sharp smashes	Tushar Desai
56	56	30	01:10:00	3 – 1	Efficient teamwork	Ravi Parmar
57	57	31	01:00:00	3 – 2	Thriller comeback	Viral Joshi
58	58	25	01:20:00	3 – 1	Smooth semifinal win	Ankit Trivedi
59	59	26	01:15:00	3 – 2	Epic 5-set duel	Raj Patel
60	60	25	01:15:00	3 – 1	Champions of Volleyball	Shivam Shah
61	61	33	01:00:00	45 – 35	Strong raiding start	Vikas Patel
62	62	33	01:00:00	48 – 40	Good team coordination	Manoj Joshi
63	63	33	01:00:00	42 – 38	Controlled defense	Rajesh Shah
64	64	34	01:00:00	41 – 37	Strong finish by Team34	Nitin Mehta
65	65	34	01:00:00	46 – 43	Good second-half comeback	Ronak Patel
66	66	35	01:00:00	39 – 35	Tight game won on raid points	Udit Joshi
67	67	37	01:00:00	43 – 41	Neck-to-neck finish	Pratik Shah
68	68	37	01:00:00	44 – 40	Tactical brilliance	Aman Patel
69	69	37	01:00:00	46 – 39	Captain led the charge	Himanshu Desai
70	70	38	01:00:00	47 – 45	All-out in final raid	Piyush Reddy
71	71	38	01:00:00	44 – 40	Great team synergy	Anand Joshi
72	72	39	01:00:00	48 – 47	One-point thriller	Nirav Mehta
73	73	33	01:05:00	45 – 38	Team33 cruised to final	Karan Shah
74	74	34	01:00:00	43 – 39	Excellent defense in second half	Dhruv Patel
75	75	33	01:10:00	49 – 44	Team33 lifts Kabaddi trophy	Yash Desai
76	76	9	06:00:00	260/8 – 240/9	Blazers open with win	Rohit Patel
77	77	9	06:20:00	270/7 – 260/9	Tight finish	Kunal Mehta
78	78	9	06:00:00	285/8 – 270/10	Aggressive batting display	Dhaval Patel
79	79	10	06:10:00	280/9 – 270/10	Excellent fielding effort	Ramesh Patel
80	80	10	06:00:00	290/8 – 275/10	Team10 stays alive	Ravi Shah
81	81	11	06:00:00	265/9 – 260/9	Close contest	Harish Patel
82	82	13	06:15:00	275/9 – 255/10	All-round performance	Nilesh Patel
83	83	13	06:20:00	300/8 – 270/10	Massive batting show	Kishan Joshi
84	84	13	06:00:00	280/7 – 275/10	Narrow victory	Ravi Desai
85	85	14	06:15:00	295/8 – 280/10	Quick-fire 50 at end	Rakesh Patel
86	86	14	06:00:00	275/7 – 260/9	Disciplined bowling	Ankit Patel
87	87	15	06:15:00	285/8 – 275/10	Tailenders contributed well	Amit Shah
88	88	9	06:30:00	290/8 – 280/9	Semi-final thriller	Yash Mehta
89	89	10	06:40:00	295/8 – 270/9	Convincing semi-final win	Harish Joshi
90	90	10	07:00:00	310/7 – 285/9	Baroda Chargers crowned champs	Nilesh Patel
91	91	1	02:00:00	2 – 1	Upset win early	Kunal Mehta
92	92	1	02:00:00	3 – 1	Recovered with style	Rohan Patel
93	93	1	02:15:00	2 – 0	Clean sheet	Pratik Patel
94	94	2	02:00:00	2 – 0	Baroda dominance	Amit Shah
95	95	2	02:00:00	3 – 1	Comfortable victory	Himanshu Patel
96	96	3	02:00:00	2 – 1	Last-minute goal	Ramesh Shah
97	97	5	02:00:00	3 – 2	Guardians win tight game	Tapan Patel
98	98	5	02:00:00	2 – 1	Gandhinagar on streak	Harsh Mehta
99	99	5	02:00:00	4 – 2	Offensive masterclass	Yash Patel
100	100	6	02:00:00	2 – 1	Hard-fought win	Amit Patel
101	101	6	02:00:00	3 – 2	Sixth straight win	Raj Patel
102	102	7	02:00:00	2 – 1	Anand saves pride	Raj Shah
103	103	1	02:10:00	2 – 1	Semi-final stunner	Tapan Patel
104	104	2	02:15:00	3 – 1	Baroda reaches final	Kunal Mehta
105	105	2	02:30:00	2 – 0	Baroda Warriors lift trophy	Harshil Patel
106	106	17	01:15:00	79 – 65	Dominant start	Rohit Mehta
107	107	17	01:20:00	85 – 70	Big shooting night	Ankit Desai
108	108	17	01:15:00	78 – 68	Strong defense	Jay Parmar
109	109	18	01:10:00	73 – 69	Close finish	Ravi Shah
110	110	18	01:20:00	74 – 70	Defensive recovery	Aakash Desai
111	111	19	01:15:00	69 – 65	Teamwork paid off	Sanjay Joshi
112	112	21	01:10:00	72 – 66	Giants begin strong	Raj Shah
113	113	21	01:20:00	75 – 67	Another clinical win	Amit Chauhan
114	114	21	01:15:00	81 – 72	Powerful playmaking	Rajesh Mehta
115	115	22	01:10:00	73 – 70	Tough game	Yug Desai
116	116	22	01:20:00	75 – 72	Overtime win	Viral Patel
117	117	23	01:15:00	71 – 69	Comeback success	Ritesh Joshi
118	118	17	01:20:00	78 – 70	Semi-final edge	Dev Patel
119	119	18	01:20:00	79 – 71	Bulls cruise to final	Raj Shah
120	120	18	01:25:00	83 – 76	Baroda Bulls take the crown	Neel Joshi
121	121	25	01:10:00	3 – 1	Sharp serves	Karan Patel
122	122	25	01:00:00	3 – 0	Clean sweep	Manav Chauhan
123	123	25	01:15:00	3 – 2	Nail-biter win	Sanjay Patel
124	124	26	01:00:00	3 – 1	Good teamwork	Tejas Joshi
125	125	26	01:15:00	3 – 2	Recovered from deficit	Pratik Joshi
126	126	27	01:10:00	3 – 1	Rockers strong attack	Amit Patel
127	127	29	01:00:00	3 – 1	Giants start dominant	Rohit Patel
128	128	29	01:10:00	3 – 2	Survived close sets	Kishan Mehta
129	129	29	01:00:00	3 – 0	Straight-set victory	Vijay Nair
130	130	30	01:10:00	3 – 1	Powerful smashes	Tushar Desai
131	131	30	01:10:00	3 – 1	Easy finish	Ravi Parmar
132	132	31	01:00:00	3 – 2	Comeback of the day	Viral Joshi
133	133	25	01:20:00	3 – 1	Smooth semi	Ankit Trivedi
134	134	26	01:15:00	3 – 2	Spikers reach final	Raj Patel
135	135	26	01:15:00	3 – 2	New volleyball champs	Sanjay Patel
136	136	33	01:00:00	45 – 35	Strong raiding start	Vikas Patel
137	137	33	01:00:00	46 – 40	Good coordination	Manoj Joshi
138	138	33	01:00:00	43 – 38	Defensive consistency	Rajesh Shah
139	139	34	01:00:00	42 – 37	Baroda steals win	Nitin Mehta
140	140	34	01:00:00	44 – 40	All-out finish	Ronak Patel
141	141	35	01:00:00	41 – 38	Raid points matter	Udit Joshi
142	142	37	01:00:00	44 – 41	Gladiators dominate	Pratik Shah
143	143	37	01:00:00	45 – 42	Tactical brilliance	Aman Patel
144	144	37	01:00:00	46 – 40	Unbeaten run	Himanshu Desai
145	145	38	01:00:00	47 – 45	Narrow win	Piyush Reddy
146	146	38	01:00:00	44 – 40	Balanced effort	Anand Joshi
147	147	39	01:00:00	48 – 47	One-point thriller	Nirav Mehta
148	148	33	01:05:00	46 – 39	Warriors into final	Karan Shah
149	149	34	01:00:00	45 – 41	Bulls unstoppable	Dhruv Patel
150	150	34	01:10:00	47 – 43	Baroda Bulls lift Kabaddi trophy	Yash Desai
151	151	9	06:00:00	250/8 – 240/10	Blazers hold off late charge	Rohit Patel
152	152	9	06:10:00	280/7 – 265/9	Explosive powerplay batting	Kunal Mehta
153	153	9	06:00:00	300/9 – 280/10	Another dominant display	Dhaval Patel
154	154	11	06:00:00	275/8 – 260/10	Tight bowling wins it	Ramesh Patel
155	155	10	06:15:00	310/7 – 295/9	Baroda comeback win	Ravi Shah
156	156	11	06:00:00	260/9 – 255/9	Narrow win with steady bowling	Harish Patel
157	157	13	06:00:00	270/8 – 260/10	Gandhinagar’s calm chase	Nilesh Patel
158	158	13	06:10:00	295/9 – 280/10	Close game, clutch finish	Kishan Joshi
159	159	13	06:00:00	290/7 – 285/9	Very intense game	Ravi Desai
160	160	14	06:00:00	280/9 – 265/10	Great middle-order recovery	Rakesh Patel
161	161	14	06:00:00	300/8 – 290/9	High-scoring thriller	Ankit Patel
162	162	15	06:10:00	285/8 – 275/10	All-rounder performance sealed it	Amit Shah
163	163	9	06:30:00	295/8 – 270/10	Blazers reach final	Yash Mehta
164	164	11	06:40:00	305/7 – 290/10	Tough semi-final	Harish Joshi
165	165	11	07:00:00	320/7 – 295/10	Rajkot Royals crowned champions	Ramesh Patel
166	166	1	02:00:00	2 – 1	Late winner by striker	Rohan Patel
167	167	1	02:00:00	3 – 1	Smooth teamwork from Strikers	Kunal Desai
168	168	1	02:10:00	2 – 0	Clean sheet, controlled tempo	Pratik Patel
169	169	3	02:00:00	1 – 0	Surat Titans grind out win	Amit Shah
170	170	2	02:00:00	2 – 1	Warriors continue form	Himanshu Patel
171	171	3	02:00:00	2 – 1	Late goal sealed win	Ramesh Shah
172	172	5	02:00:00	3 – 2	Tense end-to-end game	Tapan Patel
173	173	5	02:00:00	2 – 0	Tactical domination	Harsh Mehta
174	174	5	02:00:00	3 – 1	Flawless game from Guardians	Yash Patel
175	175	6	02:00:00	3 – 2	Brilliant defensive saves	Amit Patel
176	176	6	02:00:00	2 – 1	Close contest	Raj Patel
177	177	7	02:00:00	2 – 1	Decider for pride	Raj Shah
178	178	1	02:10:00	3 – 1	Semi-final upset averted	Rohan Mehta
179	179	3	02:15:00	2 – 1	Titans into final	Anand Patel
180	180	3	02:30:00	2 – 0	Surat Titans lift the trophy	Himanshu Shah
181	181	17	01:15:00	78 – 65	Eagles start strong	Rohit Mehta
182	182	17	01:20:00	85 – 81	Eagles surprise win	Ankit Desai
183	183	17	01:15:00	80 – 70	Recovered with intensity	Jay Parmar
184	184	19	01:10:00	74 – 69	Close game, strong finish	Ravi Shah
185	185	18	01:20:00	73 – 70	Composed under pressure	Aakash Desai
186	186	19	01:15:00	71 – 68	Raptors’ defense holds up	Sanjay Joshi
187	187	21	01:10:00	76 – 70	Giants roll through group	Raj Shah
188	188	21	01:20:00	74 – 66	Strong playmaking	Amit Chauhan
189	189	21	01:15:00	80 – 72	Dominant run continues	Rajesh Mehta
190	190	22	01:10:00	72 – 69	Hard-fought win	Yug Desai
191	191	22	01:20:00	75 – 72	Close overtime win	Viral Patel
192	192	23	01:15:00	70 – 68	Defensive battle	Ritesh Joshi
193	193	17	01:20:00	82 – 75	Semi-final shocker	Dev Patel
194	194	19	01:20:00	77 – 72	Raptors reach the final	Raj Patel
195	195	19	01:25:00	84 – 79	Rajkot Raptors crowned champions	Ankit Desai
196	196	25	01:10:00	3 – 1	Strong start	Karan Patel
197	197	25	01:00:00	3 – 0	Clean sweep	Manav Chauhan
198	198	25	01:15:00	3 – 2	Edge-of-seat finish	Sanjay Patel
199	199	27	01:00:00	3 – 1	Tight sets	Tejas Joshi
200	200	26	01:15:00	3 – 2	Comeback win	Pratik Joshi
201	201	27	01:10:00	3 – 1	Rockers deliver again	Amit Patel
202	202	29	01:00:00	3 – 2	Five-set thriller win	Rohit Patel
203	203	29	01:10:00	3 – 1	Giants dominate	Kishan Mehta
204	204	29	01:00:00	3 – 0	Straight-set domination	Vijay Nair
205	205	30	01:10:00	3 – 1	Narrow win	Tushar Desai
206	206	30	01:10:00	3 – 1	Vipers unstoppable	Ravi Parmar
207	207	31	01:00:00	3 – 2	Strong comeback	Viral Joshi
208	208	25	01:20:00	3 – 1	Smashers take semi	Ankit Trivedi
209	209	27	01:15:00	3 – 2	Rockers advance	Raj Patel
210	210	27	01:15:00	3 – 1	Rajkot Rockers win championship	Sanjay Patel
211	211	33	01:00:00	45 – 35	Quick raids early	Vikas Patel
212	212	33	01:00:00	48 – 40	Strong all-round show	Manoj Joshi
213	213	33	01:00:00	44 – 38	Defensive control	Rajesh Shah
214	214	35	01:00:00	43 – 39	Close tie-breaker	Nitin Mehta
215	215	34	01:00:00	47 – 42	Late surge wins it	Ronak Patel
216	216	35	01:00:00	40 – 39	Raid points difference	Udit Joshi
217	217	37	01:00:00	44 – 42	Gladiators rise strong	Pratik Shah
218	218	37	01:00:00	46 – 44	Tense endgame	Aman Patel
219	219	37	01:00:00	47 – 43	Perfect strategy	Himanshu Desai
220	220	38	01:00:00	45 – 44	Narrow save	Piyush Reddy
221	221	38	01:00:00	46 – 41	Clean raids	Anand Joshi
222	222	39	01:00:00	47 – 46	Thrilling last raid	Nirav Mehta
223	223	33	01:05:00	45 – 43	Warriors reach final	Karan Shah
224	224	35	01:00:00	44 – 39	Raiders grind it out	Dhruv Patel
225	225	35	01:10:00	48 – 45	Rajkot Raiders lift Kabaddi Trophy	Yash Desai
\.


--
-- TOC entry 5144 (class 0 OID 18128)
-- Dependencies: 221
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teams (team_id, college_id, name, sport_name, captain_name) FROM stdin;
1	1	Ahmedabad Strikers	Football	Rohan Patel
2	2	Baroda Warriors	Football	Kunal Mehta
3	3	Surat Titans	Football	Anshul Patel
4	4	Rajkot Rangers	Football	Pratik Patel
5	5	Gandhinagar Guardians	Football	Himanshu Patel
6	6	Bhavnagar Bulls	Football	Tapan Patel
7	7	Anand Avengers	Football	Amit Patel
8	8	Jamnagar Jaguars	Football	Raj Shah
9	9	Ahmedabad Blazers	Cricket	Rohit Patel
10	10	Baroda Chargers	Cricket	Ramesh Patel
11	11	Rajkot Royals	Cricket	Chirag Mehta
12	12	Surat SuperKings	Cricket	Dhaval Patel
13	13	Gandhinagar Gladiators	Cricket	Nilesh Patel
14	14	Vadodara Vikings	Cricket	Rakesh Patel
15	15	Bhavnagar Bulls	Cricket	Pratik Shah
16	1	Jamnagar Jets	Cricket	Yash Patel
17	2	Ahmedabad Eagles	Basketball	Rohit Mehta
18	3	Baroda Bulls	Basketball	Ankit Desai
19	4	Rajkot Raptors	Basketball	Jay Parmar
20	5	Surat Spartans	Basketball	Neel Joshi
21	6	Gandhinagar Giants	Basketball	Raj Shah
22	7	Vadodara Vultures	Basketball	Aakash Desai
23	8	Jamnagar Jets	Basketball	Sanjay Joshi
24	9	Bhavnagar Blazers	Basketball	Amit Chauhan
25	10	Ahmedabad Smashers	Volleyball	Karan Patel
26	11	Baroda Spikers	Volleyball	Manav Chauhan
27	12	Rajkot Rockers	Volleyball	Tejas Joshi
28	13	Surat Smashers	Volleyball	Sanjay Patel
29	14	Gandhinagar Giants	Volleyball	Pratik Joshi
30	15	Vadodara Vipers	Volleyball	Amit Patel
31	1	Jamnagar Jets	Volleyball	Nikhil Patel
32	2	Bhavnagar Blazers	Volleyball	Ravi Shah
33	3	Ahmedabad Warriors	Kabaddi	Rakesh Patel
34	4	Baroda Bulls	Kabaddi	Nikhil Patel
35	5	Rajkot Raiders	Kabaddi	Rahul Patel
36	6	Surat Stingers	Kabaddi	Nirav Patel
37	7	Gandhinagar Gladiators	Kabaddi	Dhruv Shah
38	8	Vadodara Vikings	Kabaddi	Tapan Patel
39	9	Jamnagar Jaguars	Kabaddi	Sanjay Patel
40	10	Bhavnagar Bulls	Kabaddi	Nilesh Patel
\.


--
-- TOC entry 5166 (class 0 OID 18455)
-- Dependencies: 243
-- Data for Name: tournament_player; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournament_player (tournament_id, player_id, arrival_date, departure_date) FROM stdin;
1	1	2022-10-29	2022-11-07
1	2	2022-10-30	2022-11-08
1	3	2022-10-30	2022-11-09
1	4	2022-10-31	2022-11-08
1	5	2022-10-31	2022-11-09
1	6	2022-10-30	2022-11-07
1	7	2022-10-29	2022-11-08
1	8	2022-10-30	2022-11-09
1	9	2022-10-30	2022-11-07
1	10	2022-10-31	2022-11-08
1	11	2022-10-31	2022-11-09
1	12	2022-10-30	2022-11-08
1	13	2022-10-30	2022-11-09
1	14	2022-10-29	2022-11-08
1	15	2022-10-31	2022-11-07
1	16	2022-10-29	2022-11-09
1	17	2022-10-30	2022-11-08
1	18	2022-10-31	2022-11-08
1	19	2022-10-29	2022-11-09
1	20	2022-10-31	2022-11-07
1	21	2022-10-30	2022-11-08
1	22	2022-10-29	2022-11-09
1	23	2022-10-30	2022-11-07
1	24	2022-10-31	2022-11-09
1	25	2022-10-30	2022-11-08
1	26	2022-10-31	2022-11-07
1	27	2022-10-29	2022-11-09
1	28	2022-10-31	2022-11-08
1	29	2022-10-30	2022-11-07
1	30	2022-10-31	2022-11-09
1	31	2022-10-30	2022-11-08
1	32	2022-10-30	2022-11-08
1	33	2022-10-29	2022-11-07
1	34	2022-10-31	2022-11-09
1	35	2022-10-30	2022-11-08
1	36	2022-10-30	2022-11-09
1	37	2022-10-31	2022-11-08
1	38	2022-10-29	2022-11-09
1	39	2022-10-30	2022-11-07
1	40	2022-10-31	2022-11-09
1	41	2022-10-29	2022-11-08
1	42	2022-10-30	2022-11-07
1	43	2022-10-31	2022-11-09
1	44	2022-10-30	2022-11-08
1	45	2022-10-31	2022-11-09
1	46	2022-10-29	2022-11-07
1	47	2022-10-30	2022-11-09
1	48	2022-10-30	2022-11-08
1	49	2022-10-29	2022-11-07
1	50	2022-10-31	2022-11-08
1	51	2022-10-30	2022-11-09
1	52	2022-10-31	2022-11-08
1	53	2022-10-30	2022-11-09
1	54	2022-10-29	2022-11-07
1	55	2022-10-30	2022-11-08
1	56	2022-10-30	2022-11-09
1	57	2022-10-29	2022-11-07
1	58	2022-10-31	2022-11-09
1	59	2022-10-30	2022-11-08
1	60	2022-10-30	2022-11-09
1	61	2022-10-29	2022-11-07
1	62	2022-10-31	2022-11-08
1	63	2022-10-30	2022-11-09
1	64	2022-10-29	2022-11-08
1	65	2022-10-31	2022-11-09
1	66	2022-10-30	2022-11-07
1	67	2022-10-29	2022-11-08
1	68	2022-10-30	2022-11-09
1	69	2022-10-30	2022-11-07
1	70	2022-10-31	2022-11-08
1	71	2022-10-30	2022-11-08
1	72	2022-10-31	2022-11-09
1	73	2022-10-29	2022-11-07
1	74	2022-10-30	2022-11-09
1	75	2022-10-30	2022-11-08
1	76	2022-10-31	2022-11-09
1	77	2022-10-29	2022-11-08
1	78	2022-10-30	2022-11-07
1	79	2022-10-30	2022-11-09
1	80	2022-10-31	2022-11-08
1	81	2022-10-31	2022-11-08
1	82	2022-10-29	2022-11-09
1	83	2022-10-30	2022-11-07
1	84	2022-10-30	2022-11-08
1	85	2022-10-31	2022-11-09
1	86	2022-10-29	2022-11-08
1	87	2022-10-30	2022-11-07
1	88	2022-10-31	2022-11-09
1	89	2022-10-29	2022-11-08
1	90	2022-10-30	2022-11-09
1	91	2022-10-31	2022-11-08
1	92	2022-10-29	2022-11-07
1	93	2022-10-30	2022-11-09
1	94	2022-10-31	2022-11-08
1	95	2022-10-30	2022-11-07
1	96	2022-10-30	2022-11-09
1	97	2022-10-31	2022-11-08
1	98	2022-10-29	2022-11-08
1	99	2022-10-30	2022-11-09
1	100	2022-10-30	2022-11-08
1	101	2022-10-31	2022-11-08
1	102	2022-10-30	2022-11-09
1	103	2022-10-29	2022-11-08
1	104	2022-10-30	2022-11-09
1	105	2022-10-30	2022-11-07
1	106	2022-10-31	2022-11-08
1	107	2022-10-30	2022-11-08
1	108	2022-10-29	2022-11-09
1	109	2022-10-30	2022-11-07
1	110	2022-10-30	2022-11-09
1	111	2022-10-29	2022-11-08
1	112	2022-10-31	2022-11-09
1	113	2022-10-30	2022-11-08
1	114	2022-10-30	2022-11-09
1	115	2022-10-31	2022-11-08
1	116	2022-10-29	2022-11-07
1	117	2022-10-30	2022-11-09
1	118	2022-10-30	2022-11-07
1	119	2022-10-31	2022-11-09
1	120	2022-10-30	2022-11-08
1	121	2022-10-30	2022-11-09
1	122	2022-10-29	2022-11-08
1	123	2022-10-30	2022-11-09
1	124	2022-10-30	2022-11-07
1	125	2022-10-29	2022-11-08
1	126	2022-10-31	2022-11-09
1	127	2022-10-30	2022-11-08
1	128	2022-10-31	2022-11-07
1	129	2022-10-30	2022-11-09
1	130	2022-10-29	2022-11-07
1	131	2022-10-31	2022-11-09
1	132	2022-10-30	2022-11-08
1	133	2022-10-29	2022-11-08
1	134	2022-10-30	2022-11-09
1	135	2022-10-30	2022-11-08
1	136	2022-10-31	2022-11-09
1	137	2022-10-30	2022-11-07
1	138	2022-10-29	2022-11-08
1	139	2022-10-31	2022-11-09
1	140	2022-10-30	2022-11-08
1	141	2022-10-30	2022-11-09
1	142	2022-10-31	2022-11-08
1	143	2022-10-29	2022-11-07
1	144	2022-10-30	2022-11-09
1	145	2022-10-30	2022-11-08
1	146	2022-10-31	2022-11-09
1	147	2022-10-30	2022-11-07
1	148	2022-10-29	2022-11-08
1	149	2022-10-31	2022-11-09
1	150	2022-10-30	2022-11-08
1	151	2022-10-30	2022-11-08
1	152	2022-10-29	2022-11-07
1	153	2022-10-30	2022-11-09
1	154	2022-10-31	2022-11-08
1	155	2022-10-30	2022-11-07
1	156	2022-10-29	2022-11-08
1	157	2022-10-30	2022-11-09
1	158	2022-10-31	2022-11-08
1	159	2022-10-30	2022-11-09
1	160	2022-10-31	2022-11-07
1	161	2022-10-30	2022-11-09
1	162	2022-10-29	2022-11-07
1	163	2022-10-30	2022-11-09
1	164	2022-10-30	2022-11-08
1	165	2022-10-31	2022-11-09
1	166	2022-10-30	2022-11-07
1	167	2022-10-29	2022-11-08
1	168	2022-10-30	2022-11-09
1	169	2022-10-30	2022-11-08
1	170	2022-10-31	2022-11-09
1	171	2022-10-30	2022-11-07
1	172	2022-10-29	2022-11-08
1	173	2022-10-30	2022-11-08
1	174	2022-10-31	2022-11-09
1	175	2022-10-30	2022-11-07
1	176	2022-10-30	2022-11-08
1	177	2022-10-31	2022-11-09
1	178	2022-10-29	2022-11-08
1	179	2022-10-30	2022-11-09
1	180	2022-10-31	2022-11-08
1	181	2022-10-30	2022-11-09
1	182	2022-10-29	2022-11-07
1	183	2022-10-30	2022-11-09
1	184	2022-10-31	2022-11-08
1	185	2022-10-30	2022-11-09
1	186	2022-10-29	2022-11-08
1	187	2022-10-30	2022-11-07
1	188	2022-10-30	2022-11-09
1	189	2022-10-31	2022-11-08
1	190	2022-10-30	2022-11-09
1	191	2022-10-31	2022-11-08
1	192	2022-10-30	2022-11-09
1	193	2022-10-29	2022-11-07
1	194	2022-10-31	2022-11-09
1	195	2022-10-30	2022-11-08
1	196	2022-10-31	2022-11-09
1	197	2022-10-29	2022-11-07
1	198	2022-10-30	2022-11-08
1	199	2022-10-30	2022-11-09
1	200	2022-10-31	2022-11-08
1	201	2022-10-29	2022-11-08
1	202	2022-10-30	2022-11-09
1	203	2022-10-31	2022-11-08
1	204	2022-10-30	2022-11-09
1	205	2022-10-30	2022-11-07
1	206	2022-10-29	2022-11-09
1	207	2022-10-30	2022-11-08
1	208	2022-10-31	2022-11-09
1	209	2022-10-30	2022-11-08
1	210	2022-10-30	2022-11-07
1	211	2022-10-29	2022-11-09
1	212	2022-10-30	2022-11-08
1	213	2022-10-31	2022-11-09
1	214	2022-10-30	2022-11-08
1	215	2022-10-30	2022-11-09
1	216	2022-10-29	2022-11-07
1	217	2022-10-30	2022-11-08
1	218	2022-10-31	2022-11-09
1	219	2022-10-29	2022-11-07
1	220	2022-10-30	2022-11-09
1	221	2022-10-30	2022-11-08
1	222	2022-10-31	2022-11-09
1	223	2022-10-30	2022-11-08
1	224	2022-10-29	2022-11-07
1	225	2022-10-30	2022-11-09
1	226	2022-10-30	2022-11-08
1	227	2022-10-31	2022-11-09
1	228	2022-10-29	2022-11-08
1	229	2022-10-30	2022-11-07
1	230	2022-10-31	2022-11-09
1	231	2022-10-30	2022-11-08
1	232	2022-10-30	2022-11-09
1	233	2022-10-31	2022-11-08
1	234	2022-10-30	2022-11-09
1	235	2022-10-29	2022-11-08
1	236	2022-10-30	2022-11-07
1	237	2022-10-31	2022-11-09
1	238	2022-10-30	2022-11-08
1	239	2022-10-30	2022-11-09
1	240	2022-10-29	2022-11-07
1	241	2022-10-31	2022-11-09
1	242	2022-10-30	2022-11-08
1	243	2022-10-30	2022-11-09
1	244	2022-10-29	2022-11-08
1	245	2022-10-31	2022-11-07
1	246	2022-10-30	2022-11-09
1	247	2022-10-30	2022-11-09
1	248	2022-10-31	2022-11-08
1	249	2022-10-29	2022-11-08
1	250	2022-10-30	2022-11-09
1	251	2022-10-30	2022-11-08
1	252	2022-10-31	2022-11-09
1	253	2022-10-29	2022-11-07
1	254	2022-10-30	2022-11-09
1	255	2022-10-30	2022-11-08
1	256	2022-10-31	2022-11-09
1	257	2022-10-29	2022-11-07
1	258	2022-10-30	2022-11-09
1	259	2022-10-30	2022-11-08
1	260	2022-10-31	2022-11-09
1	261	2022-10-29	2022-11-07
1	262	2022-10-30	2022-11-08
1	263	2022-10-30	2022-11-09
1	264	2022-10-31	2022-11-08
1	265	2022-10-29	2022-11-07
1	266	2022-10-30	2022-11-09
1	267	2022-10-30	2022-11-08
1	268	2022-10-31	2022-11-09
1	269	2022-10-30	2022-11-08
1	270	2022-10-29	2022-11-07
1	271	2022-10-30	2022-11-08
1	272	2022-10-31	2022-11-09
1	273	2022-10-29	2022-11-07
1	274	2022-10-30	2022-11-09
1	275	2022-10-30	2022-11-08
1	276	2022-10-31	2022-11-09
1	277	2022-10-29	2022-11-07
1	278	2022-10-30	2022-11-09
1	279	2022-10-30	2022-11-08
1	280	2022-10-31	2022-11-09
1	281	2022-10-29	2022-11-07
1	282	2022-10-30	2022-11-09
1	283	2022-10-30	2022-11-08
1	284	2022-10-31	2022-11-09
1	285	2022-10-30	2022-11-08
1	286	2022-10-29	2022-11-09
1	287	2022-10-30	2022-11-08
1	288	2022-10-31	2022-11-09
1	289	2022-10-29	2022-11-07
1	290	2022-10-30	2022-11-09
1	291	2022-10-30	2022-11-08
1	292	2022-10-31	2022-11-09
1	293	2022-10-30	2022-11-08
1	294	2022-10-29	2022-11-07
1	295	2022-10-31	2022-11-09
1	296	2022-10-30	2022-11-08
1	297	2022-10-30	2022-11-09
1	298	2022-10-31	2022-11-08
1	299	2022-10-29	2022-11-07
1	300	2022-10-30	2022-11-09
1	301	2022-10-30	2022-11-08
1	302	2022-10-31	2022-11-09
1	303	2022-10-29	2022-11-07
1	304	2022-10-30	2022-11-09
1	305	2022-10-30	2022-11-08
1	306	2022-10-31	2022-11-09
1	307	2022-10-30	2022-11-08
1	308	2022-10-29	2022-11-07
1	309	2022-10-30	2022-11-09
1	310	2022-10-30	2022-11-08
1	311	2022-10-31	2022-11-09
1	312	2022-10-29	2022-11-07
1	313	2022-10-30	2022-11-08
1	314	2022-10-31	2022-11-09
1	315	2022-10-29	2022-11-07
1	316	2022-10-30	2022-11-09
1	317	2022-10-30	2022-11-08
1	318	2022-10-31	2022-11-09
1	319	2022-10-29	2022-11-07
1	320	2022-10-30	2022-11-09
1	321	2022-10-30	2022-11-08
1	322	2022-10-31	2022-11-09
1	323	2022-10-29	2022-11-07
1	324	2022-10-30	2022-11-09
1	325	2022-10-30	2022-11-08
1	326	2022-10-31	2022-11-09
1	327	2022-10-30	2022-11-08
1	328	2022-10-31	2022-11-09
1	329	2022-10-29	2022-11-07
1	330	2022-10-30	2022-11-09
1	331	2022-10-30	2022-11-08
1	332	2022-10-31	2022-11-09
1	333	2022-10-29	2022-11-07
1	334	2022-10-30	2022-11-09
1	335	2022-10-30	2022-11-08
1	336	2022-10-31	2022-11-09
1	337	2022-10-30	2022-11-08
1	338	2022-10-29	2022-11-07
1	339	2022-10-30	2022-11-09
1	340	2022-10-30	2022-11-08
1	341	2022-10-31	2022-11-09
1	342	2022-10-29	2022-11-07
1	343	2022-10-30	2022-11-09
1	344	2022-10-30	2022-11-08
1	345	2022-10-31	2022-11-09
1	346	2022-10-30	2022-11-08
1	347	2022-10-30	2022-11-09
1	348	2022-10-29	2022-11-07
1	349	2022-10-30	2022-11-09
1	350	2022-10-31	2022-11-08
1	351	2022-10-30	2022-11-09
1	352	2022-10-30	2022-11-08
1	353	2022-10-29	2022-11-07
1	354	2022-10-30	2022-11-09
1	355	2022-10-31	2022-11-08
1	356	2022-10-30	2022-11-09
1	357	2022-10-29	2022-11-07
1	358	2022-10-30	2022-11-09
1	359	2022-10-30	2022-11-08
1	360	2022-10-31	2022-11-09
1	361	2022-10-30	2022-11-08
1	362	2022-10-29	2022-11-07
1	363	2022-10-30	2022-11-09
1	364	2022-10-30	2022-11-08
1	365	2022-10-31	2022-11-09
1	366	2022-10-30	2022-11-08
1	367	2022-10-30	2022-11-09
1	368	2022-10-29	2022-11-07
2	1	2023-10-22	2023-10-30
2	2	2023-10-23	2023-10-30
2	3	2023-10-23	2023-10-31
2	4	2023-10-24	2023-10-31
2	5	2023-10-22	2023-10-30
2	6	2023-10-23	2023-10-31
2	7	2023-10-24	2023-11-01
2	8	2023-10-23	2023-10-31
2	9	2023-10-22	2023-10-30
2	10	2023-10-23	2023-10-31
2	11	2023-10-24	2023-10-31
2	12	2023-10-23	2023-10-30
2	13	2023-10-22	2023-10-30
2	14	2023-10-23	2023-10-31
2	15	2023-10-23	2023-10-31
2	16	2023-10-24	2023-10-31
2	17	2023-10-22	2023-10-30
2	18	2023-10-23	2023-10-31
2	19	2023-10-24	2023-10-31
2	20	2023-10-23	2023-10-30
2	21	2023-10-22	2023-10-30
2	22	2023-10-23	2023-10-31
2	23	2023-10-23	2023-10-31
2	24	2023-10-24	2023-10-31
2	25	2023-10-22	2023-10-30
2	26	2023-10-23	2023-10-31
2	27	2023-10-24	2023-10-31
2	28	2023-10-23	2023-10-30
2	29	2023-10-22	2023-10-30
2	30	2023-10-23	2023-10-31
2	31	2023-10-23	2023-10-31
2	32	2023-10-24	2023-10-31
2	33	2023-10-22	2023-10-30
2	34	2023-10-23	2023-10-31
2	35	2023-10-23	2023-10-31
2	36	2023-10-24	2023-10-31
2	37	2023-10-22	2023-10-30
2	38	2023-10-23	2023-10-31
2	39	2023-10-24	2023-10-31
2	40	2023-10-23	2023-10-31
2	41	2023-10-22	2023-10-30
2	42	2023-10-23	2023-10-31
2	43	2023-10-24	2023-10-31
2	44	2023-10-23	2023-10-31
2	45	2023-10-22	2023-10-30
2	46	2023-10-23	2023-10-31
2	47	2023-10-23	2023-10-31
2	48	2023-10-24	2023-10-31
2	49	2023-10-22	2023-10-30
2	50	2023-10-23	2023-10-31
2	51	2023-10-23	2023-10-31
2	52	2023-10-24	2023-10-31
2	53	2023-10-22	2023-10-30
2	54	2023-10-23	2023-10-31
2	55	2023-10-24	2023-10-31
2	56	2023-10-23	2023-10-30
2	57	2023-10-22	2023-10-30
2	58	2023-10-23	2023-10-31
2	59	2023-10-24	2023-10-31
2	60	2023-10-22	2023-10-30
2	61	2023-10-22	2023-10-30
2	62	2023-10-23	2023-10-31
2	63	2023-10-24	2023-10-31
2	64	2023-10-23	2023-10-30
2	65	2023-10-22	2023-10-30
2	66	2023-10-23	2023-10-31
2	67	2023-10-23	2023-10-31
2	68	2023-10-24	2023-10-31
2	69	2023-10-22	2023-10-30
2	70	2023-10-23	2023-10-31
2	71	2023-10-23	2023-10-31
2	72	2023-10-24	2023-10-31
2	73	2023-10-22	2023-10-30
2	74	2023-10-23	2023-10-31
2	75	2023-10-23	2023-10-31
2	76	2023-10-24	2023-10-31
2	77	2023-10-22	2023-10-30
2	78	2023-10-23	2023-10-31
2	79	2023-10-23	2023-10-31
2	80	2023-10-24	2023-10-31
2	81	2023-10-22	2023-10-30
2	82	2023-10-23	2023-10-31
2	83	2023-10-24	2023-10-31
2	84	2023-10-23	2023-10-31
2	85	2023-10-22	2023-10-30
2	86	2023-10-23	2023-10-31
2	87	2023-10-23	2023-10-31
2	88	2023-10-24	2023-10-31
2	89	2023-10-22	2023-10-30
2	90	2023-10-23	2023-10-31
2	91	2023-10-23	2023-10-31
2	92	2023-10-24	2023-10-31
2	93	2023-10-22	2023-10-30
2	94	2023-10-23	2023-10-31
2	95	2023-10-23	2023-10-31
2	96	2023-10-24	2023-10-31
2	97	2023-10-22	2023-10-30
2	98	2023-10-23	2023-10-31
2	99	2023-10-24	2023-10-31
2	100	2023-10-23	2023-10-30
2	101	2023-10-22	2023-10-30
2	102	2023-10-23	2023-10-31
2	103	2023-10-23	2023-10-31
2	104	2023-10-24	2023-10-31
2	105	2023-10-22	2023-10-30
2	106	2023-10-23	2023-10-31
2	107	2023-10-23	2023-10-31
2	108	2023-10-24	2023-10-31
2	109	2023-10-22	2023-10-30
2	110	2023-10-23	2023-10-31
2	111	2023-10-23	2023-10-31
2	112	2023-10-24	2023-10-31
2	113	2023-10-22	2023-10-30
2	114	2023-10-23	2023-10-31
2	115	2023-10-24	2023-10-31
2	116	2023-10-23	2023-10-30
2	117	2023-10-22	2023-10-30
2	118	2023-10-23	2023-10-31
2	119	2023-10-23	2023-10-31
2	120	2023-10-24	2023-10-31
2	121	2023-10-22	2023-10-30
2	122	2023-10-23	2023-10-31
2	123	2023-10-23	2023-10-31
2	124	2023-10-24	2023-10-31
2	125	2023-10-22	2023-10-30
2	126	2023-10-23	2023-10-31
2	127	2023-10-23	2023-10-31
2	128	2023-10-24	2023-10-31
2	129	2023-10-22	2023-10-30
2	130	2023-10-23	2023-10-31
2	131	2023-10-23	2023-10-31
2	132	2023-10-24	2023-10-31
2	133	2023-10-22	2023-10-30
2	134	2023-10-23	2023-10-31
2	135	2023-10-23	2023-10-31
2	136	2023-10-24	2023-10-31
2	137	2023-10-22	2023-10-30
2	138	2023-10-23	2023-10-31
2	139	2023-10-23	2023-10-31
2	140	2023-10-24	2023-10-31
2	141	2023-10-22	2023-10-30
2	142	2023-10-23	2023-10-31
2	143	2023-10-23	2023-10-31
2	144	2023-10-24	2023-10-31
2	145	2023-10-22	2023-10-30
2	146	2023-10-23	2023-10-31
2	147	2023-10-23	2023-10-31
2	148	2023-10-24	2023-10-31
2	149	2023-10-22	2023-10-30
2	150	2023-10-23	2023-10-31
2	151	2023-10-23	2023-10-31
2	152	2023-10-24	2023-10-31
2	153	2023-10-22	2023-10-30
2	154	2023-10-23	2023-10-31
2	155	2023-10-23	2023-10-31
2	156	2023-10-24	2023-10-31
2	157	2023-10-22	2023-10-30
2	158	2023-10-23	2023-10-31
2	159	2023-10-23	2023-10-31
2	160	2023-10-24	2023-10-31
2	161	2023-10-22	2023-10-30
2	162	2023-10-23	2023-10-31
2	163	2023-10-23	2023-10-31
2	164	2023-10-24	2023-10-31
2	165	2023-10-22	2023-10-30
2	166	2023-10-23	2023-10-31
2	167	2023-10-23	2023-10-31
2	168	2023-10-24	2023-10-31
2	169	2023-10-22	2023-10-30
2	170	2023-10-23	2023-10-31
2	171	2023-10-23	2023-10-31
2	172	2023-10-24	2023-10-31
2	173	2023-10-22	2023-10-30
2	174	2023-10-23	2023-10-31
2	175	2023-10-23	2023-10-31
2	176	2023-10-24	2023-10-31
2	177	2023-10-22	2023-10-30
2	178	2023-10-23	2023-10-31
2	179	2023-10-23	2023-10-31
2	180	2023-10-24	2023-10-31
2	181	2023-10-22	2023-10-30
2	182	2023-10-23	2023-10-31
2	183	2023-10-23	2023-10-31
2	184	2023-10-24	2023-10-31
2	185	2023-10-22	2023-10-30
2	186	2023-10-23	2023-10-31
2	187	2023-10-23	2023-10-31
2	188	2023-10-24	2023-10-31
2	189	2023-10-22	2023-10-30
2	190	2023-10-23	2023-10-31
2	191	2023-10-23	2023-10-31
2	192	2023-10-24	2023-10-31
2	193	2023-10-22	2023-10-30
2	194	2023-10-23	2023-10-31
2	195	2023-10-23	2023-10-31
2	196	2023-10-24	2023-10-31
2	197	2023-10-22	2023-10-30
2	198	2023-10-23	2023-10-31
2	199	2023-10-23	2023-10-31
2	200	2023-10-24	2023-10-31
2	201	2023-10-22	2023-10-30
2	202	2023-10-23	2023-10-31
2	203	2023-10-23	2023-10-31
2	204	2023-10-24	2023-10-31
2	205	2023-10-22	2023-10-30
2	206	2023-10-23	2023-10-31
2	207	2023-10-23	2023-10-31
2	208	2023-10-24	2023-10-31
2	209	2023-10-22	2023-10-30
2	210	2023-10-23	2023-10-31
2	211	2023-10-23	2023-10-31
2	212	2023-10-24	2023-10-31
2	213	2023-10-22	2023-10-30
2	214	2023-10-23	2023-10-31
2	215	2023-10-23	2023-10-31
2	216	2023-10-24	2023-10-31
2	217	2023-10-22	2023-10-30
2	218	2023-10-23	2023-10-31
2	219	2023-10-24	2023-10-31
2	220	2023-10-23	2023-10-30
2	221	2023-10-22	2023-10-30
2	222	2023-10-22	2023-10-30
2	223	2023-10-23	2023-10-31
2	224	2023-10-23	2023-10-31
2	225	2023-10-24	2023-10-31
2	226	2023-10-23	2023-10-31
2	227	2023-10-22	2023-10-30
2	228	2023-10-23	2023-10-31
2	229	2023-10-23	2023-10-31
2	230	2023-10-24	2023-10-31
2	231	2023-10-23	2023-10-31
2	232	2023-10-22	2023-10-30
2	233	2023-10-23	2023-10-31
2	234	2023-10-24	2023-10-31
2	235	2023-10-23	2023-10-30
2	236	2023-10-22	2023-10-30
2	237	2023-10-22	2023-10-30
2	238	2023-10-23	2023-10-31
2	239	2023-10-24	2023-10-31
2	240	2023-10-23	2023-10-30
2	241	2023-10-22	2023-10-30
2	242	2023-10-22	2023-10-30
2	243	2023-10-23	2023-10-31
2	244	2023-10-23	2023-10-31
2	245	2023-10-24	2023-10-31
2	246	2023-10-23	2023-10-31
2	247	2023-10-22	2023-10-30
2	248	2023-10-23	2023-10-31
2	249	2023-10-23	2023-10-31
2	250	2023-10-24	2023-10-31
2	251	2023-10-23	2023-10-31
2	252	2023-10-22	2023-10-30
2	253	2023-10-23	2023-10-31
2	254	2023-10-23	2023-10-31
2	255	2023-10-24	2023-10-31
2	256	2023-10-23	2023-10-31
2	257	2023-10-22	2023-10-30
2	258	2023-10-23	2023-10-31
2	259	2023-10-24	2023-10-31
2	260	2023-10-23	2023-10-30
2	261	2023-10-22	2023-10-30
2	262	2023-10-23	2023-10-31
2	263	2023-10-23	2023-10-31
2	264	2023-10-22	2023-10-30
2	265	2023-10-23	2023-10-31
2	266	2023-10-23	2023-10-31
2	267	2023-10-24	2023-10-31
2	268	2023-10-22	2023-10-30
2	269	2023-10-23	2023-10-31
2	270	2023-10-24	2023-10-31
2	271	2023-10-22	2023-10-30
2	272	2023-10-23	2023-10-31
2	273	2023-10-23	2023-10-31
2	274	2023-10-24	2023-10-31
2	275	2023-10-22	2023-10-30
2	276	2023-10-23	2023-10-31
2	277	2023-10-23	2023-10-31
2	278	2023-10-22	2023-10-30
2	279	2023-10-23	2023-10-31
2	280	2023-10-23	2023-10-31
2	281	2023-10-24	2023-10-31
2	282	2023-10-22	2023-10-30
2	283	2023-10-23	2023-10-31
2	284	2023-10-23	2023-10-31
2	285	2023-10-22	2023-10-30
2	286	2023-10-23	2023-10-31
2	287	2023-10-23	2023-10-31
2	288	2023-10-24	2023-10-31
2	289	2023-10-22	2023-10-30
2	290	2023-10-23	2023-10-31
2	291	2023-10-23	2023-10-31
2	292	2023-10-22	2023-10-30
2	293	2023-10-23	2023-10-31
2	294	2023-10-23	2023-10-31
2	295	2023-10-24	2023-10-31
2	296	2023-10-22	2023-10-30
2	297	2023-10-23	2023-10-31
2	298	2023-10-23	2023-10-31
2	299	2023-10-24	2023-10-31
2	300	2023-10-23	2023-10-30
2	301	2023-10-22	2023-10-30
2	302	2023-10-23	2023-10-31
2	303	2023-10-23	2023-10-31
2	304	2023-10-24	2023-10-31
2	305	2023-10-22	2023-10-30
2	306	2023-10-22	2023-10-30
2	307	2023-10-23	2023-10-31
2	308	2023-10-23	2023-10-31
2	309	2023-10-24	2023-10-31
2	310	2023-10-22	2023-10-30
2	311	2023-10-23	2023-10-31
2	312	2023-10-23	2023-10-31
2	313	2023-10-22	2023-10-30
2	314	2023-10-23	2023-10-31
2	315	2023-10-23	2023-10-31
2	316	2023-10-24	2023-10-31
2	317	2023-10-22	2023-10-30
2	318	2023-10-23	2023-10-31
2	319	2023-10-24	2023-10-31
2	320	2023-10-22	2023-10-30
2	321	2023-10-23	2023-10-31
2	322	2023-10-23	2023-10-31
2	323	2023-10-24	2023-10-31
2	324	2023-10-22	2023-10-30
2	325	2023-10-23	2023-10-31
2	326	2023-10-24	2023-10-31
2	327	2023-10-22	2023-10-30
2	328	2023-10-23	2023-10-31
2	329	2023-10-23	2023-10-31
2	330	2023-10-24	2023-10-31
2	331	2023-10-22	2023-10-30
2	332	2023-10-23	2023-10-31
2	333	2023-10-23	2023-10-31
2	334	2023-10-22	2023-10-30
2	335	2023-10-23	2023-10-31
2	336	2023-10-23	2023-10-31
2	337	2023-10-24	2023-10-31
2	338	2023-10-22	2023-10-30
2	339	2023-10-23	2023-10-31
2	340	2023-10-23	2023-10-31
2	341	2023-10-22	2023-10-30
2	342	2023-10-23	2023-10-31
2	343	2023-10-23	2023-10-31
2	344	2023-10-24	2023-10-31
2	345	2023-10-22	2023-10-30
2	346	2023-10-23	2023-10-31
2	347	2023-10-23	2023-10-31
2	348	2023-10-22	2023-10-30
2	349	2023-10-23	2023-10-31
2	350	2023-10-23	2023-10-31
2	351	2023-10-24	2023-10-31
2	352	2023-10-22	2023-10-30
2	353	2023-10-23	2023-10-31
2	354	2023-10-23	2023-10-31
2	355	2023-10-22	2023-10-30
2	356	2023-10-23	2023-10-31
2	357	2023-10-23	2023-10-31
2	358	2023-10-24	2023-10-31
2	359	2023-10-22	2023-10-30
2	360	2023-10-23	2023-10-31
2	361	2023-10-23	2023-10-31
2	362	2023-10-22	2023-10-30
2	363	2023-10-23	2023-10-31
2	364	2023-10-23	2023-10-31
2	365	2023-10-24	2023-10-31
2	366	2023-10-22	2023-10-30
2	367	2023-10-23	2023-10-31
2	368	2023-10-23	2023-10-31
3	1	2024-11-03	2024-11-11
3	2	2024-11-04	2024-11-12
3	3	2024-11-04	2024-11-12
3	4	2024-11-05	2024-11-12
3	5	2024-11-03	2024-11-11
3	6	2024-11-04	2024-11-12
3	7	2024-11-05	2024-11-13
3	8	2024-11-04	2024-11-12
3	9	2024-11-03	2024-11-11
3	10	2024-11-04	2024-11-12
3	11	2024-11-05	2024-11-13
3	12	2024-11-03	2024-11-11
3	13	2024-11-04	2024-11-12
3	14	2024-11-05	2024-11-13
3	15	2024-11-03	2024-11-11
3	16	2024-11-04	2024-11-12
3	17	2024-11-03	2024-11-11
3	18	2024-11-04	2024-11-12
3	19	2024-11-04	2024-11-12
3	20	2024-11-05	2024-11-13
3	21	2024-11-03	2024-11-11
3	22	2024-11-04	2024-11-12
3	23	2024-11-05	2024-11-13
3	24	2024-11-04	2024-11-12
3	25	2024-11-03	2024-11-11
3	26	2024-11-04	2024-11-12
3	27	2024-11-05	2024-11-13
3	28	2024-11-03	2024-11-11
3	29	2024-11-04	2024-11-12
3	30	2024-11-05	2024-11-13
3	31	2024-11-03	2024-11-11
3	32	2024-11-04	2024-11-12
3	33	2024-11-03	2024-11-11
3	34	2024-11-04	2024-11-12
3	35	2024-11-04	2024-11-12
3	36	2024-11-05	2024-11-13
3	37	2024-11-03	2024-11-11
3	38	2024-11-04	2024-11-12
3	39	2024-11-05	2024-11-13
3	40	2024-11-04	2024-11-12
3	41	2024-11-03	2024-11-11
3	42	2024-11-04	2024-11-12
3	43	2024-11-05	2024-11-13
3	44	2024-11-03	2024-11-11
3	45	2024-11-04	2024-11-12
3	46	2024-11-05	2024-11-13
3	47	2024-11-03	2024-11-11
3	48	2024-11-04	2024-11-12
3	49	2024-11-03	2024-11-11
3	50	2024-11-05	2024-11-13
3	51	2024-11-04	2024-11-12
3	52	2024-11-03	2024-11-11
3	53	2024-11-04	2024-11-12
3	54	2024-11-05	2024-11-13
3	55	2024-11-03	2024-11-11
3	56	2024-11-04	2024-11-12
3	57	2024-11-05	2024-11-13
3	58	2024-11-03	2024-11-11
3	59	2024-11-04	2024-11-12
3	60	2024-11-04	2024-11-12
3	61	2024-11-03	2024-11-11
3	62	2024-11-04	2024-11-12
3	63	2024-11-05	2024-11-13
3	64	2024-11-03	2024-11-11
3	65	2024-11-04	2024-11-12
3	66	2024-11-05	2024-11-13
3	67	2024-11-03	2024-11-11
3	68	2024-11-04	2024-11-12
3	69	2024-11-03	2024-11-11
3	70	2024-11-05	2024-11-13
3	71	2024-11-04	2024-11-12
3	72	2024-11-04	2024-11-12
3	73	2024-11-03	2024-11-11
3	74	2024-11-03	2024-11-11
3	75	2024-11-04	2024-11-12
3	76	2024-11-05	2024-11-13
3	77	2024-11-03	2024-11-11
3	78	2024-11-04	2024-11-12
3	79	2024-11-05	2024-11-13
3	80	2024-11-03	2024-11-11
3	81	2024-11-04	2024-11-12
3	82	2024-11-05	2024-11-13
3	83	2024-11-03	2024-11-11
3	84	2024-11-04	2024-11-12
3	85	2024-11-03	2024-11-11
3	86	2024-11-04	2024-11-12
3	87	2024-11-05	2024-11-13
3	88	2024-11-03	2024-11-11
3	89	2024-11-04	2024-11-12
3	90	2024-11-05	2024-11-13
3	91	2024-11-03	2024-11-11
3	92	2024-11-04	2024-11-12
3	93	2024-11-05	2024-11-13
3	94	2024-11-03	2024-11-11
3	95	2024-11-04	2024-11-12
3	96	2024-11-03	2024-11-11
3	97	2024-11-04	2024-11-12
3	98	2024-11-05	2024-11-13
3	99	2024-11-03	2024-11-11
3	100	2024-11-04	2024-11-12
3	101	2024-11-05	2024-11-13
3	102	2024-11-03	2024-11-11
3	103	2024-11-04	2024-11-12
3	104	2024-11-05	2024-11-13
3	105	2024-11-03	2024-11-11
3	106	2024-11-04	2024-11-12
3	107	2024-11-03	2024-11-11
3	108	2024-11-04	2024-11-12
3	109	2024-11-05	2024-11-13
3	110	2024-11-03	2024-11-11
3	111	2024-11-04	2024-11-12
3	112	2024-11-05	2024-11-13
3	113	2024-11-03	2024-11-11
3	114	2024-11-04	2024-11-12
3	115	2024-11-05	2024-11-13
3	116	2024-11-03	2024-11-11
3	117	2024-11-04	2024-11-12
3	118	2024-11-03	2024-11-11
3	119	2024-11-04	2024-11-12
3	120	2024-11-05	2024-11-13
3	121	2024-11-03	2024-11-11
3	122	2024-11-04	2024-11-12
3	123	2024-11-05	2024-11-13
3	124	2024-11-03	2024-11-11
3	125	2024-11-04	2024-11-12
3	126	2024-11-05	2024-11-13
3	127	2024-11-03	2024-11-11
3	128	2024-11-04	2024-11-12
3	129	2024-11-03	2024-11-11
3	130	2024-11-04	2024-11-12
3	131	2024-11-05	2024-11-13
3	132	2024-11-03	2024-11-11
3	133	2024-11-04	2024-11-12
3	134	2024-11-05	2024-11-13
3	135	2024-11-03	2024-11-11
3	136	2024-11-04	2024-11-12
3	137	2024-11-05	2024-11-13
3	138	2024-11-03	2024-11-11
3	139	2024-11-04	2024-11-12
3	140	2024-11-03	2024-11-11
3	141	2024-11-04	2024-11-12
3	142	2024-11-05	2024-11-13
3	143	2024-11-03	2024-11-11
3	144	2024-11-04	2024-11-12
3	145	2024-11-05	2024-11-13
3	146	2024-11-03	2024-11-11
3	147	2024-11-04	2024-11-12
3	148	2024-11-05	2024-11-13
3	149	2024-11-03	2024-11-11
3	150	2024-11-04	2024-11-12
3	151	2024-11-03	2024-11-11
3	152	2024-11-04	2024-11-12
3	153	2024-11-05	2024-11-13
3	154	2024-11-03	2024-11-11
3	155	2024-11-04	2024-11-12
3	156	2024-11-05	2024-11-13
3	157	2024-11-03	2024-11-11
3	158	2024-11-04	2024-11-12
3	159	2024-11-05	2024-11-13
3	160	2024-11-03	2024-11-11
3	161	2024-11-04	2024-11-12
3	162	2024-11-03	2024-11-11
3	163	2024-11-04	2024-11-12
3	164	2024-11-05	2024-11-13
3	165	2024-11-03	2024-11-11
3	166	2024-11-04	2024-11-12
3	167	2024-11-05	2024-11-13
3	168	2024-11-03	2024-11-11
3	169	2024-11-04	2024-11-12
3	170	2024-11-05	2024-11-13
3	171	2024-11-03	2024-11-11
3	172	2024-11-04	2024-11-12
3	173	2024-11-03	2024-11-11
3	174	2024-11-04	2024-11-12
3	175	2024-11-05	2024-11-13
3	176	2024-11-03	2024-11-11
3	177	2024-11-04	2024-11-12
3	178	2024-11-05	2024-11-13
3	179	2024-11-03	2024-11-11
3	180	2024-11-04	2024-11-12
3	181	2024-11-05	2024-11-13
3	182	2024-11-03	2024-11-11
3	183	2024-11-04	2024-11-12
3	184	2024-11-03	2024-11-11
3	185	2024-11-04	2024-11-12
3	186	2024-11-05	2024-11-13
3	187	2024-11-03	2024-11-11
3	188	2024-11-04	2024-11-12
3	189	2024-11-03	2024-11-11
3	190	2024-11-04	2024-11-12
3	191	2024-11-05	2024-11-13
3	192	2024-11-03	2024-11-11
3	193	2024-11-04	2024-11-12
3	194	2024-11-05	2024-11-13
3	195	2024-11-03	2024-11-11
3	196	2024-11-04	2024-11-12
3	197	2024-11-05	2024-11-13
3	198	2024-11-03	2024-11-11
3	199	2024-11-04	2024-11-12
3	200	2024-11-05	2024-11-13
3	201	2024-11-03	2024-11-11
3	202	2024-11-04	2024-11-12
3	203	2024-11-05	2024-11-13
3	204	2024-11-03	2024-11-11
3	205	2024-11-04	2024-11-12
3	206	2024-11-03	2024-11-11
3	207	2024-11-04	2024-11-12
3	208	2024-11-05	2024-11-13
3	209	2024-11-03	2024-11-11
3	210	2024-11-04	2024-11-12
3	211	2024-11-05	2024-11-13
3	212	2024-11-03	2024-11-11
3	213	2024-11-04	2024-11-12
3	214	2024-11-05	2024-11-13
3	215	2024-11-03	2024-11-11
3	216	2024-11-04	2024-11-12
3	217	2024-11-03	2024-11-11
3	218	2024-11-04	2024-11-12
3	219	2024-11-05	2024-11-13
3	220	2024-11-03	2024-11-11
3	221	2024-11-04	2024-11-12
3	222	2024-11-05	2024-11-13
3	223	2024-11-03	2024-11-11
3	224	2024-11-04	2024-11-12
3	225	2024-11-05	2024-11-13
3	226	2024-11-03	2024-11-11
3	227	2024-11-04	2024-11-12
3	228	2024-11-05	2024-11-13
3	229	2024-11-03	2024-11-11
3	230	2024-11-04	2024-11-12
3	231	2024-11-05	2024-11-13
3	232	2024-11-03	2024-11-11
3	233	2024-11-04	2024-11-12
3	234	2024-11-05	2024-11-13
3	235	2024-11-03	2024-11-11
3	236	2024-11-04	2024-11-12
3	237	2024-11-05	2024-11-13
3	238	2024-11-03	2024-11-11
3	239	2024-11-04	2024-11-12
3	240	2024-11-05	2024-11-13
3	241	2024-11-03	2024-11-11
3	242	2024-11-04	2024-11-12
3	243	2024-11-05	2024-11-13
3	244	2024-11-03	2024-11-11
3	245	2024-11-04	2024-11-12
3	246	2024-11-05	2024-11-13
3	247	2024-11-03	2024-11-11
3	248	2024-11-04	2024-11-12
3	249	2024-11-05	2024-11-13
3	250	2024-11-03	2024-11-11
3	251	2024-11-04	2024-11-12
3	252	2024-11-05	2024-11-13
3	253	2024-11-03	2024-11-11
3	254	2024-11-04	2024-11-12
3	255	2024-11-05	2024-11-13
3	256	2024-11-03	2024-11-11
3	257	2024-11-03	2024-11-11
3	258	2024-11-04	2024-11-12
3	259	2024-11-05	2024-11-13
3	260	2024-11-03	2024-11-11
3	261	2024-11-04	2024-11-12
3	262	2024-11-05	2024-11-13
3	263	2024-11-03	2024-11-11
3	264	2024-11-04	2024-11-12
3	265	2024-11-05	2024-11-13
3	266	2024-11-03	2024-11-11
3	267	2024-11-04	2024-11-12
3	268	2024-11-05	2024-11-13
3	269	2024-11-03	2024-11-11
3	270	2024-11-04	2024-11-12
3	271	2024-11-03	2024-11-11
3	272	2024-11-04	2024-11-12
3	273	2024-11-05	2024-11-13
3	274	2024-11-03	2024-11-11
3	275	2024-11-04	2024-11-12
3	276	2024-11-05	2024-11-13
3	277	2024-11-03	2024-11-11
3	278	2024-11-04	2024-11-12
3	279	2024-11-05	2024-11-13
3	280	2024-11-03	2024-11-11
3	281	2024-11-04	2024-11-12
3	282	2024-11-05	2024-11-13
3	283	2024-11-03	2024-11-11
3	284	2024-11-04	2024-11-12
3	285	2024-11-03	2024-11-11
3	286	2024-11-04	2024-11-12
3	287	2024-11-05	2024-11-13
3	288	2024-11-03	2024-11-11
3	289	2024-11-04	2024-11-12
3	290	2024-11-05	2024-11-13
3	291	2024-11-03	2024-11-11
3	292	2024-11-04	2024-11-12
3	293	2024-11-05	2024-11-13
3	294	2024-11-03	2024-11-11
3	295	2024-11-04	2024-11-12
3	296	2024-11-05	2024-11-13
3	297	2024-11-03	2024-11-11
3	298	2024-11-04	2024-11-12
3	299	2024-11-05	2024-11-13
3	300	2024-11-03	2024-11-11
3	301	2024-11-04	2024-11-12
3	302	2024-11-05	2024-11-13
3	303	2024-11-03	2024-11-11
3	304	2024-11-04	2024-11-12
3	305	2024-11-05	2024-11-13
3	306	2024-11-03	2024-11-11
3	307	2024-11-04	2024-11-12
3	308	2024-11-05	2024-11-13
3	309	2024-11-03	2024-11-11
3	310	2024-11-04	2024-11-12
3	311	2024-11-05	2024-11-13
3	312	2024-11-03	2024-11-11
3	313	2024-11-03	2024-11-11
3	314	2024-11-04	2024-11-12
3	315	2024-11-05	2024-11-13
3	316	2024-11-03	2024-11-11
3	317	2024-11-04	2024-11-12
3	318	2024-11-05	2024-11-13
3	319	2024-11-03	2024-11-11
3	320	2024-11-03	2024-11-11
3	321	2024-11-04	2024-11-12
3	322	2024-11-05	2024-11-13
3	323	2024-11-03	2024-11-11
3	324	2024-11-04	2024-11-12
3	325	2024-11-05	2024-11-13
3	326	2024-11-03	2024-11-11
3	327	2024-11-04	2024-11-12
3	328	2024-11-05	2024-11-13
3	329	2024-11-03	2024-11-11
3	330	2024-11-04	2024-11-12
3	331	2024-11-05	2024-11-13
3	332	2024-11-03	2024-11-11
3	333	2024-11-04	2024-11-12
3	334	2024-11-03	2024-11-11
3	335	2024-11-04	2024-11-12
3	336	2024-11-05	2024-11-13
3	337	2024-11-03	2024-11-11
3	338	2024-11-04	2024-11-12
3	339	2024-11-05	2024-11-13
3	340	2024-11-03	2024-11-11
3	341	2024-11-04	2024-11-12
3	342	2024-11-05	2024-11-13
3	343	2024-11-03	2024-11-11
3	344	2024-11-04	2024-11-12
3	345	2024-11-05	2024-11-13
3	346	2024-11-03	2024-11-11
3	347	2024-11-04	2024-11-12
3	348	2024-11-05	2024-11-13
3	349	2024-11-03	2024-11-11
3	350	2024-11-04	2024-11-12
3	351	2024-11-05	2024-11-13
3	352	2024-11-03	2024-11-11
3	353	2024-11-04	2024-11-12
3	354	2024-11-05	2024-11-13
3	355	2024-11-03	2024-11-11
3	356	2024-11-04	2024-11-12
3	357	2024-11-05	2024-11-13
3	358	2024-11-03	2024-11-11
3	359	2024-11-04	2024-11-12
3	360	2024-11-05	2024-11-13
3	361	2024-11-03	2024-11-11
3	362	2024-11-04	2024-11-12
3	363	2024-11-05	2024-11-13
3	364	2024-11-03	2024-11-11
3	365	2024-11-04	2024-11-12
3	366	2024-11-05	2024-11-13
3	367	2024-11-03	2024-11-11
3	368	2024-11-04	2024-11-12
\.


--
-- TOC entry 5147 (class 0 OID 18172)
-- Dependencies: 224
-- Data for Name: tournament_sport; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournament_sport (tournament_id, sport_name, prize_money) FROM stdin;
1	Badminton	30000.00
2	Badminton	35000.00
3	Badminton	40000.00
4	Badminton	45000.00
1	Tennis	35000.00
2	Tennis	40000.00
3	Tennis	45000.00
4	Tennis	50000.00
1	Table Tennis	25000.00
2	Table Tennis	30000.00
3	Table Tennis	35000.00
4	Table Tennis	40000.00
1	Chess	20000.00
2	Chess	25000.00
3	Chess	30000.00
4	Chess	35000.00
1	Carrom	15000.00
2	Carrom	20000.00
3	Carrom	25000.00
4	Carrom	30000.00
1	Football	80000.00
2	Football	85000.00
3	Football	90000.00
4	Football	95000.00
1	Cricket	100000.00
2	Cricket	105000.00
3	Cricket	110000.00
4	Cricket	115000.00
1	Basketball	60000.00
2	Basketball	65000.00
3	Basketball	70000.00
4	Basketball	75000.00
1	Volleyball	50000.00
2	Volleyball	55000.00
3	Volleyball	60000.00
4	Volleyball	65000.00
1	Kabaddi	55000.00
2	Kabaddi	60000.00
3	Kabaddi	65000.00
4	Kabaddi	70000.00
\.


--
-- TOC entry 5167 (class 0 OID 18470)
-- Dependencies: 244
-- Data for Name: tournament_teams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournament_teams (tournament_id, team_id, coach_name) FROM stdin;
1	1	Harish Nair
1	2	Sandeep Patel
1	3	Rajesh Joshi
1	4	Vikram Mehta
1	5	Pravin Shah
1	6	Manoj Iyer
1	7	Ramesh Reddy
1	8	Kunal Desai
1	9	Anil Trivedi
1	10	Paresh Raval
1	11	Tejas Chauhan
1	12	Sanjay Bhatt
1	13	Amit Patel
1	14	Deepak Shah
1	15	Rohit Nair
1	16	Vishal Mehta
1	17	Rajan Joshi
1	18	Harsh Patel
1	19	Ajay Mehta
1	20	Dhruv Deshmukh
1	21	Vikas Shah
1	22	Yogesh Iyer
1	23	Prashant Trivedi
1	24	Hemant Chauhan
1	25	Sanjay Desai
1	26	Rakesh Mehta
1	27	Nitin Joshi
1	28	Jay Patel
1	29	Mihir Reddy
1	30	Tushar Shah
1	31	Rupesh Iyer
1	32	Kishan Chauhan
1	33	Ankit Desai
1	34	Manish Mehta
1	35	Raj Chauhan
1	36	Ketan Shah
1	37	Yash Patel
1	38	Dhaval Joshi
1	39	Ravi Trivedi
1	40	Viral Mehta
2	1	Arun Nair
2	2	Mahesh Patel
2	3	Rohit Joshi
2	4	Vivek Mehta
2	5	Nirav Shah
2	6	Tejas Iyer
2	7	Kiran Reddy
2	8	Vatsal Desai
2	9	Chirag Trivedi
2	10	Aayush Raval
2	11	Manav Chauhan
2	12	Jignesh Bhatt
2	13	Paresh Patel
2	14	Anil Shah
2	15	Nilesh Nair
2	16	Hemant Mehta
2	17	Rahul Joshi
2	18	Kishor Mehta
2	19	Jay Reddy
2	20	Hiren Deshmukh
2	21	Pranav Shah
2	22	Suresh Iyer
2	23	Mitesh Trivedi
2	24	Bhavin Chauhan
2	25	Amit Desai
2	26	Rohan Mehta
2	27	Harsh Joshi
2	28	Ketan Patel
2	29	Ajay Reddy
2	30	Manish Shah
2	31	Rupen Iyer
2	32	Yogesh Chauhan
2	33	Anuj Desai
2	34	Rajat Mehta
2	35	Dhruv Chauhan
2	36	Harsh Shah
2	37	Tapan Patel
2	38	Yash Joshi
2	39	Amit Trivedi
2	40	Deepak Mehta
3	1	Kunal Nair
3	2	Sagar Patel
3	3	Nikhil Joshi
3	4	Raj Mehta
3	5	Chetan Shah
3	6	Pratik Iyer
3	7	Dhruv Reddy
3	8	Ritesh Desai
3	9	Vivek Trivedi
3	10	Rajesh Raval
3	11	Kiran Chauhan
3	12	Manish Bhatt
3	13	Anil Patel
3	14	Tejas Shah
3	15	Rohit Nair
3	16	Hemant Desai
3	17	Nirav Joshi
3	18	Paresh Mehta
3	19	Rohit Reddy
3	20	Hitesh Deshmukh
3	21	Aakash Shah
3	22	Suresh Iyer
3	23	Jay Trivedi
3	24	Bhavik Chauhan
3	25	Nikhil Desai
3	26	Karan Mehta
3	27	Ritesh Joshi
3	28	Deep Patel
3	29	Mahesh Reddy
3	30	Dhaval Shah
3	31	Rupesh Iyer
3	32	Yogesh Chauhan
3	33	Amit Desai
3	34	Raj Mehta
3	35	Tushar Chauhan
3	36	Hiren Shah
3	37	Manoj Patel
3	38	Yash Joshi
3	39	Ankit Trivedi
3	40	Nirav Mehta
\.


--
-- TOC entry 5146 (class 0 OID 18165)
-- Dependencies: 223
-- Data for Name: tournaments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournaments (tournament_id, tournament_name, start_date, end_date) FROM stdin;
1	Concours'22	2022-11-02	2022-11-06
2	Concours'23	2023-10-25	2023-10-29
3	Concours'24	2024-11-06	2024-11-10
4	Concours'25	2025-11-05	2025-11-09
\.


--
-- TOC entry 5152 (class 0 OID 18228)
-- Dependencies: 229
-- Data for Name: venues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.venues (venue_id, name, capacity, venue_type, maintenance_cost) FROM stdin;
1	Cricket Ground - 1	25000	Outdoor	75000.00
2	Cricket Ground - 2	22000	Outdoor	72000.00
3	Football Ground - 1	30000	Outdoor	80000.00
4	Football Ground - 2	27000	Outdoor	76000.00
5	Basketball Court - 1	4000	Outdoor	35000.00
6	Basketball Court - 2	3500	Outdoor	32000.00
7	Volleyball Court - 1	4000	Outdoor	28000.00
8	Volleyball Court - 2	3500	Outdoor	26000.00
9	Kabaddi Ground - 1	6000	Outdoor	35000.00
10	Kabaddi Ground - 2	5500	Outdoor	33000.00
11	Badminton Court - 1	2000	Indoor	25000.00
12	Badminton Court - 2	1800	Indoor	24000.00
13	Tennis Arena - 1	4000	Indoor	35000.00
14	Tennis Arena - 2	4200	Outdoor	36000.00
15	Table Tennis Hall - 1	800	Indoor	15000.00
16	Table Tennis Hall - 2	1000	Indoor	16000.00
17	Chess Hall - 1	600	Indoor	10000.00
18	Chess Hall - 2	700	Indoor	11000.00
19	Carrom Center - 1	400	Indoor	8000.00
20	Carrom Center - 2	500	Indoor	9000.00
21	Multipurpose Indoor Stadium	8000	Indoor	45000.00
\.


--
-- TOC entry 5155 (class 0 OID 18254)
-- Dependencies: 232
-- Data for Name: volunteer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.volunteer (volunteer_id, name, gender, years_of_experience, dob, contact, availability_status) FROM stdin;
1	Aarav Patel	M	3	2002-05-14	9900000001	Available
2	Isha Shah	F	2	2003-03-22	9900000002	On Duty
3	Rohan Desai	M	4	2001-09-11	9900000003	Available
4	Meera Joshi	F	1	2004-01-17	9900000004	On Leave
5	Nikhil Reddy	M	5	2000-07-09	9900000005	Available
6	Kavya Mehta	F	2	2003-11-20	9900000006	Available
7	Ankit Parmar	M	6	1999-12-15	9900000007	On Duty
8	Priya Solanki	F	3	2002-04-08	9900000008	Available
9	Devansh Trivedi	M	4	2001-06-29	9900000009	Available
10	Riya Bhatt	F	1	2005-02-14	9900000010	On Leave
11	Manav Shah	M	2	2003-01-20	9900000011	Available
12	Ananya Iyer	F	0	2005-06-18	9900000012	Available
13	Jay Mehta	M	5	2000-10-12	9900000013	On Duty
14	Krupa Deshmukh	F	2	2003-07-09	9900000014	Available
15	Raj Patel	M	6	1999-11-04	9900000015	Available
16	Diya Nair	F	3	2002-08-23	9900000016	On Leave
17	Karan Chauhan	M	2	2003-12-02	9900000017	Available
18	Roshni Mehta	F	1	2004-03-10	9900000018	Available
19	Arjun Rao	M	4	2001-09-15	9900000019	Available
20	Kriti Bhatt	F	2	2003-05-30	9900000020	On Duty
21	Siddharth Iyer	M	5	2000-07-07	9900000021	Available
22	Janhvi Solanki	F	1	2004-04-28	9900000022	Available
23	Yash Patel	M	3	2002-11-22	9900000023	On Leave
24	Nidhi Mehta	F	4	2001-10-05	9900000024	Available
25	Vivek Shah	M	6	1999-08-14	9900000025	Available
26	Kajal Iyer	F	3	2002-06-10	9900000026	On Duty
27	Hitesh Desai	M	7	1998-09-21	9900000027	Available
28	Surbhi Nair	F	4	2001-12-17	9900000028	Available
29	Akash Reddy	M	5	2000-05-25	9900000029	Available
30	Pooja Trivedi	F	2	2003-02-10	9900000030	Available
31	Amit Bhatia	M	3	2002-09-01	9900000031	Available
32	Ritika Shah	F	2	2003-05-09	9900000032	Available
33	Chirag Patel	M	4	2001-08-17	9900000033	On Leave
34	Bhavika Mehta	F	1	2005-04-04	9900000034	Available
35	Parth Trivedi	M	6	1999-12-21	9900000035	Available
36	Komal Joshi	F	0	2005-09-17	9900000036	Available
37	Dhruv Shah	M	4	2001-07-21	9900000037	On Duty
38	Shruti Desai	F	2	2003-10-29	9900000038	Available
39	Ramesh Patel	M	8	1998-11-12	9900000039	Available
40	Sonal Nair	F	4	2001-03-08	9900000040	On Leave
41	Kishan Iyer	M	5	2000-02-28	9900000041	Available
42	Tanya Mehta	F	2	2003-06-12	9900000042	Available
43	Himanshu Shah	M	4	2001-05-20	9900000043	Available
44	Neha Deshmukh	F	3	2002-09-30	9900000044	Available
45	Aaryan Chauhan	M	2	2003-11-25	9900000045	On Duty
46	Mitali Reddy	F	4	2001-01-13	9900000046	Available
47	Rachit Solanki	M	5	2000-07-18	9900000047	Available
48	Sneha Patel	F	3	2002-08-10	9900000048	Available
49	Anshul Joshi	M	6	1999-09-22	9900000049	On Leave
50	Prerna Shah	F	1	2004-05-05	9900000050	Available
51	Arjit Nair	M	3	2002-06-14	9900000051	Available
52	Saanvi Mehta	F	1	2004-10-15	9900000052	On Duty
53	Vikram Desai	M	5	2000-09-09	9900000053	Available
54	Ritu Trivedi	F	3	2002-07-17	9900000054	Available
55	Yogesh Patel	M	2	2003-03-13	9900000055	Available
56	Alisha Shah	F	2	2003-08-29	9900000056	Available
57	Darshan Rao	M	4	2001-06-07	9900000057	On Duty
58	Ishita Nair	F	1	2005-02-11	9900000058	Available
59	Harsh Joshi	M	3	2002-09-25	9900000059	Available
60	Anjali Mehta	F	4	2001-10-18	9900000060	Available
61	Kabir Shah	M	2	2003-12-10	9900000061	Available
62	Trisha Desai	F	1	2005-03-27	9900000062	Available
63	Ayaan Iyer	M	3	2002-06-02	9900000063	Available
64	Rashmi Patel	F	2	2003-07-16	9900000064	On Leave
65	Manish Chauhan	M	5	2000-05-08	9900000065	Available
66	Divya Nair	F	3	2002-04-05	9900000066	Available
67	Tushar Mehta	M	6	1999-08-11	9900000067	Available
68	Pallavi Joshi	F	4	2001-01-29	9900000068	Available
69	Aditya Patel	M	7	1998-09-22	9900000069	Available
70	Simran Deshmukh	F	2	2003-06-03	9900000070	Available
71	Rahul Nair	M	8	1997-12-17	9900000071	On Duty
72	Shreya Shah	F	5	2000-08-02	9900000072	Available
73	Harshal Mehta	M	6	1999-03-23	9900000073	Available
74	Neelam Patel	F	4	2001-10-14	9900000074	Available
75	Rakesh Trivedi	M	7	1998-06-09	9900000075	Available
76	Tanvi Desai	F	2	2003-11-30	9900000076	Available
77	Gaurav Joshi	M	5	2000-01-25	9900000077	Available
78	Kashish Iyer	F	1	2004-02-18	9900000078	On Leave
79	Amitabh Reddy	M	4	2001-09-07	9900000079	Available
80	Roshni Mehta	F	3	2002-10-22	9900000080	Available
81	Sameer Chauhan	M	6	1999-07-21	9900000081	Available
82	Diya Solanki	F	3	2002-09-01	9900000082	Available
83	Tarun Nair	M	2	2003-05-04	9900000083	Available
84	Rekha Patel	F	4	2001-07-12	9900000084	On Duty
85	Bhavesh Shah	M	5	2000-10-30	9900000085	Available
86	Chaitali Mehta	F	1	2005-04-25	9900000086	Available
87	Mohit Reddy	M	7	1998-12-13	9900000087	Available
88	Aarushi Desai	F	3	2002-11-19	9900000088	Available
89	Nirav Patel	M	6	1999-08-27	9900000089	Available
90	Snehal Joshi	F	2	2003-09-30	9900000090	Available
91	Ravi Kumar	M	4	2001-03-15	9900000091	Available
92	Pooja Shah	F	2	2003-10-09	9900000092	On Leave
93	Arnav Mehta	M	3	2002-05-06	9900000093	Available
94	Mihika Deshmukh	F	2	2003-12-11	9900000094	Available
95	Sameera Iyer	O	4	2001-07-04	9900000095	Available
96	Advik Patel	M	5	2000-11-18	9900000096	Available
97	Tejal Nair	F	3	2002-09-22	9900000097	Available
98	Rohan Shah	M	6	1999-05-12	9900000098	Available
99	Meghna Trivedi	O	2	2004-01-27	9900000099	Available
100	Suresh Reddy	M	8	1997-10-08	9900000100	Available
\.


--
-- TOC entry 4881 (class 2606 OID 18100)
-- Name: colleges colleges_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.colleges
    ADD CONSTRAINT colleges_email_key UNIQUE (email);


--
-- TOC entry 4883 (class 2606 OID 18098)
-- Name: colleges colleges_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.colleges
    ADD CONSTRAINT colleges_name_key UNIQUE (name);


--
-- TOC entry 4885 (class 2606 OID 18096)
-- Name: colleges colleges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.colleges
    ADD CONSTRAINT colleges_pkey PRIMARY KEY (college_id);


--
-- TOC entry 4935 (class 2606 OID 18367)
-- Name: i_issue_record i_issue_record_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.i_issue_record
    ADD CONSTRAINT i_issue_record_pkey PRIMARY KEY (i_match_id, item_id);


--
-- TOC entry 4939 (class 2606 OID 18399)
-- Name: i_match_ref i_match_ref_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.i_match_ref
    ADD CONSTRAINT i_match_ref_pkey PRIMARY KEY (i_match_id, referee_id);


--
-- TOC entry 4943 (class 2606 OID 18429)
-- Name: i_volunteering_record i_volunteering_record_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.i_volunteering_record
    ADD CONSTRAINT i_volunteering_record_pkey PRIMARY KEY (i_match_id, volunteer_id);


--
-- TOC entry 4923 (class 2606 OID 18277)
-- Name: individual_sport_matches individual_sport_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_sport_matches
    ADD CONSTRAINT individual_sport_matches_pkey PRIMARY KEY (i_match_id);


--
-- TOC entry 4889 (class 2606 OID 18112)
-- Name: individual_sport_players individual_sport_players_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_sport_players
    ADD CONSTRAINT individual_sport_players_pkey PRIMARY KEY (player_id);


--
-- TOC entry 4925 (class 2606 OID 18311)
-- Name: individual_sport_result individual_sport_result_i_match_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_sport_result
    ADD CONSTRAINT individual_sport_result_i_match_id_key UNIQUE (i_match_id);


--
-- TOC entry 4927 (class 2606 OID 18309)
-- Name: individual_sport_result individual_sport_result_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_sport_result
    ADD CONSTRAINT individual_sport_result_pkey PRIMARY KEY (i_result_id);


--
-- TOC entry 4903 (class 2606 OID 18197)
-- Name: injury_record injury_record_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.injury_record
    ADD CONSTRAINT injury_record_pkey PRIMARY KEY (player_id, staff_id, injury_date);


--
-- TOC entry 4911 (class 2606 OID 18240)
-- Name: inventory inventory_item_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_item_name_key UNIQUE (item_name);


--
-- TOC entry 4913 (class 2606 OID 18238)
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (item_id);


--
-- TOC entry 4901 (class 2606 OID 18192)
-- Name: medical_staff medical_staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_staff
    ADD CONSTRAINT medical_staff_pkey PRIMARY KEY (staff_id);


--
-- TOC entry 4887 (class 2606 OID 18106)
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (player_id);


--
-- TOC entry 4915 (class 2606 OID 18248)
-- Name: referees referees_contact_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referees
    ADD CONSTRAINT referees_contact_key UNIQUE (contact);


--
-- TOC entry 4917 (class 2606 OID 18246)
-- Name: referees referees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referees
    ADD CONSTRAINT referees_pkey PRIMARY KEY (referee_id);


--
-- TOC entry 4905 (class 2606 OID 18212)
-- Name: sponsors sponsors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sponsors
    ADD CONSTRAINT sponsors_pkey PRIMARY KEY (sponsor_id);


--
-- TOC entry 4907 (class 2606 OID 18217)
-- Name: sponsorship_record sponsorship_record_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sponsorship_record
    ADD CONSTRAINT sponsorship_record_pkey PRIMARY KEY (sponsor_id, tournament_id);


--
-- TOC entry 4879 (class 2606 OID 18087)
-- Name: sports sports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sports
    ADD CONSTRAINT sports_pkey PRIMARY KEY (sport_name);


--
-- TOC entry 4937 (class 2606 OID 18383)
-- Name: t_issue_record t_issue_record_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_issue_record
    ADD CONSTRAINT t_issue_record_pkey PRIMARY KEY (t_match_id, item_id);


--
-- TOC entry 4941 (class 2606 OID 18414)
-- Name: t_match_ref t_match_ref_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_match_ref
    ADD CONSTRAINT t_match_ref_pkey PRIMARY KEY (t_match_id, referee_id);


--
-- TOC entry 4945 (class 2606 OID 18444)
-- Name: t_volunteering_record t_volunteering_record_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_volunteering_record
    ADD CONSTRAINT t_volunteering_record_pkey PRIMARY KEY (t_match_id, volunteer_id);


--
-- TOC entry 4929 (class 2606 OID 18321)
-- Name: team_sport_matches team_sport_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_sport_matches
    ADD CONSTRAINT team_sport_matches_pkey PRIMARY KEY (t_match_id);


--
-- TOC entry 4893 (class 2606 OID 18147)
-- Name: team_sport_players team_sport_players_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_sport_players
    ADD CONSTRAINT team_sport_players_pkey PRIMARY KEY (player_id);


--
-- TOC entry 4931 (class 2606 OID 18353)
-- Name: team_sport_result team_sport_result_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_sport_result
    ADD CONSTRAINT team_sport_result_pkey PRIMARY KEY (t_result_id);


--
-- TOC entry 4933 (class 2606 OID 18355)
-- Name: team_sport_result team_sport_result_t_match_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_sport_result
    ADD CONSTRAINT team_sport_result_t_match_id_key UNIQUE (t_match_id);


--
-- TOC entry 4891 (class 2606 OID 18132)
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (team_id);


--
-- TOC entry 4947 (class 2606 OID 18459)
-- Name: tournament_player tournament_player_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_player
    ADD CONSTRAINT tournament_player_pkey PRIMARY KEY (tournament_id, player_id);


--
-- TOC entry 4899 (class 2606 OID 18176)
-- Name: tournament_sport tournament_sport_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_sport
    ADD CONSTRAINT tournament_sport_pkey PRIMARY KEY (tournament_id, sport_name);


--
-- TOC entry 4949 (class 2606 OID 18474)
-- Name: tournament_teams tournament_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_teams
    ADD CONSTRAINT tournament_teams_pkey PRIMARY KEY (tournament_id, team_id);


--
-- TOC entry 4895 (class 2606 OID 18169)
-- Name: tournaments tournaments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_pkey PRIMARY KEY (tournament_id);


--
-- TOC entry 4897 (class 2606 OID 18171)
-- Name: tournaments tournaments_tournament_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_tournament_name_key UNIQUE (tournament_name);


--
-- TOC entry 4909 (class 2606 OID 18232)
-- Name: venues venues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (venue_id);


--
-- TOC entry 4919 (class 2606 OID 18262)
-- Name: volunteer volunteer_contact_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.volunteer
    ADD CONSTRAINT volunteer_contact_key UNIQUE (contact);


--
-- TOC entry 4921 (class 2606 OID 18260)
-- Name: volunteer volunteer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.volunteer
    ADD CONSTRAINT volunteer_pkey PRIMARY KEY (volunteer_id);


--
-- TOC entry 4993 (class 2620 OID 26290)
-- Name: individual_sport_result trg_finish_individual_match; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_finish_individual_match AFTER INSERT ON public.individual_sport_result FOR EACH ROW EXECUTE FUNCTION public.mark_individual_match_finished();


--
-- TOC entry 4994 (class 2620 OID 26292)
-- Name: team_sport_result trg_finish_team_match; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_finish_team_match AFTER INSERT ON public.team_sport_result FOR EACH ROW EXECUTE FUNCTION public.mark_team_match_finished();


--
-- TOC entry 4992 (class 2620 OID 26288)
-- Name: injury_record trg_update_health_on_injury; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_health_on_injury AFTER INSERT ON public.injury_record FOR EACH ROW EXECUTE FUNCTION public.update_player_health_on_injury();


--
-- TOC entry 4976 (class 2606 OID 18368)
-- Name: i_issue_record i_issue_record_i_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.i_issue_record
    ADD CONSTRAINT i_issue_record_i_match_id_fkey FOREIGN KEY (i_match_id) REFERENCES public.individual_sport_matches(i_match_id) ON DELETE CASCADE;


--
-- TOC entry 4977 (class 2606 OID 18373)
-- Name: i_issue_record i_issue_record_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.i_issue_record
    ADD CONSTRAINT i_issue_record_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory(item_id) ON DELETE CASCADE;


--
-- TOC entry 4980 (class 2606 OID 18400)
-- Name: i_match_ref i_match_ref_i_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.i_match_ref
    ADD CONSTRAINT i_match_ref_i_match_id_fkey FOREIGN KEY (i_match_id) REFERENCES public.individual_sport_matches(i_match_id) ON DELETE CASCADE;


--
-- TOC entry 4981 (class 2606 OID 18405)
-- Name: i_match_ref i_match_ref_referee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.i_match_ref
    ADD CONSTRAINT i_match_ref_referee_id_fkey FOREIGN KEY (referee_id) REFERENCES public.referees(referee_id) ON DELETE CASCADE;


--
-- TOC entry 4984 (class 2606 OID 18430)
-- Name: i_volunteering_record i_volunteering_record_i_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.i_volunteering_record
    ADD CONSTRAINT i_volunteering_record_i_match_id_fkey FOREIGN KEY (i_match_id) REFERENCES public.individual_sport_matches(i_match_id) ON DELETE CASCADE;


--
-- TOC entry 4985 (class 2606 OID 18435)
-- Name: i_volunteering_record i_volunteering_record_volunteer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.i_volunteering_record
    ADD CONSTRAINT i_volunteering_record_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.volunteer(volunteer_id) ON DELETE CASCADE;


--
-- TOC entry 4964 (class 2606 OID 18283)
-- Name: individual_sport_matches individual_sport_matches_player1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_sport_matches
    ADD CONSTRAINT individual_sport_matches_player1_id_fkey FOREIGN KEY (player1_id) REFERENCES public.individual_sport_players(player_id) ON DELETE CASCADE;


--
-- TOC entry 4965 (class 2606 OID 18288)
-- Name: individual_sport_matches individual_sport_matches_player2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_sport_matches
    ADD CONSTRAINT individual_sport_matches_player2_id_fkey FOREIGN KEY (player2_id) REFERENCES public.individual_sport_players(player_id) ON DELETE CASCADE;


--
-- TOC entry 4966 (class 2606 OID 18298)
-- Name: individual_sport_matches individual_sport_matches_sport_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_sport_matches
    ADD CONSTRAINT individual_sport_matches_sport_name_fkey FOREIGN KEY (sport_name) REFERENCES public.sports(sport_name) ON DELETE CASCADE;


--
-- TOC entry 4967 (class 2606 OID 18293)
-- Name: individual_sport_matches individual_sport_matches_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_sport_matches
    ADD CONSTRAINT individual_sport_matches_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(tournament_id) ON DELETE CASCADE;


--
-- TOC entry 4968 (class 2606 OID 18278)
-- Name: individual_sport_matches individual_sport_matches_venue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_sport_matches
    ADD CONSTRAINT individual_sport_matches_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES public.venues(venue_id) ON DELETE SET NULL;


--
-- TOC entry 4950 (class 2606 OID 18118)
-- Name: individual_sport_players individual_sport_players_college_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_sport_players
    ADD CONSTRAINT individual_sport_players_college_id_fkey FOREIGN KEY (college_id) REFERENCES public.colleges(college_id);


--
-- TOC entry 4951 (class 2606 OID 18113)
-- Name: individual_sport_players individual_sport_players_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_sport_players
    ADD CONSTRAINT individual_sport_players_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(player_id);


--
-- TOC entry 4952 (class 2606 OID 18123)
-- Name: individual_sport_players individual_sport_players_sport_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_sport_players
    ADD CONSTRAINT individual_sport_players_sport_name_fkey FOREIGN KEY (sport_name) REFERENCES public.sports(sport_name);


--
-- TOC entry 4969 (class 2606 OID 18312)
-- Name: individual_sport_result individual_sport_result_i_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_sport_result
    ADD CONSTRAINT individual_sport_result_i_match_id_fkey FOREIGN KEY (i_match_id) REFERENCES public.individual_sport_matches(i_match_id) ON DELETE CASCADE;


--
-- TOC entry 4959 (class 2606 OID 18198)
-- Name: injury_record injury_record_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.injury_record
    ADD CONSTRAINT injury_record_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(player_id) ON DELETE CASCADE;


--
-- TOC entry 4960 (class 2606 OID 18203)
-- Name: injury_record injury_record_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.injury_record
    ADD CONSTRAINT injury_record_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.medical_staff(staff_id) ON DELETE SET NULL;


--
-- TOC entry 4963 (class 2606 OID 18249)
-- Name: referees referees_sport_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referees
    ADD CONSTRAINT referees_sport_name_fkey FOREIGN KEY (sport_name) REFERENCES public.sports(sport_name) ON DELETE CASCADE;


--
-- TOC entry 4961 (class 2606 OID 18218)
-- Name: sponsorship_record sponsorship_record_sponsor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sponsorship_record
    ADD CONSTRAINT sponsorship_record_sponsor_id_fkey FOREIGN KEY (sponsor_id) REFERENCES public.sponsors(sponsor_id) ON DELETE CASCADE;


--
-- TOC entry 4962 (class 2606 OID 18223)
-- Name: sponsorship_record sponsorship_record_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sponsorship_record
    ADD CONSTRAINT sponsorship_record_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(tournament_id) ON DELETE CASCADE;


--
-- TOC entry 4978 (class 2606 OID 18389)
-- Name: t_issue_record t_issue_record_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_issue_record
    ADD CONSTRAINT t_issue_record_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.inventory(item_id) ON DELETE CASCADE;


--
-- TOC entry 4979 (class 2606 OID 18384)
-- Name: t_issue_record t_issue_record_t_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_issue_record
    ADD CONSTRAINT t_issue_record_t_match_id_fkey FOREIGN KEY (t_match_id) REFERENCES public.team_sport_matches(t_match_id) ON DELETE CASCADE;


--
-- TOC entry 4982 (class 2606 OID 18420)
-- Name: t_match_ref t_match_ref_referee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_match_ref
    ADD CONSTRAINT t_match_ref_referee_id_fkey FOREIGN KEY (referee_id) REFERENCES public.referees(referee_id) ON DELETE CASCADE;


--
-- TOC entry 4983 (class 2606 OID 18415)
-- Name: t_match_ref t_match_ref_t_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_match_ref
    ADD CONSTRAINT t_match_ref_t_match_id_fkey FOREIGN KEY (t_match_id) REFERENCES public.team_sport_matches(t_match_id) ON DELETE CASCADE;


--
-- TOC entry 4986 (class 2606 OID 18445)
-- Name: t_volunteering_record t_volunteering_record_t_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_volunteering_record
    ADD CONSTRAINT t_volunteering_record_t_match_id_fkey FOREIGN KEY (t_match_id) REFERENCES public.team_sport_matches(t_match_id) ON DELETE CASCADE;


--
-- TOC entry 4987 (class 2606 OID 18450)
-- Name: t_volunteering_record t_volunteering_record_volunteer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.t_volunteering_record
    ADD CONSTRAINT t_volunteering_record_volunteer_id_fkey FOREIGN KEY (volunteer_id) REFERENCES public.volunteer(volunteer_id) ON DELETE CASCADE;


--
-- TOC entry 4970 (class 2606 OID 18332)
-- Name: team_sport_matches team_sport_matches_sport_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_sport_matches
    ADD CONSTRAINT team_sport_matches_sport_name_fkey FOREIGN KEY (sport_name) REFERENCES public.sports(sport_name) ON DELETE CASCADE;


--
-- TOC entry 4971 (class 2606 OID 18322)
-- Name: team_sport_matches team_sport_matches_team1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_sport_matches
    ADD CONSTRAINT team_sport_matches_team1_id_fkey FOREIGN KEY (team1_id) REFERENCES public.teams(team_id) ON DELETE CASCADE;


--
-- TOC entry 4972 (class 2606 OID 18327)
-- Name: team_sport_matches team_sport_matches_team2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_sport_matches
    ADD CONSTRAINT team_sport_matches_team2_id_fkey FOREIGN KEY (team2_id) REFERENCES public.teams(team_id) ON DELETE CASCADE;


--
-- TOC entry 4973 (class 2606 OID 18342)
-- Name: team_sport_matches team_sport_matches_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_sport_matches
    ADD CONSTRAINT team_sport_matches_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(tournament_id) ON DELETE CASCADE;


--
-- TOC entry 4974 (class 2606 OID 18337)
-- Name: team_sport_matches team_sport_matches_venue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_sport_matches
    ADD CONSTRAINT team_sport_matches_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES public.venues(venue_id) ON DELETE SET NULL;


--
-- TOC entry 4955 (class 2606 OID 18148)
-- Name: team_sport_players team_sport_players_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_sport_players
    ADD CONSTRAINT team_sport_players_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(player_id);


--
-- TOC entry 4956 (class 2606 OID 18153)
-- Name: team_sport_players team_sport_players_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_sport_players
    ADD CONSTRAINT team_sport_players_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(team_id);


--
-- TOC entry 4975 (class 2606 OID 18356)
-- Name: team_sport_result team_sport_result_t_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_sport_result
    ADD CONSTRAINT team_sport_result_t_match_id_fkey FOREIGN KEY (t_match_id) REFERENCES public.team_sport_matches(t_match_id) ON DELETE CASCADE;


--
-- TOC entry 4953 (class 2606 OID 18133)
-- Name: teams teams_college_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_college_id_fkey FOREIGN KEY (college_id) REFERENCES public.colleges(college_id) ON DELETE CASCADE;


--
-- TOC entry 4954 (class 2606 OID 18138)
-- Name: teams teams_sport_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_sport_name_fkey FOREIGN KEY (sport_name) REFERENCES public.sports(sport_name) ON DELETE CASCADE;


--
-- TOC entry 4988 (class 2606 OID 18465)
-- Name: tournament_player tournament_player_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_player
    ADD CONSTRAINT tournament_player_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(player_id) ON DELETE CASCADE;


--
-- TOC entry 4989 (class 2606 OID 18460)
-- Name: tournament_player tournament_player_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_player
    ADD CONSTRAINT tournament_player_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(tournament_id) ON DELETE CASCADE;


--
-- TOC entry 4957 (class 2606 OID 18182)
-- Name: tournament_sport tournament_sport_sport_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_sport
    ADD CONSTRAINT tournament_sport_sport_name_fkey FOREIGN KEY (sport_name) REFERENCES public.sports(sport_name) ON DELETE CASCADE;


--
-- TOC entry 4958 (class 2606 OID 18177)
-- Name: tournament_sport tournament_sport_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_sport
    ADD CONSTRAINT tournament_sport_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(tournament_id) ON DELETE CASCADE;


--
-- TOC entry 4990 (class 2606 OID 18480)
-- Name: tournament_teams tournament_teams_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_teams
    ADD CONSTRAINT tournament_teams_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(team_id) ON DELETE CASCADE;


--
-- TOC entry 4991 (class 2606 OID 18475)
-- Name: tournament_teams tournament_teams_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_teams
    ADD CONSTRAINT tournament_teams_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(tournament_id) ON DELETE CASCADE;


-- Completed on 2026-06-12 22:26:23

--
-- PostgreSQL database dump complete
--

