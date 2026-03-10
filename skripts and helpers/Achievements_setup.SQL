-- =============================================
-- SCHRITT 1: Alte Daten und Spalte loeschen
-- =============================================

-- Alle alten Eintraege loeschen
DELETE FROM achievements;

-- Unnoetige Spalte loeschen
ALTER TABLE achievements DROP COLUMN IF EXISTS "requirement=var";

-- Auto-Increment zuruecksetzen damit IDs wieder bei 1 anfangen
ALTER SEQUENCE achievements_id_seq RESTART WITH 1;


-- =============================================
-- SCHRITT 2: Alle Achievements einfuegen
-- =============================================

INSERT INTO achievements (name, description, category, requirement) VALUES

-- ---------------------------
-- ADVENTURE & TRAVEL
-- ---------------------------

('Traveler I',
'Besuche 3 verschiedene Laender',
'Adventure & Travel',
'{"type": "countries_visited", "value": 3, "mechanism": "unique_count"}'),

('Traveler II',
'Besuche 5 verschiedene Laender',
'Adventure & Travel',
'{"type": "countries_visited", "value": 5, "mechanism": "unique_count"}'),

('Traveler III',
'Besuche 8 verschiedene Laender',
'Adventure & Travel',
'{"type": "countries_visited", "value": 8, "mechanism": "unique_count"}'),

('Weltreisender',
'Besuche 194 Laender',
'Adventure & Travel',
'{"type": "countries_visited", "value": 194, "mechanism": "unique_count"}'),

('Explorer',
'Sei mehr als 100 km von zuhause entfernt',
'Adventure & Travel',
'{"type": "home_distance_km", "value": 100, "mechanism": "simple_threshold"}'),

('Adventure',
'Mache mehr als 20000 Schritte an einem neuen Ort der mehr als 50 km von zuhause entfernt ist',
'Adventure & Travel',
'{"mechanism": "combined", "conditions": [{"type": "steps_today", "value": 20000, "operator": "greater_equal"}, {"type": "home_distance_km", "value": 50, "operator": "greater_equal"}, {"type": "is_new_location", "value": true, "operator": "equals"}]}'),

('Landlocked',
'Besuche ein Land ohne Meereszugang',
'Adventure & Travel',
'{"type": "visited_landlocked_country", "value": true, "mechanism": "simple_threshold"}'),

('Island Hopper',
'Besuche 3 verschiedene Inseln',
'Adventure & Travel',
'{"type": "islands_visited", "value": 3, "mechanism": "unique_count"}'),

('Capital Collector',
'Besuche 10 Hauptstaedte',
'Adventure & Travel',
'{"type": "capitals_visited", "value": 10, "mechanism": "unique_count"}'),

('Border Crosser',
'Ueberquere 3 verschiedene Landesgrenzen an einem Tag',
'Adventure & Travel',
'{"type": "borders_crossed_today", "value": 3, "mechanism": "simple_threshold"}'),

('Border Crosser I',
'Ueberquere 5 verschiedene Landesgrenzen an einem Tag',
'Adventure & Travel',
'{"type": "borders_crossed_today", "value": 5, "mechanism": "simple_threshold"}'),

('Crossy Road',
'Stehe auf einer Landesgrenze zwischen zwei Laendern',
'Adventure & Travel',
'{"type": "on_border", "value": true, "mechanism": "simple_threshold"}'),

('Four Corners',
'Stehe an einem Punkt wo 4 Laender zusammentreffen',
'Adventure & Travel',
'{"type": "four_corners", "value": true, "mechanism": "simple_threshold"}'),

('Time Traveler',
'Besuche 3 verschiedene Zeitzonen an einem Tag',
'Adventure & Travel',
'{"type": "timezones_today", "value": 3, "mechanism": "unique_count"}'),

('Urban Explorer',
'Entdecke 10 verschiedene Staedte innerhalb eines Monats',
'Adventure & Travel',
'{"type": "cities_this_month", "value": 10, "mechanism": "unique_count"}'),

('German Explorer',
'Besuche mindestens 10 deutsche Staedte',
'Adventure & Travel',
'{"type": "german_cities_visited", "value": 10, "mechanism": "unique_count"}'),

('Polar Bear',
'Bereise die Antarktis',
'Adventure & Travel',
'{"type": "visited_antarctica", "value": true, "mechanism": "simple_threshold"}'),

