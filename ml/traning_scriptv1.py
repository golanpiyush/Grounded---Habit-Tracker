"""
Grounded App - Risk Prediction Model Training
Author: [Your Name]
Date: October 2025

This script trains the on-device risk prediction model for substance use patterns.
It's designed to be lightweight enough for mobile deployment while still being 
accurate enough to provide helpful insights to users.

The model predicts risk scores (0-1) based on:
- Usage frequency and patterns
- Social context (alone, with friends, etc)
- Time of day
- Mood and sleep quality
- Recent behavior trends

Note: This is for harm reduction, not treatment. We aim to help users make
more informed choices, not judge them.
"""

import warnings
import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow import keras
from keras import layers, models
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from datetime import datetime, timedelta
import matplotlib.pyplot as plt
import json
import os

# Set random seeds for reproducibility
# (makes debugging way easier when results are consistent)
np.random.seed(42)
tf.random.set_seed(42)

# Suppress TensorFlow warnings
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'  # 0=all, 1=info, 2=warning, 3=error
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'  # Disable oneDNN warnings

# Suppress protobuf warnings
warnings.filterwarnings('ignore', category=UserWarning, module='google.protobuf')

class GroundedDataGenerator:
    """
    Generates realistic synthetic user data for training.
    
    In production, this would be replaced with actual user data from the app,
    but for development and testing we need something that looks realistic.
    """
    
    def __init__(self):
        # Define the categories we track
        self.contexts = ['alone', 'friends', 'family', 'work', 'party']
        self.times = ['morning', 'afternoon', 'evening', 'night']
        self.methods = ['smoking', 'vaping', 'edibles', 'drinking']
        self.days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
    
    def generate_user_profile(self):
        """
        Create a user profile with typical patterns.
        Different users have different patterns - some weekend users, 
        some daily users, etc.
        """
        profile = {
            'baseline_frequency': np.random.choice([1, 2, 3, 4, 5, 6], p=[0.3, 0.25, 0.2, 0.15, 0.07, 0.03]),
            'preferred_context': np.random.choice(self.contexts),
            'preferred_time': np.random.choice(self.times),
            'stress_sensitivity': np.random.uniform(0.5, 1.5),  # how much stress affects usage
            'social_influence': np.random.uniform(0.3, 1.2),     # how much friends affect usage
        }
        return profile
    
    def generate_day_data(self, profile, day_num, prev_days):
        """
        Generate data for a single day based on user profile and history.
        
        This tries to simulate realistic patterns:
        - More usage on weekends for social users
        - Stress leads to more usage
        - Poor sleep correlates with higher risk
        - Usage tends to cluster (if you used yesterday, more likely today)
        """
        
        day_of_week = day_num % 7
        is_weekend = day_of_week in [5, 6]  # saturday, sunday
        
        # Base probability of use
        use_prob = profile['baseline_frequency'] / 7.0
        
        # Weekend effect for social users
        if is_weekend and profile['preferred_context'] in ['friends', 'party']:
            use_prob *= 1.5
        
        # Recent usage creates momentum (tolerance, habit, etc)
        if len(prev_days) > 0 and prev_days[-1].get('used', False):
            use_prob *= 1.3
        
        # Generate whether substance was used today
        used = np.random.random() < use_prob
        
        if used:
            # If used, generate the details
            
            # Context influenced by profile but with some randomness
            if np.random.random() < 0.6:
                context = profile['preferred_context']
            else:
                context = np.random.choice(self.contexts)
            
            # Time of day
            if np.random.random() < 0.7:
                time_of_day = profile['preferred_time']
            else:
                time_of_day = np.random.choice(self.times)
            
            # Amount varies but social contexts tend to have more
            base_amount = np.random.uniform(1, 5)
            if context in ['friends', 'party']:
                base_amount *= np.random.uniform(1.2, 1.8)
            amount = base_amount
            
            # Cost correlates with amount
            cost = amount * np.random.uniform(8, 15)
            
            method = np.random.choice(self.methods)
            
        else:
            # No use today - set everything to defaults
            context = 'none'
            time_of_day = 'none'
            amount = 0
            cost = 0
            method = 'none'
        
        # Mood and sleep are somewhat independent but poor sleep leads to worse mood
        sleep_quality = np.random.uniform(3, 9)
        mood = sleep_quality + np.random.uniform(-2, 2)
        mood = np.clip(mood, 1, 10)
        
        # Cravings higher when stressed or after recent use
        base_craving = np.random.uniform(2, 6)
        if len(prev_days) > 0 and prev_days[-1].get('used', False):
            base_craving += np.random.uniform(1, 3)
        if mood < 4:
            base_craving += np.random.uniform(1, 2)
        craving_intensity = np.clip(base_craving, 1, 10)
        
        # App engagement (reminders, messages read)
        # Users tend to engage more when they're trying to cut back
        reminder_opens = np.random.poisson(1) if np.random.random() < 0.4 else 0
        messages_read = np.random.poisson(0.5) if reminder_opens > 0 else 0
        
        # Calculate risk score for this day
        # This is what we're trying to predict with our model
        risk_score = self._calculate_risk_score(
            used, context, time_of_day, amount, mood, 
            sleep_quality, craving_intensity, prev_days
        )
        
        return {
            'day_num': day_num,
            'day_of_week': day_of_week,
            'used': used,
            'frequency': 1 if used else 0,
            'context': context,
            'time_of_day': time_of_day,
            'method': method,
            'amount': amount,
            'cost': cost,
            'mood': mood,
            'sleep_quality': sleep_quality,
            'craving_intensity': craving_intensity,
            'reminder_opens': reminder_opens,
            'messages_read': messages_read,
            'risk_score': risk_score,
            'risk_label': 1 if risk_score > 0.6 else 0  # binary classification
        }
    
    def _calculate_risk_score(self, used, context, time_of_day, amount, 
                              mood, sleep_quality, craving_intensity, prev_days):
        """
        Calculate a 'ground truth' risk score.
        
        In reality we don't know the true risk, but for training we need labels.
        This uses domain knowledge about what patterns are concerning:
        - High frequency usage
        - Using alone at night
        - Poor mental state
        - Escalating amounts
        """
        
        risk = 0.0
        
        # Frequency risk - using multiple days in a row
        recent_use_count = sum(1 for d in prev_days[-7:] if d.get('used', False))
        if recent_use_count >= 5:
            risk += 0.3
        elif recent_use_count >= 3:
            risk += 0.15
        
        # Context risk - alone at night is higher risk
        if context == 'alone' and time_of_day in ['night', 'evening']:
            risk += 0.2
        
        # Amount risk - using a lot
        if amount > 4:
            risk += 0.15
        
        # Mental health indicators
        if mood < 4:
            risk += 0.15
        if sleep_quality < 4:
            risk += 0.1
        
        # High cravings indicate dependency forming
        if craving_intensity > 7:
            risk += 0.2
        
        # Current use adds base risk
        if used:
            risk += 0.1
        
        return np.clip(risk, 0, 1)
    
    def generate_user_data(self, n_days=90):
        """
        Generate a complete user history.
        Returns a dataframe with all the days of data.
        """
        
        profile = self.generate_user_profile()
        days = []
        
        for day_num in range(n_days):
            day_data = self.generate_day_data(profile, day_num, days)
            days.append(day_data)
        
        return pd.DataFrame(days)
    
    def generate_multi_user_dataset(self, n_users=100, days_per_user=90):
        """
        Generate data for multiple users.
        This is what we'd use for the initial general model.
        """
        
        print(f"Generating data for {n_users} users...")
        all_data = []
        
        for user_id in range(n_users):
            if (user_id + 1) % 10 == 0:
                print(f"  Generated {user_id + 1}/{n_users} users")
            
            user_data = self.generate_user_data(days_per_user)
            user_data['user_id'] = user_id
            all_data.append(user_data)
        
        combined = pd.concat(all_data, ignore_index=True)
        print(f"Total samples: {len(combined)}")
        
        return combined


