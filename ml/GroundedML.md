# On-Device ML Model for Grounded Harm Reduction App

## Overview
This guide provides a comprehensive approach to building a lightweight, privacy-preserving machine learning model for the Grounded app. The model predicts substance use risk based on behavioral and contextual data, running entirely on-device to protect user privacy.

---

## 1. Model Architecture Recommendations

### Best Choice: Lightweight LSTM or GRU

**Why this works for Grounded:**
- **Sequential patterns matter**: Substance use follows temporal patterns (time of day, day of week, recent usage frequency)
- **Context-aware**: LSTMs learn relationships between mood, sleep quality, social context, and risk
- **Mobile-friendly**: A simple 1-2 layer LSTM with 32-64 units is small enough for mobile while capturing temporal dependencies
- **State preservation**: Remembers recent patterns without needing to retrain

**Architecture specs:**
- Input: Sequence of 7-14 timesteps (days)
- LSTM layer: 32-64 hidden units
- Dropout: 0.2-0.3 for regularization
- Dense output: 1 unit (risk score 0-1) or 3 units (low/medium/high risk)
- Total parameters: ~10K-50K (under 500KB model size)

### Alternative: 1D-CNN with Temporal Convolutions

**Advantages:**
- Faster inference than LSTM (better battery life)
- Good at detecting local patterns (e.g., "late night + alone + poor sleep = higher risk")
- Simpler architecture means easier optimization
- Can use depthwise separable convolutions for extreme efficiency

**When to use:**
- If inference speed is critical
- If patterns are more about recent windows (last 2-3 days) rather than long-term trends
- If you need faster initial prototyping

### Recommended Hybrid Approach

Combine both for best results:
1. **1D-CNN layer** to extract local feature patterns
2. **Single LSTM/GRU layer** to capture temporal sequences
3. **Dense layers** for final risk classification/regression

**Architecture:**
```
Input (14 timesteps, 30 features)
    ↓
1D Conv (32 filters, kernel=3) + ReLU
    ↓
MaxPooling1D (pool_size=2)
    ↓
LSTM (32 units)
    ↓
Dropout (0.3)
    ↓
Dense (16 units) + ReLU
    ↓
Dense (1 unit) + Sigmoid → Risk Score (0-1)
```

### Avoid Transformers
- Too computationally expensive for on-device deployment
- Requires more data than you'll have per user
- Attention mechanisms add unnecessary overhead for this use case

---

## 2. Data Preprocessing Strategy

### Feature Engineering

**Categorical Variables (One-Hot Encoding):**
- Context: `alone`, `friends`, `family`, `work`, `party`, `other` → 6 binary features
- Time of day: `morning`, `afternoon`, `evening`, `night` → 4 binary features
- Consumption method: `smoking`, `vaping`, `edibles`, `drinking`, `other` → 5 binary features
- Day of week: Monday-Sunday → 7 binary features

**Numerical Variables (Normalization to 0-1):**
- Frequency of use (uses per week)
- Amount per use (standardized units)
- Cost per use
- Mood score (1-10 scale)
- Sleep quality (1-10 scale)
- Craving intensity (1-10 scale)
- Days since last use
- Reminder opens (count)
- Motivational messages read (count)

**Temporal Features (Engineered):**
- Rolling 7-day average frequency
- Rolling 30-day average frequency
- Days since last use
- Use count in last 3 days
- Weekend vs weekday (binary)
- Deviation from typical usage pattern

### Data Structure

**Per timestep (day) input vector:**
```
[
    # Categorical (one-hot encoded)
    context_alone, context_friends, context_family, context_work, context_party, context_other,
    time_morning, time_afternoon, time_evening, time_night,
    method_smoking, method_vaping, method_edibles, method_drinking, method_other,
    monday, tuesday, wednesday, thursday, friday, saturday, sunday,
    
    # Numerical (normalized 0-1)
    frequency_normalized,
    amount_normalized,
    cost_normalized,
    mood_score_normalized,
    sleep_quality_normalized,
    craving_intensity_normalized,
    days_since_last_use_normalized,
    reminder_opens_normalized,
    messages_read_normalized,
    rolling_7day_avg,
    rolling_30day_avg,
    use_count_last_3days_normalized,
    deviation_from_typical
]
# Total: ~40 features per timestep
```

**Sequence Structure:**
- Input shape: `(batch_size, 14, 40)` — 14 days of history, 40 features each
- Output: Risk score for the next day or current moment

### Handling Missing Data

1. **Forward fill**: Use last known value for continuous tracking
2. **Default values**: 
   - Mood/sleep/craving: Use user's personal average or global median
   - Context: "unknown" category or most frequent context
   - Frequency: 0 if no data
3. **Masking layer**: Add a binary "data_available" flag per feature
4. **Imputation**: Train a simple model to predict missing values from available ones

---

## 3. Training Strategy for Limited Data

### Challenge
Users will have different amounts of data, and initial data will be sparse. You need a model that generalizes well with limited per-user samples.