('Fly',
'Fliege in einem Flugzeug',
'Adventure & Travel',
'{"mechanism": "combined", "conditions": [{"type": "speed_kmh", "value": 200, "operator": "greater_equal"}, {"type": "altitude_m", "value": 1000, "operator": "greater_equal"}]}'),

('Speedster',
'Bewege dich mit mehr als 200 km/h in einem Fahrzeug',
'Adventure & Travel',
'{"type": "speed_kmh", "value": 200, "mechanism": "simple_threshold"}'),

('Sailor Sarah',
'Besuche 8 Laender nur per Schiff',
'Adventure & Travel',
'{"type": "countries_by_ship", "value": 8, "mechanism": "unique_count"}'),

('Skyfall',
'Mache einen Fallschirmsprung',
'Adventure & Travel',
'{"type": "skydive_detected", "value": true, "mechanism": "simple_threshold"}'),

('Void',
'Besuche Bielefeld',
'Adventure & Travel',
'{"type": "visited_city", "value": "Bielefeld", "mechanism": "city_visit"}'),

('Tokyo Drift',
'Besuche Tokio',
'Adventure & Travel',
'{"type": "visited_city", "value": "Tokyo", "mechanism": "city_visit"}'),

('Autopilot Disabled',
'Nimm einen anderen Weg als sonst zum gleichen Ziel',
'Adventure & Travel',
'{"type": "new_route_to_known_destination", "value": true, "mechanism": "simple_threshold"}'),

('Unknown Chunk Loaded',
'Betrete nach einem Jahr Nutzung ein komplett neues Gebiet',
'Adventure & Travel',
'{"type": "new_area_after_one_year", "value": true, "mechanism": "simple_threshold"}'),


-- ---------------------------
-- FITNESS & HEALTH
-- ---------------------------

('Wanderer',
'Wandere an einem Tag mehr als 12 km',
'Fitness & Health',
'{"type": "distance_today_km", "value": 12, "mechanism": "simple_threshold"}'),

('Wanderer II',
'Wandere an einem Tag mehr als 18 km',
'Fitness & Health',
'{"type": "distance_today_km", "value": 18, "mechanism": "simple_threshold"}'),

('Marathoner',
'Laufe 42 km an einem Tag',
'Fitness & Health',
'{"type": "distance_today_km", "value": 42, "mechanism": "simple_threshold"}'),

('Early Bird',
'Mache vor 5 Uhr morgens mehr als 200 Schritte',
'Fitness & Health',
'{"mechanism": "combined", "conditions": [{"type": "current_hour", "value": 5, "operator": "less_than"}, {"type": "steps_today", "value": 200, "operator": "greater_equal"}]}'),

('Night Walker',
'Laufe mehr als 5 km zwischen 22 und 4 Uhr',
'Fitness & Health',
'{"type": "night_distance_km", "value": 5, "mechanism": "simple_threshold"}'),

('30k Club',
'Mache 30000 Schritte an einem Tag',
'Fitness & Health',
'{"type": "steps_today", "value": 30000, "mechanism": "simple_threshold"}'),

('1 Week',
'Mache 7 Tage in Folge mindestens 10000 Schritte pro Tag',
'Fitness & Health',
'{"type": "steps_streak_days", "value": 7, "mechanism": "simple_threshold"}'),

('Iron Legs',
'Mache 7 Tage in Folge mehr als 10000 Schritte',
'Fitness & Health',
'{"type": "steps_streak_days", "value": 7, "mechanism": "simple_threshold"}'),

('Cyclist',
'Fahre mehr als 50 km Fahrrad an einem Tag',
'Fitness & Health',
'{"type": "cycling_distance_today_km", "value": 50, "mechanism": "simple_threshold"}'),

('Recovery Day',
'Mache weniger als 3000 Schritte an einem Tag',
'Fitness & Health',
'{"type": "steps_today", "value": 3000, "mechanism": "less_than"}'),

('Minimalist',
'Mache weniger als 2000 Schritte an einem Tag',
'Fitness & Health',
'{"type": "steps_today", "value": 2000, "mechanism": "less_than"}'),

('Elevator? Never!',
'Steige an einem Tag mehr als 50 Stockwerke zu Fuss',
'Fitness & Health',
'{"type": "floors_today", "value": 50, "mechanism": "simple_threshold"}'),

('Mountain Goat',
'Besteige einen Berg ueber 2000 Meter',
'Fitness & Health',
'{"type": "altitude_m", "value": 2000, "mechanism": "simple_threshold"}'),

