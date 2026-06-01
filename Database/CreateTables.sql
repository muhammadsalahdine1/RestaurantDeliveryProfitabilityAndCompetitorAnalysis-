-- TABLE 1: City
CREATE TABLE City (
    CityID INT PRIMARY KEY IDENTITY(1,1),
    CityName_AR NVARCHAR(100) NOT NULL,
    CityName_EN NVARCHAR(100) NOT NULL
);
GO

-- TABLE 2: DeliveryZone
CREATE TABLE DeliveryZone (
    ZoneID INT PRIMARY KEY IDENTITY(1,1),
    CityID INT NOT NULL,
    ZoneName_AR NVARCHAR(100) NOT NULL,
    ZoneName_EN NVARCHAR(100) NOT NULL,
    TrafficFactor DECIMAL(3,2) NOT NULL DEFAULT 1.00,
    BaseDeliveryMinutes INT NOT NULL DEFAULT 20,
    MinOrderForDelivery_EGP DECIMAL(8,2) NOT NULL DEFAULT 100,
    DeliveryFee_EGP DECIMAL(5,2) NOT NULL DEFAULT 15,
    FOREIGN KEY (CityID) REFERENCES City(CityID)
);
GO

-- TABLE 3: DeliveryPlatform
CREATE TABLE DeliveryPlatform (
    PlatformID INT PRIMARY KEY IDENTITY(1,1),
    PlatformName_AR NVARCHAR(50) NOT NULL,
    PlatformName_EN NVARCHAR(50) NOT NULL,
    CommissionRateDefault DECIMAL(5,2) NOT NULL,
    HasCODSupport BIT NOT NULL DEFAULT 1,
    HasWalletPayment BIT NOT NULL DEFAULT 0,
    AvgDeliveryFee_EGP DECIMAL(5,2) NOT NULL,
    IsNegotiable BIT NOT NULL DEFAULT 0
);
GO

-- TABLE 4: MenuCategory
CREATE TABLE MenuCategory (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName_AR NVARCHAR(50) NOT NULL,
    CategoryName_EN NVARCHAR(50) NOT NULL
);
GO

-- TABLE 5: Ingredient
CREATE TABLE Ingredient (
    IngredientID INT PRIMARY KEY IDENTITY(1,1),
    IngredientName_EN NVARCHAR(100) NOT NULL,
    IngredientName_AR NVARCHAR(100) NOT NULL,
    UnitOfMeasure NVARCHAR(20) NOT NULL DEFAULT 'kg'
);
GO

-- TABLE 6: MenuItem
CREATE TABLE MenuItem (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    CategoryID INT NOT NULL,
    ItemName_AR NVARCHAR(100) NOT NULL,
    ItemName_EN NVARCHAR(100) NOT NULL,
    CurrentPrice_EGP DECIMAL(8,2) NOT NULL,
    PackagingCost_EGP DECIMAL(4,2) NOT NULL DEFAULT 2.00,
    PrepTimeMinutes INT NOT NULL DEFAULT 5,
    IsAvailableForDelivery BIT NOT NULL DEFAULT 1,
    IsBundle BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (CategoryID) REFERENCES MenuCategory(CategoryID)
);
GO

-- TABLE 7: IngredientPrice
CREATE TABLE IngredientPrice (
    IngredientPriceID INT PRIMARY KEY IDENTITY(1,1),
    IngredientID INT NOT NULL,
    PricePerUnit_EGP DECIMAL(8,2) NOT NULL,
    EffectiveDate DATE NOT NULL,
    FOREIGN KEY (IngredientID) REFERENCES Ingredient(IngredientID)
);
GO

-- TABLE 8: MenuItemIngredient
CREATE TABLE MenuItemIngredient (
    MenuItemIngredientID INT PRIMARY KEY IDENTITY(1,1),
    ItemID INT NOT NULL,
    IngredientID INT NOT NULL,
    QuantityNeeded DECIMAL(6,2) NOT NULL,
    FOREIGN KEY (ItemID) REFERENCES MenuItem(ItemID),
    FOREIGN KEY (IngredientID) REFERENCES Ingredient(IngredientID)
);
GO

