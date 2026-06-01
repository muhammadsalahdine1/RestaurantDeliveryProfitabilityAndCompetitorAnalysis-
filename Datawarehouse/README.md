# Restaurant Delivery Profitability & Competitor Intelligence System

## Data Warehouse Documentation

### Database: `RestaurantProfitabilityDWH_EG`
### Schema Type: Galaxy Schema

---

## 📋 Table of Contents

- [Executive Summary](#executive-summary)
- [Dimension Tables](#dimension-tables)
- [Fact Tables](#fact-tables)
- [Relationships & Foreign Keys](#relationships--foreign-keys)
- [Derived Columns & Calculations](#derived-columns--calculations)
- [Business Rules](#business-rules)
- [ETL Summary](#etl-summary)

---

## Executive Summary

### Purpose

This Data Warehouse supports business intelligence and analytics for a restaurant's delivery operations, enabling analysis of:

| Business Area | Description |
|---------------|-------------|
| **Profitability** | Identify loss-making orders, items, and platforms |
| **COD Risk** | Track customer refusal patterns and blacklist high-risk customers |
| **Competitor Intelligence** | Monitor competitor pricing and promotions |
| **Ingredient Cost Tracking** | Detect price spikes and their impact on menu items |
| **Delivery Performance** | Analyze delivery times by zone and time of day |
| **Platform Performance** | Compare profitability across delivery platforms |
| **Customer Segmentation** | Identify high-value customers and their behavior |

### Key Features

| Feature | Description |
|---------|-------------|
| **Galaxy Schema** | Optimized for fast analytical queries |
| **Surrogate Keys** | All dimension tables use IDENTITY surrogate keys |
| **Natural Keys Preserved** | Original IDs from OLTP stored for traceability |
| **Pre-calculated Measures** | Key metrics calculated during ETL for performance |
| **Ramadan/Eid Tracking** | Special Islamic calendar attributes in Dim_Date |
| **Hour-level Time Dimension** | 24-hour granularity for peak hour analysis |
| **Outrigger References** | ZoneKey in Dim_Customer and Dim_Competitor |

### Table Inventory

| # | Table Name | Type | Row Count (Est.) |
|---|------------|------|------------------|
| 1 | Dim_Date | Dimension | 3,653 (10 years) |
| 2 | Dim_Time | Dimension | 1,440 (every minute) |
| 3 | Dim_Zone | Dimension | ~15 |
| 4 | Dim_Platform | Dimension | ~5 |
| 5 | Dim_Customer | Dimension | ~300 |
| 6 | Dim_MenuItem | Dimension | ~40 |
| 7 | Dim_Ingredient | Dimension | ~15 |
| 8 | Dim_Competitor | Dimension | ~7 |
| 9 | Fact_Orders | Fact | ~10,000 |
| 10 | Fact_OrderItems | Fact | ~35,000 |
| 11 | Fact_IngredientPrices | Fact | ~630 |
| 12 | Fact_CompetitorPricing | Fact | ~420 |

---

### Design Principles

| Principle | Implementation |
|-----------|----------------|
| **No Foreign Key Constraints** | Integrity guaranteed by SSIS ETL (not database-enforced) |
| **Surrogate Keys** | All dimensions use IDENTITY(1,1) surrogate keys |
| **Natural Keys** | Original OLTP IDs stored as separate columns |
| **Denormalization** | Selected attributes duplicated for performance |
| **Outrigger References** | ZoneKey referenced from Dim_Customer and Dim_Competitor |
| **Pre-calculated Measures** | Key metrics calculated during ETL |
| **Egyptian Calendar** | Special handling for Ramadan and Eid |
| **Egyptian Weekend** | Friday (DayOfWeek 6) and Saturday (DayOfWeek 7) |

---

## Dimension Tables

### Dim_Date

**Purpose:** Time dimension with calendar attributes and Egyptian holiday tracking.

**Grain:** One row per calendar day (10 years: 2020-2029, 3,653 rows)

| # | Column Name | Data Type | Description | Example |
|---|-------------|-----------|-------------|---------|
| 1 | DateKey | INT | Primary Key (YYYYMMDD) | 20250415 |
| 2 | FullDate | DATE | Actual calendar date | 2025-04-15 |
| 3 | Year | INT | Calendar year | 2025 |
| 4 | Quarter | INT | Quarter (1-4) | 2 |
| 5 | Month | INT | Month number (1-12) | 4 |
| 6 | MonthName | NVARCHAR(20) | Name of the month | 'April' |
| 7 | DayOfWeek | INT | Day number (1=Sun, 7=Sat) | 3 |
| 8 | DayName | NVARCHAR(20) | Name of the day | 'Tuesday' |
| 9 | IsWeekend | BIT | 1 = Friday or Saturday | 0 |
| 10 | IsHoliday | BIT | 1 = Egyptian national holiday | 0 |
| 11 | HolidayName | NVARCHAR(100) | Name of the holiday | 'Eid Al-Fitr' |
| 12 | IsRamadan | BIT | 1 = During Ramadan month | 1 |
| 13 | RamadanDay | INT | Day of Ramadan (1-30) | 15 |
| 14 | IsEid | BIT | 1 = Eid Al-Fitr or Eid Al-Adha | 0 |
| 15 | EidName | NVARCHAR(50) | Name of Eid | 'Eid Al-Fitr' |

---

### Dim_Time

**Purpose:** Time dimension with hour-level granularity for analyzing delivery patterns.

**Grain:** One row per minute of the day (1,440 rows)

| # | Column Name | Data Type | Description | Example |
|---|-------------|-----------|-------------|---------|
| 1 | TimeKey | INT | Primary Key (HHMM) | 1932 |
| 2 | TimeValue | TIME | Actual time value | 19:32:00 |
| 3 | Hour24 | INT | Hour in 24-hour format (0-23) | 19 |
| 4 | Hour12 | INT | Hour in 12-hour format (1-12) | 7 |
| 5 | Minute | INT | Minute (0-59) | 32 |
| 6 | Second | INT | Second (always 0) | 0 |
| 7 | AmPm | CHAR(2) | AM or PM | 'PM' |
| 8 | HourBin | NVARCHAR(20) | Hour grouping for charts | '19:00-19:59' |
| 9 | PartOfDay | NVARCHAR(20) | Morning/Afternoon/Evening/Night | 'Evening' |
| 10 | IsPeakHour | BIT | 1 = Peak hours (12-2 PM, 7-10 PM) | 1 |

**Part of Day Classification:**

| Hours | PartOfDay |
|-------|-----------|
| 5:00 AM - 11:59 AM | 'Morning' |
| 12:00 PM - 4:59 PM | 'Afternoon' |
| 5:00 PM - 9:59 PM | 'Evening' |
| 10:00 PM - 4:59 AM | 'Night' |

---

### Dim_Zone

**Purpose:** Delivery zone dimension with traffic factors and zone classification.

**Grain:** One row per delivery zone (~15 rows)

| # | Column Name | Data Type | Description | Example |
|---|-------------|-----------|-------------|---------|
| 1 | ZoneKey | INT | Surrogate Key (PK) | 1001 |
| 2 | ZoneID | INT | Natural Key | 1 |
| 3 | ZoneName_AR | NVARCHAR(100) | Zone name in Arabic | المعادي |
| 4 | ZoneName_EN | NVARCHAR(100) | Zone name in English | 'Maadi' |
| 5 | CityID | INT | City identifier | 1 |
| 6 | CityName_AR | NVARCHAR(100) | City name in Arabic | القاهرة |
| 7 | CityName_EN | NVARCHAR(100) | City name in English | 'Cairo' |
| 8 | TrafficFactor | DECIMAL(3,2) | Traffic multiplier | 1.25 |
| 9 | BaseDeliveryMinutes | INT | Expected time without traffic | 30 |
| 10 | EstimatedDeliveryMinutes | INT | DERIVED: ROUND(Base × Traffic, 0) | 38 |
| 11 | MinOrderForDelivery_EGP | DECIMAL(8,2) | Minimum order value required | 150.00 |
| 12 | DeliveryFee_EGP | DECIMAL(5,2) | Delivery fee charged | 20.00 |
| 13 | ZoneClass | NVARCHAR(10) | DERIVED: Budget/Mid/Premium | 'Budget' |

**ZoneClass Calculation:**

| DeliveryFee_EGP | ZoneClass |
|-----------------|-----------|
| ≤ 25 EGP | 'Budget' |
| 26 - 35 EGP | 'Mid' |
| > 35 EGP | 'Premium' |

---

### Dim_Platform

**Purpose:** Delivery platform dimension (Talabat, Elmenus, WhatsApp Direct, UberEats).

**Grain:** One row per platform (~5 rows)

| # | Column Name | Data Type | Description | Example |
|---|-------------|-----------|-------------|---------|
| 1 | PlatformKey | INT | Surrogate Key (PK) | 2001 |
| 2 | PlatformID | INT | Natural Key | 1 |
| 3 | PlatformName_AR | NVARCHAR(50) | Name in Arabic | تالابات |
| 4 | PlatformName_EN | NVARCHAR(50) | Name in English | 'Talabat' |
| 5 | CommissionRateDefault | DECIMAL(5,2) | Default commission percentage | 28.00 |
| 6 | HasCODSupport | BIT | Supports Cash on Delivery? | 1 |
| 7 | HasWalletPayment | BIT | Supports digital wallets? | 1 |
| 8 | AvgDeliveryFee_EGP | DECIMAL(5,2) | Average delivery fee | 15.00 |
| 9 | IsNegotiable | BIT | Commission can be negotiated? | 0 |

**Platform Data:**

| PlatformName_EN | CommissionRate | HasCOD | HasWallet | Negotiable |
|-----------------|----------------|--------|-----------|------------|
| Talabat | 28.00% | Yes | Yes | No |
| Elmenus | 22.00% | Yes | No | Yes |
| WhatsApp Direct | 0.00% | Yes | No | Yes |
| UberEats | 30.00% | No | Yes | No |

---

### Dim_Customer

**Purpose:** Customer dimension with demographic information and zone attributes.

**Grain:** One row per customer (~300 rows)

| # | Column Name | Data Type | Description | Example |
|---|-------------|-----------|-------------|---------|
| 1 | CustomerKey | INT | Surrogate Key (PK) | 5001 |
| 2 | CustomerID | INT | Natural Key | 101 |
| 3 | FullName_AR | NVARCHAR(100) | Name in Arabic | أحمد محمد |
| 4 | FullName_EN | NVARCHAR(100) | Name in English | 'Ahmed Mohamed' |
| 5 | PhoneNumber | NVARCHAR(20) | Phone number (masked in reports) | 01012345678 |
| 6 | Gender | CHAR(1) | 'M' or 'F' | 'M' |
| 7 | FirstOrderDate | DATE | Date of first order | 2024-11-10 |
| 8 | FirstOrderDateKey | INT | FK to Dim_Date | 20241110 |
| 9 | ZoneKey | INT | FK to Dim_Zone | 1001 |
| 10 | ZoneName_EN | NVARCHAR(100) | Denormalized zone name | 'Maadi' |
| 11 | ZoneClass | NVARCHAR(10) | Denormalized zone class | 'Budget' |
| 12 | CityName_EN | NVARCHAR(100) | Denormalized city name | 'Cairo' |

---

### Dim_MenuItem

**Purpose:** Menu item dimension with category information and profit margin.

**Grain:** One row per menu item (~40 rows)

| # | Column Name | Data Type | Description | Example |
|---|-------------|-----------|-------------|---------|
| 1 | ItemKey | INT | Surrogate Key (PK) | 4001 |
| 2 | ItemID | INT | Natural Key | 1 |
| 3 | ItemName_AR | NVARCHAR(100) | Name in Arabic | شاورما دجاج |
| 4 | ItemName_EN | NVARCHAR(100) | Name in English | 'Chicken Shawarma' |
| 5 | CategoryID | INT | Category identifier | 1 |
| 6 | CategoryName_AR | NVARCHAR(50) | Category name in Arabic | أطباق رئيسية |
| 7 | CategoryName_EN | NVARCHAR(50) | Category name in English | 'Mains' |
| 8 | CurrentPrice_EGP | DECIMAL(8,2) | Current selling price | 85.00 |
| 9 | PackagingCost_EGP | DECIMAL(4,2) | Cost of packaging | 2.00 |
| 10 | PrepTimeMinutes | INT | Average preparation time | 8 |
| 11 | IsAvailableForDelivery | BIT | Available for delivery? | 1 |
| 12 | IsBundle | BIT | Is combo meal? | 0 |
| 13 | ProfitMargin_Percent | INT | Pre-calculated profit margin % | 56 |

---

### Dim_Ingredient

**Purpose:** Ingredient dimension for cost tracking.

**Grain:** One row per ingredient (~15 rows)

| # | Column Name | Data Type | Description | Example |
|---|-------------|-----------|-------------|---------|
| 1 | IngredientKey | INT | Surrogate Key (PK) | 6001 |
| 2 | IngredientID | INT | Natural Key | 1 |
| 3 | IngredientName_EN | NVARCHAR(100) | Name in English | 'Chicken Breast' |
| 4 | IngredientName_AR | NVARCHAR(100) | Name in Arabic | صدر دجاج |
| 5 | UnitOfMeasure | NVARCHAR(20) | Unit of measurement | 'kg' |

---

### Dim_Competitor

**Purpose:** Competitor dimension for market analysis and price comparison.

**Grain:** One row per competitor (~7 rows)

| # | Column Name | Data Type | Description | Example |
|---|-------------|-----------|-------------|---------|
| 1 | CompetitorKey | INT | Surrogate Key (PK) | 7001 |
| 2 | CompetitorID | INT | Natural Key | 1 |
| 3 | CompetitorName_AR | NVARCHAR(100) | Name in Arabic | أبو السيد |
| 4 | CompetitorName_EN | NVARCHAR(100) | Name in English | 'Abou El Sid' |
| 5 | ZoneKey | INT | FK to Dim_Zone | 1001 |
| 6 | ZoneName_EN | NVARCHAR(100) | Denormalized zone name | 'Maadi' |
| 7 | CityName_EN | NVARCHAR(100) | Denormalized city name | 'Cairo' |
| 8 | HasDelivery | BIT | Offers delivery? | 1 |
| 9 | AverageDeliveryMinutes | INT | Average delivery time | 42 |
| 10 | GoogleMapsRating | DECIMAL(3,2) | Google rating (1-5) | 4.2 |
| 11 | PlatformsUsed | NVARCHAR(200) | Comma-separated platforms | 'Talabat, Elmenus' |

---

## Fact Tables

### Fact_Orders

**Purpose:** Order-level fact table. Central fact table.

**Grain:** One row per order (~10,000 rows)

| # | Column Name | Data Type | Description | Example |
|---|-------------|-----------|-------------|---------|
| 1 | OrderKey | INT | Surrogate Key (PK) | 1 |
| 2 | OrderID | INT | Natural Key | 5001 |
| 3 | DateKey | INT | FK to Dim_Date | 20250415 |
| 4 | TimeKey | INT | FK to Dim_Time | 1932 |
| 5 | CustomerKey | INT | FK to Dim_Customer | 5001 |
| 6 | PlatformKey | INT | FK to Dim_Platform | 2001 |
| 7 | ZoneKey | INT | FK to Dim_Zone | 1001 |
| 8 | OrderStatus | NVARCHAR(20) | Status | 'Delivered' |
| 9 | Subtotal_EGP | DECIMAL(10,2) | Sum of item prices | 195.00 |
| 10 | DeliveryFee_EGP | DECIMAL(5,2) | Delivery fee charged | 15.00 |
| 11 | Tip_EGP | DECIMAL(5,2) | Customer tip | 10.00 |
| 12 | TotalAmount_EGP | DECIMAL(10,2) | DERIVED: Subtotal + DeliveryFee + Tip | 220.00 |
| 13 | PlatformCommissionPercent | DECIMAL(5,2) | Commission percentage | 28.00 |
| 14 | PlatformCommissionAmount_EGP | DECIMAL(8,2) | DERIVED: Subtotal × (Commission%/100) | 54.60 |
| 15 | IsCOD | BIT | Cash on Delivery? | 1 |
| 16 | WasCODRefused | BIT | Refused at door? | 0 |
| 17 | RefusalReason | NVARCHAR(200) | Why refused | NULL |
| 18 | RefusedAmount_EGP | DECIMAL(10,2) | DERIVED: Subtotal + DeliveryFee | NULL |
| 19 | RefusalDateTime | DATETIME | When refusal occurred | NULL |

---

### Fact_OrderItems

**Purpose:** Line item fact table.

**Grain:** One row per order item (~35,000 rows)

| # | Column Name | Data Type | Description | Example |
|---|-------------|-----------|-------------|---------|
| 1 | OrderItemKey | INT | Surrogate Key (PK) | 1 |
| 2 | OrderItemID | INT | Natural Key | 8001 |
| 3 | OrderID | INT | Links to Fact_Orders | 5001 |
| 4 | DateKey | INT | Denormalized from parent order | 20250415 |
| 5 | CustomerKey | INT | Denormalized from parent order | 5001 |
| 6 | PlatformKey | INT | Denormalized from parent order | 2001 |
| 7 | ZoneKey | INT | Denormalized from parent order | 1001 |
| 8 | ItemKey | INT | FK to Dim_MenuItem | 4001 |
| 9 | Quantity | INT | Number of units ordered | 2 |
| 10 | UnitPriceAtTime_EGP | DECIMAL(8,2) | Price at time of order | 85.00 |
| 11 | DiscountApplied_EGP | DECIMAL(5,2) | Discount applied | 0.00 |
| 12 | LineRevenue_EGP | DECIMAL(10,2) | DERIVED: (Qty × Price) - Discount | 170.00 |
| 13 | IngredientCost_EGP | DECIMAL(10,2) | DERIVED: Point-in-time cost × Qty | 70.00 |
| 14 | PackagingCost_EGP | DECIMAL(6,2) | DERIVED: PackagingCost × Qty | 4.00 |
| 15 | CostAtTime_EGP | DECIMAL(10,2) | DERIVED: IngredientCost + PackagingCost | 74.00 |

---

### Fact_IngredientPrices

**Purpose:** Ingredient price tracking for cost volatility analysis.

**Grain:** One row per ingredient per month (~630 rows)

| # | Column Name | Data Type | Description | Example |
|---|-------------|-----------|-------------|---------|
| 1 | IngredientPriceKey | INT | Surrogate Key (PK) | 1 |
| 2 | IngredientPriceID | INT | Natural Key | 4001 |
| 3 | IngredientKey | INT | FK to Dim_Ingredient | 6001 |
| 4 | DateKey | INT | FK to Dim_Date (first of month) | 20250401 |
| 5 | PricePerUnit_EGP | DECIMAL(8,2) | Price per unit | 130.00 |

---

### Fact_CompetitorPricing

**Purpose:** Competitor price tracking.

**Grain:** One row per competitor item per tracking date (~420 rows)

| # | Column Name | Data Type | Description | Example |
|---|-------------|-----------|-------------|---------|
| 1 | CompetitorPricingKey | INT | Surrogate Key (PK) | 1 |
| 2 | CompetitorMenuItemID | INT | Natural Key | 2001 |
| 3 | CompetitorKey | INT | FK to Dim_Competitor | 7001 |
| 4 | ItemKey | INT | FK to Dim_MenuItem | 4001 |
| 5 | DateKey | INT | FK to Dim_Date | 20250414 |
| 6 | CompetitorItemName | NVARCHAR(100) | What competitor calls it | 'Shawarma Chicken' |
| 7 | CompetitorPrice_EGP | DECIMAL(8,2) | Competitor's price | 80.00 |
| 8 | OurPrice_EGP | DECIMAL(8,2) | Our price at tracking time | 85.00 |
| 9 | PriceDiff_EGP | DECIMAL(8,2) | DERIVED: CompPrice - OurPrice | -5.00 |
| 10 | PriceDiff_Pct | DECIMAL(6,2) | DERIVED: (PriceDiff / OurPrice) × 100 | -5.88 |
| 11 | IsOnPromotion | BIT | On promotion? | 0 |

---

## Relationships & Foreign Keys

| # | Foreign Key | Source Table | Target Table |
|---|-------------|--------------|--------------|
| 1 | FirstOrderDateKey | Dim_Customer | Dim_Date |
| 2 | ZoneKey | Dim_Customer | Dim_Zone |
| 3 | ZoneKey | Dim_Competitor | Dim_Zone |
| 4 | DateKey | Fact_Orders | Dim_Date |
| 5 | TimeKey | Fact_Orders | Dim_Time |
| 6 | CustomerKey | Fact_Orders | Dim_Customer |
| 7 | PlatformKey | Fact_Orders | Dim_Platform |
| 8 | ZoneKey | Fact_Orders | Dim_Zone |
| 9 | DateKey | Fact_OrderItems | Dim_Date |
| 10 | CustomerKey | Fact_OrderItems | Dim_Customer |
| 11 | PlatformKey | Fact_OrderItems | Dim_Platform |
| 12 | ZoneKey | Fact_OrderItems | Dim_Zone |
| 13 | ItemKey | Fact_OrderItems | Dim_MenuItem |
| 14 | IngredientKey | Fact_IngredientPrices | Dim_Ingredient |
| 15 | DateKey | Fact_IngredientPrices | Dim_Date |
| 16 | CompetitorKey | Fact_CompetitorPricing | Dim_Competitor |
| 17 | ItemKey | Fact_CompetitorPricing | Dim_MenuItem |
| 18 | DateKey | Fact_CompetitorPricing | Dim_Date |

---

## Derived Columns & Calculations

| # | Table | Derived Column | Calculation |
|---|-------|----------------|-------------|
| 1 | Dim_Zone | EstimatedDeliveryMinutes | ROUND(BaseDeliveryMinutes × TrafficFactor, 0) |
| 2 | Dim_Zone | ZoneClass | DeliveryFee ≤ 25 ? "Budget" : Fee ≤ 35 ? "Mid" : "Premium" |
| 3 | Dim_Customer | FirstOrderDateKey | CONVERT(INT, CONVERT(VARCHAR(8), FirstOrderDate, 112)) |
| 4 | Fact_Orders | TotalAmount_EGP | Subtotal_EGP + DeliveryFee_EGP + Tip_EGP |
| 5 | Fact_Orders | PlatformCommissionAmount_EGP | Subtotal_EGP × (CommissionPercent / 100) |
| 6 | Fact_Orders | RefusedAmount_EGP | Subtotal_EGP + DeliveryFee_EGP (when refused) |
| 7 | Fact_OrderItems | LineRevenue_EGP | (Quantity × UnitPriceAtTime) - DiscountApplied |
| 8 | Fact_OrderItems | IngredientCost_EGP | SUM(QuantityNeeded × PricePerUnit) × Quantity |
| 9 | Fact_OrderItems | PackagingCost_EGP | MenuItem.PackagingCost × Quantity |
| 10 | Fact_OrderItems | CostAtTime_EGP | IngredientCost_EGP + PackagingCost_EGP |
| 11 | Fact_CompetitorPricing | PriceDiff_EGP | CompetitorPrice_EGP - OurPrice_EGP |
| 12 | Fact_CompetitorPricing | PriceDiff_Pct | (PriceDiff_EGP / OurPrice_EGP) × 100 |
| 13 | Dim_MenuItem | ProfitMargin_Percent | ((CurrentPrice - IngredientCost - PackagingCost) / CurrentPrice) × 100 |

---

### Business Rules

| Rule | Description |
|------|-------------|
| **COD Refusal** | WasCODRefused is NULL when IsCOD = 0 |
| **DateKey Format** | Always YYYYMMDD (e.g., 20250415) |
| **TimeKey Format** | Always HHMM (e.g., 1932) |
| **Currency** | All monetary values in EGP |
| **Weekend** | Friday (DayOfWeek 6) and Saturday (DayOfWeek 7) |
| **Peak Hours** | 12 PM - 2 PM (lunch) and 7 PM - 10 PM (dinner) |

---

## ETL Summary

### ETL Load Order
Dim_Date (T-SQL script - not SSIS)

Dim_Time (T-SQL script - not SSIS)

Dim_Zone (No dependencies)

Dim_Platform (No dependencies)

Dim_Customer (Depends on Dim_Zone)

Dim_MenuItem (No dependencies)

Dim_Ingredient (No dependencies)

Dim_Competitor (Depends on Dim_Zone)

Fact_Orders (Depends on ALL Dimensions)

Fact_OrderItems (Depends on Dim_MenuItem, Fact_Orders)

Fact_IngredientPrices (Depends on Dim_Ingredient, Dim_Date)

Fact_CompetitorPricing (Depends on Dim_Competitor, Dim_MenuItem, Dim_Date)

---

### ETL Components

| ETL Name | Type | Lookups | Derived Columns |
|----------|------|---------|-----------------|
| DFT_Dim_Zone | Dimension | 0 | 2 |
| DFT_Dim_Platform | Dimension | 0 | 0 |
| DFT_Dim_Customer | Dimension | 1 (Zone) | 1 |
| DFT_Dim_MenuItem | Dimension | 0 | 0 |
| DFT_Dim_Ingredient | Dimension | 0 | 0 |
| DFT_Dim_Competitor | Dimension | 1 (Zone) | 0 |
| DFT_Fact_Orders | Fact | 5 (Date, Time, Customer, Zone, Platform) | 2 |
| DFT_Fact_OrderItems | Fact | 2 (Item, Fact_Orders) | 1 |
| DFT_Fact_IngredientPrices | Fact | 1 (Ingredient) | 0 |
| DFT_Fact_CompetitorPricing | Fact | 2 (Competitor, Item) | 2 |
