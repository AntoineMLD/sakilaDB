-- Liste des titres des films
SELECT title
FROM film;

-- Nombre de films par catégorie
SELECT count(film_id), name 
FROM film_category fc 
JOIN category c 
ON fc.category_id = c.category_id 
GROUP BY fc.category_id ;

-- Liste des films dont la durée est supérieure à 120 minutes
SELECT title, "length"
FROM film 
WHERE "length"> 120
GROUP BY "length" ;

-- Liste des films sortis entre 2004 et 2006
SELECT title, release_year 
FROM film f 
WHERE release_year BETWEEN 2004 AND 2006;

-- Liste des films de catégorie "Action" ou "Comedy"
SELECT title, name
FROM film_category fc 
JOIN film f ON fc.film_id = f.film_id 
JOIN category ON fc.category_id  = category.category_id
WHERE category.name ="Action" OR category.name = "Comedy";

-- Nombre total de films (définissez l'alias 'nombre de film' pour la valeur calculée)
SELECT COUNT(film_id) as "nombre de film"
FROM film f ;

-- les notes moyennes par catégorie
SELECT round(avg(rental_rate),2), name
FROM film_category fc
JOIN film f ON fc.film_id  = f.film_id
JOIN category c  ON fc.category_id = c.category_id
GROUP BY name;

-- Liste des dix films les plus loués
SELECT  title, count(rental_id) as nbr_rental
FROM inventory i
JOIN rental r ON i.inventory_id = r.inventory_id 
JOIN film ON film.film_id  = i.film_id
GROUP BY title 
ORDER BY nbr_rental DESC
LIMIT 10;

-- Acteurs ayant joué dans le plus grand nombre de films. (join, group by, order by, limit)
SELECT  first_name , last_name , count(fa.film_id) as nbr_film
FROM film_actor fa
JOIN actor a ON fa.actor_id = a.actor_id 
GROUP BY fa.actor_id
ORDER BY nbr_film DESC;


-- Revenu total généré par mois
SELECT SUM(amount), strftime('%m %Y',payment_date) as payment_mois_annee 
FROM payment p 
GROUP BY payment_mois_annee;



--Revenu total généré par chaque magasin par mois pour l'année 2005. (JOIN, SUM, GROUP BY, DATE functions)
SELECT SUM(amount), strftime('%m %Y',payment_date) as payment_mois_annee , store.store_id 
FROM payment p 
JOiN customer ON p.customer_id  = customer.customer_id 
JOIN store ON customer.store_id = store.store_id 
WHERE strftime('%Y',payment_date) LIKE "2005%"
GROUP BY payment_mois_annee, store.store_id



-- Les clients les plus fidèles, basés sur le nombre de locations. (SELECT, COUNT, GROUP BY, ORDER BY)
SELECT first_name,  count(rental_id)
FROM customer c 
JOIN rental r ON c.customer_id = r.customer_id 
GROUP BY r.customer_id
ORDER BY count(rental_id) DESC
LIMIT 10;

-- films qui n'ont pas été loués au cours des 6 derniers mois 
SELECT *
FROM film f
JOIN inventory i ON f.film_id = i.film_id 
JOIN rental r ON i.inventory_id  = r.inventory_id 
GROUP BY r.rental_date  IS NULL

-- Le revenu total de chaque membre du personnel à partir des locations.
SELECT SUM(amount), strftime('%m %Y',payment_date) as payment_mois_annee , s.staff_id
FROM staff s
JOIN payment p ON s.staff_id = p.staff_id 
JOIN store st ON s.store_id = st.store_id 
GROUP BY s.staff_id;

-- Catégories de films les plus populaires parmi les clients. (JOIN, GROUP BY, ORDER BY, LIMIT)
SELECT name, rental_rate
FROM film_category fc 
JOIN category c ON fc.category_id = c.category_id 
JOIN film ON fc.film_id = film.film_id 
GROUP BY name
ORDER BY SUM(film.rental_rate) DESC;


-- Durée moyenne entre la location d'un film et son retour. (SELECT, AVG, DATE functions)
SELECT ROUND(AVG(JULIANDAY(return_date) - JULIANDAY(rental_date)),2) as avg_rental_duration, rental_id 
FROM rental r 

-- Acteurs qui ont joué ensemble dans le plus grand nombre de films. Afficher l'acteur 1, l'acteur 2 et le nombre de films en commun. Trier les résultats par ordre décroissant.
-- Attention aux répétitons. (JOIN, GROUP BY, ORDER BY, Self-join)
SELECT a1.first_name , a1.last_name, a2.first_name , a2.last_name , COUNT() as nbr_film
FROM film_actor fa 
JOIN film_actor fa2 ON fa.film_id = fa2.film_id AND a1.actor_id < a2.actor_id 
JOIN actor a1 ON fa.actor_id = a1.actor_id 
JOIN actor a2 ON fa2.actor_id = a2.actor_id 
GROUP BY a1.actor_id , a2.actor_id
ORDER BY nbr_film DESC

-- Bonus : Clients qui ont loué des films mais n'ont pas fait au moins une location dans les 30 jours qui suivent. (JOIN, WHERE, DATE functions, Sub-query)
WITH intervalle_location AS (
SELECT  r1.rental_date as R1_date, r2.rental_date as R2_date, (JULIANDAY(DATE(r2.rental_date)) - JULIANDAY(DATE(r1.rental_date))) as diff_date , r1.customer_id 
FROM rental r1
JOIN rental r2 ON r1.customer_id  = r2.customer_id AND DATE(r2.rental_date) > DATE(r1.rental_date )
WHERE r2.rental_date NOT BETWEEN DATE(r1.rental_date, '+30 days') AND r1.rental_date AND STRFTIME("%Y-%m",r1.rental_date) ="2005-08"
ORDER BY diff_date
)
SELECT * 
FROM intervalle_location as il
GROUP BY il.customer_id 
HAVING diff_date > 15;



























