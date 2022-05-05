-- Keep a log of any SQL queries you execute as you solve the mystery.

/*
CS50 Duck stolen
Your goal is to identify:

Who the thief is,
What city the thief escaped to, and
Who the thief’s accomplice is who helped them escape
All you know is that the theft took place on July 28, 2021 and that it took place on Humphrey Street.
*/
/* See what we're working with. I put just .schema in the log.sql file and ran the below to output
    to text so I can have it open to the side and be able to more easily reference it. */
cat log.sql | sqlite3 fiftyville.db > schema.txt

/* Lets see a police report for July 28, 2021 referencing humprey street */
SELECT *
  FROM crime_scene_reports
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND street LIKE 'Humphrey';

/* didn't return anything so lets just try to get a row to verify what the output for a row looks like*/
SELECT * from crime_scene_reports WHERE street LIKE 'Humphrey';

/*Ok, well still no results returned... oh I probably should have used wildcards */
SELECT * from crime_scene_reports WHERE street LIKE '%Humphrey%';

/* Now I'm curious if my original query would have worked if I'd remembered/thought about wildcards
   So I'm going to run it again even though I already got the infor for the day in question from
   previous query */
SELECT *
  FROM crime_scene_reports
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND street LIKE '%Humphrey%';

/* id: 295
description: Theft of the CS50 duck took place at 10:15am at the
             Humphrey Street bakery. Interviews were conducted today with
             three witnesses who were present at the time – each of their
             interview transcripts mentions the bakery.
*/

/* From our .schema we ran earlier we know there is a table for "bakery_security_logs"
   So lets try to pull up the security logs around that time. Even though we know
   that the theft "took place" at 10:15am I'm going to pull up for a larger time frame
   in case there is an earlier or later entry that might help
   In addition to the activity and license_plate I'm capturing the id in case I need to
   reference it in a later query I won't have to look it up again.
*/
SELECT id, activity, license_plate
  FROM bakery_security_logs
 WHERE year = 2021
   AND month = 7
   AND day = 28;

/* Well I should have realized it wouldn't time stamp the activity output within the activity field.
   Re-running to output the hour and minute fields.
   I'm also going to limit things to within an hour of the 10:15 presumed time of theft
*/
 SELECT id, hour, minute, activity, license_plate
   FROM bakery_security_logs
  WHERE year = 2021
    AND month = 7
    AND day = 28
    AND hour BETWEEN 9 AND 11;

/* Cross reference the plates from the previous query with the people table.
   Should pull the name and phone number associated with the license plates
   from the security logs.*/
SELECT name, phone_number
  FROM people
 WHERE license_plate
    IN (SELECT license_plate
          FROM bakery_security_logs
         WHERE year = 2021
           AND month = 7
           AND day = 28
           AND hour BETWEEN 9 AND 11);

/* Received an error bash: syntax error near unexpected token `)'
   Oh, I forgot to go into sqlite3 fiftyville.db first
   RE-running the same query from above*/
SELECT name, phone_number
  FROM people
 WHERE license_plate
    IN (SELECT license_plate
          FROM bakery_security_logs
         WHERE year = 2021
           AND month = 7
           AND day = 28
           AND hour BETWEEN 9 AND 11);

/* Police report indicated that 3 people had been interviewed. Lets see if we
   can find those. */
SELECT name, transcript
  FROM interviews
 WHERE year = 2021
   AND month = 7
   AND day = 28;

/* So based on the interviews we believe the suspect left the bakery between 10:15 and
   10:25, we also believe the suspect used the ATM. If we check what time Eugene entered
   the bakery we'll have a rough time frame of the ATM usage.
   Lets see who left the bakery within the 10 min. time frame*/
SELECT license_plate
  FROM bakery_security_logs
 WHERE hour = 10
   AND minute BETWEEN 15 AND 25;

/* Derp, I didn't include the year, month, and day which caused me to get
   a lot more results than I want. Silly mistake. I think I get caught up in like if I was
   programming this in Python and storing the results and I'm querying them to further reduce
   the results. */
 SELECT license_plate
   FROM bakery_security_logs
  WHERE year = 2021
    AND month = 7
    AND day = 28
    AND hour = 10
    AND minute BETWEEN 15 AND 25
    AND activity LIKE 'exit';

/*
| 5P2BI95       |
| 94KL13X       |
| 6P58WS2       |
| 4328GD8       |
| G412CB7       |
| L93JTIZ       |
| 322W7JE       |
| 0NTHK55       |

Ok, with that being a valid query I'm going to modify it to put out names instead
of license plates by combining queries.
*/
SELECT name, phone_number
  FROM people
 WHERE license_plate
    IN ( SELECT license_plate
           FROM bakery_security_logs
          WHERE year = 2021
            AND month = 7
            AND day = 28
            AND hour = 10
            AND minute BETWEEN 15 AND 25
            AND activity LIKE 'exit');

/* That's our list of possible theives, so now we need to see what time Eugene arrived at the bakery*/
SELECT hour, minute
  FROM bakery_security_logs
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND hour < 11
   AND activity LIKE 'entrance'
   AND license_plate = (SELECT license_plate
                          FROM people
                         WHERE name
                          LIKE 'Eugene');

/* Didn't return anything so lets break it down into two queries to see which one is giving me troubles */
SELECT hour, minute
  FROM bakery_security_logs
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND hour < 11
   AND activity LIKE 'entrance'
   AND license_plate = 5P2BI95; -- Just chose a random one from previous query to test with.

