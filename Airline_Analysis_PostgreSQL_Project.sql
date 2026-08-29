
-- AIRLINE ANALYSIS PROJECT
-- Dataset table: airports2


-- QUESTION 1
-- Problem Statement:
-- Calculate the total number of passengers for every
-- origin-destination airport pair.


SELECT
    origin_airport,
    destination_airport,
    SUM(passengers) AS total_passengers
FROM airports2
GROUP BY origin_airport, destination_airport
ORDER BY origin_airport ASC, destination_airport ASC;


-- QUESTION 2
-- Problem Statement:
-- Find the total number of flights operated from each
-- origin airport and rank them from highest to lowest.


SELECT
    origin_airport,
    SUM(flights) AS total_flights
FROM airports2
GROUP BY origin_airport
ORDER BY total_flights DESC;



-- QUESTION 3
-- Problem Statement:
-- Identify the top 10 origin airports based on total
-- passenger volume.


SELECT
    origin_airport,
    SUM(passengers) AS total_passengers
FROM airports2
GROUP BY origin_airport
ORDER BY total_passengers DESC
LIMIT 10;



-- QUESTION 4
-- Problem Statement:
-- Identify the top 10 airport routes based on total
-- passenger volume.

SELECT
    origin_airport,
    destination_airport,
    SUM(passengers) AS total_passengers
FROM airports2
GROUP BY origin_airport, destination_airport
ORDER BY total_passengers DESC
LIMIT 10;


-- QUESTION 5
-- Problem Statement:
-- Find origin airports that handled more than
-- 100 million passengers during the complete period.


SELECT
    origin_airport,
    SUM(passengers) AS total_passengers
FROM airports2
GROUP BY origin_airport
HAVING SUM(passengers) > 100000000
ORDER BY total_passengers DESC;



-- QUESTION 6
-- Problem Statement:
-- Calculate total passenger volume for each year.


SELECT
    EXTRACT(YEAR FROM fly_date)::INTEGER AS year,
    SUM(passengers) AS total_passengers
FROM airports2
GROUP BY EXTRACT(YEAR FROM fly_date)
ORDER BY year ASC;


-- QUESTION 7
-- Problem Statement:
-- Calculate yearly passenger volume for every origin airport
-- to compare airport performance across years.


SELECT
    origin_airport,
    EXTRACT(YEAR FROM fly_date)::INTEGER AS year,
    SUM(passengers) AS total_passengers
FROM airports2
GROUP BY
    origin_airport,
    EXTRACT(YEAR FROM fly_date)
ORDER BY year ASC, total_passengers DESC;



-- QUESTION 8
-- Problem Statement:
-- Calculate the load factor for every origin airport.
--
-- Load Factor = Total Passengers / Total Seats * 100


SELECT
    origin_airport,
    ROUND(
        (SUM(passengers)::NUMERIC / NULLIF(SUM(seats), 0)) * 100,
        2
    ) AS load_factor
FROM airports2
GROUP BY origin_airport
ORDER BY load_factor DESC;



-- QUESTION 9
-- Problem Statement:
-- Determine the busiest and least busy months across
-- all years based on total flight count.


WITH monthly_flights AS (
    SELECT
        EXTRACT(MONTH FROM fly_date)::INTEGER AS month,
        SUM(flights) AS total_flights
    FROM airports2
    GROUP BY EXTRACT(MONTH FROM fly_date)
),
month_status AS (
    SELECT
        month,
        total_flights,
        MAX(total_flights) OVER () AS max_flights,
        MIN(total_flights) OVER () AS min_flights
    FROM monthly_flights
)
SELECT
    month,
    total_flights,
    CASE
        WHEN total_flights = max_flights
            THEN 'Busiest Month'
        WHEN total_flights = min_flights
            THEN 'Least Busy Month'
        ELSE 'Normal Month'
    END AS month_status
FROM month_status
ORDER BY month;


-- QUESTION 10
-- Problem Statement:
-- Calculate the average number of passengers carried
-- per flight for each year.
--
-- Passengers per Flight =
-- Total Passengers / Total Flights


SELECT
    EXTRACT(YEAR FROM fly_date)::INTEGER AS year,
    ROUND(
        SUM(passengers)::NUMERIC / NULLIF(SUM(flights), 0),
        2
    ) AS passengers_per_flight
FROM airports2
GROUP BY EXTRACT(YEAR FROM fly_date)
ORDER BY year ASC;



-- QUESTION 11
-- Problem Statement:
-- Identify the peak traffic month for each origin city
-- based on the highest number of passengers.
-- Include all ties.


WITH monthly_passengers AS (
    SELECT
        origin_city,
        EXTRACT(YEAR FROM fly_date)::INTEGER AS year,
        EXTRACT(MONTH FROM fly_date)::INTEGER AS month,
        SUM(passengers) AS total_passengers
    FROM airports2
    GROUP BY
        origin_city,
        EXTRACT(YEAR FROM fly_date),
        EXTRACT(MONTH FROM fly_date)
),
ranked_months AS (
    SELECT
        origin_city,
        year,
        month,
        total_passengers,
        DENSE_RANK() OVER (
            PARTITION BY origin_city
            ORDER BY total_passengers DESC
        ) AS rank_no
    FROM monthly_passengers
)
SELECT
    origin_city,
    year,
    month,
    total_passengers
FROM ranked_months
WHERE rank_no = 1
ORDER BY origin_city, year, month;



-- QUESTION 12
-- Problem Statement:
-- Identify the top 10 routes by load factor.
-- Only include routes having at least 100,000 seats so that
-- very small routes do not dominate the ranking.


SELECT
    origin_airport,
    destination_airport,
    SUM(passengers) AS total_passengers,
    SUM(seats) AS total_seats,
    ROUND(
        (SUM(passengers)::NUMERIC / NULLIF(SUM(seats), 0)) * 100,
        2
    ) AS load_factor
FROM airports2
GROUP BY origin_airport, destination_airport
HAVING SUM(seats) >= 100000
ORDER BY load_factor DESC
LIMIT 10;



-- QUESTION 13
-- Problem Statement:
-- Calculate yearly seat capacity, passenger demand,
-- and unused seat capacity.
--
-- Unused Seat Capacity = Total Seats - Total Passengers


SELECT
    EXTRACT(YEAR FROM fly_date)::INTEGER AS year,
    SUM(seats) AS total_seats,
    SUM(passengers) AS total_passengers,
    SUM(seats) - SUM(passengers) AS unused_seat_capacity
FROM airports2
GROUP BY EXTRACT(YEAR FROM fly_date)
ORDER BY year ASC;


-- QUESTION 14
-- Problem Statement:
-- Identify the top 10 airport routes based on the
-- total number of flights operated.


SELECT
    origin_airport,
    destination_airport,
    SUM(flights) AS total_flights,
    SUM(passengers) AS total_passengers
FROM airports2
GROUP BY origin_airport, destination_airport
ORDER BY total_flights DESC
LIMIT 10;




