# 🚀 "End-To-End Statistical Programming And Transformation Of Raw Data To CDISC Standards (SDTM ADaM,TLFs) For Synthetic Oncology Clinical Trial Data Using SAS OnDemand.

---

## 📋 Project Overview
**"End-To-End Statistical Programming And Transformation Of Raw Data To CDISC Standards (SDTM, ADaM, TLFs) For Synthetic Oncology Clinical Trial Data Using SAS OnDemand®"**

This project showcases a complete, industry-standard clinical data transformation workflow for a **Phase III Oncology (Lung Cancer) clinical trial (ONCO-PEMBRO-500)** using Base SAS and SAS OnDemand. It demonstrates end-to-end CDISC implementation from simulated raw data to SDTM mapping, ADaM analysis-ready datasets, and regulatory-compliant TLFs with QC validation.

---

## 🏛️ Academic & Institutional Details
* **College:** Dr. N. J. Paulbudhe College of Pharmacy, Savedi, Ahilyanagar, Maharashtra – 414003
* **Affiliation:** Savitribai Phule Pune University (SPPU), Pune, Maharashtra
* **Academic Year:** 2025 – 2026
* **Program:** M.Pharm (Pharmacology) - Semester IV
* **Candidate:** Mr. Aher Shailendra Shainath (Seat No.: 10492)
* **Project Guide:** Dr. Aman B. Upaganlawar (M.Pharm., Ph.D., M.B.A., FAMS, Department of Pharmacology)

---

## 🎯 Aim & Objectives

* **Aim:** To develop an end-to-end SAS Programming framework for the statistical analysis of synthetic oncology clinical data in compliance with CDISC Standards.
* **Objectives:**
  1. **Import & Map:** Raw Data to SDTM Standards.
  2. **Derive:** SDTM to ADaM Datasets for Analysis.
  3. **Generate:** Tables, Listings, and Figures (TLFs).
  4. **Validate:** Ensure code accuracy using Quality Control (QC).

---

## 🔬 Study Design & Protocol Comparison
* **Protocol ID:** ONCO-PEMBRO-500 (Simulated Advanced Scenario) vs. KEYNOTE-024 (NCT02142738 Original Reference)
* **Study Phase:** Phase III, Randomized, Double-Blind (Expanded for Power, $N = 500$)
  
  <br>
  
* **Treatment Arms:** 
  * *Arm A (Test):* Pembrolizumab (200 mg) + Platinum Chemo
  * *Arm B (Control):* Placebo + Platinum Chemo
* **Objective:** SAS Programming & CDISC Implementation for Oncology Clinical Trials.

---

## 🧪 Why Synthetic Data?
* **Privacy Compliance:** Real patient data is strictly protected under HIPAA/GDPR laws and cannot be accessed for academic purposes.
* **Technical Validation:** Used High-Fidelity Synthetic Data to rigorously test complex SAS algorithms without ethical risks.
* **Focus Shift:** Allows complete validation of the SAS programming pipeline, independent of the drug's actual clinical outcome.
* **Reproducibility:** Proves that the SAS macros developed can be applied to any real-world oncology trial in the future.

---

## ⚙️ Project Methodology & Statistical Programming Workflow
1. **Data Acquisition:** CDM Export (Raw Data)
2. **SAS Import:** `PROC IMPORT` to Pre-SDTM Datasets
3. **SDTM Mapping:** Study Data Tabulation Model implementation
4. **ADaM Derivation:** Analysis Data Model generation
5. **TLF Generation:** Creating statistical Tables, Listings, and Figures
6. **QC & Validation:** Independent double programming logic for code accuracy
7. **Regulatory Submission:** Delivers validated statistical results ready package for CSR - Section 14 (RTF/PDF) format for the Medical Writing Review Team.

---

## 📊 Research Hypothesis
* **Null Hypothesis ($H_0$):** The automated SAS framework fails to accurately transform raw data into compliant CDISC standards and TLFs.
* **Alternative Hypothesis ($H_1$):** The automated SAS framework successfully and accurately transforms raw oncology data into FDA-compliant CDISC standards and generates accurate TLFs.

---

## 📊 Complete Project Inventory & Data Traceability

### 1. Raw Data (9 Domains)
* **Patient & Disposition:** DM, DS
* **Safety Data:** AE, LB, VS, EX
* **Oncology Specific:** TU, TR, RS

### 2. SDTM Implementation (14 Domains)
* **9 Parent Domains:** DM, DS, AE, LB, VS, EX, TU, TR, RS
* **5 Supplemental Domains:** SUPPDM, SUPPAE, SUPPPEX, SUPPLB, SUPPVS