/* Oops I forgot license plate is text not int */
SELECT hour, minute
  FROM bakery_security_logs
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND hour < 11
   AND activity LIKE 'entrance'
   AND license_plate = '5P2BI95';

/* Ok I got 9 15 out of that. Going to check the Eugene part next*/
SELECT license_plate
  FROM people
 WHERE name
  LIKE 'Eugene';

/* Ok got a license plate back, 47592FJ. Going to try IN, the sub-query isn't returning
    more than one result but it could so maybe we need IN.*/
SELECT hour, minute
  FROM bakery_security_logs
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND hour < 11
   AND activity LIKE 'entrance'
   AND license_plate IN (SELECT license_plate
                          FROM people
                         WHERE name
                          LIKE 'Eugene');

/* Returns nothing... The only difference I see is that I wrapped the license plate in quotes
   but they're both text fields... I would think that SQL would be smart enough to figure out
   text to text.. I guess I'll have to try JOIN, seems like overkill/a waste */
SELECT logs.hour, logs.minute
  FROM bakery_security_logs AS logs
  JOIN people
    ON logs.license_plate = people.license_plate
 WHERE logs.year = 2021
   AND logs.month = 7
   AND logs.day = 28
   AND logs.hour < 11
   AND logs.activity LIKE 'entrance'
   AND people.license_plate LIKE 'Eugene';

/* Still not returning anything. We know Eugene has a license plate in people.
   Maybe her licsense plate doesn't have an entry in security logs?*/
SELECT license_plate, name
  FROM people
 WHERE name
  LIKE 'Eugene';
-- | 47592FJ       | Eugene |
SELECT hour, minute
  FROM bakery_security_logs
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND hour < 11
   AND activity LIKE 'entrance'
   AND license_plate = '47592FJ';

/* Nothing... Going over things again..Hmm..In the interview she mentioned walking by the ATM but that was "earlier this morning"
   I guess I was assuming that she drove to the bakery maybe she just walks everywhere
   Ok then, change tact, who used the ATM that morning AND exited the bakery around 10:15.
   Need: ATM transactions on 7/28/21 before 10:15am of people who exited the bakery after 10
   I'm not finding a consensus on which is better multiple nested queries or joins.
   It is possible to join multiple tables, and looks feasable for the ones I want to join.
   However is that harder/less readable than nested queries with the waterfall formatting?
   I'm going to try the multi-join first because I haven't done it before and the fact that we'd
   then be explicitely stating what we're looking at IE people.licence_plate seems like it'll be easier
   to follow.
   */
SELECT people.name
  FROM people
  JOIN bakery_security_logs AS logs
    ON people.license_plate = logs.license_plate
 WHERE logs.year = 2021
   AND logs.month = 7
   AND logs.day = 28
   AND logs.activity LIKE 'exit';

/* Ok that seems to have worked. Lets try Joining another table. */
SELECT people.name, bank_accounts.person_id
  FROM people
  JOIN bakery_security_logs AS logs
    ON people.license_plate = logs.license_plate
  JOIN bank_accounts
    ON people.id = bank_accounts.person_id
 WHERE logs.year = 2021
   AND logs.month = 7
   AND logs.day = 28
   AND logs.activity LIKE 'exit'
   AND logs.hour BETWEEN 10 AND 11;

/* Ok now lets add atm_transactions */
SELECT people.name, bank_accounts.person_id
  FROM people
  JOIN bakery_security_logs AS logs
    ON people.license_plate = logs.license_plate
  JOIN bank_accounts
    ON people.id = bank_accounts.person_id
  JOIN atm_transactions AS atm
    ON atm.account_number = bank_accounts.account_number
 WHERE logs.year = 2021
   AND logs.month = 7
   AND logs.day = 28
   AND logs.activity LIKE 'exit'
   AND logs.hour BETWEEN 10 AND 11
   AND atm.atm_location LIKE '%Leggett%';

/* hmph, well it successfully ran. Most of the names are doubled. Presumably because of more than one atm trans.
  I'm going to run another to try to validate the info and if possible reduce the returns to just one entry per
  person*/
SELECT people.name, bank_accounts.person_id, atm.transaction_type, atm.atm_location
  FROM people
  JOIN bakery_security_logs AS logs
    ON people.license_plate = logs.license_plate
  JOIN bank_accounts
    ON people.id = bank_accounts.person_id
  JOIN atm_transactions AS atm
    ON atm.account_number = bank_accounts.account_number
 WHERE logs.year = 2021
   AND logs.month = 7
   AND logs.day = 28
   AND logs.activity LIKE 'exit'
   AND logs.hour BETWEEN 10 AND 11
   AND atm.atm_location LIKE '%Leggett%';

