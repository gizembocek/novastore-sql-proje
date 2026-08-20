-- NovaStore - Pet Shop E-Ticaret Veri Tabani
-- Hazirlayan: Gizem Bocek
-- Ortam: Microsoft SQL Server (T-SQL)


-- ============ BOLUM 1: VERI TABANI TASARIMI (DDL) ============

USE master;
GO

-- Scripti tekrar calistirabilmek icin varsa eski veri tabanini siliyoruz
IF DB_ID('NovaStoreDB') IS NOT NULL
BEGIN
    ALTER DATABASE NovaStoreDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NovaStoreDB;
END
GO

-- Turkce karakterlerin varchar kolonlarda bozulmamasi icin Turkish collation
CREATE DATABASE NovaStoreDB COLLATE Turkish_CI_AS;
GO

USE NovaStoreDB;
GO


-- Tablo sirasi onemli: once ana tablolar, sonra FK veren tablolar

-- A. Categories
CREATE TABLE Categories
(
    CategoryID   int IDENTITY(1,1) NOT NULL,
    CategoryName varchar(50)       NOT NULL,
    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID)
);
GO

-- C. Customers  (Email benzersiz olmali -> UNIQUE)
CREATE TABLE Customers
(
    CustomerID int IDENTITY(1,1) NOT NULL,
    FullName   varchar(50)       NULL,
    City       varchar(20)       NULL,
    Email      varchar(100)      NULL,
    CONSTRAINT PK_Customers PRIMARY KEY (CustomerID),
    CONSTRAINT UQ_Customers_Email UNIQUE (Email)
);
GO

-- B. Products  (Stock girilmezse 0 olsun -> DEFAULT)
CREATE TABLE Products
(
    ProductID   int IDENTITY(1,1) NOT NULL,
    ProductName varchar(100)      NOT NULL,
    Price       decimal(10,2)     NULL,
    Stock       int               NOT NULL
        CONSTRAINT DF_Products_Stock DEFAULT (0),
    CategoryID  int               NULL,
    CONSTRAINT PK_Products PRIMARY KEY (ProductID),
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID)
        REFERENCES Categories (CategoryID)
);
GO

-- D. Orders  (Tarih girilmezse o anki tarih -> DEFAULT GETDATE())
CREATE TABLE Orders
(
    OrderID     int IDENTITY(1,1) NOT NULL,
    CustomerID  int               NULL,
    OrderDate   datetime          NOT NULL
        CONSTRAINT DF_Orders_OrderDate DEFAULT (GETDATE()),
    TotalAmount decimal(10,2)     NULL,
    CONSTRAINT PK_Orders PRIMARY KEY (OrderID),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID)
        REFERENCES Customers (CustomerID)
);
GO

-- E. OrderDetails  (Orders ile Products arasindaki N-N iliskiyi cozen ara tablo)
CREATE TABLE OrderDetails
(
    DetailID  int IDENTITY(1,1) NOT NULL,
    OrderID   int               NULL,
    ProductID int               NULL,
    Quantity  int               NULL,
    CONSTRAINT PK_OrderDetails PRIMARY KEY (DetailID),
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderID)
        REFERENCES Orders (OrderID),
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductID)
        REFERENCES Products (ProductID)
);
GO


-- ============ BOLUM 2: VERI GIRISI (DML) ============

-- Gorev 1: 5 kategori
INSERT INTO Categories (CategoryName) VALUES
('Mama'),                 -- 1
('Oyuncak'),              -- 2
('Tasma ve Gezdirme'),    -- 3
('Kum ve Hijyen'),        -- 4
('Kafes ve Akvaryum');    -- 5
GO

