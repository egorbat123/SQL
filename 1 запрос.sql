/* Таблица, в которой только клиенты, с непрерывной историей за год */
CREATE VIEW all_year as SELECT 
	date_new,
	Id_check,
	dist_id.ID_client,
	Count_products,
	Sum_payment
FROM (SELECT DISTINCT  ID_client
	FROM (	
		SELECT 
			COUNT(date_new) OVER(PARTITION BY ID_client) AS cnt_date,
			date_new, 
			ID_client 
		FROM (
			SELECT DISTINCT
				date_new,
				ID_client 
			FROM transactions_info 
			ORDER BY ID_client, date_new) AS a
			) AS b
	WHERE cnt_date = 13) AS dist_id
LEFT JOIN transactions_info AS ti 
ON dist_id.ID_client = ti.ID_client;

/* Группировка по чекам с подсчётом суммы в каждом чеке */
CREATE VIEW sum_by_check AS
SELECT 
	date_new, 
	Id_check, 
	ID_client,
	SUM(Sum_payment) AS sum_check 
FROM all_year
GROUP BY Id_check;


/* Сборка конечного запроса */
SELECT 
	a.ID_client,
	a.avg_check_period,
	b.avg_month_buy,
	c.cnt_operations_period
FROM (
	/* Средний чек за период */
	SELECT DISTINCT 
		ID_client, 
		AVG(sum_check) OVER(PARTITION BY ID_client) AS avg_check_period
	FROM (
		SELECT *
		FROM sum_by_check
		/* Период для подсчёта среднего чека */
		WHERE date_new BETWEEN '2015-08-01' AND '2015-11-01'
		) period ) a
	JOIN (
	
	/* Средняя сумма покупок за месяц */
	SELECT DISTINCT 
		ID_client,
		AVG(sum_month) OVER(PARTITION BY ID_client) AS avg_month_buy
	FROM (
		SELECT DISTINCT 
			ID_client, 
			date_new,
			SUM(sum_check) OVER(PARTITION BY ID_client, date_new) AS sum_month
		FROM sum_by_check) AS month_avg ) b
	ON a.ID_client = b.ID_client
	JOIN (
	/* Количество операций клиенат за период */
	SELECT DISTINCT 
		ID_client,
		COUNT(ID_client) OVER(PARTITION BY ID_client) AS cnt_operations_period
	FROM all_year
	/* Период для подсчёта количества операций клиента */
	WHERE date_new BETWEEN '2015-08-01' AND '2015-11-01') c
	ON a.ID_client = c.ID_client




