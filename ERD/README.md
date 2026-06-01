## Entity-Relationship Diagram (ERD)
This diagram maps the full data structure of the system, showing 14 entities and how they relate to each other — from customers and orders, to menu items, ingredients, competitors, and delivery zones. Each entity represents a core business concept, and the relationships between them reflect how real operations flow: a customer places an order through a platform, that order contains items from the menu, those items are built from ingredients with tracked costs, and competitors are monitored against the same menu for price comparison.


### 1. `City`
Stores the cities where the restaurant operates or delivers.

| Column | Description |
|--------|-------------|
| `CityID` 🔑 | Primary key |
| `CityName_AR` | City name in Arabic |
| `CityName_EN` | City name in English |

---

### 2. `DeliveryZone`
Represents a specific delivery area within a city, with its own traffic conditions, delivery time estimate, and fee rules.

| Column | Description |
|--------|-------------|
| `ZoneID` 🔑 | Primary key |
| `ZoneName_AR` | Zone name in Arabic |
| `ZoneName_EN` | Zone name in English |
| `TrafficFactor` | Multiplier for estimated delivery time (1.0 = normal traffic) |
| `BaseDeliveryMinutes` | Delivery time in minutes before applying traffic factor |
| `MinOrderForDelivery` | Minimum order value (EGP) required to qualify for delivery |
| `DeliveryFee` | Delivery fee charged to the customer (EGP) |

---

### 3. `DeliveryPlatform`
Represents a third-party delivery platform (e.g., Talabat, Elmenus) with its commission and payment capabilities.

| Column | Description |
|--------|-------------|
| `PlatformID` 🔑 | Primary key |
| `PlatformName_AR` | Platform name in Arabic |
| `PlatformName_EN` | Platform name in English |
| `CommissionRateDefault` | Default commission % the platform charges per order |
| `HasCODSupport` | Whether the platform supports Cash on Delivery |
| `HasWalletPayment` | Whether the platform supports digital wallet payment |
| `AvgDeliveryFee_EGP` | Average delivery fee shown to customers on this platform |
| `IsNegotiable` | Whether the commission rate can be negotiated with the platform |

---

### 4. `Customer`
Stores customer identity and basic behavioral metadata.

| Column | Description |
|--------|------------|
| `CustomerID` 🔑 | Primary key |
| `FullName_AR` | Customer full name in Arabic |
| `FullName_EN` | Customer full name in English |
| `PhoneNumber` | Masked phone number for privacy |
| `Gender` | Customer gender |
| `FirstOrderDate` | Date the customer placed their first order |

---

### 5. `Orders`
The **core fact table** of the system. Every order placed through any channel is recorded here with full financial and operational details.

| Column | Description |
|--------|-------------|
| `OrderID` 🔑 | Primary key |
| `OrderDate` | Date the order was placed |
| `OrderTime` | Exact time the order was placed |
| `OrderStatus` | Current status: Pending / Confirmed / Delivered / Refused |
| `Subtotal_EGP` | Total item value before delivery fee and commission |
| `DeliveryFee_EGP` | Delivery fee charged to the customer |
| `IsCOD` | Whether the order is paid via Cash on Delivery |
| `WasCODRefused` | Whether the customer refused to pay at the door |
| `Tip_EGP` | Optional tip added by the customer |
| `PlatformCommissionPercent` | Commission % applied for this specific order |
| `PlatformCommissionAmount_EGP` | Calculated commission deducted from the order revenue |

---

### 6. `OrderItem`
Captures each individual item line within an order, including the price at time of purchase.

| Column | Description |
|--------|-------------|
| `OrderItemID` 🔑 | Primary key |
| `Quantity` | Number of units ordered |
| `UnitPriceAtTime_EGP` | Price per unit at the time of the order (snapshot, not current price) |
| `DiscountApplied_EGP` | Discount amount deducted from this item |

---

### 7. `MenuItem`
The restaurant's menu catalog with pricing, costs, and availability flags.

| Column | Description |
|--------|-------------|
| `ItemID` 🔑 | Primary key |
| `ItemName_AR` | Item name in Arabic |
| `ItemName_EN` | Item name in English |
| `CurrentPrice_EGP` | Current selling price to the customer |
| `PackagingCost_EGP` | Cost of packaging materials per unit |
| `PrepTimeMinutes` | Average kitchen preparation time in minutes |
| `IsAvailableForDelivery` | Whether this item can be ordered for delivery |
| `IsBundle` | Whether this item is a combo/bundle meal |

