---- db: -h localhost -p 5433 -U postgres fhirbase 

----
----CREATE TABLE phonenumbers(
----private VARCHAR(20),home VARCHAR(20),workplace VARCHAR(20)
--);
----
--insert into phoneNumbers(private,home,workplace) values('+7901213445','+1543213534','telephone');
----
--insert into phoneNumbers(private,home,workplace) values('+7901213445','+1543213534','newphone');
---
----SELECT * FROM phonenumbers;
------
--DELETE FROM phonenumbers
--WHERE workplace = 'nephone';
----
--UPDATE phonenumbers SET workplace = 'nephone'
--WHERE workplace = 'phone';
----
--SELECT resource#>>'{name,0,given,0}', resource#>>'{name,0,family}' FROM patient
--WHERE (resource#>>'{activestatus}')::boolean = true
--LIMIT 20;
----
 UPDATE patient SET resource = resource || '{"activestatus":false}'::jsonb
WHERE resource#>>'{name,0,given,0}'='Abram53'; 
---- 
--SELECT p.resource#>>'{name,0,given,0}'
--FROM patient p
--JOIN encounter e ON e.resource#>>'{subject,id}' = p.id
--WHERE (e.resource #>>'{status}' = 'finished')
--LIMIT 20;
----
--The most ill patients
\timing
SELECT p.resource#>>'{name,0,given,0}' as patient_name, enc.cnt FROM patient p
 JOIN(
SELECT count(e.resource#>>'{subject,id}') as cnt,(e.resource#>>'{subject,id}') as user_id
FROM encounter e
GROUP BY e.resource#>>'{subject,id}'
)AS enc
ON p.id = enc.user_id
ORDER BY enc.cnt desc
LIMIT 10;
----
--The most dangerous ill
SELECT c.resource#>>'{code,text}' as illness, count(distinct c.resource#>>'{subject,id}' ) as cnt
FROM condition c
GROUP BY illness
ORDER by cnt DESC;
----


SELECT p.resource#>>'{name,0,given,0}' as first_name, p.resource#>>'{name,0,family}' as second_name, con.illness, con.cnt
FROM patient p
JOIN(SELECT c.resource#>>'{code,text}' as illness, count(*) as cnt, c.resource#>>'{subject,id}' as pt_id
FROM condition c
GROUP BY illness, pt_id
ORDER BY cnt DESC) AS con
ON p.id = con.pt_id;
----


SELECT  date_part('year', CURRENT_DATE) - date_part('year',TO_DATE(p.resource#>>'{birthDate}', 'YYYY-MM-DD')) as age, count(*) as num FROM patient p
WHERE date_part('year', CURRENT_DATE) - date_part('year',TO_DATE(p.resource#>>'{birthDate}', 'YYYY-MM-DD'))>0 AND date_part('year', CURRENT_DATE) - date_part('year',TO_DATE(p.resource#>>'{birthDate}', 'YYYY-MM-DD')) < 18  
GROUP BY age;
----

\timing
--Amount of visits depending on certain age
SELECT (date_part('year',CURRENT_DATE) - date_part('year',TO_DATE(p.resource#>>'{birthDate}','YYYY-MM-DD'))) AS age, SUM(con.amnt) as s FROM patient p
JOIN(SELECT e.resource#>>'{subject,id}' as p_id, count(*) as amnt FROM encounter e GROUP BY p_id) AS con
ON p.id = con.p_id
GROUP BY age
ORDER BY s DESC;
----
SELECT count(*) FROM patient p
WHERE (date_part('year',CURRENT_DATE) - date_part('year',TO_DATE(p.resource#>>'{birthDate}','YYYY-MM-DD')) = 111; 
----