### Multi-Stage Training Approach

#### Stage 1: Pre-training on Aggregated Data
- Collect anonymized data from users who opt-in to cloud sharing
- Train a general model on pooled data (hundreds of users)
- This learns universal patterns across all users
- Model size: Keep under 200KB for initial deployment

#### Stage 2: Transfer Learning & Personalization
- Start with pre-trained weights
- Fine-tune on individual user's data (on-device or cloud)
- Use few-shot learning techniques
- Freeze early layers, only train last 1-2 layers for personalization

#### Stage 3: Continual On-Device Learning
- Incrementally update model as user generates more data
- Use online learning or periodic retraining
- Keep lightweight update mechanism

### Data Augmentation Techniques

Since data is limited, artificially expand training set:

1. **Temporal jittering**: Slightly shift time of day categories
2. **Feature noise**: Add small random noise to numerical features
3. **Sequence augmentation**: Create overlapping windows
4. **Synthetic samples**: Generate realistic patterns based on existing data
5. **Context swapping**: If user uses "with friends" → also simulate "alone" variant

### Regularization to Prevent Overfitting

- **Dropout**: 0.2-0.4 between layers
- **L2 regularization**: Weight decay of 1e-4 to 1e-5
- **Early stopping**: Stop training when validation loss stops improving
- **Batch normalization**: Helps with small datasets

### Training Configuration

```
Batch size: 16-32 (small for limited data)
Learning rate: 0.001 with decay schedule
Optimizer: Adam (adaptive learning works well with small data)
Loss function: Binary crossentropy (for risk classification) or MSE (for risk score regression)
Epochs: 50-100 with early stopping (patience=10)
Validation split: 20% of data
```

### Handling Imbalanced Data

- Users may have many "low risk" days and few "high risk" days
- **Class weighting**: Give more weight to high-risk samples
- **SMOTE**: Synthetic minority oversampling for high-risk patterns
- **Focal loss**: Focus training on hard-to-classify examples

---

## 4. Quantization & Mobile Optimization

### Model Compression Techniques

#### 1. Post-Training Quantization (Easiest)
- Convert 32-bit floats to 8-bit integers
- **Benefits**: 4x smaller model, 2-4x faster inference
- **Accuracy loss**: Usually <1% with proper calibration
- **Implementation**: Built into TensorFlow Lite converter

```python
# Dynamic range quantization (no calibration data needed)
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# Full integer quantization (best compression, needs representative data)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset = representative_data_gen
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
```

#### 2. Quantization-Aware Training (Better accuracy)
- Train model knowing it will be quantized
- Model learns to be robust to quantization errors
- Better accuracy than post-training quantization

#### 3. Pruning
- Remove weights that contribute little to predictions
- Can remove 50-80% of weights with minimal accuracy loss
- Use TensorFlow Model Optimization Toolkit

#### 4. Knowledge Distillation
- Train large "teacher" model on cloud data
- Train small "student" model to mimic teacher's predictions
- Student model deployed on device

### Mobile-Specific Optimizations

**Use Mobile-Optimized Operations:**
- Replace LSTM with GRU (fewer parameters, faster)
- Use depthwise separable convolutions instead of regular convolutions
- Limit batch normalization (slower on mobile)

**Model Size Targets:**
- **Ideal**: <500KB (uncompressed), <200KB (quantized)
- **Maximum**: <2MB for smooth user experience
- Your model should easily fit in 100-500KB range

**Inference Speed Targets:**
- <50ms for real-time predictions
- <200ms acceptable for background tasks
- Your model should achieve <20ms on modern phones

### TensorFlow Lite Optimization

```python
# Enable all optimizations
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# Use float16 quantization (good balance)
converter.target_spec.supported_types = [tf.float16]

# Or full int8 quantization (maximum compression)
converter.representative_dataset = representative_data_gen
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.int8
converter.inference_output_type = tf.int8
```

---

## 5. Sample Python Training Code