class DataPreprocessor:
    """
    Handles all the data preprocessing - encoding, normalization, etc.
    
    This needs to be saved along with the model so we can do the same
    transformations on new data in production.
    """
    
    def __init__(self):
        self.scaler = MinMaxScaler()
        self.feature_names = []
        
        # These match the categories in the data generator
        self.contexts = ['alone', 'friends', 'family', 'work', 'party', 'none']
        self.times = ['morning', 'afternoon', 'evening', 'night', 'none']
        self.methods = ['smoking', 'vaping', 'edibles', 'drinking', 'none']
        self.days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
    
    def prepare_features(self, df):
        """
        Convert raw data into model-ready features.
        
        This does:
        1. One-hot encoding for categorical variables
        2. Normalization of numerical variables
        3. Feature engineering (rolling averages, etc)
        """
        
        features_list = []
        
        # One-hot encode context
        for context in self.contexts:
            features_list.append((df['context'] == context).astype(float))
        
        # One-hot encode time of day
        for time in self.times:
            features_list.append((df['time_of_day'] == time).astype(float))
        
        # One-hot encode method
        for method in self.methods:
            features_list.append((df['method'] == method).astype(float))
        
        # One-hot encode day of week
        for i, day in enumerate(self.days):
            features_list.append((df['day_of_week'] == i).astype(float))
        
        # Numerical features - we'll normalize these
        numerical_cols = ['amount', 'cost', 'mood', 'sleep_quality', 
                         'craving_intensity', 'reminder_opens', 'messages_read']
        
        numerical_data = df[numerical_cols].values
        
        # Add rolling averages for frequency (helps capture trends)
        # This is important - we want to know if someone's been using more lately
        df['frequency_7day'] = df.groupby('user_id')['frequency'].rolling(7, min_periods=1).mean().reset_index(0, drop=True)
        df['frequency_30day'] = df.groupby('user_id')['frequency'].rolling(30, min_periods=1).mean().reset_index(0, drop=True)
        
        numerical_data = np.column_stack([
            numerical_data,
            df['frequency_7day'].values,
            df['frequency_30day'].values
        ])
        
        # Fit scaler on first call, transform always
        if not hasattr(self.scaler, 'data_min_'):
            numerical_data = self.scaler.fit_transform(numerical_data)
        else:
            numerical_data = self.scaler.transform(numerical_data)
        
        features_list.extend([numerical_data[:, i] for i in range(numerical_data.shape[1])])
        
        # Stack all features into a matrix
        feature_matrix = np.column_stack(features_list)
        
        return feature_matrix
    
    def create_sequences(self, features, labels, sequence_length=14):
        """
        Create sequences for time series prediction.
        
        We look at the last 14 days to predict risk for day 15.
        This is like giving the model a 2-week window into someone's patterns.
        """
        
        X, y = [], []
        
        for i in range(len(features) - sequence_length):
            X.append(features[i:i + sequence_length])
            y.append(labels[i + sequence_length])
        
        return np.array(X), np.array(y)


