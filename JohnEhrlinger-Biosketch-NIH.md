# BIOGRAPHICAL SKETCH

**Provide the following information for the Senior/key personnel and other significant contributors.**
**Follow this format for each person. DO NOT EXCEED FIVE PAGES.**

---

**NAME:** Ehrlinger, John

**eRA COMMONS USER NAME:** EHRLINJ

**POSITION TITLE:** Assistant Staff – Lead Data Scientist

**ORCID iD:** [0000-0002-5340-5154](https://orcid.org/0000-0002-5340-5154)

**EDUCATION/TRAINING:**

| INSTITUTION AND LOCATION | DEGREE | Completion Date MM/YYYY | FIELD OF STUDY |
|---|---|---|---|
| Case Western Reserve University, Cleveland, OH | BS | 05/1993 | Mechanical Engineering |
| Case Western Reserve University, Cleveland, OH | MS | 05/1994 | Mechanical / Aerospace Engineering |
| Case Western Reserve University, Cleveland, OH | PhD | 05/2011 | Statistics |

---

## A. Personal Statement

I am an applied statistician and data scientist with expertise in computational statistical machine learning, deep learning, and their application to clinical and engineering data. My research career spans both the theoretical development of machine learning methods and their direct application to health outcomes, with a particular focus on time-to-event data, longitudinal and temporal data analysis, and survival methods.

My foundational methodological work on regularization and gradient boosting—specifically the theoretical characterization of L₂Boosting and its connections to the lasso and stagewise regression—established a principled framework for understanding regularized machine learning in high-dimensional settings. I have extended this work to multivariate longitudinal settings through boosted tree ensembles, enabling richer modeling of complex clinical trajectories. In parallel, I have developed open-source R software tools (ggRandomForests, l2boost) that make these methods accessible to the broader statistical and biomedical research community.

At Microsoft's Azure AI group, I applied these methods at scale across healthcare and engineering industries, building production machine learning pipelines and contributing to the Azure Machine Learning platform. I have since returned to Cleveland Clinic's Heart, Vascular & Thoracic Institute as Assistant Staff – Lead Data Scientist in the Department of Cardiothoracic Surgery, where I lead a team of data engineers and data scientists focused on cardiovascular outcomes research. In this role I drive statistical methods research as applied to observational clinical research, establish best practices in software engineering and reproducible research, and implement process improvements to optimize the departmental research pipeline from data collection through publication.

I am well positioned to contribute to projects at the intersection of machine learning methodology and clinical data science, particularly those involving survival or longitudinal outcomes, mechanically assisted circulatory support, or predictive modeling for surgical decision support.

**Selected citations relevant to this application:**

1. **Ehrlinger J**, Ishwaran H. Characterizing *L*₂Boosting. *The Annals of Statistics.* **40**(2): 1074–1101. 2012.

2. Pande A, Li L, Rajeswaran J, **Ehrlinger J**, Blackstone EH, Ishwaran H, Lauer MS. Boosted multivariate trees for longitudinal data. *Machine Learning.* **106**(2): 277–305. 2017.

3. Hurst T, Xanthopoulos A, **Ehrlinger J**, et al. Dynamic prediction of left ventricular assist device pump thrombosis based on lactate dehydrogenase trends. *ESC Heart Failure.* **6**(5): 1005–1014. 2019.

4. **Ehrlinger J**. ggRandomForests: Exploring Random Forest Survival. *ArXiv e-prints.* arXiv:1612.08974 [stat.CO]. 2016.

---

## B. Positions, Scientific Appointments, and Honors

### Positions and Scientific Appointments

| | |
|---|---|
| 1994–1995 | Mechanical Engineer, Life Systems, Inc., Beachwood, OH |
| 1995–1998 | Aerodynamic Engineer, Cooper Turbocompressor, Inc., Buffalo, NY |
| 1999–2012 | Lead Systems Analyst: Scientific Programmer, Dept. of Thoracic and Cardiovascular Surgery, Cleveland Clinic, Cleveland, OH |
| 2012–2015 | Assistant Staff, Dept. of Quantitative Health Sciences, Lerner Research Institute, Cleveland Clinic, Cleveland, OH |
| 2015 | Assistant Professor of Medicine, Cleveland Clinic Lerner College of Medicine – Case Western Reserve University |
| 2015–2023 | Senior Data and Applied Scientist, Artificial Intelligence, Azure Global Commercial Industry (AGCI-AI), Microsoft, Cambridge, MA |
| 2023–2024 | Senior Data Scientist, Altamira Technologies, McLean, VA |
| 2024–present | Assistant Staff – Lead Data Scientist, Dept. of Cardiothoracic Surgery, Heart, Vascular & Thoracic Institute, Cleveland Clinic, Cleveland, OH |

### Honors

| | |
|---|---|
| 1992–1994 | NASA Graduate Research Fellowship |
| 2003 | Cleveland Clinic Innovations Award |

---

## C. Contributions to Science

### 1. Theoretical Foundations of Regularized Statistical Machine Learning

My dissertation and early research established rigorous theoretical properties of gradient boosting under an L₂ loss function, characterizing the functional form and convergence behavior of L₂Boosting in terms of well-known shrinkage estimators including the lasso and LARS. This work provided the statistical community with a principled framework for understanding when and why boosting works as a regularization tool. I extended this work to multivariate longitudinal settings via boosted tree ensembles, enabling flexible nonparametric modeling of clinical time-course data. These contributions provide the methodological grounding for applying regularized machine learning in high-dimensional biomedical settings.

a. **Ehrlinger J**, Ishwaran H. Characterizing *L*₂Boosting. *The Annals of Statistics.* **40**(2): 1074–1101. 2012.

b. Pande A, Li L, Rajeswaran J, **Ehrlinger J**, Blackstone EH, Ishwaran H, Lauer MS. Boosted multivariate trees for longitudinal data. *Machine Learning.* **106**(2): 277–305. 2017.

### 2. Random Forest Methods and Open-Source Statistical Software

I have contributed to the development and dissemination of random forest methods for survival, regression, and classification settings. A central outcome of this work is the ggRandomForests R package, which provides a visual exploration framework for random forest models built with the randomForestSRC package. The package enables researchers to interpret variable importance, partial dependence, and survival curves from forest models, substantially lowering the barrier to adoption of ensemble methods in health research. I also developed the l2boost R package, providing an efficient reference implementation of the boosting framework established in my theoretical work.

a. **Ehrlinger J**. ggRandomForests: Visually Exploring a Random Forest for Regression. *ArXiv e-prints.* arXiv:1501.07196 [stat.CO]. 2015.

b. **Ehrlinger J**. ggRandomForests: Exploring Random Forest Survival. *ArXiv e-prints.* arXiv:1612.08974 [stat.CO]. 2016.

### 3. Temporal and Longitudinal Modeling for Cardiac Outcomes

A core application of my methodological work has been the modeling of time-varying clinical data from cardiac patients. I have developed and applied parametric nonlinear temporal decomposition models and mixture model approaches to characterize evolving phenomena such as atrial fibrillation recurrence after ablation, and to estimate population-level prevalence of AF from repeated diagnosis codes. These approaches provide more nuanced and statistically rigorous characterizations of disease trajectories than simple event-rate analyses, and have directly informed clinical practice guidelines and surgical decision-making at Cleveland Clinic.

a. Rajeswaran J, Blackstone EH, **Ehrlinger J**, Thuita L, et al. Probability of atrial fibrillation after ablation: Using a parametric nonlinear temporal decomposition mixed effects model. *Statistical Methods in Medical Research.* **27**(1): 126–141. 2018.

b. Li L, Mao H, Ishwaran H, **Ehrlinger J**, Yousuf O, Wazni O, Lindsay BD. Estimating the prevalence of atrial fibrillation from a three class mixture model for repeated diagnoses. *Biometrical Journal.* **59**(2): 331–343. 2017.

c. Blackstone EH, Chang HL, Rajeswaran J, **Ehrlinger J**, et al. Biatrial maze procedure versus pulmonary vein isolation for atrial fibrillation during mitral valve surgery: New analytical approaches and end points. *The Journal of Thoracic and Cardiovascular Surgery.* **157**(1): 234–243.e9. 2019.

d. Hurst T, Xanthopoulos A, **Ehrlinger J**, et al. Dynamic prediction of left ventricular assist device pump thrombosis based on lactate dehydrogenase trends. *ESC Heart Failure.* **6**(5): 1005–1014. 2019.

### 4. Machine Learning Applications in Mechanical Circulatory Support

My clinical collaboration work at Cleveland Clinic's Heart and Vascular Institute yielded several high-impact contributions identifying risk factors and predictive biomarkers for LVAD pump thrombosis. These studies, appearing in venues including the *New England Journal of Medicine* and *ESC Heart Failure*, combined large registry data with advanced statistical and machine learning modeling to identify actionable clinical signals. Notably, the 2014 NEJM paper documenting an abrupt increase in LVAD thrombosis rates had immediate regulatory and clinical implications nationally, and subsequent work developed dynamic predictive models based on LDH kinetics.

a. Starling RC, Moazami N, Silvestry SC, Ewald G, Rogers JG, Milano CA, Rame JE, Acker MA, Blackstone EH, **Ehrlinger J**, et al. Unexpected Abrupt Increase in Left Ventricular Assist Device Thrombosis. *New England Journal of Medicine.* **370**(1): 33–40. 2014.

b. Smedira NG, Blackstone EH, **Ehrlinger J**, Thuita L, Pierce CD, Moazami N, Starling RC. Current risks of HeartMate II pump thrombosis: non-parametric analysis of Interagency Registry for Mechanically Assisted Circulatory Support data. *The Journal of Heart and Lung Transplantation.* **34**(12): 1527–1534. 2015.

c. Wojnarski CM, Roselli EE, Idrees JJ, et al. Machine-learning phenotypic classification of bicuspid aortopathy. *The Journal of Thoracic and Cardiovascular Surgery.* **155**(2): 461–469.e4. 2018.

### 5. Cardiovascular Surgical Outcomes and Decision Support

Spanning my entire career at Cleveland Clinic, I have contributed analytical expertise to a wide range of cardiac surgery outcomes studies, including outcomes analyses of LVAD support, transcatheter aortic valve replacement (TAVR/PARTNER trial), and esophageal cancer surgery. In addition to peer-reviewed publications, this work led to the development of JPredictor—a graphical patient-specific survival prediction tool for surgical decision support, incorporating validated models for CABG, cardiomyopathy, LVAD, and post-infarction VSD—and the Hazard SAS module for time-to-event decomposed hazard/survival analysis, both of which remain in active use at Cleveland Clinic.

a. Szeto WY, Svensson LG, Rajeswaran J, **Ehrlinger J**, et al. Appropriate Patient Selection or Healthcare Rationing? Lessons from Surgical Aortic Valve Replacement in the PARTNER-I Trial. *The Journal of Thoracic and Cardiovascular Surgery.* **150**(3): 557–568. 2015.

b. Raja S, Rice TW, **Ehrlinger J**, et al. Importance of Residual Cancer after Induction Therapy for Esophageal Adenocarcinoma. *The Journal of Thoracic and Cardiovascular Surgery.* **152**(3): 756–761. 2016.

c. Dalton JE, Glance LG, Mascha EJ, **Ehrlinger J**, Chamoun N, Sessler DI. Impact of Present-on-admission Indicators on Risk-adjusted Hospital Mortality Measurement. *Anesthesiology.* **118**(6): 1298–1306. 2013.

d. Wojnarski CM, Svensson LG, Roselli EE, et al. Aortic Dissection in Patients with Bicuspid Aortic Valve–Associated Aneurysm. *Annals of Thoracic Surgery.* **100**(5): 1666–1674. 2015.

---

## D. Additional Information: Research Support and/or Scholastic Performance

### Pending Research Support

**NIH – R01 (pending)**
*Improving Waitlist and Transplant Survival in Advanced Heart Failure Populations*
Multiple PIs: Eileen Hsich, M.D. and Eugene H. Blackstone, M.D. · Submitted February 2026
Role: Co-Investigator

### Completed Research Support

**NIH – 1R01HL103552-01A1**
*Ancillary Comparative Effectiveness of Atrial Fibrillation Ablation Surgery*
P.I.: Eugene H. Blackstone, M.D. · 8/10/2011 – 5/31/2014
Role: Co-Investigator

**State of Ohio (Wright Center of Innovation)**
*Atrial Fibrillation Innovation Center State of Ohio*
P.I.: A. Marc Gillinov, M.D. · 8/1/2005 – 12/31/2010
Role: Scientific programming and computing systems management

**NIH – HHSN26820080026C**
*National Heart, Lung & Blood Institute Quantitative Clinical Cardiovascular Epidemiology Projects*
P.I.: Eugene H. Blackstone, M.D. · 9/30/2008 – 9/29/2010
Role: Scientific programming and computing systems management

**NIH – 5R01HL072771**
*Logical Analysis of Data and Cardiac Surgery Risk*
P.I.: Michael S Lauer, M.D. · 10/1/2005 – 9/30/2008