('Tutorial Finished',
'Werde 18 Jahre alt',
'Fitness & Health',
'{"type": "age", "value": 18, "mechanism": "simple_threshold"}'),

('50%',
'Werde 50 Jahre alt',
'Fitness & Health',
'{"type": "age", "value": 50, "mechanism": "simple_threshold"}'),

('100%',
'Werde 100 Jahre alt',
'Fitness & Health',
'{"type": "age", "value": 100, "mechanism": "simple_threshold"}'),

('Survive Covid 19',
'Sei vor 2021 geboren',
'Fitness & Health',
'{"type": "birth_year", "value": 2021, "mechanism": "less_than"}'),

('Homebody',
'Verlasse das Haus 48 Stunden nicht',
'Fitness & Health',
'{"type": "hours_at_home", "value": 48, "mechanism": "simple_threshold"}'),


-- ---------------------------
-- NATURE
-- ---------------------------

('Bushcamper I',
'Uebernachte eine Nacht in der Wildnis',
'Nature',
'{"type": "nights_in_wild", "value": 1, "mechanism": "simple_threshold"}'),

('Bushcamper II',
'Bleibe laenger als 3 Tage in der Wildnis',
'Nature',
'{"type": "days_in_wild", "value": 3, "mechanism": "simple_threshold"}'),

('Golden Hour',
'Sei draussen bei einem Sonnenauf- oder Sonnenuntergang',
'Nature',
'{"type": "golden_hour_outdoor", "value": true, "mechanism": "simple_threshold"}'),

('Sunrise Chaser',
'Sieh mehr als 3 Sonnenaufgaenge hintereinander',
'Nature',
'{"type": "sunrise_streak", "value": 3, "mechanism": "simple_threshold"}'),

('Night Owl',
'Sei mehr als 3 Naechte hintereinander draussen sobald es dunkel ist',
'Nature',
'{"type": "outdoor_night_streak", "value": 3, "mechanism": "simple_threshold"}'),

('Stargazer',
'Verbringe eine Nacht unter klarem Sternenhimmel',
'Nature',
'{"mechanism": "combined", "conditions": [{"type": "is_night", "value": true, "operator": "equals"}, {"type": "is_clear_sky", "value": true, "operator": "equals"}, {"type": "is_outdoor", "value": true, "operator": "equals"}]}'),

('Weather Resistant',
'Sei draussen trotz Regen und unter 5 Grad',
'Nature',
'{"mechanism": "combined", "conditions": [{"type": "temperature_c", "value": 5, "operator": "less_than"}, {"type": "is_raining", "value": true, "operator": "equals"}, {"type": "is_outdoor", "value": true, "operator": "equals"}]}'),

('First Snow',
'Sei beim ersten Schneefall des Jahres draussen',
'Nature',
'{"mechanism": "combined", "conditions": [{"type": "is_first_snow_of_year", "value": true, "operator": "equals"}, {"type": "is_outdoor", "value": true, "operator": "equals"}]}'),

('Snow Explorer',
'Verbringe mehr als 3 Stunden im Schnee',
'Nature',
'{"mechanism": "combined", "conditions": [{"type": "is_snowing", "value": true, "operator": "equals"}, {"type": "hours_outdoor_today", "value": 3, "operator": "greater_equal"}]}'),

('Rainbow Chaser',
'Sei draussen direkt nach einem Regen bei Sonnenschein',
'Nature',
'{"type": "rainbow_conditions_outdoor", "value": true, "mechanism": "simple_threshold"}'),

('Beach',
'Besuche einen Strand',
'Nature',
'{"type": "visited_beach", "value": true, "mechanism": "simple_threshold"}'),

('Miner',
'Sei 500 Meter unter dem Meeresspiegel',
'Nature',
'{"type": "altitude_m", "value": -500, "mechanism": "less_than"}'),

('Lost Signal',
'Sei 2 Stunden ohne Internet und GPS Verbindung',
'Nature',
'{"type": "hours_offline", "value": 2, "mechanism": "simple_threshold"}'),

('Offline Mode',
'Sei einen ganzen Tag offline',
'Nature',
'{"type": "hours_offline", "value": 24, "mechanism": "simple_threshold"}'),

('Flat Earther',
'Sei an einem Tag gleichzeitig an einer sehr tiefen und einer sehr hohen Stelle',
'Nature',
'{"type": "altitude_range_today_m", "value": 2000, "mechanism": "simple_threshold"}'),


