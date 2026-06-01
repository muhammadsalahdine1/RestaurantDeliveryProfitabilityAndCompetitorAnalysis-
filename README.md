# RestaurantDeliveryProfitabilityAndCompetitorAnalysis

> A full-stack Business Intelligence system built for Egyptian restaurants to optimize delivery profitability, predict COD refusal risk, monitor competitor pricing, and automate real-time alerts — reducing operational losses by up to 50%.

---

## Project Overview

FoodFlow is a complete Business Intelligence system designed for the Egyptian restaurant and food delivery market. It consolidates order data from Talabat, Elmenus, Otlob, Akelni, and WhatsApp into a single platform, enabling restaurant owners to make data-driven decisions on every level — from individual menu items to full delivery zone strategy.

The system includes a normalized SQL Server OLTP database with 15 tables, a galaxy schema data warehouse, 6 SSRS reports, 20 Power BI dashboards, and an AI-powered automation pipeline built on n8n that sends real-time COD risk alerts via Telegram.

---

## Business Problem

Egyptian restaurants operating on delivery platforms face several compounding challenges that silently drain profitability:

- **High platform commissions** (13%–22%) with no visibility into their real impact per order
- **COD refusals** — customers refusing payment at the door with no early warning system
- **No competitor visibility** — prices and promotions change weekly with no tracking
- **Ingredient cost volatility** — daily price swings directly affecting menu margins
- **Poor menu decisions** — no data on which items are profitable vs loss-making

FoodFlow addresses all of these with a unified, automated BI platform.

---

## Database Design (OLTP)

The OLTP database consists of 15 tables built around the `Orders` fact table. The ERD defines 14 entities — the 15th table (`DeliveryPlatformZone`) was added as a mapping table to handle a multi-valued attribute between platforms and zones. Data was loaded from CSV files using `BULK INSERT` directly into SQL Server tables.

### Entity Relationship Diagram

> *The diagram below presents the final ERD for the system, illustrating all 14 entities (15 tables in implementation), their attributes, and the relationships between them. It serves as the structural blueprint of the database, showing how orders, customers, menu items, ingredients, competitors, and delivery data are connected.*