```python
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split

# ============================================
# 1. DATA PREPARATION
# ============================================

def prepare_data(user_data_df):
    """
    Prepare user data for training
    
    Expected columns in dataframe:
    - date, frequency, amount, cost
    - context (categorical), time_of_day (categorical), method (categorical)
    - mood, sleep_quality, craving_intensity
    - reminder_opens, messages_read
    - risk_label (target: 0 for low risk, 1 for high risk)
    """
    
    # Normalize numerical features
    numerical_features = [
        'frequency', 'amount', 'cost', 'mood', 'sleep_quality',
        'craving_intensity', 'reminder_opens', 'messages_read'
    ]
    
    scaler = MinMaxScaler()
    user_data_df[numerical_features] = scaler.fit_transform(
        user_data_df[numerical_features]
    )
    
    # One-hot encode categorical features
    context_encoded = pd.get_dummies(user_data_df['context'], prefix='context')
    time_encoded = pd.get_dummies(user_data_df['time_of_day'], prefix='time')
    method_encoded = pd.get_dummies(user_data_df['method'], prefix='method')
    
    # Add day of week
    user_data_df['day_of_week'] = pd.to_datetime(user_data_df['date']).dt.dayofweek
    day_encoded = pd.get_dummies(user_data_df['day_of_week'], prefix='day')
    
    # Combine all features
    feature_df = pd.concat([
        user_data_df[numerical_features],
        context_encoded,
        time_encoded,
        method_encoded,
        day_encoded
    ], axis=1)
    
    return feature_df, user_data_df['risk_label'].values, scaler

def create_sequences(features, labels, sequence_length=14):
    """
    Create sequences for time series prediction
    
    Args:
        features: Feature array (n_samples, n_features)
        labels: Label array (n_samples,)
        sequence_length: Number of timesteps to look back
    
    Returns:
        X: Sequences (n_sequences, sequence_length, n_features)
        y: Labels for each sequence (n_sequences,)
    """
    X, y = [], []
    
    for i in range(len(features) - sequence_length):
        X.append(features[i:i+sequence_length])
        y.append(labels[i+sequence_length])  # Predict next day's risk
    
    return np.array(X), np.array(y)

# ============================================
# 2. MODEL ARCHITECTURE
# ============================================

def build_lightweight_lstm_model(sequence_length, n_features):
    """
    Build a lightweight LSTM model for mobile deployment
    """
    model = keras.Sequential([
        # Input layer
        layers.Input(shape=(sequence_length, n_features)),
        
        # LSTM layer
        layers.LSTM(32, return_sequences=False),
        layers.Dropout(0.3),
        
        # Dense layers
        layers.Dense(16, activation='relu'),
        layers.Dropout(0.2),
        layers.Dense(1, activation='sigmoid')  # Risk score 0-1
    ])
    
    return model

def build_hybrid_model(sequence_length, n_features):
    """
    Build a hybrid CNN-LSTM model for better pattern recognition
    """
    model = keras.Sequential([
        # Input layer
        layers.Input(shape=(sequence_length, n_features)),
        
        # 1D CNN for local pattern extraction
        layers.Conv1D(32, kernel_size=3, activation='relu', padding='same'),
        layers.MaxPooling1D(pool_size=2),
        
        # LSTM for temporal dependencies
        layers.LSTM(32, return_sequences=False),
        layers.Dropout(0.3),
        
        # Dense layers
        layers.Dense(16, activation='relu'),
        layers.Dropout(0.2),
        layers.Dense(1, activation='sigmoid')
    ])
    
    return model

def build_gru_model(sequence_length, n_features):
    """
    Build a GRU model (faster than LSTM, fewer parameters)
    """
    model = keras.Sequential([
        layers.Input(shape=(sequence_length, n_features)),
        layers.GRU(32, return_sequences=False),
        layers.Dropout(0.3),
        layers.Dense(16, activation='relu'),
        layers.Dropout(0.2),
        layers.Dense(1, activation='sigmoid')
    ])
    
    return model

# ============================================
# 3. TRAINING
# ============================================

def train_model(X_train, y_train, X_val, y_val, model_type='lstm'):
    """
    Train the risk prediction model
    """
    sequence_length, n_features = X_train.shape[1], X_train.shape[2]
    
    # Build model
    if model_type == 'lstm':
        model = build_lightweight_lstm_model(sequence_length, n_features)
    elif model_type == 'hybrid':
        model = build_hybrid_model(sequence_length, n_features)
    elif model_type == 'gru':
        model = build_gru_model(sequence_length, n_features)
    
    # Compile model
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=0.001),
        loss='binary_crossentropy',
        metrics=['accuracy', 'AUC']
    )
    
    # Callbacks
    callbacks = [
        keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=10,
            restore_best_weights=True
        ),
        keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=5,
            min_lr=1e-6
        )
    ]
    
    # Handle class imbalance
    class_weights = {
        0: 1.0,  # Low risk
        1: 3.0   # High risk (give more weight)
    }
    
    # Train
    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=100,
        batch_size=16,
        callbacks=callbacks,
        class_weight=class_weights,
        verbose=1
    )
    
    return model, history

# ============================================
# 4. FULL TRAINING PIPELINE
# ============================================

def full_training_pipeline(data_df):
    """
    Complete pipeline from data to trained model
    """
    print("Step 1: Preparing data...")
    features, labels, scaler = prepare_data(data_df)
    
    print("Step 2: Creating sequences...")
    X, y = create_sequences(features.values, labels, sequence_length=14)
    
    print(f"Data shape: {X.shape}, Labels shape: {y.shape}")
    
    print("Step 3: Splitting data...")
    X_train, X_val, y_train, y_val = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    print("Step 4: Training model...")
    model, history = train_model(
        X_train, y_train, X_val, y_val, model_type='hybrid'
    )
    
    print("Step 5: Evaluating model...")
    val_loss, val_acc, val_auc = model.evaluate(X_val, y_val)
    print(f"Validation Accuracy: {val_acc:.4f}")
    print(f"Validation AUC: {val_auc:.4f}")
    
    # Print model size
    model.summary()
    
    return model, scaler, history

# ============================================
# 5. EXAMPLE USAGE
# ============================================

# Example with synthetic data
def generate_synthetic_data(n_samples=1000):
    """Generate synthetic user data for testing"""
    np.random.seed(42)
    
    data = {
        'date': pd.date_range('2024-01-01', periods=n_samples, freq='D'),
        'frequency': np.random.randint(0, 7, n_samples),
        'amount': np.random.uniform(1, 10, n_samples),
        'cost': np.random.uniform(5, 50, n_samples),
        'context': np.random.choice(['alone', 'friends', 'family', 'work'], n_samples),
        'time_of_day': np.random.choice(['morning', 'afternoon', 'evening', 'night'], n_samples),
        'method': np.random.choice(['smoking', 'vaping', 'edibles'], n_samples),
        'mood': np.random.randint(1, 11, n_samples),
        'sleep_quality': np.random.randint(1, 11, n_samples),
        'craving_intensity': np.random.randint(1, 11, n_samples),
        'reminder_opens': np.random.randint(0, 5, n_samples),
        'messages_read': np.random.randint(0, 3, n_samples),
        'risk_label': np.random.randint(0, 2, n_samples)  # Binary: 0=low, 1=high
    }
    
    return pd.DataFrame(data)

# Run training
if __name__ == "__main__":
    # Generate or load your data
    df = generate_synthetic_data(n_samples=500)
    
    # Train model
    model, scaler, history = full_training_pipeline(df)
    
    # Save model (will convert to TFLite in next section)
    model.save('grounded_risk_model.h5')
    
    # Save scaler for preprocessing in production
    import joblib
    joblib.dump(scaler, 'feature_scaler.pkl')
```