def build_model(sequence_length, n_features, model_type='hybrid'):
    """
    Build the neural network model.
    
    We've tried a few architectures and the hybrid CNN+LSTM works best.
    The CNN catches local patterns (like "always uses on Friday nights")
    and the LSTM catches longer-term trends.
    """
    
    if model_type == 'lstm':
        # Simple LSTM model - good baseline
        model = keras.Sequential([
            layers.Input(shape=(sequence_length, n_features)),
            layers.LSTM(32, return_sequences=False),
            layers.Dropout(0.3),
            layers.Dense(16, activation='relu'),
            layers.Dropout(0.2),
            layers.Dense(1, activation='sigmoid')
        ], name='grounded_lstm_model')
    
    elif model_type == 'gru':
        # GRU is faster than LSTM, fewer parameters
        model = keras.Sequential([
            layers.Input(shape=(sequence_length, n_features)),
            layers.GRU(32, return_sequences=False),
            layers.Dropout(0.3),
            layers.Dense(16, activation='relu'),
            layers.Dropout(0.2),
            layers.Dense(1, activation='sigmoid')
        ], name='grounded_gru_model')
    
    elif model_type == 'hybrid':
        # Best performer - CNN for local patterns, LSTM for temporal
        model = keras.Sequential([
            layers.Input(shape=(sequence_length, n_features)),
            layers.Conv1D(32, kernel_size=3, activation='relu', padding='same'),
            layers.MaxPooling1D(pool_size=2),
            layers.LSTM(32, return_sequences=False),
            layers.Dropout(0.3),
            layers.Dense(16, activation='relu'),
            layers.Dropout(0.2),
            layers.Dense(1, activation='sigmoid')
        ], name='grounded_hybrid_model')
    
    return model