/*
| Bruce  | 686048    | withdraw         | Leggett Street |
| Bruce  | 686048    | withdraw         | Leggett Street |
| Diana  | 514354    | deposit          | Leggett Street |
| Diana  | 514354    | withdraw         | Leggett Street |
| Iman   | 396669    | deposit          | Leggett Street |
| Iman   | 396669    | withdraw         | Leggett Street |
| Luca   | 467400    | deposit          | Leggett Street |
| Luca   | 467400    | withdraw         | Leggett Street |
| Taylor | 449774    | withdraw         | Leggett Street |
| Barry  | 243696    | deposit          | Leggett Street |
Seems legit, ok going to just distinct on the name to reduce it to just one entry per person*/
SELECT distinct(people.name), bank_accounts.person_id, atm.transaction_type, atm.atm_location
  FROM people
  JOIN bakery_security_logs AS logs
    ON people.license_plate = logs.license_plate
  JOIN bank_accounts
    ON people.id = bank_accounts.person_id
  JOIN atm_transactions AS atm
    ON atm.account_number = bank_accounts.account_number
 WHERE logs.year = 2021
   AND logs.month = 7
   AND logs.day = 28
   AND logs.activity LIKE 'exit'
   AND logs.hour BETWEEN 10 AND 11
   AND atm.atm_location LIKE '%Leggett%';

/* Shows duplicate names still, names in different order which is a bit wierd.
  Looking up distinct, it doesn't require (), not sure having them should show the results
  we're seeing but we'll try without just to eliminate the possibility*/
SELECT DISTINCT people.name, bank_accounts.person_id
  FROM people
  JOIN bakery_security_logs AS logs
    ON people.license_plate = logs.license_plate
  JOIN bank_accounts
    ON people.id = bank_accounts.person_id
  JOIN atm_transactions AS atm
    ON atm.account_number = bank_accounts.account_number
 WHERE logs.year = 2021
   AND logs.month = 7
   AND logs.day = 28
   AND logs.activity LIKE 'exit'
   AND logs.hour BETWEEN 10 AND 11
   AND atm.atm_location LIKE '%Leggett%';

/*
| Luca   | 467400    |
| Diana  | 514354    |
| Iman   | 396669    |
| Bruce  | 686048    |
| Barry  | 243696    |
| Taylor | 449774    |
That's more like it.
Ok Raymond's interview stated he had seen the thief make a phone call as he was exiting.
The phone call lasted less than a minute.
Seems odd to not have phone numbers in the phone_calls table, but whatever.
Lets see caller/receiver for any phone calls around 10:15 that lasted less then a minute.
I'm going to start with checking an example output from phone_calls. The phone_calls and people
tables only seem to have one field that might be in common caller>name but they're not set to be
directly related via foreign key>primary key I guess we're to assume there aren't two people with
the same name... at least for most of the tables.
 */
SELECT caller, receiver, duration
  FROM phone_calls
 WHERE year = 2021
   AND month = 7
   AND day = 28;

/*
|     caller     |    receiver    | duration |
+----------------+----------------+----------+
| (336) 555-0077 | (098) 555-1164 | 318      |
| (918) 555-5327 | (060) 555-2489 | 146      |
ok well glad I decided to test first. "caller TEXT" suggested to me a name. But it makes sense
now as phone numbers since they'd want to allow either dashes or () in a phone number.
Ok now to narrow down the time and duration. I'm assuming the duration is in seconds based on
our example output.
*/
SELECT caller, receiver, duration
  FROM phone_calls
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND hour = 10
   AND duration < 60;

/* Parse error: no such column: hour
Mixed my tables up in my head. I should have double checked .schema. Although to be fair why wouldn't
a phone call tracking table have time stamps?

On a side note, whoever decided that terminal wouldn't respect the same ctrl+c ctrl+v scheme
as most windows apps.. They're not cool and I don't like them. */
SELECT caller, receiver, duration
  FROM phone_calls
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND duration < 60;
/*
| (130) 555-0289 | (996) 555-8899 | 51       |
| (499) 555-9472 | (892) 555-8872 | 36       |
| (367) 555-5533 | (375) 555-8161 | 45       |
| (499) 555-9472 | (717) 555-1342 | 50       |
| (286) 555-6063 | (676) 555-6554 | 43       |
| (770) 555-1861 | (725) 555-3243 | 49       |
| (031) 555-6622 | (910) 555-3251 | 38       |
| (826) 555-1652 | (066) 555-9701 | 55       |
| (338) 555-6650 | (704) 555-2131 | 54       |
Not a bad list really all things considering. Need to try to narrow it down by cross referencing other tables.
I think phone_calls > people (via phone #) > bakery_security_logs (via license plate)
I need someone who left the bakery at or around 10:15 AND made a call.
Actually first we need to make sure we can get a usable result from phone numbers connecting
people to phone_calls.
*/
SELECT name, phone_number
  FROM people
 WHERE phone_number
    IN (SELECT caller
          FROM phone_calls
         WHERE year = 2021
           AND month = 7
           AND day = 28
           AND duration < 60);

/* Looks pretty good.
Now to tie it into security logs and atm transactions to hopefully get just one result.
In this case I'm going to try to use JOIN rather than sub-queries as I've got 3 queries
that I'm combining, with their sub-queries, JOIN should naturally reduce results based
on it's results being from both halves of the joined table which hopefully should make
resulting query easier to read. I think ultimately I want to end with a name.
name
where atm transactions that day/location
AND
phone call <60 seconds that day
AND
exited bakery that day/time

I think that should get me what I want with my previous work confirming each piece
I should just have to glue them together. I can actually re-use the query from line 332
 */