### 3. ADaM Datasets (6 Analysis-Ready Datasets)
* **ADSL:** Subject Level Analysis (from DM + DS + EX)
* **ADAE:** Adverse Events Analysis (from AE + ADSL)
* **ADLB:** Laboratory Analysis (from LB + ADSL)
* **ADVS:** Vital Signs Analysis (from VS + ADSL)
* **ADRESP:** Tumor Response Analysis (from ADSL + RS)
* **ADTTE:** Time-to-Event Analysis (from ADSL + ADVS)

### 4. Statistical Outputs - TLFs (15 Total)
* **Tables (7):** Demographics, Exposure, TEAE, ORR, BOR, Lab Toxicity, Overall Survival.
* **Listings (5):** Subject Listing, AE Listing, Lab Results, Tumor Response, Time-to-Event.
* **Figures (3):** KM Plot (OS), KM Plot (PFS), Bar Chart (Best Overall Response) using `PROC SGPLOT` & `PROC LIFETEST`.

---

## 🔍 Quality Control & Validation Strategy
* **The Validation Methodology:** Independent Double Programming Logic (IDP) used where the exact same dataset is executed using a different production/validation code to compare results.
* **List of QC Performed:**
  * **QC_T1 & QC_T2:** Demographic and Exposure Tables verification.
  * **QC_L1 & QC_L2:** Subject and Adverse Event Listings review.
  * **QC_F1 & QC_F2:** Kaplan-Meier Overall Survival and Progression-Free Survival Plots validation.
* **Outcome:** All programs successfully passed the independent QC check with identical results.

---

## 🔄 End-To-End Traceability Matrix (The Data Journey)
| Data Stage | Total Files | Key Components / Domains | Industry Standard |
| :--- | :--- | :--- | :--- |
| **1. Raw Input** | 09 Files | DM, AE, EX, LB, VS, TU, TR, RS, DS | CDM Export (CSV) |
| **2. SDTM** | 14 Domains | DM, AE, EX, LB, VS, TU, TR, RS, DS + 5 SUPP Domains | CDISC SDTM v3.2 |
| **3. ADaM** | 06 Datasets | ADSL, ADAE, ADLB, ADVS, ADRESP, ADTTE | CDISC ADaM v1.1 |
| **4. TLF Output** | 15 Outputs | 07 Tables, 05 Listings, 03 Figures (KM Plot) | ICH E3 Guidelines |

---

## 📈 Results - 1. Demographics & Baseline Characteristics
* **Patient Profile Summary:** Total Sample Size $N = 500$ (Synthetic Population successfully processed).
* **Demographic Distribution:** Accurately summarized Age, Sex, Race, and ECOG status across both Arms (Arm A: 250, Arm B: 250).
* **Key Programming Metrics:** All demographic variables were analyzed and formatted using **SAS PROC REPORT**.

---

## 📉 2. Efficacy Analysis Results : Overall Survival & Hypothesis Validation
* **Statistical Method:** Statistical Hypothesis Testing on Synthetic Data using **SAS PROC LIFETEST**.
* **Statistical Decision:** Since the SAS pipeline accurately processed data without errors:

  
  <br>
  
  * ❌ **REJECTED:** Null Hypothesis ($H_0$) — Code fails to process/report accurately.
  * ✅ **ACCEPTED:** Alternative Hypothesis ($H_1$) — SAS framework successfully transforms and reports oncology data.

---

## 🛡️ 3. Safety Analysis : Adverse Events (AE) Summary
* **Summary of Side Effects:** 
  * *Subjects with TEAE:* Arm A ($69.2\%$) vs. Arm B ($77.2\%$).
  * *Serious Adverse Events (SAE):* Arm A ($32.0\%$) vs. Arm B ($34.8\%$).
    
    <br>
    
* **Key Findings:** 
  * **Better Profile:** SAS analysis confirms Pembrolizumab (Arm A) has fewer side effects compared to Chemotherapy (Arm B).
  * **Programming Accuracy:** **SAS PROC REPORT** was used to ensure percentage calculations match the ITT (Intent-to-Treat) population count.

---

## 📦 CSR Integration : Statistical Data Package for Submission
> *"This is not a full Clinical Study Report (CSR). This is the Statistical Deliverable Package, which forms the core of Section 14 (Results) and Section 16.2 (Listings) of the final CSR submitted to regulatory bodies like the FDA."*

* **14.1 Demographic Data:** 
  * Table 1: Demographics & Baseline Charts
  * Table 2: Treatment Exposure Summary