def train_model(X_train, y_train, X_val, y_val, model_type='hybrid', epochs=100):
    """
    Train the risk prediction model.
    
    We use class weighting because high-risk days are less common,
    and we really don't want to miss those.
    """
    
    sequence_length = X_train.shape[1]
    n_features = X_train.shape[2]
    
    print(f"\nBuilding {model_type} model...")
    print(f"Input shape: ({sequence_length} days, {n_features} features)")
    
    model = build_model(sequence_length, n_features, model_type)
    
    # Adam optimizer works well for this
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=0.001),
        loss='binary_crossentropy',
        metrics=['accuracy', keras.metrics.AUC(name='auc')]
    )
    
    model.summary()
    
    # Callbacks to prevent overfitting and save best model
    callbacks = [
        keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=15,
            restore_best_weights=True,
            verbose=1
        ),
        keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=7,
            min_lr=1e-6,
            verbose=1
        ),
        keras.callbacks.ModelCheckpoint(
            'best_model.h5',
            monitor='val_auc',
            save_best_only=True,
            mode='max',
            verbose=1
        )
    ]
    
    # Give more weight to high-risk samples since they're less common
    # This helps the model learn to catch those important moments
    class_weight = {0: 1.0, 1: 2.5}
    
    print("\nStarting training...")
    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=epochs,
        batch_size=32,
        callbacks=callbacks,
        class_weight=class_weight,
        verbose=1
    )
    
    return model, history


def evaluate_model(model, X_test, y_test):
    """
    Evaluate model performance with multiple metrics.
    
    For this use case, we care most about:
    - AUC: Can we distinguish high vs low risk?
    - Recall: Are we catching the high-risk moments?
    """
    
    from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score
    
    print("\n" + "="*60)
    print("MODEL EVALUATION")
    print("="*60)
    
    # Get predictions
    y_pred_proba = model.predict(X_test, verbose=0)
    y_pred = (y_pred_proba > 0.5).astype(int).flatten()
    
    # Basic metrics
    test_loss, test_acc, test_auc = model.evaluate(X_test, y_test, verbose=0)
    print(f"\nTest Accuracy: {test_acc:.4f}")
    print(f"Test AUC:      {test_auc:.4f}")
    print(f"Test Loss:     {test_loss:.4f}")
    
    # Classification report
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, 
                                target_names=['Low Risk', 'High Risk']))
    
    # Confusion matrix
    cm = confusion_matrix(y_test, y_pred)
    print("\nConfusion Matrix:")
    print(f"True Negatives (Low Risk correctly identified):  {cm[0,0]}")
    print(f"False Positives (False alarms):                  {cm[0,1]}")
    print(f"False Negatives (Missed high-risk moments):      {cm[1,0]}")
    print(f"True Positives (High Risk correctly identified): {cm[1,1]}")
    
    # Calculate precision and recall manually for clarity
    precision = cm[1,1] / (cm[1,1] + cm[0,1]) if (cm[1,1] + cm[0,1]) > 0 else 0
    recall = cm[1,1] / (cm[1,1] + cm[1,0]) if (cm[1,1] + cm[1,0]) > 0 else 0
    
    print(f"\nPrecision (how many alerts are real): {precision:.4f}")
    print(f"Recall (how many real risks we catch): {recall:.4f}")
    
    print("="*60)
    
    return {
        'accuracy': test_acc,
        'auc': test_auc,
        'precision': precision,
        'recall': recall
    }


def plot_training_history(history):
    """
    Visualize the training process.
    Helps us understand if the model is learning or overfitting.
    """
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    
    # Loss
    axes[0].plot(history.history['loss'], label='Training')
    axes[0].plot(history.history['val_loss'], label='Validation')
    axes[0].set_title('Model Loss')
    axes[0].set_xlabel('Epoch')
    axes[0].set_ylabel('Loss')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Accuracy
    axes[1].plot(history.history['accuracy'], label='Training')
    axes[1].plot(history.history['val_accuracy'], label='Validation')
    axes[1].set_title('Model Accuracy')
    axes[1].set_xlabel('Epoch')
    axes[1].set_ylabel('Accuracy')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    # AUC
    axes[2].plot(history.history['auc'], label='Training')
    axes[2].plot(history.history['val_auc'], label='Validation')
    axes[2].set_title('Model AUC')
    axes[2].set_xlabel('Epoch')
    axes[2].set_ylabel('AUC')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('training_history.png', dpi=150, bbox_inches='tight')
    print("\nSaved training history plot to 'training_history.png'")

# LEGACY VERSION
# def save_model_for_mobile(model, preprocessor, output_dir='models'):
#     """
#     Save the model in formats ready for mobile deployment.
#     """
    
#     os.makedirs(output_dir, exist_ok=True)
    
#     # Save Keras model
#     keras_path = os.path.join(output_dir, 'grounded_model.h5')
#     model.save(keras_path)
#     print(f"\nSaved Keras model to {keras_path}")
    
#     # Convert to TFLite
#     converter = tf.lite.TFLiteConverter.from_keras_model(model)
#     converter.optimizations = [tf.lite.Optimize.DEFAULT]
#     tflite_model = converter.convert()
    
