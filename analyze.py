"""Reproduce descriptive findings from the committed CSV, without a database."""
from pathlib import Path
import hashlib
import json
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pandas as pd

ROOT = Path(__file__).resolve().parent

def main():
    source = ROOT / 'laptopData.csv'
    data = pd.read_csv(source)
    data['Price'] = pd.to_numeric(data['Price'], errors='coerce')
    valid = data.dropna(subset=['Price', 'Company'])
    brands = valid.groupby('Company')['Price'].agg(count='count', median='median', mean='mean').round(2)
    out = ROOT / 'docs/results'
    out.mkdir(parents=True, exist_ok=True)
    brands.sort_values('count', ascending=False).to_csv(out / 'brand_summary.csv')
    content = data.drop(columns=[c for c in data.columns if c.lower().startswith('unnamed')])
    report = {
        'dataset_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
        'rows': len(data), 'columns': len(data.columns), 'companies': int(data['Company'].nunique()),
        'duplicate_content_rows': int(content.duplicated().sum()),
        'missing_price_rows': int(data['Price'].isna().sum()),
        'median_price': round(float(valid['Price'].median()), 2),
        'mean_price': round(float(valid['Price'].mean()), 2),
        'price_unit': 'Original dataset units; currency not verified by repository metadata',
        'most_common_company': str(brands['count'].idxmax()),
        'most_common_company_count': int(brands['count'].max()),
        'method': 'Descriptive Python validation of the raw committed CSV; not an execution of the SQL scripts. Duplicate rows are counted, not removed.',
    }
    (out / 'summary.json').write_text(json.dumps(report, indent=2) + '\n')
    plot = brands[brands['count'] >= 20].sort_values('median')
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 6), facecolor='white')
    plot['median'].plot.barh(ax=ax1, color='#2563eb')
    ax1.set(title='Median listed price by brand (at least 20 laptops)', xlabel='Price in dataset units', ylabel='')
    brands.sort_values('count', ascending=False).head(10)['count'].plot.bar(ax=ax2, color='#0f766e')
    ax2.set(title='Ten most represented brands', ylabel='Rows in the dataset', xlabel='')
    ax2.tick_params(axis='x', rotation=45)
    fig.suptitle('Laptop dataset: descriptive findings', fontsize=17)
    fig.tight_layout()
    fig.savefig(out / 'laptop_analysis.png', dpi=160)
    plt.close(fig)
    print(json.dumps(report, indent=2))

if __name__ == '__main__':
    main()
