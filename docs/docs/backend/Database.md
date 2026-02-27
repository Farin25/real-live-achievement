hier ist eine visualliesierung der Datenbank:
<img src="![/img/supabase-schema-uqrjhrhzvbvuaeurpcse.png](https://github.com/Farin25/real-live-achievement/blob/main/docs/static/img/supabase-schema-uqrjhrhzvbvuaeurpcse.png)" width="250"/>


### Aufbau des backends und der Datenbank:

### Datatabels:

## Achievments
Im Datatabel Achievments werden Alle Achievmenst gespeichert und verwaltet später vieleicht auch automatisiert über Discordbot über ein Comunity?

beim Spichern der Achievments sieht das dann so aus, hier als Besipsiel die Traveler I und das Tutorial Finished Achievments:
|id|name|description|reqiement|category|created_at|
|--------|--------|--------|--------|--------|--------|
|01|Travler I|Besuche 3 verschiedene Länder|countries_visited >= 3|travel|2026-02-21 18:24:49.174175+00|
|02|Tutorial Finished|Werde 18 Jahre alt|age >= 18|milestone|2026-02-21 18:22:33.967152+00|

**Erklärung:**  
**id** eine eindeute id zu jedem Achievment es gibt nimeals die gleiche id für Achievment.  
**name** der Name vom Achievment.   
**description** die BEschreibung vom Achievment.  
**reqiement** was erfüllt sein muss damit ein user das Acheivment hat so wie es in dart später in die if schleife eingebaut wird.  
**category** die Ketegorie vom Achievment mal schauen wa swir damit amchen ist bisher erstnoch eine Idee.  
**created at** der genaue Zeitpunkt wann das Achievment in den Datatebel eingetragen wurde  

## Profieles
Im Datattabel Profieles hat jeder User einen EintragHoer ist ein Beispiel Eintrag:

|id|first_name|last_name|username|birthday|created_at|updated_at|beta_user|profile_visibility|cloud_sync|
|----|----|----|----|----|----|----|----|----|----|
|01|Paul|späth|Paulander|1978-04-03|2026-02-21 18:22:33.967152+00|2026-02-21 18:22:33.967152+00|true|friends|true|

|**Feld**|**Erklärung:**|**Erlaubte Werte**|
|---------|--------|------|
|id|Eindeutige id die jeder user hat eine andere es gibt nie zweimal die gleiche|uuid|
|first_name| vorname |Text|
|last_name|Nachnahme |Text|
| username | Username|Text|
|birthday | Geburstadatum |date|
|created_at | Datum der des Beitritts der App |time_stap|
|updatet_at| wann es das letzte mal Aktivität auf dem Acount gab|time_stap|
|beta_user| ob der user die beta achievments und features haben darf | true oder false |
|profile_visibility|Ob Profiel Privat, friends oder public|Privat, friends oder public|
|cloud_sync| Ob cloud sync aktiviert oder nicht|true oder false|

Relativ Selbsterklärend. Bei Cloud sync müssen wir noch schuen wie wir das machen kann sein das es wieder raus kommt.



