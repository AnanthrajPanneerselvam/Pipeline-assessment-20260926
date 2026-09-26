SELECT
    event_name,
    COUNT(*) AS event_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY event_name
ORDER BY event_count DESC