SELECT DISTINCT people.name
  FROM people
  JOIN bakery_security_logs AS logs
    ON people.license_plate = logs.license_plate
  JOIN bank_accounts
    ON people.id = bank_accounts.person_id
  JOIN atm_transactions AS atm
    ON atm.account_number = bank_accounts.account_number
  JOIN phone_calls AS calls
    ON calls.caller = people.phone_number
 WHERE logs.year = 2021
   AND logs.month = 7
   AND logs.day = 28
   AND logs.activity LIKE 'exit'
   AND logs.hour BETWEEN 10 AND 11
   AND atm.atm_location LIKE '%Leggett%'
   AND calls.duration < 60;

/*
Good news is the query worked, bad news it spit out 3 people.
| Diana  |
| Bruce  |
| Taylor |

Re-reading the interviews:
Ruth stated "Sometime within ten minutes of the theft"
Eugene stated "withdrawing some money"
So I'm going to narrow down the time frame from logs and the transaction type from atm.

The waterfall style is ok visually, but it can be hard to line up items when the queries get
complex. I'll have to go over the style again to see if I'm misunderstanding it or something
since it seems someone else would have had the same thought.
*/
SELECT DISTINCT people.name
  FROM people
  JOIN bakery_security_logs AS logs
    ON people.license_plate = logs.license_plate
  JOIN bank_accounts
    ON people.id = bank_accounts.person_id
  JOIN atm_transactions AS atm
    ON atm.account_number = bank_accounts.account_number
  JOIN phone_calls AS calls
    ON calls.caller = people.phone_number
 WHERE logs.year = 2021
   AND logs.month = 7
   AND logs.day = 28
   AND logs.activity LIKE 'exit'
   AND logs.hour BETWEEN 10 AND 11
   AND logs.minute BETWEEN 15 AND 25
   AND atm.atm_location LIKE '%Leggett%'
   AND atm.transaction_type = 'withdraw'
   AND calls.duration < 60;

/*
| Bruce |
| Diana |
Ok well guess the next step is to start looking to the flight aspect. Presumably one of
these folks talked to someone who booked a flight.

Ok, airports, flights, and passengers tie together with flights being the hub.
Join all three
Raymond overheard the theif say they were "planning to take the earliest flight out of Fiftyville
 tomorrow" so that locks us to 7/29/21
At first I was assuming we could count on the flight leaving Fiftyville's airport but we
don't know it has one much less that they chose that one to escape.
Going to start with a query to see what airports had flights leave the morning of 7/29/21.
Then will build up to where we narrow it down by person from there.
 */
SELECT airports.city
  FROM airports
  JOIN flights
    ON airports.id = flights.origin_airport_id
 WHERE flights.year = 2021
   AND flights.month = 7
   AND flights.day = 29
 ORDER BY flights.hour;

/* Ok well I got 5 results all of "Fiftyville". Not ideal but at least we know Fiftyville
has an airport now so that's something.
I think I probably want flights.id rather than airports.city
I also want to narrow down using origin_airport_id in case Fiftyville has more than one airport?
Since our previous query only resulted in Fiftyville flights origin_airport_id may not matter...
 */
SELECT flights.id
  FROM flights
  JOIN airports
    ON airports.id = flights.origin_airport_id
 WHERE flights.year = 2021
   AND flights.month = 7
   AND flights.day = 29
   AND flights.origin_airport_id = (SELECT id
                                      FROM airports
                                     WHERE city
                                      LIKE 'origin_airport_id')
 ORDER BY flights.hour;

/* Didn't return anything I'm guessing because of the sub-query. I wasn't sure if it'd accept
the joined name, wasn't sure but now that I i'm rethinking it I believe that should be
out of scope, self contained from the main query.
Also I just noticed that my copy paste seems to have failed and didnt copy Fiftyville like I wanted
Always nice to make sloppy, easily avoidable mistakes /sigh
 */
SELECT flights.id
  FROM flights
  JOIN airports
    ON airports.id = flights.origin_airport_id
 WHERE flights.year = 2021
   AND flights.month = 7
   AND flights.day = 29
   AND flights.origin_airport_id = (SELECT id
                                      FROM airports
                                     WHERE city
                                      LIKE 'Fiftyville')
 ORDER BY flights.hour;

/*
| 36 |
| 43 |
| 23 |
| 53 |
| 18 |
Now that we have a workable query to pull flights from just that morning we can build up
to include checking for particular people.
Actually I need to re-work it because ultimately I want a name not a flight id.
 */
SELECT people.name
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
  JOIN passengers
    ON passengers.flight_id = flights.id
  JOIN airports
    ON airports.id = flights.origin_airport_id
 WHERE flights.year = 2021
   AND flights.month = 7
   AND flights.day = 29
   AND flights.origin_airport_id = (SELECT id
                                      FROM airports
                                     WHERE city
                                      LIKE 'Fiftyville')
   AND
 ORDER BY flights.hour;

/* Tested the reconfigured query and got an error
Parse error: near "ORDER": syntax error
                         LIKE 'Fiftyville')    AND  ORDER BY flights.hour;
                                      error here ---^
I had put the AND there yesterday as I was working on adding a new parameter but realized I
needed to reconfigure for name but ran out of time and didn't notice it was there this morning
when I redid the query. Trying the same without the last AND
*/
SELECT people.name
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
  JOIN passengers
    ON passengers.flight_id = flights.id
  JOIN airports
    ON airports.id = flights.origin_airport_id
 WHERE flights.year = 2021
   AND flights.month = 7
   AND flights.day = 29
   AND flights.origin_airport_id = (SELECT id
                                      FROM airports
                                     WHERE city
                                      LIKE 'Fiftyville')
 ORDER BY flights.hour;

