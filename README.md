# Capstone Project — Mamaearth Returns & Growth Intelligence Pipeline

**Program:** Data Analytics with AI & Gen AI · E&ICT Academy IIT Roorkee  

---

## Executive Summary

This repository presents an end-to-end data analytics and Generative AI intelligence pipeline built for Mamaearth's Growth Analytics team. The pipeline investigates product return patterns, reconciles revenue metrics across raw and cleaned relational stores, identifies critical risk segments (such as Cash on Delivery orders in Tier-2 cities), and synthesizes these quantitative findings into an executive Situation-Complication-Resolution (SCR) business narrative powered by Google's Gemini API with a zero-dependency offline fallback path.

Every numerical figure reported in this repository is strictly computed and verified across three connected pipeline layers:
1. **Part 1 — SQL Relational Layer & Reporting**
2. **Part 2 — Python/Pandas Data Wrangling & EDA** 
3. **Part 3 — GenAI-Powered Insight Narrator**

---

## Repository Structure

```
.
├── README.md                           # Front door documentation & execution guide
├── requirements.txt                    # Project dependencies (pandas, matplotlib, google-genai)
├── sql/
│   ├── schema.sql                      # DDL schema definitions (customers, products, orders)
│   ├── seed_data.sql                   # SQL INSERT statements for 45 customers, 16 products, 180 orders
│   └── reports.sql                     # 9 analytical SQL queries (a-i) with verified execution output comments
├── data/
│   ├── customers.csv                   # Raw customer dataset (45 rows)
│   ├── products.csv                    # Raw product catalog dataset (16 rows)
│   └── orders.csv                      # Raw order transaction dataset (180 rows, includes duplicates/nulls)
├── analysis/
│   ├── clean_and_eda.py                # Data cleaning, deduplication, imputation, IQR, hypothesis & time series
│   └── visualize.py                    # Matplotlib visualizer producing publication-ready PNG charts
├── visualizations/
│   ├── return_rate_by_payment.png      # Bar chart: Return rate by payment method (COD returns at 44.4%)
│   └── monthly_revenue_trend.png       # Line chart: Outlier-corrected monthly revenue trend (March peak)
└── narrator/
    ├── findings.json                   # Structured JSON metric store generated dynamically by clean_and_eda.py
    └── generate_narrative.py           # Gemini 3.8 Flash GenAI narrator script with offline fallback & verification
```

---

## Pipeline Execution Order & Data Flow

To reproduce all results end-to-end, execute the pipeline components in the exact order shown below:

```
+-----------------------------------------------------------------------------------+
| 1. SQL Layer (sql/)                                                               |
|    Load schema.sql & seed_data.sql -> Run reports.sql (Raw total: INR 99,860.20)     |
+-----------------------------------------------------------------------------------+
                                          |
                                          v (Raw source CSVs read by Pandas)
+-----------------------------------------------------------------------------------+
| 2. Python Analysis Layer (analysis/)                                              |
|    a) clean_and_eda.py -> Standardize, deduplicate (175 rows), impute, IQR, seg. |
|       -> Export verified findings to narrator/findings.json                       |
|    b) visualize.py    -> Generate charts in visualizations/                         |
+-----------------------------------------------------------------------------------+
                                          |
                                          v (findings.json consumed by Narrator)
+-----------------------------------------------------------------------------------+
| 3. GenAI Narrator Layer (narrator/)                                               |
|    generate_narrative.py -> Gemini API (gemini-3.8-flash) or Keyless Offline Mode |
|       -> Validates numeric accuracy -> Output saved to narrator/sample_output.txt  |
+-----------------------------------------------------------------------------------+
```

---

## How to Run the Pipeline

### Prerequisites

Ensure Python 3.9+ is installed, then install all required Python packages:
```bash
pip install -r requirements.txt
```

### Step 1: Execute SQL Relational Layer & Reporting (Part 1)