-- TABLE 9: Customer
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    PhoneNumber NVARCHAR(20) NOT NULL UNIQUE,
    FullName_AR NVARCHAR(100) NULL,
    FullName_EN NVARCHAR(100) NULL,
    ZoneID INT NOT NULL,
    FirstOrderDate DATE NOT NULL,
    FOREIGN KEY (ZoneID) REFERENCES DeliveryZone(ZoneID),
    Gender CHAR(1) NOT NULL
);
GO

-- TABLE 10: Competitor 
CREATE TABLE Competitor (
    CompetitorID INT PRIMARY KEY IDENTITY(1,1),
    ZoneID INT NOT NULL,
    CompetitorName_AR NVARCHAR(100) NOT NULL,
    CompetitorName_EN NVARCHAR(100) NOT NULL,
    HasDelivery BIT NOT NULL DEFAULT 1,
    AverageDeliveryMinutes INT NULL,
    GoogleMapsRating DECIMAL(3,2) NULL,
    FOREIGN KEY (ZoneID) REFERENCES DeliveryZone(ZoneID)
);
GO

-- TABLE 11: CompetitorPlatform
CREATE TABLE CompetitorPlatform (
    CompetitorPlatformID INT PRIMARY KEY IDENTITY(1,1),
    CompetitorID INT NOT NULL,
    PlatformID INT NOT NULL,
    FOREIGN KEY (CompetitorID) REFERENCES Competitor(CompetitorID),
    FOREIGN KEY (PlatformID) REFERENCES DeliveryPlatform(PlatformID)
);
GO

-- TABLE 12: Orders
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    PlatformID INT NOT NULL,
    ZoneID INT NOT NULL,
    OrderStatus NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    OrderDate DATE NOT NULL,
    OrderTime TIME NOT NULL,
    Subtotal_EGP DECIMAL(10,2) NOT NULL,
    DeliveryFee_EGP DECIMAL(5,2) NOT NULL DEFAULT 0,
    PlatformCommissionPercent DECIMAL(5,2) NOT NULL,
    PlatformCommissionAmount_EGP DECIMAL(8,2) NOT NULL,
    Tip_EGP DECIMAL(5,2) NULL DEFAULT 0,
    IsCOD BIT NOT NULL DEFAULT 1,
    WasCODRefused BIT NULL DEFAULT 0,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (PlatformID) REFERENCES DeliveryPlatform(PlatformID),
    FOREIGN KEY (ZoneID) REFERENCES DeliveryZone(ZoneID)
);
GO

-- TABLE 13: OrderItem
CREATE TABLE OrderItem (
    OrderItemID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    ItemID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    UnitPriceAtTime_EGP DECIMAL(8,2) NOT NULL,
    DiscountApplied_EGP DECIMAL(5,2) NULL DEFAULT 0,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ItemID) REFERENCES MenuItem(ItemID)
);
GO

-- TABLE 14: CODRefusalLog
CREATE TABLE CODRefusalLog (
    RefusalID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    RefusalReason NVARCHAR(200) NOT NULL,
    RefusedAmount_EGP DECIMAL(10,2) NOT NULL,
    RefusalDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
GO

-- TABLE 15: CompetitorMenuItem
CREATE TABLE CompetitorMenuItem (
    CompetitorMenuItemID INT PRIMARY KEY IDENTITY(1,1),
    CompetitorID INT NOT NULL,
    YourItemID INT NOT NULL,
    CompetitorItemName NVARCHAR(100) NOT NULL,
    CompetitorPrice_EGP DECIMAL(8,2) NOT NULL,
    IsOnPromotion BIT NOT NULL DEFAULT 0,
    DateTracked DATE NOT NULL,
    FOREIGN KEY (CompetitorID) REFERENCES Competitor(CompetitorID),
    FOREIGN KEY (YourItemID) REFERENCES MenuItem(ItemID)
);
GO