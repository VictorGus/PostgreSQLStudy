---- db: -h localhost -p 5433 -U postgres postgres
----
\dt

----

--Work with another database(from master class)
----
CREATE TABLE commits(id text primary key, doc jsonb);
----

--Building an array
\a
select jsonb_pretty(jsonb_build_array('one', 'two', 3, false, null));
----
CREATE TABLE someone(resource jsonb);
----
INSERT INTO someone(resource) VALUES(jsonb_build_object('gender','male', 'birthDate','1982.11.10','address','[{"city":"SPB"},{"country":"Russia"},{"street":"First soviet"}]'::jsonb));
----
select
jsonb_build_object('gender','male', 'birthDate','1982.11.10','address','[{"city":"SPB"}]'::jsonb);
----
\a
SELECT jsonb_pretty(resource) FROM someone
WHERE resource#>>'{address,2,street}' = 'First soviet';
----
DELETE FROM someone; 
----
INSERT INTO someone(resource) VALUES (jsonb_build_object('gender','female','birthDate','1974.11.10','address','[{"city":"Muhasransk"},{"country":"Russia"},{"street":"First soviet"}]'::jsonb));
----
UPDATE someone SET resource = resource || '{"gender":"UNDEFINED"}'::jsonb
WHERE resource#>>'{address,0,city}' = 'Muhasransk';
----
SELECT resource#>>'{gender}' FROM someone
WHERE resource#>>'{address,0,city}' = 'Muhasransk';
----
select jsonb_pretty(
jsonb_set('{"a": "b"}', '{c}', '"d"')
);
----
--Tasks from books

CREATE TABLE aircrafts(
aircraft_code char(3) NOT NULL,
model text NOT NULL,
range integer NOT NULL,
CHECK(range>0), PRIMARY KEY (aircraft_code));
----
INSERT INTO aircrafts(aircraft_code, model, range) VALUES ('SU9','Sukhoi SuperJet-100',3000); 
----
INSERT INTO aircrafts(aircraft_code, model, range)
VALUES
('773','Boeing 777-300',1100),
( '763', 'Boeing 767-300', 7900 ),
( '733', 'Boeing 737-300', 4200 ),
( '320', 'Airbus A320-200', 5700 ),
( '321', 'Airbus A321-200', 5600 ),
( '319', 'Airbus A319-100', 6700 ),
( 'CN1', 'Cessna 208 Caravan', 1200 ),
( 'CR2', 'Bombardier CRJ-200', 2700 );
----
SELECT * FROM aircrafts
ORDER BY range ASC;
----
CREATE TABLE seats(
aircraft_code char(3) NOT NULL,
seat_no varchar(4) NOT NULL,
fare_conditions varchar(10) NOT NULL,
CHECK (fare_conditions IN('Economy','Comfort','Business')),
PRIMARY KEY(aircraft_code, seat_no),
FOREIGN KEY(aircraft_code)
    REFERENCES aircrafts (aircraft_code)
    ON DELETE CASCADE
);
----
INSERT INTO seats VALUES
('763', '1A', 'Business'),
('763', '1B', 'Business'),
('763', '2A', 'Business'),
('763', '2B', 'Business'),
('763', '2C', 'Business'),
('763', '10A', 'Economy'),
('763', '10B', 'Economy'),
('763', '10C', 'Economy'),
('763', '10D', 'Economy'),
('763', '10E', 'Economy'),
('763', '10F', 'Economy'),
('763', '10G', 'Economy'),
('763', '10H', 'Economy'),
('763', '20A', 'Economy'),
('763', '20B', 'Economy'),
('763', '20F', 'Economy'),
('763', '20G', 'Economy'),
('763', '30A', 'Economy'),
('763', '30B', 'Economy'),
('763', '30C', 'Economy'),
('763', '30D', 'Economy');
----
SELECT a.aircraft_code,a.model, amnt.amount_of_seats, amnt.f_c FROM aircrafts a
JOIN(
SELECT aircraft_code as code, fare_conditions as f_c, count(*) as amount_of_seats FROM seats
GROUP BY aircraft_code, f_c) as amnt
ON a.aircraft_code = amnt.code
GROUP BY a.aircraft_code, amnt.amount_of_seats,amnt.f_c;
----
SELECT * FROM aircrafts
WHERE aircraft_code = 'SU9';
---- 
SELECT extract('year' FROM current_date); 
----
INSERT INTO pilots
VALUES('Ivan','{1,2,3,4,5,6}'::integer[]),
      ('Petr','{1,2,5,7}'::integer[]),
      ('Pavel', '{2,5}'::integer[]);
----
UPDATE pilots
       SET schedule = schedule || 7
       WHERE pilot_name = 'Pavel';
----

--Add element to the end of array
UPDATE pilots
       SET schedule = array_append(schedule,6)
       WHERE pilot_name = 'Pavel';
----

--Add element to the beginning of array
UPDATE pilots
       SET schedule = array_prepend(4,schedule)
       WHERE pilot_name = 'Pavel';
----
SELECT * FROM pilots;
----

--Remove element from array with certain value
UPDATE pilots
       SET schedule = array_remove(schedule,6)
       WHERE pilot_name = 'Ivan';
----

--@> allows to check if the right-side array contains left-side array
SELECT * FROM pilots WHERE schedule @> '{1,7}'::integer[];
----

--Represent array elements as the column 
SELECT unnest(schedule) AS days_of_the_week FROM pilots
WHERE pilot_name = 'Ivan';
----
INSERT INTO pilot_hobies VALUES(
'Pavel', '{"sports":["football"],"home_lib":true,"trips":3}'::jsonb);
----
\a
SELECT pilot_name FROM pilot_hobies
WHERE NOT(hobbies @> '{"sports":["baseball"]}'::jsonb);
----
SELECT count(*) FROM pilot_hobies
WHERE hobbies ? 'sports';
----
UPDATE pilot_hobies SET hobbies = jsonb_set(hobbies, '{sports, 1}', '"skiing"')
WHERE pilot_name = 'Petr';
----
\a
SELECT pilot_name, jsonb_pretty(hobbies) FROM pilot_hobies;
----

----
