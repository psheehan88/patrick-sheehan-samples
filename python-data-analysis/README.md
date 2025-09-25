# Python Data Analysis – Capability & SPC Example

This project demonstrates how to use Python for **statistical process control (SPC)** and capability analysis.  
The script loads a CSV dataset, computes key metrics (mean, standard deviation, Pp, Ppk), and generates  
visualizations such as histograms with probability density functions.

### Features
- Reads data from CSV input
- Computes descriptive statistics
- Calculates capability indices (Pp, Ppk)
- Builds histograms and overlays a normal distribution curve
- Identifies defect rates outside specification limits
- Outputs results in both console and visual formats

### Purpose
This project highlights:
- **Data handling & analysis** with Python (pandas, numpy, scipy)
- **Statistical methods** for quality & compliance
- **Data visualization** using matplotlib
- **Code clarity** with modular functions and inline documentation

### Example Output
**Capability Histogram with Normal Distribution Curve**

![Histogram Example](histogram_example.png)

---

### How to Run
```bash
pip install pandas numpy matplotlib scipy
python capability_analysis.py