#     tflite_path = os.path.join(output_dir, 'grounded_model.tflite')
#     with open(tflite_path, 'wb') as f:
#         f.write(tflite_model)
    
#     # Check size
#     size_kb = os.path.getsize(tflite_path) / 1024
#     print(f"Saved TFLite model to {tflite_path}")
#     print(f"Model size: {size_kb:.2f} KB")
    
#     # Save preprocessor
#     import joblib
#     scaler_path = os.path.join(output_dir, 'feature_scaler.pkl')
#     joblib.dump(preprocessor.scaler, scaler_path)
#     print(f"Saved scaler to {scaler_path}")
    
#     # Save metadata
#     metadata = {
#         'model_version': '1.0.0',
#         'created_at': datetime.now().isoformat(),
#         'sequence_length': model.input_shape[1],
#         'n_features': model.input_shape[2],
#         'model_type': model.name
#     }
    
#     metadata_path = os.path.join(output_dir, 'model_metadata.json')
#     with open(metadata_path, 'w') as f:
#         json.dump(metadata, f, indent=2)
#     print(f"Saved metadata to {metadata_path}")

def save_model_for_mobile(model, preprocessor, output_dir='models'):
    """
    Save the model in formats ready for mobile deployment.
    Also prints summary to console.
    """
    
    os.makedirs(output_dir, exist_ok=True)
    
    # Save Keras model
    keras_path = os.path.join(output_dir, 'grounded_model.h5')
    model.save(keras_path)
    print(f"\n✓ Saved Keras model to {keras_path}")
    
    # Convert to TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    
    tflite_path = os.path.join(output_dir, 'grounded_model.tflite')
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
    
    # Check size
    size_kb = os.path.getsize(tflite_path) / 1024
    print(f"✓ Saved TFLite model to {tflite_path}")
    print(f"✓ Model size: {size_kb:.2f} KB (optimized for mobile)")
    
    # Save preprocessor
    import joblib
    scaler_path = os.path.join(output_dir, 'feature_scaler.pkl')
    joblib.dump(preprocessor.scaler, scaler_path)
    print(f"✓ Saved scaler to {scaler_path}")
    
    # Save metadata
    metadata = {
        'model_version': '1.0.0',
        'created_at': datetime.now().isoformat(),
        'sequence_length': model.input_shape[1],
        'n_features': model.input_shape[2],
        'model_type': model.name
    }
    
    metadata_path = os.path.join(output_dir, 'model_metadata.json')
    with open(metadata_path, 'w') as f:
        json.dump(metadata, f, indent=2)
    print(f"✓ Saved metadata to {metadata_path}")

def print_sample_predictions(model, preprocessor, data, n_samples=5):
    """
    Print some example predictions to console for verification.
    """
    
    print("\n" + "="*80)
    print("SAMPLE PREDICTIONS (Random Days from Dataset)")
    print("="*80)
    
    # Prepare features
    features = preprocessor.prepare_features(data)
    labels = data['risk_label'].values
    
    # Create sequences
    X, y = preprocessor.create_sequences(features, labels, sequence_length=14)
    
    # Get random samples
    indices = np.random.choice(len(X), min(n_samples, len(X)), replace=False)
    
    for idx in indices:
        sequence = X[idx:idx+1]
        actual_label = y[idx]
        prediction = model.predict(sequence, verbose=0)[0][0]
        
        # Get the actual day data
        day_idx = idx + 14  # accounting for sequence length
        day_data = data.iloc[day_idx]
        
        print(f"\n{'─'*80}")
        print(f"Day {day_data['day_num']} | User {day_data['user_id']}")
        print(f"{'─'*80}")
        print(f"Context: {day_data['context'].title()} | Time: {day_data['time_of_day'].title()}")
        print(f"Used: {'Yes' if day_data['used'] else 'No'} | Amount: {day_data['amount']:.1f}")
        print(f"Mood: {day_data['mood']:.1f}/10 | Sleep: {day_data['sleep_quality']:.1f}/10")
        print(f"Craving: {day_data['craving_intensity']:.1f}/10")
        print(f"\nPrediction: {prediction:.3f} (Risk: {'HIGH' if prediction > 0.5 else 'LOW'})")
        print(f"Actual: {'HIGH RISK' if actual_label == 1 else 'LOW RISK'}")
        print(f"{'✓ CORRECT' if (prediction > 0.5) == actual_label else '✗ INCORRECT'}")

