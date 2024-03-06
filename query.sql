-- Create Datamart Design --
CREATE TABLE Kimia_Farma.Analysis_Transaction AS
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

-- Create Aggregate Table 1: Pendapatan Pertahun --
CREATE TABLE Kimia_Farma.pendapatan_pertahun AS
SELECT
    EXTRACT(YEAR FROM st.date) AS tahun,
    SUM(nett_sales) AS pendapatan,
    AVG(nett_sales) AS avg_pendapatan
FROM
    Kimia_Farma.Analysis_Transaction AS st
GROUP BY
    tahun
ORDER BY
    tahun
;

-- Create Aggregate Table 2: Total Transaksi Provinsi --
CREATE TABLE Kimia_Farma.total_transaksi_provinsi AS
SELECT 
    provinsi,
    COUNT(*) AS total_transaksi,
    SUM(nett_sales) AS total_pendapatan
FROM 
    Kimia_Farma.Analysis_Transaction AS st
GROUP BY 
    provinsi
ORDER BY 
    total_transaksi DESC
LIMIT 10
;

-- Create Aggregate Table 3: Nett Sales Provinsi --
CREATE TABLE Kimia_Farma.nett_sales_provinsi AS 
SELECT 
    provinsi, 
    SUM(nett_sales) AS nett_sales_cabang,
    COUNT(st.product_id) AS total_produk_terjual
FROM 
    `Kimia_Farma.Analysis_Transaction` AS st
GROUP BY 
    provinsi
ORDER BY 
    nett_sales_cabang DESC
LIMIT 10
;

-- Create Aggregate Table 4: Total Profit Provinsi --
CREATE TABLE Kimia_Farma.total_profit_provinsi AS
SELECT
    provinsi,
    SUM(nett_profit) AS total_profit,
    COUNT(product_id) AS total_produk_terjual
FROM 
    `Kimia_Farma.Analysis_Transaction` AS st
GROUP BY 
    provinsi
ORDER BY
    total_profit DESC, total_produk_terjual DESC
;

-- Create Aggregate Table 5: Jumlah Transaksi Customer --
CREATE TABLE Kimia_Farma.jumlah_transaksi_customer AS
SELECT
    customer_name,
    COUNT(transaction_id) AS total_transaksi
FROM 
    Kimia_Farma.Analysis_Transaction AS st
WHERE 
    EXTRACT(YEAR FROM date) BETWEEN 2020 AND 2023
GROUP BY 
    customer_name
ORDER BY 
    total_transaksi DESC
LIMIT 5
;

-- Create Aggregate Table 6: Cabang Rating Tertinggi, Rating Transaksi Rendah --
CREATE TABLE Kimia_Farma.cabang_rating_tertingi_rating_transaksi_terendah AS
SELECT
    kc.branch_name,
    kc.kota, 
    AVG(ft.rating) AS avg_rating_transaction, 
    kc.rating AS rating_cabang
FROM 
    `Kimia_Farma.kf_final_transaction` AS ft
LEFT JOIN 
    Kimia_Farma.kf_kantor_cabang AS kc
ON 
    ft.branch_id = kc.branch_id
GROUP BY 
    kc.branch_name, kc.kota, kc.rating
ORDER BY 
    kc.rating DESC, AVG(ft.rating) ASC
LIMIT 5
;