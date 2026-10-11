"""
Capstone Project — Mamaearth Returns & Growth Intelligence Pipeline
Part 2: Python / Pandas Data Wrangling & EDA
File: analysis/visualize.py
"""

import os
import pandas as pd
import matplotlib.pyplot as plt


def create_visualizations():
    os.makedirs('visualizations', exist_ok=True)

    # Load data
    orders = pd.read_csv('data/orders.csv')
    products = pd.read_csv('data/products.csv')

    # Standardize payment method
    orders['payment_method'] = orders['payment_method'].astype(str).str.strip().str.upper()

    # Deduplicate
    natural_key = [
        'customer_id', 'product_id', 'order_date', 'quantity',
        'discount_pct', 'payment_method', 'rating', 'returned'
    ]
    orders_clean = orders.drop_duplicates(subset=natural_key, keep='first').copy()

    # Impute missing discount_pct
    orders_clean['discount_pct'] = orders_clean['discount_pct'].fillna(0)

    # Merge products
    merged = orders_clean.merge(products, on='product_id', how='left')
    merged['order_value'] = merged['quantity'] * merged['price'] * (1 - merged['discount_pct'] / 100.0)

    # -------------------------------------------------------------------------
    # Visualization 1: Return Rate by Payment Method (Bar Chart)
    # -------------------------------------------------------------------------
    pay_agg = merged.groupby('payment_method')['returned'].agg(['count', 'mean']).reset_index()
    pay_agg['return_rate_pct'] = (pay_agg['mean'] * 100).round(1)
    pay_agg = pay_agg.sort_values(by='return_rate_pct', ascending=False)

    plt.figure(figsize=(8, 5), dpi=300)
    colors = ['#d9534f' if p == 'COD' else '#428bca' for p in pay_agg['payment_method']]
    bars = plt.bar(pay_agg['payment_method'], pay_agg['return_rate_pct'], color=colors, width=0.55, edgecolor='black', linewidth=0.8)

    plt.title('COD Returns at 44.4% - 3x Higher Than Card & UPI', fontsize=13, fontweight='bold', pad=15)
    plt.xlabel('Payment Method', fontsize=11, labelpad=8)
    plt.ylabel('Return Rate (%)', fontsize=11, labelpad=8)
    plt.ylim(0, 55)
    plt.grid(axis='y', linestyle='--', alpha=0.5)

    # Annotate exact percentage labels on top of bars
    for bar in bars:
        height = bar.get_height()
        plt.text(
            bar.get_x() + bar.get_width() / 2.0,
            height + 1.2,
            f'{height:.1f}%',
            ha='center',
            va='bottom',
            fontsize=11,
            fontweight='bold'
        )

    plt.tight_layout()
    v1_path = 'visualizations/return_rate_by_payment.png'
    plt.savefig(v1_path)
    plt.close()
    print(f"Saved visualization 1 to {v1_path}")

    # -------------------------------------------------------------------------
    # Visualization 2: Monthly Revenue Trend (Outlier-Corrected Line Chart)
    # -------------------------------------------------------------------------
    # Identify IQR outliers on quantity
    q1 = merged['quantity'].quantile(0.25)
    q3 = merged['quantity'].quantile(0.75)
    iqr = q3 - q1
    upper_bound = q3 + 1.5 * iqr
    lower_bound = q1 - 1.5 * iqr

    merged['is_outlier'] = (merged['quantity'] < lower_bound) | (merged['quantity'] > upper_bound)
    merged['order_date'] = pd.to_datetime(merged['order_date'])
    merged['year_month'] = merged['order_date'].dt.to_period('M').astype(str)

    ts_no_outliers = merged[~merged['is_outlier']].groupby('year_month')['order_value'].sum().reset_index()

    plt.figure(figsize=(9, 5.5), dpi=300)
    plt.plot(
        ts_no_outliers['year_month'],
        ts_no_outliers['order_value'],
        marker='o',
        color='#2e7d32',
        linewidth=2.5,
        markersize=7,
        label='Outlier-Corrected Revenue'
    )

    plt.title('Outlier-Corrected Monthly Revenue: March 2026 is the True Peak (₹20,318.90)', fontsize=13, fontweight='bold', pad=15)
    plt.xlabel('Month (2026)', fontsize=11, labelpad=8)
    plt.ylabel('Total Clean Revenue (INR ₹)', fontsize=11, labelpad=8)
    plt.grid(True, linestyle='--', alpha=0.5)

    # Highlight peak month March 2026
    march_idx = ts_no_outliers[ts_no_outliers['year_month'] == '2026-03'].index[0]
    march_val = ts_no_outliers.loc[march_idx, 'order_value']

    plt.annotate(
        f'Peak Month: March 2026\n₹{march_val:,.2f}',
        xy=(march_idx, march_val),
        xytext=(march_idx - 0.5, march_val + 2000),
        arrowprops=dict(facecolor='#1b5e20', shrink=0.08, width=1.5, headwidth=8),
        fontsize=10,
        fontweight='bold',
        bbox=dict(boxstyle='round,pad=0.4', facecolor='#e8f5e9', edgecolor='#2e7d32', alpha=0.9)
    )

    plt.ylim(5000, 24000)
    plt.tight_layout()
    v2_path = 'visualizations/monthly_revenue_trend.png'
    plt.savefig(v2_path)
    plt.close()
    print(f"Saved visualization 2 to {v2_path}")


if __name__ == '__main__':
    create_visualizations()
