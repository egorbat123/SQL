-- Задача 1. Написать запрос, который выводит пилотов, которые в качестве второго пилота в августе этого
-- года трижды летали в аэропорт Шереметьево.

SELECT 
	pilots.* 
FROM pilots
JOIN flights ON flights.second_pilot_id = pilots.pilot_id
WHERE YEAR(flights.flight_dt) = 2022 AND MONTH(flights.flight_dt) = 8 
AND flights.destination LIKE 'Шереметьево'
GROUP BY pilots.pilot_id
HAVING COUNT(flights.flight_id) = 3;

-- Задача 2. Написать запрос, который выводит пилотов старше 45 лет, совершавших полеты на самолетах с 
-- количеством пассажиров больше 30.

SELECT pilots.* FROM pilots
JOIN flights ON flights.first_pilot_id = pilots.pilot_id OR flights.second_pilot_id = pilots.pilot_id
JOIN planes ON planes.plane_id = flights.plande_id AND planes.cargo_flg = 0
WHERE pilots.age > 45 AND planes.capacity > 30
GROUP BY pilots.pilot_id;

-- Задача 3. Написать запрос, который выведет ТОП 10 пилотов-капитанов, совершивших наибольшее число
-- грузовых перелетов в этом году.

SELECT pilots.* FROM pilots
JOIN flights ON flights.first_pilot_id = pilots.pilot_id
JOIN planes ON planes.plane_id = flights.plande_id AND planes.cargo_flg = 1
WHERE YEAR(flights.flight_dt) = 2022
GROUP BY pilots.pilot_id
ORDER BY COUNT(flights.flight_id) DESC LIMIT 10;