---

## 6. Export to TensorFlow Lite for Flutter

### Step 1: Convert Keras Model to TFLite

```python
import tensorflow as tf
import numpy as np

def convert_to_tflite(model_path, output_path, quantize=True):
    """
    Convert Keras model to TensorFlow Lite format
    
    Args:
        model_path: Path to saved Keras model (.h5)
        output_path: Path for output .tflite file
        quantize: Whether to apply quantization
    """
    # Load the trained model
    model = tf.keras.models.load_model(model_path)
    
    # Create converter
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    if quantize:
        # Apply dynamic range quantization
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        
        # Optional: Full integer quantization (requires representative dataset)
        def representative_data_gen():
            """Generate representative data for quantization calibration"""
            # Load some real user data
            for _ in range(100):
                # Generate random data matching input shape
                # In production, use real user data samples
                data = np.random.random((1, 14, 40)).astype(np.float32)
                yield [data]
        
        converter.representative_dataset = representative_data_gen
        converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
        converter.inference_input_type = tf.uint8
        converter.inference_output_type = tf.uint8
    
    # Convert the model
    tflite_model = converter.convert()
    
    # Save the model
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    # Print model size
    import os
    size_kb = os.path.getsize(output_path) / 1024
    print(f"TFLite model size: {size_kb:.2f} KB")
    
    return tflite_model

# Usage
convert_to_tflite(
    'grounded_risk_model.h5',
    'grounded_risk_model.tflite',
    quantize=True
)
```

### Step 2: Test TFLite Model (Optional but Recommended)

```python
def test_tflite_model(tflite_path, test_data):
    """
    Test the TFLite model to ensure it works correctly
    """
    # Load TFLite model
    interpreter = tf.lite.Interpreter(model_path=tflite_path)
    interpreter.allocate_tensors()
    
    # Get input and output details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print("Input shape:", input_details[0]['shape'])
    print("Input type:", input_details[0]['dtype'])
    print("Output shape:", output_details[0]['shape'])
    print("Output type:", output_details[0]['dtype'])
    
    # Test prediction
    interpreter.set_tensor(input_details[0]['index'], test_data)
    interpreter.invoke()
    prediction = interpreter.get_tensor(output_details[0]['index'])
    
    print(f"Prediction: {prediction[0][0]:.4f}")
    return prediction

# Test with sample data
test_input = np.random.random((1, 14, 40)).astype(np.float32)
test_tflite_model('grounded_risk_model.tflite', test_input)
```

### Step 3: Integrate into Flutter

**Add TFLite dependency to `pubspec.yaml`:**

```yaml
dependencies:
  flutter:
    sdk: flutter
  tflite_flutter: ^0.10.0
  tflite_flutter_helper: ^0.3.1
```

**Place model file:**
- Put `grounded_risk_model.tflite` in `assets/` folder
- Update `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/grounded_risk_model.tflite
```

**Flutter Integration Code:**