/* Parse error: no such column: flights.year
Missed joining flights when I changed the first call from flights to people.
Probably would have been better to just start over with rather than try to re-use
the original query since it's too easy to miss things like this.
Also just noticed I had passengers joined twice, probably where I was going to join
flights and missed it the first time. Apparently my brain isn't fully functioning
yet this morning.
Also I have a real hard time with updating the previous query then copying it down
further into the log rather than doing the reverse. I think I've caught it each time...*/
SELECT people.name
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
  JOIN flights
    ON passengers.flight_id = flights.id
  JOIN airports
    ON airports.id = flights.origin_airport_id
 WHERE flights.year = 2021
   AND flights.month = 7
   AND flights.day = 29
   AND flights.origin_airport_id = (SELECT id
                                      FROM airports
                                     WHERE city
                                      LIKE 'Fiftyville')
 ORDER BY flights.hour;

/* Well we got a result that time, a list of 38 names. Unfortunately including both Bruce
and Diana
Just noticed that I hadn't yet reduced the flights by morning hours, just down to date.
*/

SELECT people.name
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
  JOIN flights
    ON passengers.flight_id = flights.id
  JOIN airports
    ON airports.id = flights.origin_airport_id
 WHERE flights.year = 2021
   AND flights.month = 7
   AND flights.day = 29
   AND flights.hour < 12
   AND flights.origin_airport_id = (SELECT id
                                      FROM airports
                                     WHERE city
                                      LIKE 'Fiftyville')
 ORDER BY flights.hour;

/* Smaller list.  Oh HO, Bruce but no Diana, gotcha sucka (I hope)
Ok, so who did Bruce talk to on the 28th with a duraction under 60.
*/

SELECT people.name, people.phone_number
  FROM people
  JOIN phone_calls AS calls
    ON people.phone_number = calls.caller
 WHERE calls.id
    IN (SELECT id
          FROM phone_calls
          WHERE calls.caller LIKE 'Bruce'
            AND calls.year = 2021
            AND calls.month = 7
            AND calls.duration < 60);

/* I got distracted and ran it before removing the calls. from the rest of the fields
in the sub-query*/
SELECT people.name, people.phone_number
  FROM people
  JOIN phone_calls AS calls
    ON people.phone_number = calls.caller
 WHERE calls.id
    IN (SELECT id
          FROM phone_calls
          WHERE caller LIKE 'Bruce'
            AND year = 2021
            AND month = 7
            AND duration < 60);

/*
Still no result returned. Not sure atm why it's not returning anything but going
over it again I'm not attempting to get what I want to get anyways so start from scratch.
I want the receiver's name from call ID's where Bruce is the caller but I'm not doing anything
with receiver there.
*/
/*
Oh, actually as I'm writing the next bit I realised my mistake, caller is a phone number
not a name, which is the same mistake I made before /sigh.
oh, and I forgot to put in the day...
*/
/*
receiver name
where date is 7/28
AND Bruce's phone # is caller
AND duration < 60
*/
SELECT calls.receiver
  FROM phone_calls AS calls
  JOIN people
    ON people.phone_number = calls.caller
 WHERE calls.caller = (SELECT caller
                         FROM phone_calls
                        WHERE year = 2021
                          AND month = 7
                          AND day = 28
                          AND duration < 60)
                          AND caller =
                                   (SELECT phone_number
                                      FROM people
                                     WHERE name LIKE 'Bruce');

/* ) ended my first sub-query earlier than I wanted*/
SELECT calls.receiver
  FROM phone_calls AS calls
  JOIN people
    ON people.phone_number = calls.caller
 WHERE calls.caller = (SELECT caller
                         FROM phone_calls
                        WHERE year = 2021
                          AND month = 7
                          AND day = 28
                          AND duration < 60
                          AND caller =
                                   (SELECT phone_number
                                      FROM people
                                     WHERE name LIKE 'Bruce'));
/*
| (113) 555-7544 |
| (238) 555-5554 |
| (660) 555-3095 |
| (286) 555-0131 |
| (375) 555-8161 |
| (344) 555-9601 |
| (022) 555-4052 |
| (704) 555-5790 |
| (455) 555-5315 |
| (841) 555-3728 |
| (696) 555-9195 |
hmm.. how do we determine who bought a plane ticket? Are we to assume that the accomplice
went with them? bank_accounts doesn't have transactions... atm_transactions doesn't make sense
I might have to breakdown and watch the walkthrough. I have not until now as I wanted to try it on my own first.
Lets verify atm_transactions won't help, previously it just showed withdraw or deposit but it was
a fairly narrow search.
*/
SELECT transaction_type
  FROM atm_transactions
 WHERE year = 2021
   AND month = 7
   AND day = 28;

/*
Ok, as I assumed only the two types.
Next thought is to see if any of the numbers that Bruce called on 7/28 have seats on the same flight.
Passengers has passport, as does people.
Going to try something like:
  Get phone # for Bruce
  get passport for Bruce
  Get passport for all people Bruce called from previous query
  get flight id where both passports are passengers
*/
SELECT name, phone_number, passport_number
  FROM people
 WHERE name LIKE 'Bruce';
-- | Bruce | (367) 555-5533 | 5773159633      |