def main():
    """
    Main training pipeline with console output.
    """
    
    print("="*80)
    print(" "*20 + "GROUNDED RISK PREDICTION MODEL")
    print(" "*25 + "Training Pipeline")
    print("="*80)
    
    # Step 1: Generate synthetic data
    print("\n[STEP 1/7] Generating training data...")
    print("─"*80)
    generator = GroundedDataGenerator()
    data = generator.generate_multi_user_dataset(n_users=100, days_per_user=90)
    
    print(f"\n📊 Dataset Statistics:")
    print(f"   • Total days: {len(data):,}")
    print(f"   • High risk days: {data['risk_label'].sum():,} ({data['risk_label'].mean()*100:.1f}%)")
    print(f"   • Low risk days: {(1-data['risk_label']).sum():,} ({(1-data['risk_label'].mean())*100:.1f}%)")
    print(f"   • Users: {data['user_id'].nunique()}")
    print(f"   • Days per user: {len(data) // data['user_id'].nunique()}")
    
    # Show usage patterns
    print(f"\n📈 Usage Patterns:")
    print(f"   • Days with use: {data['used'].sum():,} ({data['used'].mean()*100:.1f}%)")
    print(f"   • Average amount (when used): {data[data['used']]['amount'].mean():.2f}")
    print(f"   • Most common context: {data['context'].mode()[0].title()}")
    print(f"   • Most common time: {data['time_of_day'].mode()[0].title()}")
    
    # Step 2: Preprocess
    print("\n[STEP 2/7] Preprocessing features...")
    print("─"*80)
    preprocessor = DataPreprocessor()
    features = preprocessor.prepare_features(data)
    labels = data['risk_label'].values
    
    print(f"✓ Feature matrix: {features.shape[0]:,} samples × {features.shape[1]} features")
    print(f"✓ Labels: {labels.shape[0]:,} samples")
    
    # Step 3: Create sequences
    print("\n[STEP 3/7] Creating time sequences...")
    print("─"*80)
    X, y = preprocessor.create_sequences(features, labels, sequence_length=14)
    
    print(f"✓ Sequences: {X.shape[0]:,} sequences")
    print(f"✓ Window size: {X.shape[1]} days")
    print(f"✓ Features per day: {X.shape[2]}")
    
    # Step 4: Split data
    print("\n[STEP 4/7] Splitting dataset...")
    print("─"*80)
    X_temp, X_test, y_temp, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    X_train, X_val, y_train, y_val = train_test_split(
        X_temp, y_temp, test_size=0.2, random_state=42, stratify=y_temp
    )
    
    print(f"   • Training:   {len(X_train):,} samples ({len(X_train)/len(X)*100:.1f}%)")
    print(f"   • Validation: {len(X_val):,} samples ({len(X_val)/len(X)*100:.1f}%)")
    print(f"   • Test:       {len(X_test):,} samples ({len(X_test)/len(X)*100:.1f}%)")
    
    # Step 5: Train
    print("\n[STEP 5/7] Training model...")
    print("─"*80)
    model, history = train_model(
        X_train, y_train, 
        X_val, y_val,
        model_type='hybrid',
        epochs=100
    )
    
    # Step 6: Evaluate
    print("\n[STEP 6/7] Evaluating model...")
    print("─"*80)
    metrics = evaluate_model(model, X_test, y_test)
    
    # Step 7: Show predictions
    print("\n[STEP 7/7] Sample predictions...")
    print_sample_predictions(model, preprocessor, data, n_samples=5)
    
    # Save everything
    print("\n" + "="*80)
    print("SAVING MODEL FILES")
    print("="*80)
    save_model_for_mobile(model, preprocessor)
    
    # Plot if possible
    try:
        plot_training_history(history)
    except:
        print("\n⚠ Could not save training plots (matplotlib display issue)")
    
    # Final summary
    print("\n" + "="*80)
    print(" "*30 + "✓ TRAINING COMPLETE!")
    print("="*80)
    print("\n📦 Generated Files:")
    print("   • models/grounded_model.h5 (Full Keras model)")
    print("   • models/grounded_model.tflite (Optimized for mobile)")
    print("   • models/feature_scaler.pkl (Data preprocessing)")
    print("   • models/model_metadata.json (Model configuration)")
    print("   • training_history.png (Performance graphs)")
    
    print("\n📱 Next Steps:")
    print("   1. Test the model with: python test_model.py")
    print("   2. Copy .tflite file to Flutter assets/")
    print("   3. Integrate with your app!")
    print("\n" + "="*80)


if __name__ == '__main__':
    main()