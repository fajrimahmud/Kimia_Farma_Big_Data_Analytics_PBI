--CREATE TABLE Kimia_Farma.Analysis_Transaction AS
SELECT
    ft.transaction_id,
    ft.date,
    ft.branch_id,
    kc.branch_name,
    kc.kota,
    kc.provinsi,
    kc.rating AS rating_cabang_Kimia_Farma,
    ft.customer_name,
    p.product_id,
    p.product_name,
    ft.price AS actual_price,
    ft.discount_percentage,
    CASE
        WHEN ft.price <= 50000 THEN 0.1
        WHEN ft.price > 50000 - 100000 THEN 0.15
        WHEN ft.price > 100000 - 300000 THEN 0.2
        WHEN ft.price > 300000 - 500000 THEN 0.25
        When ft.price > 500000 THEN 0.30
        ELSE 0.3
    END AS persentase_gross_laba,
    ft.price * (1 - ft.discount_percentage) AS nett_sales,
    (ft.price * (1 - ft.discount_percentage) * 
        CASE
            WHEN ft.price <= 50000 THEN 0.1
            WHEN ft.price > 50000 - 100000 THEN 0.15
            WHEN ft.price > 100000 - 300000 THEN 0.2
            WHEN ft.price > 300000 - 500000 THEN 0.25
            WHEN ft.price > 500000 THEN 0.30
            ELSE 0.3
        END) AS nett_profit,
    ft.rating AS rating_transaksi
FROM
    Kimia_Farma.kf_final_transaction AS ft
LEFT JOIN
    Kimia_Farma.kf_kantor_cabang AS kc ON ft.branch_id = kc.branch_id
LEFT JOIN
    Kimia_Farma.kf_product AS p ON ft.product_id = p.product_id
;