```dart
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

class RiskPredictor {
  Interpreter? _interpreter;
  
  // Initialize the model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/grounded_risk_model.tflite');
      print('Model loaded successfully');
      print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      print('Error loading model: $e');
    }
  }
  
  // Predict risk score
  Future<double> predictRisk(List<List<double>> sequenceData) async {
    if (_interpreter == null) {
      await loadModel();
    }
    
    // Prepare input: shape should be [1, 14, 40]
    // sequenceData should be 14 days x 40 features
    var input = [sequenceData]; // Wrap in batch dimension
    
    // Prepare output buffer: shape [1, 1]
    var output = List.filled(1, 0.0).reshape([1, 1]);
    
    // Run inference
    _interpreter!.run(input, output);
    
    // Extract risk score (0-1)
    double riskScore = output[0][0];
    return riskScore;
  }
  
  // Helper: Convert user data to model input format
  List<List<double>> prepareInputData(List<Map<String, dynamic>> userData) {
    // userData should be last 14 days of user activity
    List<List<double>> sequence = [];
    
    for (var day in userData) {
      List<double> features = [];
      
      // Add categorical features (one-hot encoded)
      features.addAll(_encodeContext(day['context']));
      features.addAll(_encodeTimeOfDay(day['time_of_day']));
      features.addAll(_encodeMethod(day['method']));
      features.addAll(_encodeDayOfWeek(day['day_of_week']));
      
      // Add numerical features (normalized 0-1)
      features.add(_normalize(day['frequency'], 0, 10));
      features.add(_normalize(day['amount'], 0, 20));
      features.add(_normalize(day['cost'], 0, 100));
      features.add(_normalize(day['mood'], 1, 10));
      features.add(_normalize(day['sleep_quality'], 1, 10));
      features.add(_normalize(day['craving_intensity'], 1, 10));
      features.add(_normalize(day['reminder_opens'], 0, 10));
      features.add(_normalize(day['messages_read'], 0, 10));
      
      sequence.add(features);
    }
    
    return sequence;
  }
  
  // Helper functions for encoding
  List<double> _encodeContext(String context) {
    const contexts = ['alone', 'friends', 'family', 'work', 'party', 'other'];
    return contexts.map((c) => c == context ? 1.0 : 0.0).toList();
  }
  
  List<double> _encodeTimeOfDay(String time) {
    const times = ['morning', 'afternoon', 'evening', 'night'];
    return times.map((t) => t == time ? 1.0 : 0.0).toList();
  }
  
  List<double> _encodeMethod(String method) {
    const methods = ['smoking', 'vaping', 'edibles', 'drinking', 'other'];
    return methods.map((m) => m == method ? 1.0 : 0.0).toList();
  }
  
  List<double> _encodeDayOfWeek(int day) {
    return List.generate(7, (i) => i == day ? 1.0 : 0.0);
  }
  
  double _normalize(dynamic value, double min, double max) {
    double val = (value ?? 0).toDouble();
    return (val - min) / (max - min);
  }
  
  // Generate notification message based on risk score
  String getNotificationMessage(double riskScore, Map<String, dynamic> context) {
    if (riskScore < 0.3) {
      return "You're doing great! Keep up the mindful choices. 🌟";
    } else if (riskScore < 0.6) {
      return "Notice any patterns today? You might want to check in with yourself. 💭";
    } else if (riskScore < 0.8) {
      if (context['context'] == 'friends') {
        return "You might be out with friends — consider taking a little less. 🤝";
      } else if (context['time_of_day'] == 'night') {
        return "Late night patterns detected. Maybe try a different wind-down routine? 🌙";
      } else {
        return "Higher risk moment detected. Want to explore what's driving this? 🧭";
      }
    } else {
      return "We notice you might be in a vulnerable moment. Your support system is here if you need it. 💚";
    }
  }
  
  void dispose() {
    _interpreter?.close();
  }
}

// Usage example
void main() async {
  var predictor = RiskPredictor();
  await predictor.loadModel();
  
  // Example: Get last 14 days of user data from local database
  List<Map<String, dynamic>> userData = await getUserLast14Days();
  
  // Prepare input
  var inputData = predictor.prepareInputData(userData);
  
  // Get risk prediction
  double risk = await predictor.predictRisk(inputData);
  
  // Generate notification
  String message = predictor.getNotificationMessage(risk, userData.last);
  
  print('Risk Score: ${(risk * 100).toStringAsFixed(1)}%');
  print('Message: $message');
}
```

