SELECT
	DISTINCT(to_char(OH1.sale_date, 'yyyy')) "Year",
	COUNT(OH1.parcel_parcel_id) "Total Number of Sales",
	TO_CHAR(SUM(OH1.Sale_price), '$999,999,999') "Total Sales Value",
	COUNT(DISTINCT(OH1.owner_owner_id)) "Number of Market Participants",
	STATS_MODE(P1.School_dist) "Most Popular School District",
	TO_CHAR(ROUND(AVG(T1.base), 2), '$999.99') "Average Taxation on Sold Properties"
FROM owner_history OH1
JOIN parcel P1 ON P1.parcel_id = OH1.parcel_parcel_id
JOIN taxes T1 ON T1.parcel_parcel_id = OH1.parcel_parcel_id
GROUP BY TO_CHAR(OH1.sale_date, 'yyyy')
ORDER BY TO_CHAR(OH1.sale_date, 'yyyy') DESC



SELECT p.parcel_id AS "Parcel ID",
	p.street_number || ' ' || p.property_location || ', ' || p.city || ' ' || p.state || ', ' || p.zip AS "Address", 
	TO_CHAR(v.curr_land + v.curr_bldg, '$999,999') AS "Current Total Value",
	TO_CHAR(v.assessed_land + v.assessed_bldg, '$999,999') AS "Assessed Total Value",
	CASE
		WHEN ((v.assessed_land + v.assessed_bldg) - (v.curr_land + v.curr_bldg)) > 10000
			THEN 'Overvalued'
		WHEN ((v.curr_land + v.curr_bldg) - (v.assessed_land + v.assessed_bldg)) > 10000
			THEN 'Undervalued'
		ELSE 'Accurate'
	END AS "Assessed Valuation Accuracy"
FROM parcel p JOIN valuation v ON p.parcel_id = v.parcel_parcel_id
ORDER BY p.property_location



SELECT p.parcel_id AS "Parcel ID",
	TO_CHAR(v.curr_land + v.curr_bldg, '$999,999.99') AS "Current Total Value",
	r.total_sq_ft AS "Total Square Feet",
	TO_CHAR(((v.curr_land + v.curr_bldg) / r.total_sq_ft) * 1000, '$999,999.99') AS "Current Total Value Per 1,000 Sq Ft", 
	r.full_baths + (r.half_baths * 0.5) AS "# of Bathrooms",
	TO_CHAR((v.curr_land + v.curr_bldg) / (r.full_baths + (r.half baths 0.5)), '$999,999.99') AS "Current Total Value Per Bathroom",
	CASE
		WHEN (((v.curr_land + v.curr_bldg) / r.total_sq_ft) * 1000) > ((v.curr_land + v.curr_bldg) / (r.full_baths + (r.half_baths * 0.5)))
		THEN 'Square Feet'
	ELSE 'Bathrooms'
	END AS "Stronger Determinant of Value"
FROM parcel p JOIN valuation v ON p.parcel_id = v.parcel_parcel_id
	JOIN residential r ON p.parcel_id = r.parcel_parcel_id
WHERE r.full_baths + (r.half_baths * 0.5) > 0
ORDER BY "Current Total Value" DESC



SELECT
	'Code' || C1.code "Code or Act Flag",
	C1.Code_desc "Description",
	COUNT(HC1. Residential_parcel_id) "Number of Parcels with Code or Flag", 
	SUM(P1.CAMA_acres) "Acreage Under Code or Flag",
	CASE
		WHEN COUNT(HC1.Residential_parcel_id) < 1 then 'No Usage'
		WHEN COUNT(HC1.Residential_parcel_id) < 3 then 'Low Usage'
		ELSE 'Acceptable Usage'
		END "Usage Rate"
FROM codes C1
JOIN has_code HC1 on HC1.codes_code = C1.code
JOIN parcel P1 on HC1.Residential_parcel_id = P1.Parcel_id
GROUP BY C1.code, C1.Code_desc
UNION ALL
SELECT
	'Act Flag' || A1.act_flag "Code or Act Flag",
	A1.act_desc "Description",
	COUNT(HA1.Parcel_parcel_id) "Number of Parcels with Code or Flag", 
	SUM(P1.CAMA_acres) "Acreage Under Code or Flag",
	CASE
	WHEN COUNT(HA1.Parcel_parcel_id) < 1 THEN 'No Usage'
	WHEN COUNT(HA1.Parcel_parcel_id) < 3 THEN 'Low Usage'
	ELSE 'Acceptable Usage'
	END "Usage Rate"
FROM act_flags A1
JOIN has_act HA1 on HA1.act_flags_act_flag = A1.act_flag
JOIN parcel P1 on HA1.Parcel_parcel_id = P1.Parcel_id
GROUP BY A1.act_flag, A1.act_desc



SELECT
	DISTINCT(P1.school_dist) "School District",
	ROUND(AVG(R1.total_sq_ft), 2) "Average Square Feet",
	ROUND(AVG(R1.bedrooms), 2) "Average Bedrooms",
	TO_CHAR(ROUND(AVG(V1.curr_bldg / R1.total_sq_ft), 2), '$999.99') "Average Current Price Per Square Foot", 
	TO_CHAR(ROUND(AVG(V1.assessed_bldg / R1.total_sq_ft), 2), '$999.99') "Average Assessed Price Per Square Foot", 
	TO_CHAR(ROUND(AVG(OH1.sale_price / R1.total_sq_ft), 2), '$999.99') "Average Sale Price Per Square Foot",
	stats_mode(R1.grade) "Most Common Grade",
	COUNT(P1.parcel_id) "Number of Properties"
FROM parcel P1
JOIN residential R1 ON R1.parcel_parcel_id = P1.parcel_id
JOIN valuation V1 ON V1.parcel_parcel_id = P1.parcel_id
JOIN Owner_History OH1 ON OH1.parcel_parcel_id = P1.parcel_id
GROUP BY P1.school_dist