# Grounded App – Risk Prediction Model Explained

This document provides a **step-by-step explanation** of the Grounded App's on-device risk prediction model for substance use. It covers the purpose, data generation, preprocessing, model architecture, training, evaluation, and deployment.

---

## 1. Overview

The Grounded App model predicts **risk scores (0–1)** for substance use based on:

- Usage frequency and patterns  
- Social context (alone, with friends, etc.)  
- Time of day  
- Mood and sleep quality  
- Recent behavior trends  

**Goal:** Harm reduction — helping users make safer choices, not providing treatment.

---

## 2. Imports and Setup

The script uses:

- **NumPy & Pandas** for data handling  
- **TensorFlow/Keras** for neural networks  
- **Scikit-learn** for preprocessing and train/test splitting  
- **Matplotlib** for visualization  
- `np.random.seed(42)` and `tf.random.set_seed(42)` for reproducibility  
- Warning suppression for cleaner logs  

---

## 3. Data Generation – `GroundedDataGenerator`

Generates **synthetic user data** for training the model.

### Key Components

1. **`generate_user_profile()`**  
   Creates a synthetic user with baseline frequency, preferred context/time, stress sensitivity, and social influence.

2. **`generate_day_data(profile, day_num, prev_days)`**  
   Generates data for one day including:
   - Whether the user used a substance  
   - Context, time, method, amount, cost  
   - Mood, sleep, cravings  
   - App engagement (reminders/messages)  
   - **Risk score** (0–1) using `_calculate_risk_score()`

3. **`_calculate_risk_score(...)`**  
   Domain-knowledge-based “ground truth” for risk:
   - Frequent consecutive usage → higher risk  
   - Alone at night → higher risk  
   - High amounts, poor sleep/mood, high cravings → higher risk  

4. **`generate_user_data(n_days)`**  
   Creates full user history (e.g., 90 days)

5. **`generate_multi_user_dataset(n_users, days_per_user)`**  
   Generates dataset for multiple users (e.g., 100 users × 90 days)

**Purpose:** Provides realistic labeled data for model training.

---

## 4. Data Preprocessing – `DataPreprocessor`

Transforms raw data into **model-ready features**:

1. **One-hot encoding:** `context`, `time_of_day`, `method`, `day_of_week`  
2. **Normalization:** `amount`, `cost`, `mood`, `sleep_quality`, `craving_intensity`, `reminder_opens`, `messages_read`  
3. **Feature engineering:** Rolling averages for usage trends (`frequency_7day`, `frequency_30day`)  
4. **Sequence creation:** Last 14 days → predict day 15 risk  

---

## 5. Model Architectures

`build_model(sequence_length, n_features, model_type='hybrid')` supports:

1. **LSTM** – captures long-term trends  
2. **GRU** – faster alternative to LSTM  
3. **Hybrid CNN+LSTM** – best performer:  
   - **CNN:** local patterns (e.g., Friday night use)  
   - **LSTM:** long-term patterns (2-week window)  

Output layer: Sigmoid neuron (0–1 risk score)

---

## 6. Training – `train_model()`

- Loss: Binary Cross-Entropy  
- Optimizer: Adam  
- **Class weighting:** higher weight for rare high-risk days  
- Callbacks:
  - `EarlyStopping` → prevent overfitting  
  - `ReduceLROnPlateau` → adjust learning rate  
  - `ModelCheckpoint` → save best model based on AUC  

---

## 7. Evaluation – `evaluate_model()`

Metrics:

- Accuracy  
- AUC (distinguishing high vs low risk)  
- Precision & Recall (catching high-risk events)  
- Confusion matrix (true/false positives/negatives)  

---

## 8. Visualization – `plot_training_history()`

Plots **training & validation** metrics over epochs:

- Loss  
- Accuracy  
- AUC  

Saves plots as `training_history.png`.

---

## 9. Saving the Model – `save_model_for_mobile()`

Saves everything **ready for mobile deployment**:

- Keras model (`grounded_model.h5`)  
- TFLite optimized model (`grounded_model.tflite`)  
- Preprocessor/scaler (`feature_scaler.pkl`)  
- Metadata (`model_metadata.json`)  

---

## 10. Sample Predictions – `print_sample_predictions()`

- Picks random days from dataset  
- Shows context, time, amount, mood, cravings  
- Compares predicted vs actual risk  
- Indicates correct/incorrect predictions

---

## 11. Main Pipeline – `main()`

1. Generate synthetic data (100 users × 90 days)  
2. Preprocess features & create sequences  
3. Split into train/validation/test sets  
4. Train **hybrid CNN+LSTM model**  
5. Evaluate metrics  
6. Show sample predictions  
7. Save **mobile-ready model** and **plots**

---

## ✅ Summary

This script provides a **complete ML pipeline**:

- Synthetic, realistic user data generation  
- Preprocessing & feature engineering  
- Time-series sequences for modeling  
- CNN+LSTM neural network training  
- Evaluation with accuracy, AUC, precision, recall  
- Mobile deployment-ready artifacts  

It’s modular, so you can replace synthetic data with **real app data** later.

---

**Next Steps:**

1. Test the model (`python test_model.py`)  
2. Integrate `.tflite` into mobile app (Flutter/Android/iOS)  
3. Monitor predictions and improve model iteratively