-- ---------------------------
-- LANDMARKS
-- ---------------------------

('Eiffel Gazer',
'Besuche den Eiffelturm in Paris',
'Landmarks',
'{"type": "landmark", "value": "eiffel_tower", "mechanism": "landmark_visit"}'),

('Colosseum Visitor',
'Besuche das Kolosseum in Rom',
'Landmarks',
'{"type": "landmark", "value": "colosseum", "mechanism": "landmark_visit"}'),

('Big Ben Watcher',
'Besuche den Big Ben in London',
'Landmarks',
'{"type": "landmark", "value": "big_ben", "mechanism": "landmark_visit"}'),

('Sagrada Familia',
'Besuche die Sagrada Familia in Barcelona',
'Landmarks',
'{"type": "landmark", "value": "sagrada_familia", "mechanism": "landmark_visit"}'),

('Statue of Liberty',
'Besuche die Freiheitsstatue in New York',
'Landmarks',
'{"type": "landmark", "value": "statue_of_liberty", "mechanism": "landmark_visit"}'),

('Machu Picchu',
'Besuche Machu Picchu in Peru',
'Landmarks',
'{"type": "landmark", "value": "machu_picchu", "mechanism": "landmark_visit"}'),

('Taj Mahal',
'Besuche das Taj Mahal in Indien',
'Landmarks',
'{"type": "landmark", "value": "taj_mahal", "mechanism": "landmark_visit"}'),

('Great Wall Walker',
'Besuche die Chinesische Mauer',
'Landmarks',
'{"type": "landmark", "value": "great_wall", "mechanism": "landmark_visit"}'),

('Chichen Itza',
'Besuche Chichen Itza in Mexiko',
'Landmarks',
'{"type": "landmark", "value": "chichen_itza", "mechanism": "landmark_visit"}'),

('Christ the Redeemer',
'Besuche den Christus in Rio de Janeiro',
'Landmarks',
'{"type": "landmark", "value": "christ_redeemer", "mechanism": "landmark_visit"}'),

('Petra',
'Besuche Petra in Jordanien',
'Landmarks',
'{"type": "landmark", "value": "petra", "mechanism": "landmark_visit"}'),

('Half Wonder',
'Besuche 3 der 7 Weltwunder',
'Landmarks',
'{"type": "wonders_visited", "value": 3, "mechanism": "unique_count"}'),

('Wonder of the World',
'Besuche alle 7 Weltwunder',
'Landmarks',
'{"type": "wonders_visited", "value": 7, "mechanism": "unique_count"}'),

('Gamer',
'Besuche eine Gamescom',
'Landmarks',
'{"type": "visited_gamescom", "value": 1, "mechanism": "simple_threshold"}'),

('Gamer I',
'Besuche 3 Gamescoms',
'Landmarks',
'{"type": "visited_gamescom", "value": 3, "mechanism": "simple_threshold"}'),

('Gamer II',
'Besuche 5 Gamescoms',
'Landmarks',
'{"type": "visited_gamescom", "value": 5, "mechanism": "simple_threshold"}'),

('Maker',
'Besuche eine Maker Faire',
'Landmarks',
'{"type": "visited_makerfaire", "value": 1, "mechanism": "simple_threshold"}'),

('Maker I',
'Besuche 3 Maker Faires',
'Landmarks',
'{"type": "visited_makerfaire", "value": 3, "mechanism": "simple_threshold"}'),

('Maker II',
'Besuche 5 Maker Faires',
'Landmarks',
'{"type": "visited_makerfaire", "value": 5, "mechanism": "simple_threshold"}'),

('Culture Seeker',
'Besuche 5 Museen in einem Monat',
'Landmarks',
'{"type": "museums_this_month", "value": 5, "mechanism": "unique_count"}'),


-- ---------------------------
-- FUN
-- ---------------------------

('Goblin Mode',
'Gehe nach Mitternacht raus',
'Fun',
'{"mechanism": "combined", "conditions": [{"type": "current_hour", "value": 0, "operator": "greater_equal"}, {"type": "is_outdoor", "value": true, "operator": "equals"}]}'),

('Music Lover',
'Hoere mehr als 5 Stunden Musik an einem Tag',
'Fun',
'{"type": "music_hours_today", "value": 5, "mechanism": "simple_threshold"}'),

