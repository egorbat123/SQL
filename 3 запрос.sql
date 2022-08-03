/* Таблица customer_info с проставленными возрастными категориями */
CREATE VIEW with_categoryas SELECT 
	Id_client,
	Age,
	case 
		/* 0 - не проставленный возраст */ 
		when Age = 0
			then 0
		when Age > 0 AND Age <= 20
			then 1
		when Age > 10 AND Age <= 20
			then 2
		when Age > 20 AND Age <= 30
			then 3
		when Age > 30 AND Age <= 40
			then 4
		when Age > 40 AND Age <= 50
			then 5
		when Age > 50 AND Age <= 60
			then 6
		when Age > 60 AND Age <= 70
			then 7
		when Age > 70 AND Age <= 80
			then 8
		when Age > 80 AND Age <= 90
			then 9
	END AS category		
FROM customer_info;



SELECT DISTINCT 
	/* Я сделал запрос поквартально для разных годов. 
	В итоге для всего предоставленного времени получилось 5 кварталов */
	year_new,
	quart,
	/* Возрастная категоря */
	category,
	/* Сумма операций за весь период */
	sum_by_cat,
	/* Количество операций за весь период */
	cnt_by_cat,
	/* Сумма операций поквартально */
	sum_by_cat_quart,
	/* Количество операций поквартально */
	cnt_by_cat_quart,
	/* Средняя сумма операций за весь период */
	AVG(sum_by_cat) OVER() AS avg_sum_by_cat,
	/* Процент суммы операций за квартал от общей суммы операций за весь период*/
	100 * sum_by_cat / all_sum AS percent_sum_by_cat
FROM (
	SELECT 
		YEAR(date_new) AS year_new,
		quart,
		category, 
		SUM(t.Sum_payment) OVER() AS all_sum,
		SUM(t.Sum_payment) OVER(PARTITION BY c.category) AS sum_by_cat,
		COUNT(*) OVER(PARTITION BY c.category) AS cnt_by_cat,
		SUM(t.Sum_payment) OVER(PARTITION BY c.category, YEAR(t.date_new), quart) AS sum_by_cat_quart,
		COUNT(*) OVER(PARTITION BY c.category, YEAR(t.date_new), quart) AS cnt_by_cat_quart
	FROM (
		(SELECT *, QUARTER(date_new) AS quart
		FROM transactions_info) AS t
		JOIN 
		(SELECT *
		FROM with_category) AS c
		ON t.ID_client = c.Id_client
			)
		) res