-- Gorev 2: 12 urun
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES
('Kuru Kedi Mamasi 2 kg',       489.90,  22, 1),   -- 1
('Kuru Kopek Mamasi 15 kg',    1899.00,   9, 1),   -- 2
('Yas Kedi Mamasi 85 g',         39.90, 150, 1),   -- 3
('Kedi Olta Oyuncagi',          129.90,  35, 2),   -- 4
('Kopek Kemik Oyuncagi',        189.90,  12, 2),   -- 5
('Catirdayan Ordek Oyuncak',     99.50,   6, 2),   -- 6
('Deri Kopek Tasmasi',          549.00,  14, 3),   -- 7
('Otomatik Gezdirme Kayisi',    799.90,   8, 3),   -- 8
('Topaklanan Kedi Kumu 10 L',   349.90,  40, 4),   -- 9
('Kapali Kedi Tuvaleti',       1249.00,   5, 4),   -- 10
('Muhabbet Kusu Kafesi',       1599.00,   7, 5),   -- 11
('Akvaryum 60 L Filtreli',     2799.00,   3, 5);   -- 12
GO

-- Gorev 3: 6 musteri
INSERT INTO Customers (FullName, City, Email) VALUES
('Selin Arikan',   'Istanbul',  'selin.arikan@patimail.com'),     -- 1
('Burak Ozdemir',  'Ankara',    'burak.ozdemir@patimail.com'),    -- 2
('Deniz Korkmaz',  'Izmir',     'deniz.korkmaz@patimail.com'),    -- 3
('Ceren Yildiz',   'Eskisehir', 'ceren.yildiz@patimail.com'),     -- 4
('Emre Tasdemir',  'Antalya',   'emre.tasdemir@patimail.com'),    -- 5
('Melis Guler',    'Istanbul',  'melis.guler@patimail.com');      -- 6
GO

-- Gorev 4: 10 siparis. Tutarlari asagida detaylardan hesaplatacagimiz icin 0 giriyoruz.
-- Tarihi ISO formatinda (YYYY-MM-DDTHH:MM:SS) yaziyoruz ki dil ayarindan etkilenmesin.
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES
(1, '2026-01-18T11:20:00', 0),   -- 1
(2, '2026-02-07T15:40:00', 0),   -- 2
(3, '2026-02-25T09:10:00', 0),   -- 3
(4, '2026-03-11T17:55:00', 0),   -- 4
(1, '2026-04-06T12:30:00', 0),   -- 5
(5, '2026-05-19T14:15:00', 0),   -- 6
(6, '2026-06-14T10:05:00', 0),   -- 7
(2, '2026-07-03T19:45:00', 0),   -- 8
(1, '2026-07-28T08:25:00', 0),   -- 9
(3, '2026-08-09T16:50:00', 0);   -- 10
GO

-- Siparis detaylari
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1,  1,  2), (1,  9,  1),
(2,  4,  1), (2,  5,  1),
(3,  2,  1), (3,  3, 12),
(4,  7,  1), (4,  6,  2),
(5, 10,  1), (5,  9,  2),
(6, 11,  1), (6,  3,  6),
(7, 12,  1),
(8,  8,  1), (8,  4,  2),
(9,  1,  1), (9,  6,  1), (9, 3, 10),
(10, 2,  1), (10, 7,  1);
GO

-- Siparis tutarlarini detaylardan hesaplayip guncelliyoruz.
-- Boylece Orders.TotalAmount ile OrderDetails her zaman tutarli olur.
UPDATE o
SET o.TotalAmount = t.Tutar
FROM Orders o
INNER JOIN (
    SELECT od.OrderID, SUM(od.Quantity * p.Price) AS Tutar
    FROM OrderDetails od
    INNER JOIN Products p ON p.ProductID = od.ProductID
    GROUP BY od.OrderID
) t ON t.OrderID = o.OrderID;
GO

-- Veri kontrolu
SELECT * FROM Categories;
SELECT * FROM Products;
SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;
GO


-- ============ BOLUM 3: SORGULAMA VE ANALIZ (DQL) ============

-- Soru 1: Stok miktari 20'den az olan urunler, stoga gore azalan sirada
SELECT
    ProductName AS [Urun Adi],
    Stock       AS [Stok Miktari]
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;
GO


