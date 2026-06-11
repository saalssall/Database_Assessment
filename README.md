# 🏥 Database Assessment — SQL Scripts

A collection of MySQL database scripts covering schema design, data manipulation, views, transactions, user management, and access control across four domains.

---

## 📁 Databases Covered

| Database | Domain |
|---|---|
| `HospitalDB` | Hospital patients, doctors, rooms, treatments, medications |
| `Assessment_3B_24s2_HomebaseDB` | Property rental — clients, staff, inspections, branches |
| `BankingDB` | Bank customers, accounts, user roles and permissions |
| `RetailDB` | Products, orders, and stock management |

---

## 🗂️ Task Breakdown

### Task 2 — HospitalDB

| Part | Description |
|---|---|
| **A** | Schema creation — `Patient`, `Doctor`, `Room`, `Treatment`, `Medication` tables with PKs, FKs, and constraints |
| **C** | Valid dummy data inserts across all 5 tables |
| **D** | Invalid inserts demonstrating constraint violations (NULL PK, duplicate UNIQUE, invalid ENUM, FK mismatch, CHECK failure) |
| **E** | Invalid insert demonstrating FK violation on `room_number` |
| **F** | `Patient_Public_View` — view exposing only non-sensitive patient fields |

### Task 3 — HomebaseDB Queries

| Part | Description |
|---|---|
| **A** | `SELECT` — clients preferring flats with rent > $400 |
| **B** | `INSERT` — new client record |
| **C** | `DELETE` — remove a specific inspection record |
| **D** | `UPDATE` — apply 207% salary increase to two staff members |
| **E** | `JOIN` + `GROUP BY` — count properties owned by a specific owner |
| **F** | `LIKE` — properties on streets starting with 16 or 18 |
| **G** | `JOIN` + `HAVING` — branches managing more than one property |

### Task 4 — HomebaseDB Subqueries

| Part | Description |
|---|---|
| **A** | Clients who have had inspections after May 2023 |
| **B** | Owners of properties with more than 2 rooms |
| **C** | Clients who inspected properties in a specific postcode (nested 3-level subquery) |
| **D** | Branch summary — total salary, employee count, property count via `RIGHT JOIN` |

### Task 5 — BankingDB

| Part | Description |
|---|---|
| **A** | Database creation |
| **B** | `Customer` table schema |
| **C** | `Account` table schema with ENUM and CHECK constraints |
| **D** | Create four users (`admin`, `teller`, `auditor`, `customer_support`) with expiring passwords |
| **E** | Role creation and privilege grants per user type |
| **F** | Revoke `DELETE` privilege from `teller` on both tables |

### Task 6 — RetailDB

| Part | Description |
|---|---|
| **A** | Database creation |
| **B** | `Product` and `Orders` table schemas |
| **C** | 10 products and 10 orders inserted as dummy data |
| **D** | `START TRANSACTION` / `COMMIT` — deduct 3 units from Laptop stock |

---

## ⚠️ Intentional Constraint Violations (Task 2 Part D & E)

These inserts are **designed to fail** to demonstrate enforcement of database constraints:

| Insert | Constraint Violated |
|---|---|
| Patient with `NULL` ID | `NOT NULL` on primary key |
| Doctor with duplicate email | `UNIQUE` on `email` |
| Room with availability `'T'` | `ENUM ('Y', 'N')` |
| Treatment with `Total_Cost = 0.4` | `CHECK (Total_Cost > 0)` (rounds to 0) |
| Medication referencing treatment `40` | Foreign key — treatment does not exist |
| Treatment with `room_number = 9` | Foreign key — room does not exist |

---

## 🔐 BankingDB — User Permissions Summary

| User | SELECT | INSERT | UPDATE | DELETE |
|---|---|---|---|---|
| `admin` | ✅ | ✅ | ✅ | ✅ |
| `teller` | ✅ | ✅ | ✅ | ❌ (revoked) |
| `auditor` | ✅ | ❌ | ❌ | ❌ |
| `customer_support` | ✅ (Customer only) | ❌ | ❌ | ❌ |

---

## 🛠️ How to Run

1. Open **MySQL Workbench** (or any MySQL client).
2. Run the full script top to bottom.
3. Tasks 2–6 each create and switch to their own database — no manual setup needed.

> **Note:** relevant dummy databases are required for Tasks 3 and 4.