SELECT passport_number
  FROM people
 WHERE phone_number
    IN (SELECT calls.receiver
          FROM phone_calls AS calls
          JOIN people
            ON people.phone_number = calls.caller
         WHERE calls.caller = (SELECT caller
                                 FROM phone_calls
                                WHERE year = 2021
                                  AND month = 7
                                  AND day = 28
                                  AND duration < 60
                                  AND caller = (SELECT phone_number
                                                  FROM people
                                                 WHERE name LIKE 'Bruce')));

/*
| 1050247273      |
| 5031682798      |
| 8613298074      |
| 3355598951      |
| 4328444220      |
| 3833243751      |
| 7226911797      |
| 7771405611      |
| 6034823042      |
|                 |
| 8714200946      |
Presumably the blank is a person who Bruce called but didn't have a passport.
Now for flights with both passports.

Name of Passport:
  any passport with flight id of:
    Flight Id with
      bruce's passport
      AND
      Any person From list of people Bruce called
*/
SELECT people.name, people.passport_number
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
 WHERE passengers.flight_id
    IN (SELECT passengers.flight_id
          FROM passengers
          JOIN people
            ON people.passport_number = passengers.passport_number
         WHERE people.passport_number
          LIKE (SELECT passport_number
                  FROM people
                 WHERE phone_number
                    IN (SELECT calls.receiver
                          FROM phone_calls AS calls
                          JOIN people
                            ON people.phone_number = calls.caller
                         WHERE calls.caller = (SELECT caller
                                                 FROM phone_calls
                                                WHERE year = 2021
                                                  AND month = 7
                                                  AND day = 28
                                                  AND duration < 60
                                                  AND caller = (SELECT phone_number
                                                                  FROM people
                                                                WHERE name LIKE 'Bruce'))))
          AND people.passport_number
          IN (SELECT passport_number
                FROM people
               WHERE name
                LIKE 'Bruce'));

-- missed a )
SELECT people.name, people.passport_number
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
 WHERE passengers.flight_id
    IN (SELECT passengers.flight_id
          FROM passengers
          JOIN people
            ON people.passport_number = passengers.passport_number
         WHERE people.passport_number
          LIKE (SELECT passport_number
                  FROM people
                 WHERE phone_number
                    IN (SELECT calls.receiver
                          FROM phone_calls AS calls
                          JOIN people
                            ON people.phone_number = calls.caller
                         WHERE calls.caller = (SELECT caller
                                                 FROM phone_calls
                                                WHERE year = 2021
                                                  AND month = 7
                                                  AND day = 28
                                                  AND duration < 60
                                                  AND caller = (SELECT phone_number
                                                                  FROM people
                                                                WHERE name LIKE 'Bruce'))))
          AND people.passport_number
          IN (SELECT passport_number
                FROM people
               WHERE name
                LIKE 'Bruce'));

/* I can't honestly say I'm surprised that the above query didn't return a result.
I built it from previously successful queries but that's a lot to unpack.
We'll try taking out the AND part to include Bruce
*/
SELECT people.name, people.passport_number
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
 WHERE passengers.flight_id
    IN (SELECT passengers.flight_id
          FROM passengers
          JOIN people
            ON people.passport_number = passengers.passport_number
         WHERE people.passport_number
          LIKE (SELECT passport_number
                  FROM people
                 WHERE phone_number
                    IN (SELECT calls.receiver
                          FROM phone_calls AS calls
                          JOIN people
                            ON people.phone_number = calls.caller
                         WHERE calls.caller = (SELECT caller
                                                 FROM phone_calls
                                                WHERE year = 2021
                                                  AND month = 7
                                                  AND day = 28
                                                  AND duration < 60
                                                  AND caller = (SELECT phone_number
                                                                  FROM people
                                                                WHERE name LIKE 'Bruce'))))
);

/*
Ok that returned a list, I was worried the part to include Bruce wouldn't work and it seems I was right
to do so.
Ok, re-think what we need. We want to find a flight ID that is attached to both Bruce and one Person
in the list we created of people Bruce called. Then we want the name of that other person, and the
destination of that flight.

*/
SELECT people.name, people.passport_number
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
 WHERE passengers.flight_id
    IN (SELECT passengers.flight_id
          FROM passengers
          JOIN people
            ON people.passport_number = passengers.passport_number
         WHERE people.passport_number
          LIKE (SELECT passport_number
                  FROM people
                 WHERE phone_number
                    IN (SELECT calls.receiver
                          FROM phone_calls AS calls
                          JOIN people
                            ON people.phone_number = calls.caller
                         WHERE calls.caller = (SELECT caller
                                                 FROM phone_calls
                                                WHERE year = 2021
                                                  AND month = 7
                                                  AND day = 28
                                                  AND duration < 60
                                                  AND caller = (SELECT phone_number
                                                                  FROM people
                                                                WHERE name LIKE 'Bruce')))))
  AND passengers.flight_id
   IN (SELECT flight_id
         FROM passengers
        WHERE passport_number = (SELECT passport_number
                                   FROM people
                                  WHERE name
                                   LIKE 'Bruce'));

