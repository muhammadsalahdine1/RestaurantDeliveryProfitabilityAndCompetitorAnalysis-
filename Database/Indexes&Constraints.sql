/* =========================
   INDEXES
========================= */

-- Orders
CREATE INDEX IX_Orders_CustomerID ON Orders(CustomerID);
CREATE INDEX IX_Orders_OrderDate ON Orders(OrderDate);
CREATE INDEX IX_Orders_PlatformID ON Orders(PlatformID);
CREATE INDEX IX_Orders_ZoneID ON Orders(ZoneID);

-- OrderItem
CREATE INDEX IX_OrderItem_OrderID ON OrderItem(OrderID);
CREATE INDEX IX_OrderItem_ItemID ON OrderItem(ItemID);

-- Customer
CREATE INDEX IX_Customer_ZoneID ON Customer(ZoneID);

-- DeliveryZone
CREATE INDEX IX_DeliveryZone_CityID ON DeliveryZone(CityID);

-- Competitor
CREATE INDEX IX_Competitor_ZoneID ON Competitor(ZoneID);

-- CompetitorPlatform
CREATE INDEX IX_CompetitorPlatform_CompetitorID ON CompetitorPlatform(CompetitorID);
CREATE INDEX IX_CompetitorPlatform_PlatformID ON CompetitorPlatform(PlatformID);

-- IngredientPrice
CREATE INDEX IX_IngredientPrice_IngredientID ON IngredientPrice(IngredientID);

-- MenuItem
CREATE INDEX IX_MenuItem_CategoryID ON MenuItem(CategoryID);


/* =========================
   UNIQUE CONSTRAINTS
========================= */

-- Prevent duplicate ingredient per item
ALTER TABLE MenuItemIngredient
ADD CONSTRAINT UQ_MenuItemIngredient UNIQUE (ItemID, IngredientID);

-- Prevent duplicate platform per competitor
ALTER TABLE CompetitorPlatform
ADD CONSTRAINT UQ_CompetitorPlatform UNIQUE (CompetitorID, PlatformID);

-- Prevent duplicate ingredient price per date
ALTER TABLE IngredientPrice
ADD CONSTRAINT UQ_IngredientPrice UNIQUE (IngredientID, EffectiveDate);


/* =========================
   CHECK CONSTRAINTS
========================= */

-- Customer
ALTER TABLE Customer
ADD CONSTRAINT CHK_CustomerGender CHECK (Gender IN ('M', 'F'));

-- DeliveryZone
ALTER TABLE DeliveryZone
ADD CONSTRAINT CHK_TrafficFactor CHECK (TrafficFactor BETWEEN 0.5 AND 3);

ALTER TABLE DeliveryZone
ADD CONSTRAINT CHK_DeliveryFee CHECK (DeliveryFee_EGP >= 0);

ALTER TABLE DeliveryZone
ADD CONSTRAINT CHK_MinOrder CHECK (MinOrderForDelivery_EGP >= 0);

-- DeliveryPlatform
ALTER TABLE DeliveryPlatform
ADD CONSTRAINT CHK_CommissionRate CHECK (CommissionRateDefault BETWEEN 0 AND 100);

ALTER TABLE DeliveryPlatform
ADD CONSTRAINT CHK_AvgDeliveryFee CHECK (AvgDeliveryFee_EGP >= 0);

-- MenuItem
ALTER TABLE MenuItem
ADD CONSTRAINT CHK_MenuItemPrice CHECK (CurrentPrice_EGP >= 0);

ALTER TABLE MenuItem
ADD CONSTRAINT CHK_PackagingCost CHECK (PackagingCost_EGP >= 0);

-- Orders
ALTER TABLE Orders
ADD CONSTRAINT CHK_Subtotal CHECK (Subtotal_EGP >= 0);

ALTER TABLE Orders
ADD CONSTRAINT CHK_DeliveryFee_Order CHECK (DeliveryFee_EGP >= 0);

ALTER TABLE Orders
ADD CONSTRAINT CHK_CommissionPercent CHECK (PlatformCommissionPercent BETWEEN 0 AND 100);

ALTER TABLE Orders
ADD CONSTRAINT CHK_CommissionAmount CHECK (PlatformCommissionAmount_EGP >= 0);

ALTER TABLE Orders
ADD CONSTRAINT CHK_Tip CHECK (Tip_EGP >= 0);

ALTER TABLE Orders
ADD CONSTRAINT CHK_OrdersCOD CHECK ((IsCOD = 1) OR (WasCODRefused IS NULL));

-- OrderItem
ALTER TABLE OrderItem
ADD CONSTRAINT CHK_Quantity CHECK (Quantity > 0);

ALTER TABLE OrderItem
ADD CONSTRAINT CHK_UnitPrice CHECK (UnitPriceAtTime_EGP >= 0);

ALTER TABLE OrderItem
ADD CONSTRAINT CHK_Discount CHECK (DiscountApplied_EGP >= 0);

-- Ingredient
ALTER TABLE Ingredient
ADD CONSTRAINT CHK_Unit CHECK (LEN(UnitOfMeasure) > 0);

-- Competitor
ALTER TABLE Competitor
ADD CONSTRAINT CHK_Rating CHECK (GoogleMapsRating BETWEEN 0 AND 5);

-- CODRefusalLog
ALTER TABLE CODRefusalLog
ADD CONSTRAINT CHK_RefusedAmount CHECK (RefusedAmount_EGP >= 0);