('Konami Code',
'Gib den Konami Code in der App ein',
'Fun',
'{"type": "konami_code_entered", "value": true, "mechanism": "simple_threshold"}'),

('Hello World',
'Logge dich zum ersten Mal in der App ein',
'Fun',
'{"type": "total_logins", "value": 1, "mechanism": "simple_threshold"}'),

('Old Phone',
'Benutze die App auf einem Handy das aelter als 5 Jahre ist',
'Fun',
'{"type": "device_age_years", "value": 5, "mechanism": "simple_threshold"}'),

('Friday the 13th',
'Oeffne die App an einem Freitag dem 13.',
'Fun',
'{"type": "is_friday_13th", "value": true, "mechanism": "simple_threshold"}'),

('Palindrome Day',
'Oeffne die App an einem Palindrom-Datum',
'Fun',
'{"type": "is_palindrome_date", "value": true, "mechanism": "simple_threshold"}'),

('Birthday',
'Oeffne die App genau an deinem Geburtstag',
'Fun',
'{"type": "is_users_birthday", "value": true, "mechanism": "simple_threshold"}'),

('404 Not Found',
'Laufe in der Natur mindestens 4 Mal an derselben Stelle vorbei',
'Fun',
'{"type": "same_spot_passes", "value": 4, "mechanism": "simple_threshold"}'),

('Mathias Mode',
'Benutze den Light Mode 30 Tage lang',
'Fun',
'{"type": "light_mode_days", "value": 30, "mechanism": "simple_threshold"}'),

('Void',
'Besuche Bielefeld',
'Fun',
'{"type": "visited_city", "value": "Bielefeld", "mechanism": "city_visit"}'),


-- ---------------------------
-- APP
-- ---------------------------

('First User',
'Sei unter den ersten 50 Nutzern der App',
'App',
'{"type": "user_number", "value": 50, "mechanism": "less_than"}'),

('Beta User',
'Nehme am Beta Programm teil und gebe Feedback',
'App',
'{"type": "is_beta_user", "value": true, "mechanism": "simple_threshold"}'),

('Up Mark Dev',
'Mache einen erfolgreichen Pull Request zu Up Mark',
'App',
'{"type": "upmark_pull_requests", "value": 1, "mechanism": "simple_threshold"}'),

('Open Source Hero',
'Mache 5 Pull Requests zu Open Source Projekten',
'App',
'{"type": "open_source_prs", "value": 5, "mechanism": "simple_threshold"}'),

('Bug Hunter',
'Melde einen Bug in der App',
'App',
'{"type": "bugs_reported", "value": 1, "mechanism": "simple_threshold"}'),

('Loyal',
'Nutze die App 365 Tage lang',
'App',
'{"type": "app_usage_days", "value": 365, "mechanism": "simple_threshold"}'),

('Streak',
'Schalte innerhalb von 5 Wochen pro Woche 2 oder mehr Achievements frei',
'App',
'{"type": "weekly_achievement_streak", "value": 5, "mechanism": "simple_threshold"}'),

('Speed Runner',
'Schalte 10 Achievements innerhalb einer Woche frei',
'App',
'{"type": "achievements_this_week", "value": 10, "mechanism": "simple_threshold"}'),

('Night Coder',
'Oeffne die App zwischen 2 und 4 Uhr morgens',
'App',
'{"mechanism": "combined", "conditions": [{"type": "current_hour", "value": 2, "operator": "greater_equal"}, {"type": "current_hour", "value": 4, "operator": "less_than"}]}'),

('Dark Side',
'Wechsle dauerhaft in den Dark Mode',
'App',
'{"type": "dark_mode_days", "value": 30, "mechanism": "simple_threshold"}'),

('Duo',
'Erhalte mit einem Freund gleichzeitig ein Achievement',
'App',
'{"type": "simultaneous_achievement_with_friend", "value": true, "mechanism": "simple_threshold"}'),

('Jufo',
'Mache bei Jugend Forscht mit',
'App',
'{"type": "jufo_participations", "value": 1, "mechanism": "simple_threshold"}'),

('Jufo I',
'Mache zum zweiten Mal bei Jugend Forscht mit',
'App',
'{"type": "jufo_participations", "value": 2, "mechanism": "simple_threshold"}'),

('Jufo II',
'Mache 4 Mal bei Jugend Forscht mit',
'App',
'{"type": "jufo_participations", "value": 4, "mechanism": "simple_threshold"}');