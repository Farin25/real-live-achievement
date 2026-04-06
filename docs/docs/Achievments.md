# Achievement Übersicht

Hier findest du alle geplanten Achievements für Up Mark – mit Kategorie, Mechanismus, Requirement-Typ und ob sie bereits in der Engine implementiert sind.

> Du hast eine eigene Idee für ein Achievement? [Hier einreichen →](https://farin25.github.io/real-live-achievement/docs/Dein%20Achievment)

---

## Adventure & Travel

| ID | Name | Beschreibung | Mechanismus | Requirement-Typ | In Engine |
|----|------|-------------|-------------|-----------------|-----------|
| 1 | Traveler I | Besuche 3 verschiedene Länder | `unique_count` | `countries_visited` | Nein |
| 2 | Traveler II | Besuche 5 verschiedene Länder | `unique_count` | `countries_visited` | Nein |
| 3 | Traveler III | Besuche 8 verschiedene Länder | `unique_count` | `countries_visited` | Nein |
| 4 | Weltreisender | Besuche 194 Länder | `unique_count` | `countries_visited` | Nein |
| 5 | Explorer | Sei mehr als 100 km von zuhause entfernt | `simple_threshold` | `home_distance_km` | Nein |
| 6 | Adventure | 20.000 Schritte an einem neuen Ort >50 km von zuhause | `combined` | `steps_today + home_distance_km + is_new_location` | Nein |
| 7 | Landlocked | Besuche ein Land ohne Meereszugang | `simple_threshold` | `visited_landlocked_country` | Nein |
| 8 | Island Hopper | Besuche 3 verschiedene Inseln | `unique_count` | `islands_visited` | Nein |
| 9 | Capital Collector | Besuche 10 Hauptstädte | `unique_count` | `capitals_visited` | Nein |
| 10 | Border Crosser | Überquere 3 Landesgrenzen an einem Tag | `simple_threshold` | `borders_crossed_today` | Nein |
| 11 | Border Crosser I | Überquere 5 Landesgrenzen an einem Tag | `simple_threshold` | `borders_crossed_today` | Nein |
| 12 | Crossy Road | Stehe auf einer Landesgrenze zwischen zwei Ländern | `simple_threshold` | `on_border` | Nein |
| 13 | Four Corners | Stehe an einem Punkt wo 4 Länder zusammentreffen | `simple_threshold` | `four_corners` | Nein |
| 14 | Time Traveler | Besuche 3 verschiedene Zeitzonen an einem Tag | `unique_count` | `timezones_today` | Nein |
| 15 | Urban Explorer | Entdecke 10 verschiedene Städte innerhalb eines Monats | `unique_count` | `cities_this_month` | Nein |
| 16 | German Explorer | Besuche mindestens 10 deutsche Städte | `unique_count` | `german_cities_visited` | Nein |
| 17 | Polar Bear | Bereise die Antarktis | `simple_threshold` | `visited_antarctica` | Nein |
| 18 | Fly | Fliege in einem Flugzeug | `combined` | `speed_kmh + altitude_m` | Nein |
| 19 | Speedster | Bewege dich mit mehr als 200 km/h | `simple_threshold` | `speed_kmh` | Nein |
| 20 | Sailor Sarah | Besuche 8 Länder nur per Schiff | `unique_count` | `countries_by_ship` | Nein |
| 21 | Skyfall | Mache einen Fallschirmsprung | `simple_threshold` | `skydive_detected` | Nein |
| 22 | Void | Besuche Bielefeld | `city_visit` | `visited_city = Bielefeld` | Nein |
| 23 | Tokyo Drift | Besuche Tokio | `city_visit` | `visited_city = Tokyo` | Nein |
| 24 | Autopilot Disabled | Nimm einen anderen Weg als sonst zum gleichen Ziel | `simple_threshold` | `new_route_to_known_destination` | Nein |
| 25 | Unknown Chunk Loaded | Betrete nach einem Jahr Nutzung ein komplett neues Gebiet | `simple_threshold` | `new_area_after_one_year` | Nein |

---

## Fitness & Health

| ID | Name | Beschreibung | Mechanismus | Requirement-Typ | In Engine |
|----|------|-------------|-------------|-----------------|-----------|
| 26 | Wanderer | Wandere an einem Tag mehr als 12 km | `simple_threshold` | `distance_today_km` | Nein |
| 27 | Wanderer II | Wandere an einem Tag mehr als 18 km | `simple_threshold` | `distance_today_km` | Nein |
| 28 | Marathoner | Laufe 42 km an einem Tag | `simple_threshold` | `distance_today_km` | Nein |
| 29 | Early Bird | Vor 5 Uhr morgens mehr als 200 Schritte | `combined` | `current_hour + steps_today` | Ja |
| 30 | Night Walker | Laufe mehr als 5 km zwischen 22 und 4 Uhr | `simple_threshold` | `night_distance_km` | Nein |
| 31 | 30k Club | Mache 30.000 Schritte an einem Tag | `simple_threshold` | `steps_today` | Nein |
| 32 | 1 Week | 7 Tage in Folge mindestens 10.000 Schritte | `simple_threshold` | `steps_streak_days` | Nein |
| 33 | Iron Legs | 7 Tage in Folge mehr als 10.000 Schritte | `simple_threshold` | `steps_streak_days` | Nein |
| 34 | Cyclist | Fahre mehr als 50 km Fahrrad an einem Tag | `simple_threshold` | `cycling_distance_today_km` | Nein |
| 37 | Elevator? Never! | Steige an einem Tag mehr als 50 Stockwerke zu Fuß | `simple_threshold` | `floors_today` | Nein |
| 38 | Mountain Goat | Besteige einen Berg über 2000 m | `simple_threshold` | `altitude_m` | Nein |
| 39 | Tutorial Finished | Werde 18 Jahre alt | `simple_threshold` | `age` | Ja |
| 40 | 50% | Werde 50 Jahre alt | `simple_threshold` | `age` | Ja |
| 41 | 100% | Werde 100 Jahre alt | `simple_threshold` | `age` | Ja |
| 42 | Survive Covid 19 | Sei vor 2021 geboren | `less_than` | `birth_year` | Ja |
| 43 | Homebody | Verlasse das Haus 48 Stunden nicht | `simple_threshold` | `hours_at_home` | Nein |

---

## Nature

| ID | Name | Beschreibung | Mechanismus | Requirement-Typ | In Engine |
|----|------|-------------|-------------|-----------------|-----------|
| 44 | Bushcamper I | Übernachte eine Nacht in der Wildnis | `simple_threshold` | `nights_in_wild` | Nein |
| 45 | Bushcamper II | Bleibe länger als 3 Tage in der Wildnis | `simple_threshold` | `days_in_wild` | Nein |
| 46 | Golden Hour | Sei draußen bei einem Sonnenauf- oder -untergang | `simple_threshold` | `golden_hour_outdoor` | Nein |
| 47 | Sunrise Chaser | Sieh mehr als 3 Sonnenaufgänge hintereinander | `simple_threshold` | `sunrise_streak` | Nein |
| 48 | Night Owl | Mehr als 3 Nächte hintereinander draußen wenn es dunkel ist | `simple_threshold` | `outdoor_night_streak` | Nein |
| 50 | Weather Resistant | Draußen trotz Regen und unter 5 Grad | `combined` | `temperature_c + is_raining + is_outdoor` | Nein |
| 51 | First Snow | Beim ersten Schneefall des Jahres draußen | `combined` | `is_first_snow_of_year + is_outdoor` | Nein |
| 52 | Snow Explorer | Verbringe mehr als 3 Stunden im Schnee | `combined` | `is_snowing + hours_outdoor_today` | Nein |
| 53 | Rainbow Chaser | Draußen direkt nach Regen bei Sonnenschein | `simple_threshold` | `rainbow_conditions_outdoor` | Nein |
| 54 | Beach | Besuche einen Strand | `simple_threshold` | `visited_beach` | Nein |
| 55 | Miner | Sei 500 Meter unter dem Meeresspiegel | `less_than` | `altitude_m` | Nein |
| 56 | Lost Signal | Sei 2 Stunden ohne Internet und GPS | `simple_threshold` | `hours_offline` | Nein |
| 57 | Offline Mode | Sei einen ganzen Tag offline | `simple_threshold` | `hours_offline` | Nein |
| 58 | Flat Earther | An einem Tag gleichzeitig sehr tief und sehr hoch | `simple_threshold` | `altitude_range_today_m` | Nein |

---

## Landmarks

| ID | Name | Beschreibung | Mechanismus | Requirement-Typ | In Engine |
|----|------|-------------|-------------|-----------------|-----------|
| 59 | Eiffel Gazer | Besuche den Eiffelturm in Paris | `landmark_visit` | `landmark = eiffel_tower` | Nein |
| 60 | Colosseum Visitor | Besuche das Kolosseum in Rom | `landmark_visit` | `landmark = colosseum` | Nein |
| 61 | Big Ben Watcher | Besuche den Big Ben in London | `landmark_visit` | `landmark = big_ben` | Nein |
| 62 | Sagrada Família | Besuche die Sagrada Família in Barcelona | `landmark_visit` | `landmark = sagrada_familia` | Nein |
| 63 | Statue of Liberty | Besuche die Freiheitsstatue in New York | `landmark_visit` | `landmark = statue_of_liberty` | Nein |
| 64 | Machu Picchu | Besuche Machu Picchu in Peru | `landmark_visit` | `landmark = machu_picchu` | Nein |
| 65 | Taj Mahal | Besuche das Taj Mahal in Indien | `landmark_visit` | `landmark = taj_mahal` | Nein |
| 66 | Great Wall Walker | Besuche die Chinesische Mauer | `landmark_visit` | `landmark = great_wall` | Nein |
| 67 | Chichen Itza | Besuche Chichen Itza in Mexiko | `landmark_visit` | `landmark = chichen_itza` | Nein |
| 68 | Christ the Redeemer | Besuche den Christus in Rio de Janeiro | `landmark_visit` | `landmark = christ_redeemer` | Nein |
| 69 | Petra | Besuche Petra in Jordanien | `landmark_visit` | `landmark = petra` | Nein |
| 70 | Half Wonder | Besuche 3 der 7 Weltwunder | `unique_count` | `wonders_visited` | Nein |
| 71 | Wonder of the World | Besuche alle 7 Weltwunder | `unique_count` | `wonders_visited` | Nein |
| 72 | Gamer | Besuche eine Gamescom | `simple_threshold` | `visited_gamescom` | Nein |
| 73 | Gamer I | Besuche 3 Gamescoms | `simple_threshold` | `visited_gamescom` | Nein |
| 74 | Gamer II | Besuche 5 Gamescoms | `simple_threshold` | `visited_gamescom` | Nein |
| 75 | Maker | Besuche eine Maker Faire | `simple_threshold` | `visited_makerfaire` | Nein |
| 76 | Maker I | Besuche 3 Maker Faires | `simple_threshold` | `visited_makerfaire` | Nein |
| 77 | Maker II | Besuche 5 Maker Faires | `simple_threshold` | `visited_makerfaire` | Nein |
| 78 | Culture Seeker | Besuche 5 Museen in einem Monat | `unique_count` | `museums_this_month` | Nein |

---

## Fun

| ID | Name | Beschreibung | Mechanismus | Requirement-Typ | In Engine |
|----|------|-------------|-------------|-----------------|-----------|
| 80 | Music Lover | Höre mehr als 5 Stunden Musik an einem Tag | `simple_threshold` | `music_hours_today` | Nein |
| 81 | Konami Code | Gib den Konami Code in der App ein | `simple_threshold` | `konami_code_entered` | Nein |
| 82 | Hello World | Logge dich zum ersten Mal in der App ein | `simple_threshold` | `total_logins` | Nein |
| 83 | Old Phone | Benutze die App auf einem Handy älter als 5 Jahre | `simple_threshold` | `device_age_years` | Nein |
| 84 | Friday the 13th | Öffne die App an einem Freitag dem 13. | `simple_threshold` | `is_friday_13th` | Ja |
| 85 | Palindrome Day | Öffne die App an einem Palindrom-Datum | `simple_threshold` | `is_palindrome_date` | Ja |
| 86 | Birthday | Öffne die App genau an deinem Geburtstag | `simple_threshold` | `is_users_birthday` | Ja |
| 87 | 404 Not Found | Laufe in der Natur mindestens 4 Mal an derselben Stelle vorbei | `simple_threshold` | `same_spot_passes` | Nein |
| 88 | Mathias Mode | Benutze den Light Mode 30 Tage lang | `simple_threshold` | `light_mode_days` | Ja |
| 89 | Void | Besuche Bielefeld | `city_visit` | `visited_city = Bielefeld` | Nein |

---

## App

| ID | Name | Beschreibung | Mechanismus | Requirement-Typ | In Engine |
|----|------|-------------|-------------|-----------------|-----------|
| 91 | Beta User | Nehme am Beta Programm teil und gebe Feedback | `simple_threshold` | `is_beta_user` | Ja |
| 92 | Up Mark Dev | Mache einen erfolgreichen Pull Request zu Up Mark | `simple_threshold` | `upmark_pull_requests` | Nein |
| 93 | Open Source Hero | Mache 5 Pull Requests zu Open Source Projekten | `simple_threshold` | `open_source_prs` | Nein |
| 94 | Bug Hunter | Melde einen Bug in der App | `simple_threshold` | `bugs_reported` | Nein |
| 95 | Loyal | Nutze die App 365 Tage lang | `simple_threshold` | `app_usage_days` | Nein |
| 96 | Streak | Pro Woche 2+ Achievements in 5 Wochen hintereinander | `simple_threshold` | `weekly_achievement_streak` | Nein |
| 97 | Speed Runner | Schalte 10 Achievements innerhalb einer Woche frei | `simple_threshold` | `achievements_this_week` | Nein |
| 98 | Night Coder | Öffne die App zwischen 2 und 4 Uhr morgens | `combined` | `current_hour` | Ja |
| 99 | Dark Side | Benutze den Dark Mode 30 Tage lang | `simple_threshold` | `dark_mode_days` | Ja |
| 100 | Duo | Erhalte mit einem Freund gleichzeitig ein Achievement | `simple_threshold` | `simultaneous_achievement_with_friend` | Nein |
| 101 | Jufo | Mache bei Jugend Forscht mit | `simple_threshold` | `jufo_participations` | Nein |
| 102 | Jufo I | Mache zum zweiten Mal bei Jugend Forscht mit | `simple_threshold` | `jufo_participations` | Nein |
| 103 | Jufo II | Mache 4 Mal bei Jugend Forscht mit | `simple_threshold` | `jufo_participations` | Nein |
| 104 | Founder | Du warst unter den ersten 10 Nutzern von Up Mark | `simple_threshold` | `user_number` | Ja |
| 105 | First User | Du warst unter den ersten 50 Nutzern von Up Mark | `simple_threshold` | `user_number` | Ja |

---

*Hast du eine Idee für ein neues Achievement? [Hier einreichen →](https://farin25.github.io/real-live-achievement/docs/Dein%20Achievment)*