### Step 4: Implement Background Prediction Service

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundRiskMonitor {
  static void registerBackgroundTask() {
    Workmanager().registerPeriodicTask(
      "risk_prediction_task",
      "riskPrediction",
      frequency: Duration(hours: 6), // Check every 6 hours
      constraints: Constraints(
        networkType: NetworkType.not_required, // Fully offline
      ),
    );
  }
  
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      try {
        // Load predictor
        var predictor = RiskPredictor();
        await predictor.loadModel();
        
        // Get user data from local database
        var userData = await getUserLast14Days();
        
        // Predict risk
        var inputData = predictor.prepareInputData(userData);
        double riskScore = await predictor.predictRisk(inputData);
        
        // Send notification if risk is elevated
        if (riskScore > 0.5) {
          await _sendNotification(riskScore, userData.last);
        }
        
        predictor.dispose();
        return Future.value(true);
      } catch (e) {
        print('Background task error: $e');
        return Future.value(false);
      }
    });
  }
  
  static Future<void> _sendNotification(double risk, Map<String, dynamic> context) async {
    final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
    
    var predictor = RiskPredictor();
    String message = predictor.getNotificationMessage(risk, context);
    
    const androidDetails = AndroidNotificationDetails(
      'grounded_risk_channel',
      'Risk Alerts',
      channelDescription: 'Notifications about usage patterns',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const notificationDetails = NotificationDetails(android: androidDetails);
    
    await notifications.show(
      0,
      'Grounded Check-In',
      message,
      notificationDetails,
    );
  }
}
```

---

## 7. Handling Sparse or Missing User Data

### Challenge
New users have no data, and even active users may have gaps. The model must handle this gracefully.

### Strategy 1: Cold Start Problem (New Users)

**Option A: Generic Model**
- Use pre-trained model on aggregated data
- Provides reasonable predictions based on general patterns
- Gradually personalizes as user data accumulates

**Option B: Simple Rule-Based System**
- For first 7-14 days, use heuristic rules instead of ML
- Example rules:
  - High frequency (>5 times/week) + poor sleep = elevated risk
  - Late night use + alone context = elevated risk
  - Strong cravings + low support = elevated risk
- Switch to ML model once sufficient data exists

**Implementation:**

```python
class HybridPredictor:
    def __init__(self, model, min_data_points=14):
        self.model = model
        self.min_data_points = min_data_points
    
    def predict(self, user_data):
        if len(user_data) < self.min_data_points:
            return self._rule_based_prediction(user_data)
        else:
            return self._ml_prediction(user_data)
    
    def _rule_based_prediction(self, user_data):
        """Simple heuristic for new users"""
        latest = user_data[-1]
        
        risk_score = 0.0
        
        # Frequency factor
        if latest['frequency'] > 5:
            risk_score += 0.3
        elif latest['frequency'] > 3:
            risk_score += 0.15
        
        # Context factor
        if latest['context'] == 'alone' and latest['time_of_day'] == 'night':
            risk_score += 0.25
        
        # Wellbeing factor
        if latest['mood'] < 4 or latest['sleep_quality'] < 4:
            risk_score += 0.2
        
        # Craving factor
        if latest['craving_intensity'] > 7:
            risk_score += 0.25
        
        return min(risk_score, 1.0)
    
    def _ml_prediction(self, user_data):
        """Use ML model for experienced users"""
        # Standard ML prediction
        return self.model.predict(user_data)
```

### Strategy 2: Handling Missing Features

**Missing Data Patterns:**
1. User didn't log data for certain days
2. User skipped optional fields (mood, sleep quality)
3. Feature not applicable (e.g., no consumption method if didn't use)

**Imputation Techniques:**

```python
class DataImputer:
    def __init__(self, user_history):
        self.user_history = user_history
        self.compute_user_baselines()
    
    def compute_user_baselines(self):
        """Calculate user's personal averages"""
        self.baseline_mood = np.mean([d['mood'] for d in self.user_history if d['mood'] is not None])
        self.baseline_sleep = np.mean([d['sleep_quality'] for d in self.user_history if d['sleep_quality'] is not None])
        self.baseline_frequency = np.mean([d['frequency'] for d in self.user_history if d['frequency'] is not None])
    
    def impute_missing_values(self, data_point):
        """Fill in missing values intelligently"""
        # Use personal baseline if available, else use global median
        if data_point['mood'] is None:
            data_point['mood'] = self.baseline_mood or 5.0
        
        if data_point['sleep_quality'] is None:
            data_point['sleep_quality'] = self.baseline_sleep or 6.0
        
        if data_point['frequency'] is None:
            data_point['frequency'] = 0  # Assume no use if not logged
        
        # For categorical, use most common
        if data_point['context'] is None:
            data_point['context'] = self._most_common_context() or 'unknown'
        
        return data_point
    
    def _most_common_context(self):
        from collections import Counter
        contexts = [d['context'] for d in self.user_history if d['context'] is not None]
        if contexts:
            return Counter(contexts).most_common(1)[0][0]
        return None
```

### Strategy 3: Confidence Scoring

Add confidence scores to predictions based on data quality:

```python
def predict_with_confidence(model, user_data):
    """
    Returns prediction and confidence score
    """
    # Calculate data quality metrics
    completeness = calculate_completeness(user_data)
    recency = calculate_recency(user_data)
    consistency = calculate_consistency(user_data)
    
    # Get prediction
    risk_score = model.predict(user_data)
    
    # Calculate confidence (0-1)
    confidence = (completeness * 0.5 + recency * 0.3 + consistency * 0.2)
    
    return risk_score, confidence