-- Nada
SELECT people.name, people.passport_number
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
 WHERE passengers.flight_id
    IN (SELECT passengers.flight_id
          FROM passengers
          JOIN people
            ON people.passport_number = passengers.passport_number
         WHERE people.passport_number
          LIKE (SELECT passport_number
                  FROM people
                 WHERE phone_number
                    IN (SELECT calls.receiver
                          FROM phone_calls AS calls
                          JOIN people
                            ON people.phone_number = calls.caller
                         WHERE calls.caller = (SELECT caller
                                                 FROM phone_calls
                                                WHERE year = 2021
                                                  AND month = 7
                                                  AND day = 28
                                                  AND duration < 60
                                                  AND caller = (SELECT phone_number
                                                                  FROM people
                                                                WHERE name LIKE 'Bruce')))))
  AND passengers.flight_id = (SELECT flight_id
                                FROM passengers
                               WHERE passport_number = (SELECT passport_number
                                                          FROM people
                                                         WHERE name
                                                          LIKE 'Bruce'));

/*
Ok, well lets make sure I didn't screw up the part for Bruce.
*/
SELECT people.name, people.passport_number
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
 WHERE passengers.flight_id = (SELECT flight_id
                                 FROM passengers
                                WHERE passport_number = (SELECT passport_number
                                                           FROM people
                                                          WHERE name
                                                           LIKE 'Bruce'));

/*
the above gave me
|  name  | passport_number |
+--------+-----------------+
| Doris  | 7214083635      |
| Sofia  | 1695452385      |
| Bruce  | 5773159633      |
| Edward | 1540955065      |
| Kelsey | 8294398571      |
| Taylor | 1988161715      |
| Kenny  | 9878712108      |
| Luca   | 8496433585      |

...
Maybe passengers isn't giving me what I've been assuming it would.
*/
SELECT *
FROM passengers
WHERE flight_id < 10;

/*
| flight_id | passport_number | seat |
| 1         | 2400516856      | 2C   |
| 1         | 9183348466      | 3B   |
| 1         | 9628244268      | 4B   |
| 1         | 3412604728      | 5A   |
is the result for flight_id 1

1 flight ID, two passengers (bruce + someone he called), 7/29 morning,
we want the name of the accomplice and the destination city
Going to join people, passengers, airports, and flights. Hopefully easier to read and troubleshoot.
It looks like a lot but the main query with the Joins I've done before, and bot the sub-queries I've
done before. I did change the first query to pull name instead of a phone number.
*/
SELECT people.name, airports.city
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
  JOIN phone_calls AS calls
    ON people.phone_number = calls.caller
  JOIN flights
    ON passengers.flight_id = flights.flight_id
  JOIN airports
    ON flights.origin_airport_id = airports.id
 WHERE people.name
    IN (SElECT people.name
          FROM people
          JOIN phone_calls AS calls
            ON people.phone_number = calls.caller
         WHERE calls.caller = (SELECT caller
                         FROM phone_calls
                        WHERE year = 2021
                          AND month = 7
                          AND day = 28
                          AND duration < 60
                          AND caller =
                                   (SELECT phone_number
                                      FROM people
                                     WHERE name LIKE 'Bruce')))
   AND flight_id
    IN (SELECT flight_id
          FROM passengers
         WHERE passport_number = (SELECT passport_number
                                    FROM people
                                   WHERE name
                                    LIKE 'Bruce'));

/*
Parse error: no such column: flights.flight_id
Meant flights.id
*/
SELECT people.name, airports.city
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
  JOIN phone_calls AS calls
    ON people.phone_number = calls.caller
  JOIN flights
    ON passengers.flight_id = flights.id
  JOIN airports
    ON flights.origin_airport_id = airports.id
 WHERE people.name
    IN (SElECT people.name
          FROM people
          JOIN phone_calls AS calls
            ON people.phone_number = calls.caller
         WHERE calls.caller = (SELECT caller
                         FROM phone_calls
                        WHERE year = 2021
                          AND month = 7
                          AND day = 28
                          AND duration < 60
                          AND caller =
                                   (SELECT phone_number
                                      FROM people
                                     WHERE name LIKE 'Bruce')))
   AND flight_id
    IN (SELECT flight_id
          FROM passengers
         WHERE passport_number = (SELECT passport_number
                                    FROM people
                                   WHERE name
                                    LIKE 'Bruce'));

/*
returned 10 lines of:
| Bruce | Fiftyville |
*/
SElECT people.name
  FROM people
  JOIN phone_calls AS calls
    ON people.phone_number = calls.caller
  WHERE calls.caller = (SELECT caller
                  FROM phone_calls
                 WHERE year = 2021
                   AND month = 7
                   AND day = 28
                   AND duration < 60
                   AND caller =
                            (SELECT phone_number
                               FROM people
                              WHERE name LIKE 'Bruce'));

/*
So there I asked for the caller in the outer where but I want receiver
*/
SElECT people.name
  FROM people
  JOIN phone_calls AS calls
    ON people.phone_number = calls.caller
  WHERE calls.receiver = (SELECT receiver
                  FROM phone_calls
                 WHERE year = 2021
                   AND month = 7
                   AND day = 28
                   AND duration < 60
                   AND caller =
                            (SELECT phone_number
                               FROM people
                              WHERE name LIKE 'Bruce'));