---

### 8. `MenuCategory`
Groups menu items into logical categories (e.g., Mains, Drinks, Desserts).

| Column | Description |
|--------|------------|
| `CategoryID` 🔑 | Primary key |
| `CategoryName_AR` | Category name in Arabic |
| `CategoryName_EN` | Category name in English |

---

### 9. `Ingredient`
Master list of all ingredients used in the kitchen.

| Column | Description |
|--------|-------------|
| `IngredientID` 🔑 | Primary key |
| `IngredientName` | Name of the ingredient |
| `UnitOfMeasure` | Unit used to measure this ingredient (e.g., kg, liter) |

---

### 10. `IngredientPrice`
Tracks the price of each ingredient over time to monitor cost volatility.

| Column | Description |
|--------|-------------|
| `IngredientPriceID` 🔑 | Primary key |
| `PricePerUnit_EGP` | Price per unit of the ingredient on a given date |
| `EffectiveDate` | The date this price became effective |

---

### 11. `MenuItemIngredient`
Junction table that links menu items to their ingredients and specifies how much of each ingredient is needed per serving.

| Column | Description |
|--------|-------------|
| `MenuItemIngredientID` 🔑 | Primary key |
| `QuantityNeeded` | Amount of the ingredient required for one unit of the menu item |

---

### 12. `Competitor`
Stores information about competing restaurants in the same delivery zones.

| Column | Description |
|--------|-------------|
| `CompetitorID` 🔑 | Primary key |
| `CompetitorName_AR` | Competitor name in Arabic |
| `CompetitorName_EN` | Competitor name in English |
| `HasDelivery` | Whether the competitor offers delivery |
| `DeliveryPlatformsUsed` | Comma-separated list of platforms they operate on |
| `AverageDeliveryMinutes` | Their average reported delivery time |
| `GoogleMapsRating` | Their Google Maps rating (1.0–5.0) |

---

### 13. `CompetitorMenuItem`
Tracks competitor item prices over time, linked to equivalent items in our own menu for direct comparison.

| Column | Description |
|--------|-------------|
| `CompetitorMenuItemID` 🔑 | Primary key |
| `CompetitorItemName` | What the competitor calls this item |
| `CompetitorPrice_EGP` | The competitor's listed price for this item |
| `IsOnPromotion` | Whether the item is currently discounted or promoted |
| `DateTracked` | The date this price data was collected |

---

### 14. `CODRefusalLog`
Logs every cash-on-delivery refusal event with the reason and lost amount.

| Column | Description |
|--------|-------------|
| `RefusalID` 🔑 | Primary key |
| `RefusalReason` | Reason recorded for the refusal (e.g., "Customer not home") |
| `RefusedAmount_EGP` | Total order value lost due to the refusal |
| `RefusalDateTime` | DATEExact timestamp of when the refusal occurred |

---

## 🔗 Entity Relationships

| Relationship | Cardinality | Description |
|---|---|---|
| `City` → `DeliveryZone` | 1 : Many | A city contains multiple delivery zones |
| `DeliveryZone` → `Customer` | 1 : Many | Each customer is associated with their delivery zone |
| `DeliveryZone` → `Orders` | 1 : Many | Each order is placed within a delivery zone |
| `DeliveryZone` → `Competitor` | 1 : Many | Competitors are tracked per delivery zone |
| `DeliveryPlatform` → `Orders` | 1 : Many | Orders arrive through a specific platform (or direct) |
| `Customer` → `Orders` | 1 : Many | A customer places many orders over time |
| `Orders` → `OrderItem` | 1 : Many | An order is made up of one or more item lines |
| `Orders` → `CODRefusalLog` | 1 : 1 | A COD order may have one refusal record if rejected |
| `MenuItem` → `OrderItem` | 1 : Many | A menu item can appear in many order lines |
| `MenuItem` → `MenuItemIngredient` | 1 : Many | A menu item is composed of multiple ingredients |
| `MenuItem` → `CompetitorMenuItem` | 1 : Many | Each item can be tracked against multiple competitor equivalents |
| `MenuCategory` → `MenuItem` | 1 : Many | Menu items are grouped under a category |
| `Ingredient` → `MenuItemIngredient` | 1 : Many | An ingredient is used in multiple menu items |
| `Ingredient` → `IngredientPrice` | 1 : Many | Each ingredient has a price history tracked over time |
| `Competitor` → `CompetitorMenuItem` | 1 : Many | A competitor lists multiple items tracked for comparison |