def calculate_completeness(user_data):
    """Percentage of fields filled"""
    total_fields = 0
    filled_fields = 0
    
    for day in user_data:
        for key, value in day.items():
            total_fields += 1
            if value is not None:
                filled_fields += 1
    
    return filled_fields / total_fields if total_fields > 0 else 0

def calculate_recency(user_data):
    """More recent data = higher confidence"""
    days_ago = (datetime.now() - user_data[-1]['date']).days
    return max(0, 1 - (days_ago / 7))  # Decay over 7 days

def calculate_consistency(user_data):
    """Check for data gaps"""
    dates = [d['date'] for d in user_data]
    expected_days = 14
    actual_days = len(dates)
    return actual_days / expected_days
```

**Use Confidence in Notifications:**

```dart
String getNotificationMessage(double riskScore, double confidence, Map context) {
  if (confidence < 0.5) {
    return "We're still learning your patterns. Keep logging to get more personalized insights! 📊";
  }
  
  // Normal risk-based messages if confidence is high
  if (riskScore > 0.7) {
    return "We notice you might be in a vulnerable moment (${(confidence*100).toInt()}% confident). 💚";
  }
  // ... other messages
}
```

### Strategy 4: Progressive Data Collection

**Minimize burden on new users:**

Week 1: Collect only essential data
- Frequency of use
- Basic context (alone/with others)
- Time of day

Week 2-3: Add wellbeing metrics
- Mood
- Sleep quality
- Cravings

Week 4+: Full feature set
- All contextual details
- Support system interactions
- Detailed consumption patterns

**Adaptive Model:**

```python
class ProgressiveModel:
    def __init__(self):
        self.simple_model = build_simple_model(n_features=10)  # Week 1 model
        self.full_model = build_full_model(n_features=40)      # Week 4+ model
    
    def predict(self, user_data, user_week):
        if user_week < 2:
            # Use simple model with basic features
            basic_features = extract_basic_features(user_data)
            return self.simple_model.predict(basic_features)
        else:
            # Use full model
            full_features = extract_all_features(user_data)
            return self.full_model.predict(full_features)
```

### Strategy 5: Federated Learning (Optional Advanced Feature)

For users who opt-in to contribute anonymized data:

**Benefits:**
- Model improves from collective patterns without sharing raw data
- Each device trains on local data
- Only model updates (weights) are shared and aggregated
- Preserves individual privacy

**Implementation Outline:**

```python
# On-device training
local_model = load_base_model()
local_model.fit(user_local_data, epochs=5)

# Extract weight updates only
weight_updates = compute_weight_difference(base_model, local_model)

# Send encrypted updates to server (not raw data)
send_to_server(encrypt(weight_updates))

# Server aggregates updates from many users
aggregated_model = federated_averaging(all_weight_updates)

# Push improved model back to devices
distribute_updated_model(aggregated_model)
```

---

## 8. Testing & Validation Strategy

### Model Validation Metrics

**Primary Metrics:**
- **Accuracy**: Overall correctness of predictions
- **Precision**: Of predicted high-risk moments, how many were actually high-risk
- **Recall**: Of actual high-risk moments, how many did we catch
- **AUC-ROC**: Model's ability to distinguish between risk levels
- **F1-Score**: Balance between precision and recall

**Target Performance:**
- Accuracy: >75% (realistic for behavioral data)
- AUC: >0.80 (good discriminative ability)
- Precision: >70% (minimize false alarms)
- Recall: >80% (catch most high-risk moments)

### Validation Code

```python
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
import matplotlib.pyplot as plt

def evaluate_model(model, X_test, y_test):
    """
    Comprehensive model evaluation
    """
    # Get predictions
    y_pred_proba = model.predict(X_test)
    y_pred = (y_pred_proba > 0.5).astype(int)
    
    # Calculate metrics
    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred)
    recall = recall_score(y_test, y_pred)
    f1 = f1_score(y_test, y_pred)
    auc = roc_auc_score(y_test, y_pred_proba)
    
    print("="*50)
    print("MODEL EVALUATION RESULTS")
    print("="*50)
    print(f"Accuracy:  {accuracy:.4f}")
    print(f"Precision: {precision:.4f}")
    print(f"Recall:    {recall:.4f}")
    print(f"F1-Score:  {f1:.4f}")
    print(f"AUC-ROC:   {auc:.4f}")
    print("="*50)
    
    # Confusion matrix
    from sklearn.metrics import confusion_matrix
    cm = confusion_matrix(y_test, y_pred)
    print("\nConfusion Matrix:")
    print(f"True Negatives:  {cm[0,0]}")
    print(f"False Positives: {cm[0,1]}")
    print(f"False Negatives: {cm[1,0]}")
    print(f"True Positives:  {cm[1,1]}")
    
    return {
        'accuracy': accuracy,
        'precision': precision,
        'recall': recall,
        'f1': f1,
        'auc': auc
    }