-- Soru 2: Hangi musteri hangi tarihte siparis vermis (INNER JOIN)
SELECT
    c.FullName    AS [Musteri Adi],
    c.City        AS [Sehir],
    o.OrderDate   AS [Siparis Tarihi],
    o.TotalAmount AS [Toplam Tutar]
FROM Customers c
INNER JOIN Orders o ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate;
GO


-- Soru 3: Selin Arikan'in aldigi urunler, fiyatlari ve kategorileri
-- Bes tablo zincirleme birlestiriliyor
SELECT
    c.FullName       AS [Musteri],
    o.OrderID        AS [Siparis No],
    o.OrderDate      AS [Siparis Tarihi],
    p.ProductName    AS [Urun Adi],
    p.Price          AS [Birim Fiyat],
    od.Quantity      AS [Adet],
    cat.CategoryName AS [Kategori]
FROM Customers c
INNER JOIN Orders       o   ON o.CustomerID   = c.CustomerID
INNER JOIN OrderDetails od  ON od.OrderID     = o.OrderID
INNER JOIN Products     p   ON p.ProductID    = od.ProductID
INNER JOIN Categories   cat ON cat.CategoryID = p.CategoryID
WHERE c.FullName = 'Selin Arikan'
ORDER BY o.OrderDate;
GO


-- Soru 4: Kategori basina urun sayisi
-- Hic urunu olmayan kategori de 0 ile gorunsun diye LEFT JOIN
SELECT
    c.CategoryName     AS [Kategori],
    COUNT(p.ProductID) AS [Urun Sayisi]
FROM Categories c
LEFT JOIN Products p ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY [Urun Sayisi] DESC;
GO


-- Soru 5: Musteri bazinda toplam ciro, cok harcayandan aza dogru
-- Hic siparisi olmayan musteride SUM NULL doner, ISNULL ile 0 yapiyoruz
SELECT
    c.CustomerID                  AS [Musteri No],
    c.FullName                    AS [Musteri Adi],
    c.City                        AS [Sehir],
    COUNT(o.OrderID)              AS [Siparis Sayisi],
    ISNULL(SUM(o.TotalAmount), 0) AS [Toplam Ciro]
FROM Customers c
LEFT JOIN Orders o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FullName, c.City
ORDER BY [Toplam Ciro] DESC;
GO


-- Soru 6: Siparislerin uzerinden bugune kadar kac gun gectigi
SELECT
    o.OrderID                             AS [Siparis No],
    c.FullName                            AS [Musteri Adi],
    o.OrderDate                           AS [Siparis Tarihi],
    GETDATE()                             AS [Bugun],
    DATEDIFF(DAY, o.OrderDate, GETDATE()) AS [Gecen Gun Sayisi]
FROM Orders o
INNER JOIN Customers c ON c.CustomerID = o.CustomerID
ORDER BY [Gecen Gun Sayisi] DESC;
GO


-- ============ BOLUM 4: VIEW VE YEDEKLEME ============

-- Uzun JOIN sorgusunu her seferinde yazmamak icin view
IF OBJECT_ID('vw_SiparisOzet', 'V') IS NOT NULL
    DROP VIEW vw_SiparisOzet;
GO

CREATE VIEW vw_SiparisOzet
AS
SELECT
    c.FullName    AS MusteriAdi,
    o.OrderDate   AS SiparisTarihi,
    p.ProductName AS UrunAdi,
    od.Quantity   AS Adet
FROM Customers c
INNER JOIN Orders       o  ON o.CustomerID = c.CustomerID
INNER JOIN OrderDetails od ON od.OrderID   = o.OrderID
INNER JOIN Products     p  ON p.ProductID  = od.ProductID;
GO

-- View'in kullanimi
SELECT * FROM vw_SiparisOzet
ORDER BY SiparisTarihi;
GO


-- Yedekleme
-- C:\Yedek klasoru onceden var olmali, yoksa "Operating system error 3" alinir.
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB.bak'
WITH INIT,
     NAME  = 'NovaStoreDB Tam Yedek',
     STATS = 10;
GO
