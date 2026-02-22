hier ist eine visualliesierung der Datenbank:
<img src="/img/supabase-schema-uqrjhrhzvbvuaeurpcse.png" width="250"/>


### Aufbau des backends und der Datenbank:

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