```

### A/B Testing in Production

Test different model versions with real users:

```dart
class ModelABTest {
  String getUserGroup(String userId) {
    // Consistent assignment based on user ID
    int hash = userId.hashCode % 100;
    if (hash < 50) return 'model_a';  // 50% get model A
    return 'model_b';  // 50% get model B
  }
  
  Future<double> predictWithAB(String userId, List userData) async {
    String group = getUserGroup(userId);
    
    if (group == 'model_a') {
      return await predictorA.predictRisk(userData);
    } else {
      return await predictorB.predictRisk(userData);
    }
  }
  
  void logPrediction(String userId, double prediction, String actualOutcome) {
    // Log for analysis
    analytics.log('prediction', {
      'user_group': getUserGroup(userId),
      'prediction': prediction,
      'outcome': actualOutcome,
      'timestamp': DateTime.now(),
    });
  }
}
```

---

## 9. Privacy & Security Considerations

### On-Device Data Protection

**Encryption at Rest:**
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureDataStorage {
  final storage = FlutterSecureStorage();
  
  Future<void> saveUserData(Map<String, dynamic> data) async {
    String encrypted = encryptData(jsonEncode(data));
    await storage.write(key: 'user_data', value: encrypted);
  }
  
  Future<Map<String, dynamic>> loadUserData() async {
    String? encrypted = await storage.read(key: 'user_data');
    if (encrypted != null) {
      String decrypted = decryptData(encrypted);
      return jsonDecode(decrypted);
    }
    return {};
  }
}
```

### Anonymization for Cloud Insights

If users opt-in to share data:

```python
def anonymize_user_data(user_data):
    """
    Remove all personally identifiable information
    """
    anonymized = {
        'user_id_hash': hash_user_id(user_data['user_id']),  # One-way hash
        'age_range': get_age_range(user_data['age']),  # e.g., "25-34"
        'region': user_data['region'],  # General location only
        'patterns': user_data['usage_patterns'],  # No timestamps or specific details
        'aggregated_metrics': compute_aggregates(user_data),
    }
    
    # Remove any fields that could identify individual
    del anonymized['name']
    del anonymized['email']
    del anonymized['exact_location']
    
    return anonymized
```

### Compliance

**HIPAA Considerations:**
- Health data must be encrypted
- User must consent to data collection
- Right to delete all data
- Audit logs for data access

**GDPR Compliance:**
- Clear consent mechanisms
- Data portability (export user data)
- Right to be forgotten (delete all user data)
- Transparent about data usage

---

## 10. Deployment Checklist

### Pre-Launch

- [ ] Model achieves >75% accuracy on validation set
- [ ] TFLite model size < 500KB
- [ ] Inference time < 100ms on mid-range devices
- [ ] Handle missing data gracefully
- [ ] Privacy review completed
- [ ] User consent flows implemented
- [ ] Encrypted local storage
- [ ] Background task working reliably

### Testing

- [ ] Test with sparse data (new users)
- [ ] Test with complete data (active users)
- [ ] Test with missing features
- [ ] Test notification triggers
- [ ] Test battery impact (should be minimal)
- [ ] Test on low-end devices
- [ ] A/B test model versions

### Monitoring

- [ ] Track prediction accuracy over time
- [ ] Monitor false positive/negative rates
- [ ] Track user engagement with notifications
- [ ] Monitor model performance metrics
- [ ] Collect user feedback on predictions

---

## 11. Future Improvements

### Short-Term (1-3 months)
1. **Personalization**: Fine-tune model per user as data grows
2. **Context enhancement**: Add location patterns, calendar events
3. **Multi-substance support**: Separate models per substance type
4. **Intervention effectiveness**: Track which notifications work best

### Medium-Term (3-6 months)
1. **Federated learning**: Improve model from collective insights
2. **Real-time triggers**: GPS geofencing for location-based alerts
3. **Social features**: Anonymous community patterns
4. **Wearable integration**: Heart rate, sleep tracking from smartwatches

### Long-Term (6-12 months)
1. **Advanced NLP**: Analyze user journal entries for sentiment
2. **Multimodal learning**: Combine behavioral + biometric + contextual data
3. **Reinforcement learning**: Optimize intervention timing
4. **Explainable AI**: Show users why predictions were made

---

## Conclusion

This guide provides a complete roadmap for building an on-device ML model for the Grounded harm reduction app. Key takeaways:

1. **Start simple**: LSTM or GRU with 32-64 units is sufficient and mobile-friendly
2. **Handle missing data**: Use imputation, confidence scores, and progressive collection
3. **Privacy first**: Everything runs on-device, with optional anonymized sharing
4. **Personalization**: Start with general model, personalize as data grows
5. **Quantization**: Compress model 4x with minimal accuracy loss
6. **Testing**: Validate thoroughly before deployment, monitor continuously

The model should empower users with insights, not judge them. Keep notifications supportive, actionable, and non-judgmental. Good luck building Grounded! 🌱