* **14.2 Efficacy Data (Study Results):** 
  * Table 4: ORR Summary, Table 5: BOR Summary
  * Table 7: Overall Survival (OS) Summary
  * Figure 1: KM Plot of Overall Survival | Figure 2: KM Plot of PFS | Figure 3: Bar Chart of Best Response
* **14.3 Safety Data (Side Effects):** 
  * Table 3: TEAE Summary (Adverse Events)
  * Table 6: Laboratory Results Summary
* **16.2 Patient Data Listings (IPD):** 
  * Listing 1: Subject Listing | Listing 2: Adverse Event Listing
  * Listing 3: Laboratory Results Listing
  * Listing 4: Tumor Response Assessment
  * Listing 5: Time-to-Event Endpoints

---

## 🏁 Conclusion : Project Outcomes & Deliverables
* **1. Core Deliverables:**
  * **Data Standardization:** Successfully converted raw oncology data into CDISC - SDTM, ADaM Standards.
  * **Statistical Reporting:** Generated 15 Validated TLFs (Tables, Listings, Figures) for CSR Sections 14 & 16.
* **2. Technical Validation & Outcomes:**
  * **QC & Validation:** 100% Quality Control passed using Independent Double Programming (IDP) logic.
  * **Hypothesis Decision:** Successfully **REJECTED ($H_0$)** and **ACCEPTED ($H_1$)** — Proving that the automated SAS framework accurately transforms and reports oncology data without errors.
> *"The Study Successfully Demonstrates That An End-to-end Statistical Programming Framework Is Industry-ready And Aligned With Global Regulatory Expectations (CDISC & ICH-E3)."*

---

## 🔮 Future Scope & Industrial Significance
* **The "Golden Rule" of New Drug Approval:**
  * **Mandatory for Submission:** Regulatory Authorities (RA) do not accept unstructured raw data (like Excel).
  * **The SAS Requirement:** Agencies like the US FDA and PMDA (Japan) mandate data submission in SAS XPT Transport Format strictly following CDISC standards.
  * **No SAS = No Approval:** Without validated SAS datasets (SDTM/ADaM), a New Drug Application (NDA) is immediately rejected.
> *"SAS Programming acts as the bridge between Medical Research and Government Approval, ensuring safe drugs reach patients faster."*

---

## 🛠️ Tools, Technologies & Operational Environment
1. **The Statistical Engine (SAS):** SAS® Studio (SAS OnDemand for Academics) on Cloud for Data Manipulation, Statistical Analysis, and TLF Generation.
2. **Documentation & Reporting Operational Tools:**
   * **Microsoft Excel:** Designing Mapping Specifications, Reviewing Raw Data.
   * **Microsoft Word:** Viewing .RTF Outputs (Tables) and compiling the Clinical Study Report (CSR).
   * **Microsoft PowerPoint:** Stakeholder Presentation and Scientific Defense.
3. **Hardware & OS Environment:** Windows 11 Pro with Cloud-based processing.

---

## 📚 References
> *"Since my project is based on SAS programming and CDISC workflow implementation, regulatory and technical references were more important than multiple journal references."*
1. **Primary Clinical Study (The Model Source):** 
   * Reck M, et al. 2016. *Pembrolizumab versus Chemotherapy for PD-L1–Positive Non–Small–Cell Lung Cancer*. The New England Journal of Medicine (NEJM). DOI: 10.1056/NEJMoa1606774. (Official KEYNOTE-024 publication used for Protocol Design).
2. **Regulatory Standards (The Rules):** 
   * CDISC Foundation. 2013: *Study Data Tabulation Model Implementation Guide (SDTMIG) Version 3.2*.
   * CDISC Foundation. 2016: *Analysis Data Model Implementation Guide (ADaMIG) Version 1.1*.
3. **Technical Documentation (The Tools):** 
   * SAS Institute Inc. 2013: *SAS 9.4 Documentation and User's Guide*. Cary, NC: SAS Institute Inc.
   * US FDA (2020): *Study Data Technical Conformance Guide*.

---

## 📬 Contact & Connect
> *"Data is not just numbers, it's a patient's life waiting to be saved."*

* **Name:** Mr. Aher Shailendra Shainath
* **Role:** Clinical SAS Programmer (Fresher) | CDISC SDTM, ADaM, TLF | Oncology Clinical Trial Specialist
* **Email:** [shailendraaher21@gmail.com](mailto:shailendraaher21@gmail.com)
* **LinkedIn:** [linkedin.com/in/shailendra-aher](https://www.linkedin.com/in/shailendra-aher)

---