You can run the SQL scripts using standard SQLite (or Python's built-in `sqlite3` engine):

```bash
# SQLite CLI execution example
sqlite3 mamaearth.db < sql/schema.sql
sqlite3 mamaearth.db < sql/seed_data.sql
sqlite3 mamaearth.db < sql/reports.sql
```

Alternatively, run the queries via Python:
```python
import sqlite3

conn = sqlite3.connect(':memory:')
with open('sql/schema.sql') as f:
    conn.executescript(f.read())
with open('sql/seed_data.sql') as f:
    conn.executescript(f.read())
with open('sql/reports.sql') as f:
    conn.executescript(f.read())
```

### Step 2: Execute Python Data Wrangling, EDA & Visualizations (Part 2)

Run the data cleaning script, followed by the visualization generator:

```bash
# 1. Clean data, perform EDA, and generate narrator/findings.json
python analysis/clean_and_eda.py

# 2. Generate visualization PNG files in visualizations/
python analysis/visualize.py
```

### Step 3: Execute GenAI Insight Narrator (Part 3)

#### Option A: Online Gemini API Mode
Set your Gemini API key as an environment variable:

```bash
# Set Gemini API Key (Windows PowerShell)
$env:GEMINI_API_KEY="your_gemini_api_key_here"

# Run Narrator Generator
python narrator/generate_narrative.py
```

#### Option B: Offline / Keyless Mode
If no API key is provided, or if network/quota issues occur, the script automatically falls back to the deterministic offline path:

```bash
# Unset key to force offline execution
$env:GEMINI_API_KEY=""

python narrator/generate_narrative.py
```

---

## Summary of Verified Analytics Findings

### Part 1 — SQL Key Results (Raw Data)
* **Report (a) Order Totals:** Total Orders = `180`, Total Revenue = `₹99,860.20`, Average Order Value = `₹554.78`.
* **Report (b) Missing Values:** Total rows = `180`, Rated rows = `165`, Unrated rows = `15`.
* **Report (c) Zero-Match Customer:** Both `LEFT JOIN` and `NOT IN` queries return customer `C045` (Vihaan).
* **Report (d) High-Return Cities (>20%):** Jaipur (`42.1%`), Lucknow (`30.6%`), Bangalore (`24.2%`).
* **Report (e) Top Spend Ranking:** 
  1. `C043` Reyansh (`₹12,920.00`)
  2. `C026` Isha (`₹8,371.60`)
  3. `C008` Meera (`₹4,564.60`)
  4. `C011` Arjun (`₹4,111.00`)
  5. `C042` Sanya (`₹3,785.00`)
  *`LIMIT 3 OFFSET 2` returns ranks 3-5 (`C008`, `C011`, `C042`). Tie-breaking on `customer_id ASC` ensures deterministic ranking order.*
* **Report (f) Revenue by Category:** Haircare (`₹44,956.10`), Skincare (`₹27,346.00`), Babycare (`₹16,805.00`), PersonalCare (`₹10,753.10`).
* **Report (g) Name Pattern ('A%'):** Exactly `10` customers.
* **Report (h) Acquisition Channels:** `Ad`, `Organic`, `Referral`, `Social` (`4` channels).
* **Report (i) Loyalty Tiers:** `Gold` (`28` customers, Tier-1), `Silver` (`17` customers, Tier-2).

---

### Part 2 — Python Cleaning & EDA Insights

1. **Deduplication & Reconciliation:**
   * Removed 5 exact duplicate order rows (`O0176`, `O0177`, `O0178`, `O0179`, `O0180`), reducing active orders from 180 to **175 rows**.
   * Cleaned Total Revenue across 175 rows = **₹97,358.30**.
   * **Reconciliation Note:** The exact delta of **₹2,501.90** between Part 1 raw revenue (`₹99,860.20`) and Part 2 cleaned revenue (`₹97,358.30`) is 100% accounted for by the order value sum of the 5 dropped duplicate rows (`O0176`: ₹942.90 + `O0177`: ₹244.30 + `O0178`: ₹412.20 + `O0179`: ₹318.40 + `O0180`: ₹584.10 = ₹2,501.90). Missing value imputation in Task 4 did not alter revenue.

2. **Outlier Detection (IQR on Quantity):**
   * Q1 = `1.0`, Q3 = `2.0`, IQR = `1.0`, Bounds = `[-0.5, 3.5]`.
   * Detected 2 bulk order outliers: `O0011` (quantity 25) and `O0098` (quantity 30). Flagged with `is_outlier=True`.

3. **Payment Method & Return Rate Analysis:**
   * CARD: **14.7%** return rate (10/68)
   * UPI: **18.9%** return rate (10/53)
   * COD: **44.4%** return rate (24/54) — **Hypothesis Confirmed** (3x electronic rates).

4. **Multi-level Risk Segmentation:**
   * Single Highest-Risk Segment: **COD + Tier-2 Cities at 54.5% return rate** (12/22 returned).
   * COD Tier-1 return rate is lower at **37.5%** (12/32), demonstrating that COD risk is concentrated in Tier-2 regions.

5. **Correlation Analysis:**
   * All pairwise correlations across rating, returned, discount_pct, and quantity fall into the **negligible band** ($|r| < 0.20$).
   * Hypothesis "higher discounts reduce returns" is **Busted** ($r = -0.0880$).

6. **Time Series & True Peak Month:**
   * Unadjusted series (with outliers) showed January 2026 as the apparent peak (`₹29,582.10`).
   * Outlier-corrected series (excluding `O0011` & `O0098`) adjusts January to `₹11,637.10` and reveals **March 2026 (`2026-03`) as the true peak month (`₹20,318.90`)**.

---

### Part 3 — GenAI SCR Narrative Verification

The GenAI Narrator evaluates the verified metrics from `findings.json` and outputs an executive Situation-Complication-Resolution report containing all 5 mandatory figures:

| Required Figure | Expected Value | Verification Status |
| :--- | :--- | :---: |
| Cleaned Total Revenue | `₹97,358.30` | **PASS** |
| COD Return Rate | `44.4%` | **PASS** |
| Highest Risk Segment Return Rate | `54.5%` | **PASS** |
| Duplicate Reconciliation Delta | `₹2,501.90` | **PASS** |
| True Peak Month & Revenue | `March (2026-03)` / `₹20,318.90` | **PASS** |

The final verified narrative is displayed on stdout along with verification check results.

---

## Project Compliance Checklist

- [x] **No hardcoded statistics:** All numbers dynamically flow SQL -> Pandas -> JSON -> GenAI.
- [x] **Exact structural match:** All files committed in requested layout.
- [x] **Re-runnable pipeline:** Executing Python scripts reproducibly regenerates all outputs.
- [x] **Offline fallback path:** Full offline functionality built into `generate_narrative.py`.
- [x] **100% numerical accuracy:** All figures match brief specifications exactly.
