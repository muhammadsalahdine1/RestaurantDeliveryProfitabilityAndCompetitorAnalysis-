# ERD to DBML Mapping — Documentation
## Egyptian Restaurant Delivery Profitability & Competitor Intelligence System

---

## Deliverables

| File | Description |
|---|---|
| `Mapping.dbml` | DBML schema translated from the ERD |
| `mapping.png` | Visual diagram exported from dbdiagram.io |

---

## Step 1 — Identify Entities and Attributes

The ERD defines **15 entities**, each mapped to a DBML table. Every attribute becomes a column with its data type, nullability, and default where applicable.

| # | Entity | Table |
|---|---|---|
| 1 | City | `City` |
| 2 | Delivery Zone | `DeliveryZone` |
| 3 | Delivery Platform | `DeliveryPlatform` |
| 4 | Customer | `Customer` |
| 5 | Orders | `Orders` |
| 6 | Order Item | `OrderItem` |
| 7 | Menu Item | `MenuItem` |
| 8 | Menu Category | `MenuCategory` |
| 9 | Ingredient | `Ingredient` |
| 10 | Ingredient Price | `IngredientPrice` |
| 11 | Menu Item Ingredient *(junction)* | `MenuItemIngredient` |
| 12 | Competitor | `Competitor` |
| 13 | Competitor Platform *(junction)* | `CompetitorPlatform` |
| 14 | Competitor Menu Item | `CompetitorMenuItem` |
| 15 | COD Refusal Log | `CODRefusalLog` |

> **Note:** `CompetitorPlatform` was not an entity in the original ERD. It was extracted from the multivalued attribute `DeliveryPlatformsUsed` on `Competitor` during normalization — see Step 3.

---

## Step 2 — Define Primary Keys

Every table has a surrogate integer primary key with auto-increment.

```dbml
CityID int [pk, increment]
```

---

## Step 3 — Map All Relationships

### 3.1 — Direct Foreign Keys (1:M)

| Relationship | FK Column | Placed In | References |
|---|---|---|---|
| City → DeliveryZone | `CityID` | `DeliveryZone` | `City.CityID` |
| DeliveryZone → Customer | `ZoneID` | `Customer` | `DeliveryZone.ZoneID` |
| DeliveryZone → Orders | `ZoneID` | `Orders` | `DeliveryZone.ZoneID` |
| DeliveryZone → Competitor | `ZoneID` | `Competitor` | `DeliveryZone.ZoneID` |
| DeliveryPlatform → Orders | `PlatformID` | `Orders` | `DeliveryPlatform.PlatformID` |
| Customer → Orders | `CustomerID` | `Orders` | `Customer.CustomerID` |
| Orders → OrderItem | `OrderID` | `OrderItem` | `Orders.OrderID` |
| MenuItem → OrderItem | `ItemID` | `OrderItem` | `MenuItem.ItemID` |
| MenuCategory → MenuItem | `CategoryID` | `MenuItem` | `MenuCategory.CategoryID` |
| Ingredient → IngredientPrice | `IngredientID` | `IngredientPrice` | `Ingredient.IngredientID` |
| Ingredient → MenuItemIngredient | `IngredientID` | `MenuItemIngredient` | `Ingredient.IngredientID` |
| MenuItem → MenuItemIngredient | `ItemID` | `MenuItemIngredient` | `MenuItem.ItemID` |
| Competitor → CompetitorMenuItem | `CompetitorID` | `CompetitorMenuItem` | `Competitor.CompetitorID` |
| Competitor → CompetitorPlatform | `CompetitorID` | `CompetitorPlatform` | `Competitor.CompetitorID` |
| DeliveryPlatform → CompetitorPlatform | `PlatformID` | `CompetitorPlatform` | `DeliveryPlatform.PlatformID` |

### 3.2 — One-to-One Relationship

| Relationship | FK Column | Placed In | References | Constraint |
|---|---|---|---|---|
| Orders → CODRefusalLog | `OrderID` | `CODRefusalLog` | `Orders.OrderID` | `unique` — enforces 1:1 |

### 3.3 — Optional Foreign Keys

| Relationship | FK Column | Placed In | References | Notes |
|---|---|---|---|---|
| MenuItem → CompetitorMenuItem | `YourItemID` | `CompetitorMenuItem` | `MenuItem.ItemID` | Nullable — no match if competitor item has no equivalent |
| DeliveryPlatform → CompetitorPlatform | `PlatformID` | `CompetitorPlatform` | `DeliveryPlatform.PlatformID` | Nullable — competitor may use platforms not in our system |

### 3.4 — M:N Relationships Resolved via Junction Tables

| M:N Relationship | Junction Table | FK 1 | FK 2 |
|---|---|---|---|
| `MenuItem` ↔ `Ingredient` | `MenuItemIngredient` | `ItemID → MenuItem.ItemID` | `IngredientID → Ingredient.IngredientID` |
| `Competitor` ↔ `DeliveryPlatform` | `CompetitorPlatform` | `CompetitorID → Competitor.CompetitorID` | `PlatformID → DeliveryPlatform.PlatformID` |

> `CompetitorPlatform` was introduced to replace the multivalued attribute `DeliveryPlatformsUsed` that existed as a comma-separated string in the original ERD. Normalizing it into a junction table enables proper relational querying.

---

## Step 4 — Add Constraints and Defaults

Key column rules encoded in DBML:

| Column | Rule |
|---|---|
| `PhoneNumber` in `Customer` | `unique` |
| `OrderID` in `CODRefusalLog` | `unique` (enforces 1:1 with Orders) |
| `TrafficFactor` | `default: 1.00` |
| `BaseDeliveryMinutes` | `default: 20` |
| `OrderStatus` | `default: 'Pending'` |
| `IsCOD` | `default: true` |
| `IsBundle`, `IsAvailableForDelivery` | `default: false / true` |
| `PackagingCost_EGP` | `default: 2.00` |
| `UnitOfMeasure` | `default: 'kg'` |

---

## Step 5 — Generate the Visual Diagram (`mapping.png`)

1. Open [dbdiagram.io](https://dbdiagram.io)
2. Paste the full content of `Mapping.dbml`
3. The diagram renders automatically
4. Export → PNG → save as `mapping.png`

---

## Schema Relationship Tree

```
City
 └── DeliveryZone
      ├── Customer
      │    └── Orders ──────────────────────────────┐
      │         ├── OrderItem                        │
      │         │    └── MenuItem                    │
      │         │         ├── MenuCategory           │
      │         │         └── MenuItemIngredient     │
      │         │              └── Ingredient        │
      │         │                   └── IngredientPrice
      │         └── CODRefusalLog (1:1)              │
      │                                              │
      ├── Competitor ◄──────────────────────────────┘ (ZoneID)
      │    ├── CompetitorPlatform ── DeliveryPlatform ── (Orders.PlatformID)
      │    └── CompetitorMenuItem ── MenuItem (optional FK)
      └── (Orders.ZoneID, Orders.PlatformID also FK here)
