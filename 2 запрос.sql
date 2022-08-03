
/*1 часть
--------------------------------------*/
SELECT 
	res.date_new,
	/* Средняя сумма чека в месяц (посчитал суммы всех чеков и нашёл среднее значение в каждом месяце)*/ 
	avg_month_check,
	/* Среднее количество операций в месяц (как я понял - это одно число, то есть усреднённое количество операций по всем месяцам) */ 
	avg_cnt_oper,
	/* Количество клиентово, которые совершали операции. По каждому месяцу*/ 
	clients_by_month,
	/* Среднее количество, которые совершали операции. По всем месяцам*/ 
	AVG(clients_by_month) OVER() AS avg_clients_by_month,
	/* Доля операций месяца от общего количества операций за год*/ 
	part_oper_of_year,
	/* Доля платежей в месяце от общего количества операций за год*/ 
	part_month_sum_payment
FROM (
	SELECT 
		date_new,
		AVG(cnt_oper) OVER() AS avg_cnt_oper,
		avg_month_check,
		
		cnt_oper / (SELECT 
							COUNT(*)
						FROM transactions_info) AS part_oper_of_year,
		sum_month / (SELECT 
							SUM(Sum_payment) 
						 FROM transactions_info) AS part_month_sum_payment
	FROM (
		SELECT DISTINCT 
			date_new, 
			cnt_oper,
			sum_month,
			AVG(sum_check) OVER(PARTITION BY YEAR(date_new), MONTH(date_new)) AS avg_month_check
		FROM (
			SELECT DISTINCT 
				date_new, 
				Id_check, 
				ID_client,
				SUM(Sum_payment) OVER(PARTITION BY Id_check) sum_check,
				SUM(Sum_payment) OVER(PARTITION BY YEAR(date_new), MONTH(date_new)) sum_month,
				COUNT(*) OVER(PARTITION BY YEAR(date_new), MONTH(date_new)) AS cnt_oper
			FROM transactions_info) AS a
			) AS b
		) AS res
	JOIN 
	(SELECT DISTINCT 
		date_new, 
		COUNT(ID_client) OVER(PARTITION BY YEAR(date_new), MONTH(date_new)) AS clients_by_month
	FROM (
		SELECT  DISTINCT 
			date_new, 
			ID_client 
		FROM transactions_info) AS c) AS cl
	ON res.date_new = cl.date_new;


/*2 часть (Можно сджойнить с частью 1, но я решил оставить отдельно, чтобы не было слишком громозтко)
---------------------------------*/ 
/* Таблица long формата, первый столбец - дата, второй пол. И сводки по сочетаниям первыз
двух столбцов - процент клиентов выбранного пола, который совершал операции в месяце
и доля платежей по полу в каждом месяце */ 
CREATE VIEW long_gender AS SELECT DISTINCT 
	date_new,
	Gender,
	100 * cnt_gender_month / cnt_all_month AS percent_cnt_gender,
	sum_date_client_gender / sum_date_client_all AS part_sum_gender
FROM (
	SELECT 
		date_new, 
		ID_client,
		sum_by_date_client,
		Gender,
		SUM(sum_by_date_client) OVER(PARTITION BY YEAR(date_new), MONTH(date_new)) AS sum_date_client_all,
		SUM(sum_by_date_client) OVER(PARTITION BY Gender, YEAR(date_new), MONTH(date_new)) AS sum_date_client_gender,
		COUNT(*) OVER(PARTITION BY YEAR(date_new), MONTH(date_new)) AS cnt_all_month,
		COUNT(Gender) OVER(PARTITION BY Gender, YEAR(date_new), MONTH(date_new)) AS cnt_gender_month
	FROM(
		SELECT DISTINCT 
			a.date_new,
			a.ID_client,
			SUM(a.Sum_payment) OVER(PARTITION BY a.ID_client, YEAR(a.date_new), MONTH(a.date_new)) AS sum_by_date_client,
			b.Gender
		FROM (
			(SELECT 
				date_new,
				ID_client,
				Sum_payment
			FROM transactions_info) AS a
			JOIN (
			SELECT 
				Id_client,
				Gender
			FROM customer_info) AS b
			ON a.ID_client = b.Id_client
			)
		) AS all_with_gender ) AS result
ORDER BY date_new;


/* Вывод результата, приведённого в широкий формат */ 
SELECT 
	f.date_new,
	f.percent_cnt_gender AS F_cnt_percent,
	m.percent_cnt_gender AS M_cnt_percent,
	n.percent_cnt_gender AS NULL_cnt_percent,
	f.part_sum_gender AS F_part_sum,
	m.part_sum_gender AS M_part_sum,
	n.part_sum_gender AS NULL_part_sum
FROM (
	(SELECT * 
	FROM long_gender
	WHERE Gender = 'F') AS f
	JOIN 
	(SELECT * 
	FROM long_gender
	WHERE Gender = 'M') AS m
	ON f.date_new = m.date_new
	JOIN 
	(SELECT * 
	FROM long_gender
	WHERE Gender != 'F' AND Gender != 'M') AS n
	ON f.date_new = n.date_new
	)