![ERD](https://github.com/mazen-alasas/ITI-Graduation-Project/blob/main/1.%20Entity%20Relationship%20Diagram/ERD.png)

### Key Relationships

| Parent | Child | Cardinality | Description |
|--------|-------|-------------|-------------|
| `City` | `DeliveryZone` | 1 : Many | A city contains multiple delivery zones |
| `DeliveryZone` | `Customer` | 1 : Many | Each customer belongs to a zone |
| `DeliveryZone` | `Orders` | 1 : Many | Each order is placed within a zone |
| `DeliveryZone` | `Competitor` | 1 : Many | Competitors tracked per zone |
| `DeliveryPlatform` | `Orders` | 1 : Many | Orders come through a specific platform |
| `Customer` | `Orders` | 1 : Many | A customer places many orders |
| `Orders` | `OrderItem` | 1 : Many | An order contains multiple item lines |
| `Orders` | `CODRefusalLog` | 1 : 1 | A COD order may have one refusal record |
| `MenuItem` | `OrderItem` | 1 : Many | A menu item appears in many order lines |
| `MenuItem` | `MenuItemIngredient` | 1 : Many | A menu item is made of multiple ingredients |
| `MenuItem` | `CompetitorMenuItem` | 1 : Many | Each item tracked against competitor equivalents |
| `MenuCategory` | `MenuItem` | 1 : Many | Items grouped under a category |
| `Ingredient` | `MenuItemIngredient` | 1 : Many | An ingredient used in multiple items |
| `Ingredient` | `IngredientPrice` | 1 : Many | Each ingredient has a price history |
| `Competitor` | `CompetitorMenuItem` | 1 : Many | A competitor lists multiple tracked items |

---

## Data Warehouse (OLAP)

The data warehouse follows a **Galaxy Schema** (Fact Constellation) design with 4 fact tables sharing common dimension tables, optimized for Power BI reporting and analytical queries.

> 📄 For full column-level documentation of all tables see: [Database Dictionary](https://github.com/mazen-alasas/ITI-Graduation-Project/blob/main/5.%20Database%20Population%20%26%20Programming/README.md)

![DWH Diagram](https://github.com/mazen-alasas/ITI-Graduation-Project/blob/main/6.%20Data%20Warehouse/images/DWH_Diagram.png)

### Fact Tables

| Table | Description | Key Metrics |
|-------|-------------|-------------|
| `Fact_Orders` | One row per order | Revenue, Commission, COD flags, Refusal data |
| `Fact_OrderItems` | One row per item line | Quantity, Unit Price, Discount, Line Revenue, Cost |
| `Fact_IngredientPrices` | Ingredient price history | Price per unit over time |
| `Fact_CompetitorPricing` | Competitor price tracking | Competitor price, our price, price diff |

### Dimension Tables

| Table | Key Columns |
|-------|-------------|
| `Dim_Date` | FullDate, Year, Quarter, Month, IsWeekend, IsHoliday, IsRamadan, RamadanDay, IsEid, EidName |
| `Dim_Time` | Hour, TimeSlot, Period, ShiftName |
| `Dim_Customer` | CustomerID, FullName, Gender, FirstOrderDate, ZoneKey, **Customer LTV**, **Segment Label**, **Churn Flag** |
| `Dim_Zone` | ZoneName, CityName, TrafficFactor, EstimatedDeliveryMinutes, ZoneClass, DeliveryFee |
| `Dim_Platform` | PlatformName, CommissionRateDefault, HasCODSupport, HasWalletPayment |
| `Dim_MenuItem` | ItemName, CategoryName, CurrentPrice, PackagingCost, PrepTime, ProfitMargin_Percent |
| `Dim_Competitor` | CompetitorName, ZoneName, HasDelivery, AverageDeliveryMinutes, GoogleMapsRating |
| `Dim_Ingredient` | IngredientName, UnitOfMeasure |

---

## SSRS Reports

6 parameterized reports built directly on the OLTP database via Stored Procedures.

| # | Report | Key Parameters | Description |
|---|--------|----------------|-------------|
| 1 | Zone Performance Report | DateFrom, DateTo | Revenue and order metrics per delivery zone |
| 2 | Customer Profitability Report | DateFrom, DateTo, Top N | Top customers ranked by total spend |
| 3 | Platform Performance Report | DateFrom, DateTo | Commission, revenue, and order count per platform |
| 4 | Competitor Comparison Report | ZoneID, DateTracked | Our prices vs competitor prices per item |
| 5 | Order Details Report | DateFrom, DateTo, Status | Full order-level breakdown |
| 6 | Order + Customer Payment Details | DateFrom, DateTo | Combined order and payment info per customer |

---

## Dashboards

20 dashboards organized across 5 focus areas.

### Customers
| # | Dashboard | Focus |
|---|-----------|-------|
| 1 | Customer Segmentation & Value Analysis | VIP / Regular / New scatter, revenue share by segment |
| 2 | Customer Churn Analysis | Churned vs At-Risk customers, days since last order |
| 3 | Ramadan & Holiday Analyzer | Seasonal revenue lift, Iftar peak heatmap, top Ramadan items |
| 4 | Customer LTV & Loyalty | Lifetime value trends, loyalty patterns by zone and segment |

### Menu & Ingredients
| # | Dashboard | Focus |
|---|-----------|-------|
| 5 | Item Performance — Revenue & Gross Profit | Scatter of margin % vs quantity sold per item |
| 6 | Ingredient Cost & Impact | Cost per ingredient and its direct impact on item profitability |
| 7 | Price Volatility & Profit Impact | Ingredient price trends over time and effect on menu margins |
| 8 | Menu Decision Support | Quadrant chart — Stars, Cash Cows, Dogs, Question Marks |

### Executive & Operations
| # | Dashboard | Focus |
|---|-----------|-------|
| 9 | Executive Command Center | Full business overview — Revenue, Profit, Orders, Zone map |
| 10 | Hourly Profit Heatmap | Day × Hour matrix showing peak and loss periods |
| 11 | Refund & Order Accuracy | Order issues, refund rates, and accuracy tracking |
| 12 | What-If Scenario Simulator | Simulate price/commission changes and their profit impact |

### COD & Zones
| # | Dashboard | Focus |
|---|-----------|-------|
| 13 | COD Risk & Refusal Analyzer | Refusal rates by zone, high-risk customer scatter |
| 14 | COD Loss Deep Dive | Waterfall of monthly COD losses, refusal reasons breakdown |
| 15 | Zone Delivery Performance | EstimatedDeliveryMinutes vs TrafficFactor per zone |
| 16 | Zone Profitability Scorecard | Net profit per zone after delivery fee and commission |

### Platforms & Competitors
| # | Dashboard | Focus |
|---|-----------|-------|
| 17 | Platform Profitability | Net revenue and commission burden per platform |
| 18 | Platform Customer Insights | Customer behavior and order patterns per platform |
| 19 | Competitor Price Map Analysis | Our price vs competitor price per item and zone |
| 20 | Competitor Market Positioning | Competitor strategy, ratings, and delivery performance |

---

## AI & Automation

### COD Risk Monitor — n8n Workflow

The system includes an automated pipeline that monitors incoming COD orders every 5 minutes and sends real-time risk alerts directly to the restaurant owner via a Telegram bot.

![n8n Workflow](https://github.com/mazen-alasas/ITI-Graduation-Project/blob/main/9.%20AI%20%26%20Automation/images/workflow.png)

#### How It Works

**Step 1 — Schedule Trigger**
The workflow fires automatically every 1 minutes.

**Step 2 — Microsoft SQL (Update Risk)**
Executes `sp_UpdateCustomerRisk` to recalculate the risk score for every customer based on their full COD refusal history.

```sql
EXEC sp_UpdateCustomerRisk;
```

**Step 3 — Microsoft SQL (Fetch High-Risk Orders)**
Queries all pending COD orders placed today and classifies them by risk level:

```sql
SELECT
    o.OrderID,
    o.PhoneNumber,
    c.FullName_EN,
    (o.Subtotal_EGP + o.DeliveryFee_EGP + ISNULL(o.Tip_EGP, 0)) AS TotalAmount_EGP,
    r.TotalRefusals,
    r.TotalCODOrders,
    r.RefusalRate,
    CASE 
        WHEN r.RefusalRate >= 50 THEN 'CRITICAL (50%+)'
        WHEN r.RefusalRate >= 30 THEN 'HIGH (30-49%)'
        WHEN r.RefusalRate >= 15 THEN 'MEDIUM (15-29%)'
        ELSE 'LOW (0-14%)'
    END AS RiskLevel
FROM Orders o
LEFT JOIN Customer c ON o.PhoneNumber = c.PhoneNumber
INNER JOIN CustomerRisk r ON o.PhoneNumber = r.PhoneNumber
WHERE o.IsCOD = 1 
    AND o.WasCODRefused = 0
    AND o.OrderDate = CAST(GETDATE() AS DATE)
    AND o.OrderTime >= CAST(DATEADD(MINUTE, -1, GETDATE()) AS TIME)  -- ← FIXED
    AND r.RefusalRate >= 15
ORDER BY r.RefusalRate DESC
```

**Step 4 — Telegram Alert**
Sends a formatted message for every high-risk order directly to the restaurant owner:

```
🚨 COD RISK ALERT! 🚨
Order #4057
Phone: 01545383639
Customer: Fatma Hegazy
Amount: 225 EGP
Risk: CRITICAL (50%+)
Refusal Rate: 50%
Past Refusals: 1 out of 2 COD orders

⚠️ ACTION: Call 01545383639 to confirm order before dispatch
```

![Telegram Alert](https://github.com/mazen-alasas/ITI-Graduation-Project/blob/main/9.%20AI%20%26%20Automation/images/telegram%20alert%20massage.jpeg)

#### Risk Level Classification

| Level | Refusal Rate | Action |
|-------|-------------|--------|
| 🟢 LOW | 0–14% | Proceed normally |
| 🟡 MEDIUM | 15–29% | Optional confirmation call |
| 🟠 HIGH | 30–49% | Call customer before dispatch |
| 🔴 CRITICAL | 50%+ | Call customer before dispatch |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Database | Microsoft SQL Server |
| Data Loading | BULK INSERT from CSV |
| Stored Procedures | T-SQL |
| Reporting | SSRS (SQL Server Reporting Services) |
| Data Warehouse | Galaxy Schema on SQL Server and SSIS (SQL Server Integration Services) |
| BI & Dashboards | Power BI and Tableau |
| DAX | Calculated Columns + Measures ... |
| Automation | n8n |
| Alerts | Telegram Bot API |

---

*FoodFlow — Built for the Egyptian food delivery market*