/*
ok that looks better.
| Sophia |
| Bruce  |
| Lisa   |
| Ashley |
Now to put it back in our previous query from line 1072
Also updated the join for airports to point to the destination airport id as that's the city I want
*/
SELECT people.name, airports.city
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
  JOIN phone_calls AS calls
    ON people.phone_number = calls.caller
  JOIN flights
    ON passengers.flight_id = flights.id
  JOIN airports
    ON flights.destination_airport_id = airports.id
 WHERE people.name
    IN (SElECT people.name
          FROM people
          JOIN phone_calls AS calls
            ON people.phone_number = calls.caller
         WHERE calls.receiver = (SELECT receiver
                         FROM phone_calls
                        WHERE year = 2021
                          AND month = 7
                          AND day = 28
                          AND duration < 60
                          AND caller =
                                   (SELECT phone_number
                                      FROM people
                                     WHERE name LIKE 'Bruce')))
   AND flights.id
    IN (SELECT flight_id
          FROM passengers
         WHERE passport_number = (SELECT passport_number
                                    FROM people
                                   WHERE name
                                    LIKE 'Bruce'));

/*
| Bruce | New York City | about 10 times..
ugh... /tableFlip


*/
SELECT people.name, calls.caller, calls.receiver, people.passport_number
  FROM phone_calls AS calls
  JOIN people
    ON people.phone_number = calls.caller
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND duration < 60
   AND caller =
            (SELECT phone_number
              FROM people
              WHERE name LIKE 'Bruce');

/*
| name  |     caller     |    receiver    | passport_number |
+-------+----------------+----------------+-----------------+
| Bruce | (367) 555-5533 | (375) 555-8161 | 5773159633      |
+-------+----------------+----------------+-----------------+
so.. Bruce only called one person within our time frame..? But previously I had found several people...
SELECT passport_number
  FROM people
 WHERE phone_number
    IN (SELECT calls.receiver
          FROM phone_calls AS calls
          JOIN people
            ON people.phone_number = calls.caller
         WHERE calls.caller = (SELECT caller
                                 FROM phone_calls
                                WHERE year = 2021
                                  AND month = 7
                                  AND day = 28
                                  AND duration < 60
                                  AND caller = (SELECT phone_number
                                                  FROM people
                                                 WHERE name LIKE 'Bruce')));

/*
| 1050247273      |
| 5031682798      |
| 8613298074      |
| 3355598951      |
| 4328444220      |
| 3833243751      |
| 7226911797      |
| 7771405611      |
| 6034823042      |
|                 |
| 8714200946      |

I'm honestly confused about this development.

*/

/*
Going to try to simply things and see if I can verify results a bit.
*/
SELECT caller, receiver
  FROM phone_calls
 WHERE caller = (SELECT phone_number
                  FROM people
                 WHERE name
                  LIKE 'Bruce')
   AND year = 2021
   AND month = 7
   AND day = 28
   AND duration < 60;
-- Parse error: unrecognized token: ""
SELECT caller, receiver
  FROM phone_calls
 WHERE caller = (SELECT phone_number
                  FROM people
                 WHERE name
                  LIKE 'Bruce')
   AND year = 2021
   AND month = 7
   AND day = 28
   AND duration < 60;
-- There was no space before SELECT so I'm not sure what it's problem was but deleting and re-typing it solved it

/*
|     caller     |    receiver    |
+----------------+----------------+
| (367) 555-5533 | (375) 555-8161 |
ok, Bruce only called one person. If we're correct that Bruce is our thief then whoever is at 555-8161 must be
the accomplice
So who is this mystery person
*/
SELECT name
  FROM people
 WHERE phone_number
  LIKE '(375) 555-8161';
-- | Robin |

-- what flight did Bruce take that morning.
SELECT passengers.flight_id
  FROM passengers
  JOIN flights
    ON passengers.flight_id = flights.id
 WHERE flights.year = 2021
   AND flights.month = 7
   AND flights.day = 29
   AND flights.hour < 12
   AND passengers.passport_number = (SELECT passport_number
                                       FROM people
                                      WHERE name
                                       LIKE 'Bruce');
-- flight_id 36

-- What was the destination city of flight_id 36
SELECT airports.city
  FROM airports
  JOIN flights
    ON airports.id = flights.destination_airport_id
 WHERE flights.id = 36;
-- | New York City |
-- Just out of curiosity was Robin on that flight?
SELECT people.name
  FROM people
  JOIN passengers
    ON people.passport_number = passengers.passport_number
 WHERE passengers.flight_id = 36;

/*
 She wasn't.
| Doris  |
| Sofia  |
| Bruce  |
| Edward |
| Kelsey |
| Taylor |
| Kenny  |
| Luca   |
*/
check50 cs50/problems/2022/x/fiftyville
/*
:) log.sql and answers.txt exist
:) log file contains SELECT queries
:) mystery solved
*/

/*
Final thoughts:
I could have solved this in probably half the lines, initially I had the mentality that nothing
should be hardcoded into the query, ie flight_id = 36. In the end I decided that it was ok to do
so in this case. I try to approach these problems as if I was at work and my boss gave it to me
as something to work on.

I typically work on these at work during down time as I have other things that need my attention
at home. Normally that's fine but I feel that in this instance it really hurt me as I had several
days where I wasn't able to work on it at all and others where I got interupted fairly often which
made it more difficult to keep a focused more cohesive plan of attack. Something I'll need to work
to get better at in the future.

Trying to 'prove' the accomplice deffinately caused me to get lost in the weeds a bit. Normally
you'd be able to verify the transactions with the bank but we didn't have that option here so I was
trying to use other methods but the scenario was more simple than that for sake of the class and
really I just needed to know who the theif called during the specified time frame.

Anywho on to the next one.
*/