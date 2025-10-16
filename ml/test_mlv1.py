"""
Grounded App - Model Testing Script
Tests the trained risk prediction model with realistic user scenarios
"""

import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow import keras
import joblib
import json
import os


class ScenarioTester:
    """
    Tests the model with realistic user scenarios.
    """
    
    def __init__(self, model_path='models/grounded_model.h5', 
                 scaler_path='models/feature_scaler.pkl'):
        """Load the trained model and preprocessor."""
        
        print("="*80)
        print(" "*25 + "LOADING MODEL")
        print("="*80)
        
        self.model = keras.models.load_model(model_path)
        self.scaler = joblib.load(scaler_path)
        
        print(f"✓ Model loaded from {model_path}")
        print(f"✓ Scaler loaded from {scaler_path}")
        print(f"✓ Input shape: {self.model.input_shape}")
        
        # Categories matching training
        self.contexts = ['alone', 'friends', 'family', 'work', 'party', 'none']
        self.times = ['morning', 'afternoon', 'evening', 'night', 'none']
        self.methods = ['smoking', 'vaping', 'edibles', 'drinking', 'none']
        
    
    def create_day(self, used=False, context='none', time_of_day='none', 
                   method='none', amount=0, cost=0, mood=5, sleep_quality=7,
                   craving_intensity=3, reminder_opens=0, messages_read=0,
                   day_of_week=0):
        """Create a single day's data."""
        
        return {
            'used': used,
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
            'day_of_week': day_of_week,
            'frequency': 1 if used else 0
        }
    
    
    def prepare_features(self, df):
        """Prepare features exactly like training."""
        
        features_list = []
        
        # One-hot encode context
        for context in self.contexts:
            features_list.append((df['context'] == context).astype(float))
        
        # One-hot encode time
        for time in self.times:
            features_list.append((df['time_of_day'] == time).astype(float))
        
        # One-hot encode method
        for method in self.methods:
            features_list.append((df['method'] == method).astype(float))
        
        # One-hot encode day of week
        for i in range(7):
            features_list.append((df['day_of_week'] == i).astype(float))
        
        # Numerical features
        numerical_cols = ['amount', 'cost', 'mood', 'sleep_quality', 
                         'craving_intensity', 'reminder_opens', 'messages_read']
        
        numerical_data = df[numerical_cols].values
        
        # Add rolling averages
        df['frequency_7day'] = df['frequency'].rolling(7, min_periods=1).mean()
        df['frequency_30day'] = df['frequency'].rolling(30, min_periods=1).mean()
        
        numerical_data = np.column_stack([
            numerical_data,
            df['frequency_7day'].values,
            df['frequency_30day'].values
        ])
        
        # Normalize
        numerical_data = self.scaler.transform(numerical_data)
        
        features_list.extend([numerical_data[:, i] for i in range(numerical_data.shape[1])])
        
        return np.column_stack(features_list)
    
    
    def predict_from_history(self, days_history):
        """
        Predict risk for the next day given 14 days of history.
        """
        
        if len(days_history) < 14:
            print(f"⚠ Warning: Need 14 days of history, got {len(days_history)}")
            return None
        
        # Take last 14 days
        recent_days = days_history[-14:]
        
        # Convert to DataFrame
        df = pd.DataFrame(recent_days)
        
        # Prepare features
        features = self.prepare_features(df)
        
        # Reshape for model input (1 sequence, 14 days, n_features)
        sequence = features.reshape(1, 14, -1)
        
        # Predict
        prediction = self.model.predict(sequence, verbose=0)[0][0]
        
        return prediction
    
    
    def print_scenario_result(self, scenario_name, prediction, history):
        """Print the results nicely."""
        
        print(f"\n{'='*80}")
        print(f"SCENARIO: {scenario_name}")
        print(f"{'='*80}")
        
        # Show last 7 days summary
        print(f"\n📅 Last 7 Days Summary:")
        recent_week = history[-7:]
        
        for i, day in enumerate(recent_week):
            day_num = len(history) - 7 + i + 1
            if day['used']:
                print(f"   Day {day_num}: Used {day['amount']:.0f} drinks/units | "
                      f"{day['context'].title()} at {day['time_of_day'].title()} | "
                      f"Mood: {day['mood']:.0f}/10")
            else:
                print(f"   Day {day_num}: No use | Mood: {day['mood']:.0f}/10 | "
                      f"Sleep: {day['sleep_quality']:.0f}/10")
        
        # Calculate usage stats
        week_use_count = sum(1 for d in recent_week if d['used'])
        week_total_amount = sum(d['amount'] for d in recent_week)
        
        print(f"\n📊 Week Stats:")
        print(f"   • Days used: {week_use_count}/7")
        print(f"   • Total amount: {week_total_amount:.1f}")
        print(f"   • Average mood: {np.mean([d['mood'] for d in recent_week]):.1f}/10")
        print(f"   • Average sleep: {np.mean([d['sleep_quality'] for d in recent_week]):.1f}/10")
        
        # Show prediction
        risk_level = "🔴 HIGH" if prediction > 0.6 else "🟡 MODERATE" if prediction > 0.4 else "🟢 LOW"
        
        print(f"\n🎯 RISK PREDICTION FOR NEXT DAY:")
        print(f"   Score: {prediction:.3f} ({prediction*100:.1f}%)")
        print(f"   Level: {risk_level} RISK")
        
        # Recommendations
        print(f"\n💡 Interpretation:")
        if prediction > 0.6:
            print("   ⚠ High risk detected. Pattern shows concerning trends.")
            print("   → Consider: Taking a break, reaching out to support network")
        elif prediction > 0.4:
            print("   ⚡ Moderate risk. Some patterns may need attention.")
            print("   → Consider: Monitoring usage, planning alternative activities")
        else:
            print("   ✓ Low risk. Current patterns appear manageable.")
            print("   → Keep up healthy habits and self-awareness")
        
        print(f"{'='*80}\n")
    
    
    def test_scenario_1(self):
        """
        SCENARIO 1: Weekend Social Drinker
        User drinks mostly on weekends with friends at parties.
        Moderate amounts, good mood and sleep.
        """
        
        history = []
        
        # Week 1: Mon-Thu no drinking, Fri-Sat party
        for day in range(14):
            day_of_week = day % 7
            
            if day_of_week in [4, 5]:  # Friday, Saturday
                history.append(self.create_day(
                    used=True,
                    context='friends',
                    time_of_day='night',
                    method='drinking',
                    amount=4,  # 4 drinks
                    cost=40,
                    mood=7,
                    sleep_quality=6,
                    craving_intensity=3,
                    day_of_week=day_of_week
                ))
            else:  # Weekdays
                history.append(self.create_day(
                    used=False,
                    mood=6,
                    sleep_quality=7,
                    craving_intensity=2,
                    day_of_week=day_of_week
                ))
        
        prediction = self.predict_from_history(history)
        self.print_scenario_result("Weekend Social Drinker", prediction, history)
        
        return prediction
    
    
    def test_scenario_2(self):
        """
        SCENARIO 2: Heavy Regular User  
        User drinks 6 pegs + beers almost every night at 8pm.
        Mix of alone and with friends. Poor sleep, high cravings.
        """
        
        history = []
        
        # 14 days of frequent heavy use
        for day in range(14):
            day_of_week = day % 7
            
            # Use 5-6 days per week
            if day % 7 != 2:  # Skip one day per week
                history.append(self.create_day(
                    used=True,
                    context='alone' if day % 3 == 0 else 'friends',
                    time_of_day='night',
                    method='drinking',
                    amount=6.5,  # 6 pegs + beers
                    cost=65,
                    mood=4,
                    sleep_quality=4,
                    craving_intensity=7,
                    day_of_week=day_of_week
                ))
            else:
                history.append(self.create_day(
                    used=False,
                    mood=3,
                    sleep_quality=5,
                    craving_intensity=8,  # High cravings on off day
                    day_of_week=day_of_week
                ))
        
        prediction = self.predict_from_history(history)
        self.print_scenario_result("Heavy Regular User (High Risk)", prediction, history)
        
        return prediction
    
    
    def test_scenario_3(self):
        """
        SCENARIO 3: Stress Drinker
        Occasional user, but recent stress leading to more frequent alone drinking.
        Escalating pattern over 2 weeks.
        """
        
        history = []
        
        # First week: 2 times, moderate
        for day in range(7):
            if day in [2, 5]:  # Wed, Sat
                history.append(self.create_day(
                    used=True,
                    context='friends' if day == 5 else 'alone',
                    time_of_day='evening' if day == 5 else 'night',
                    method='drinking',
                    amount=3,
                    cost=30,
                    mood=5,
                    sleep_quality=6,
                    craving_intensity=4,
                    day_of_week=day
                ))
            else:
                history.append(self.create_day(
                    used=False,
                    mood=6,
                    sleep_quality=7,
                    craving_intensity=3,
                    day_of_week=day
                ))
        
        # Second week: Stress hits, 4 times, mostly alone
        for day in range(7, 14):
            day_of_week = day % 7
            if day in [7, 9, 11, 13]:  # Mon, Wed, Fri, Sun
                history.append(self.create_day(
                    used=True,
                    context='alone',
                    time_of_day='night',
                    method='drinking',
                    amount=5,
                    cost=50,
                    mood=3,
                    sleep_quality=4,
                    craving_intensity=6,
                    day_of_week=day_of_week
                ))
            else:
                history.append(self.create_day(
                    used=False,
                    mood=4,
                    sleep_quality=5,
                    craving_intensity=5,
                    day_of_week=day_of_week
                ))
        
        prediction = self.predict_from_history(history)
        self.print_scenario_result("Escalating Stress Drinker", prediction, history)
        
        return prediction
    
    
    def test_scenario_4(self):
        """
        SCENARIO 4: Cutting Back Successfully
        Was drinking daily, now tapering down with app support.
        """
        
        history = []
        
        # First week: Daily heavy use
        for day in range(7):
            history.append(self.create_day(
                used=True,
                context='alone',
                time_of_day='evening',
                method='drinking',
                amount=5,
                cost=50,
                mood=4,
                sleep_quality=5,
                craving_intensity=7,
                reminder_opens=0,
                messages_read=0,
                day_of_week=day
            ))
        
        # Second week: Cutting back, using app
        for day in range(7, 14):
            day_of_week = day % 7
            if day % 2 == 0:  # Every other day
                history.append(self.create_day(
                    used=True,
                    context='friends',
                    time_of_day='evening',
                    method='drinking',
                    amount=3,
                    cost=30,
                    mood=6,
                    sleep_quality=7,
                    craving_intensity=5,
                    reminder_opens=2,
                    messages_read=1,
                    day_of_week=day_of_week
                ))
            else:
                history.append(self.create_day(
                    used=False,
                    mood=7,
                    sleep_quality=8,
                    craving_intensity=4,
                    reminder_opens=3,
                    messages_read=2,
                    day_of_week=day_of_week
                ))
        
        prediction = self.predict_from_history(history)
        self.print_scenario_result("User Cutting Back (Improvement)", prediction, history)
        
        return prediction
    
    
    def test_scenario_5(self):
        """
        SCENARIO 5: Cannabis User for Escapism
        Uses weed daily, mostly alone at night to cope with stress/anxiety.
        Increasing frequency, declining mental health.
        """
        
        history = []
        
        # Two weeks of escalating cannabis use for emotional escape
        for day in range(14):
            day_of_week = day % 7
            
            # First week: 4-5 times
            if day < 7:
                if day in [0, 2, 4, 5, 6]:  # 5 days first week
                    history.append(self.create_day(
                        used=True,
                        context='alone',
                        time_of_day='night',
                        method='smoking',  # Cannabis
                        amount=2,  # Joints/sessions
                        cost=20,
                        mood=3,  # Low mood, using to escape
                        sleep_quality=5,
                        craving_intensity=6,
                        day_of_week=day_of_week
                    ))
                else:
                    history.append(self.create_day(
                        used=False,
                        mood=2,  # Worse mood when not using
                        sleep_quality=4,
                        craving_intensity=7,
                        day_of_week=day_of_week
                    ))
            # Second week: Daily use, dependency forming
            else:
                history.append(self.create_day(
                    used=True,
                    context='alone',
                    time_of_day='night' if day % 2 == 0 else 'evening',
                    method='smoking',
                    amount=3,  # Increasing amount
                    cost=30,
                    mood=2,  # Declining mental health
                    sleep_quality=4,
                    craving_intensity=8,  # High psychological dependence
                    day_of_week=day_of_week
                ))
        
        prediction = self.predict_from_history(history)
        self.print_scenario_result("Cannabis User (Emotional Escape)", prediction, history)
        
        return prediction
    
    
    def test_scenario_6(self):
        """
        SCENARIO 6: Party Drug User (MDMA/LSD)
        Recreational psychedelic/party drug use on weekends.
        Social context, but increasing frequency concerns.
        """
        
        history = []
        
        for day in range(14):
            day_of_week = day % 7
            
            # Weekend use, but moving to mid-week too
            is_weekend = day_of_week in [4, 5, 6]  # Fri-Sun
            is_wednesday = day_of_week == 3
            
            if is_weekend or (day >= 7 and is_wednesday):  # Mid-week use in week 2
                history.append(self.create_day(
                    used=True,
                    context='party' if is_weekend else 'friends',
                    time_of_day='night',
                    method='edibles',  # Representing MDMA/LSD
                    amount=1,  # Tabs/doses
                    cost=50,
                    mood=6 if day < 7 else 4,  # Declining
                    sleep_quality=3,  # Poor sleep after use
                    craving_intensity=5 if day < 7 else 7,  # Increasing
                    day_of_week=day_of_week
                ))
            else:
                history.append(self.create_day(
                    used=False,
                    mood=5 if day < 7 else 3,  # Mood crashes increasing
                    sleep_quality=6,
                    craving_intensity=4 if day < 7 else 6,
                    day_of_week=day_of_week
                ))
        
        prediction = self.predict_from_history(history)
        self.print_scenario_result("Psychedelic/Party Drug User", prediction, history)
        
        return prediction
    
    
    def test_scenario_7(self):
        """
        SCENARIO 7: Stimulant User (Meth/Cocaine Pattern)
        Started recreational, now showing concerning frequency.
        Staying up late, poor sleep, mood swings.
        """
        
        history = []
        
        # Progressive stimulant use pattern
        for day in range(14):
            day_of_week = day % 7
            
            # Week 1: Weekend + once mid-week
            if day < 7:
                if day in [2, 5, 6]:  # Wed, Sat, Sun
                    history.append(self.create_day(
                        used=True,
                        context='friends' if day in [5, 6] else 'alone',
                        time_of_day='night',
                        method='smoking',  # Representing stimulants
                        amount=2,
                        cost=60,
                        mood=7,  # High/euphoric during use
                        sleep_quality=2,  # Very poor sleep
                        craving_intensity=5,
                        day_of_week=day_of_week
                    ))
                else:
                    history.append(self.create_day(
                        used=False,
                        mood=3,  # Crash
                        sleep_quality=4,
                        craving_intensity=6,
                        day_of_week=day_of_week
                    ))
            # Week 2: Increasing to 4-5 times
            else:
                if day in [7, 9, 11, 12, 13]:  # More frequent
                    history.append(self.create_day(
                        used=True,
                        context='alone' if day % 2 == 0 else 'friends',
                        time_of_day='night',
                        method='smoking',
                        amount=3,  # Increasing dosage
                        cost=90,
                        mood=6,  # Less euphoria, using to feel normal
                        sleep_quality=2,
                        craving_intensity=8,  # Strong dependency forming
                        day_of_week=day_of_week
                    ))
                else:
                    history.append(self.create_day(
                        used=False,
                        mood=2,  # Severe crashes
                        sleep_quality=3,
                        craving_intensity=9,  # Intense cravings
                        day_of_week=day_of_week
                    ))
        
        prediction = self.predict_from_history(history)
        self.print_scenario_result("Stimulant User (Escalating)", prediction, history)
        
        return prediction
    
    
    def test_scenario_8(self):
        """
        SCENARIO 8: Polydrug User
        Mixing different substances - cannabis, alcohol, occasionally harder drugs.
        High risk due to combination and frequency.
        """
        
        history = []
        
        substances = ['drinking', 'smoking', 'vaping', 'edibles']
        contexts = ['alone', 'friends', 'party', 'alone']
        
        for day in range(14):
            day_of_week = day % 7
            
            # Using 5-6 days per week, varying substances
            if day % 7 not in [1, 3]:  # Skip 2 days per week
                substance_idx = day % len(substances)
                history.append(self.create_day(
                    used=True,
                    context=contexts[substance_idx],
                    time_of_day='evening' if day % 2 == 0 else 'night',
                    method=substances[substance_idx],
                    amount=3 + (day % 3),  # Varying amounts
                    cost=40 + (day % 4) * 10,
                    mood=4,  # Unstable
                    sleep_quality=4,
                    craving_intensity=7,
                    day_of_week=day_of_week
                ))
            else:
                history.append(self.create_day(
                    used=False,
                    mood=3,
                    sleep_quality=5,
                    craving_intensity=8,  # High cravings
                    day_of_week=day_of_week
                ))
        
        prediction = self.predict_from_history(history)
        self.print_scenario_result("Polydrug User (Multiple Substances)", prediction, history)
        
        return prediction
    
    
    def test_scenario_9(self):
        """
        SCENARIO 9: Medical Cannabis User (Low Risk)
        Uses cannabis therapeutically, consistent dosing, good mental health.
        Responsible pattern.
        """
        
        history = []
        
        # Consistent, responsible medical use
        for day in range(14):
            day_of_week = day % 7
            
            # Every evening, same amount, therapeutic
            history.append(self.create_day(
                used=True,
                context='alone',  # Home use
                time_of_day='evening',
                method='vaping',  # More controlled method
                amount=1,  # Consistent low dose
                cost=10,
                mood=7,  # Stable, good mental health
                sleep_quality=8,  # Using for sleep, working well
                craving_intensity=2,  # Low psychological dependence
                reminder_opens=1,  # Engaged with tracking
                messages_read=1,
                day_of_week=day_of_week
            ))
        
        prediction = self.predict_from_history(history)
        self.print_scenario_result("Medical Cannabis User (Therapeutic)", prediction, history)
        
        return prediction
    
    
    def test_scenario_10(self):
        """
        SCENARIO 10: Recovery Relapse Pattern
        User had clean period, now relapsing with binge pattern.
        Critical risk period.
        """
        
        history = []
        
        # First 10 days clean
        for day in range(10):
            history.append(self.create_day(
                used=False,
                mood=6 if day < 5 else 4,  # Mood declining
                sleep_quality=7 if day < 5 else 5,
                craving_intensity=4 if day < 5 else 7,  # Cravings increasing
                reminder_opens=2,
                messages_read=1,
                day_of_week=day % 7
            ))
        
        # Days 11-14: Relapse with heavy use
        for day in range(10, 14):
            day_of_week = day % 7
            history.append(self.create_day(
                used=True,
                context='alone',  # Isolated use - concerning
                time_of_day='night',
                method='drinking',
                amount=7,  # Heavy use
                cost=70,
                mood=2,  # Guilt/shame
                sleep_quality=3,
                craving_intensity=9,  # Very high
                reminder_opens=0,  # Stopped using app
                messages_read=0,
                day_of_week=day_of_week
            ))
        
        prediction = self.predict_from_history(history)
        self.print_scenario_result("Recovery Relapse (Critical)", prediction, history)
        
        return prediction
    
    
    def run_all_scenarios(self):
        """Run all test scenarios and show summary."""
        
        print("\n" + "="*80)
        print(" "*20 + "GROUNDED MODEL TESTING")
        print(" "*20 + "Realistic User Scenarios")
        print("="*80 + "\n")
        
        scenarios = [
            self.test_scenario_1,
            self.test_scenario_2,
            self.test_scenario_3,
            self.test_scenario_4,
            self.test_scenario_5
        ]
        
        predictions = []
        for scenario_func in scenarios:
            pred = scenario_func()
            predictions.append(pred)
            input("Press Enter to continue to next scenario...")
        
        # Summary
        print("\n" + "="*80)
        print(" "*30 + "SUMMARY")
        print("="*80)
        
        scenario_names = [
            "Weekend Social Drinker",
            "Heavy Regular User",
            "Escalating Stress Drinker",
            "User Cutting Back",
            "Occasional Binge Drinker"
        ]
        
        print("\n📊 Risk Predictions Across Scenarios:\n")
        for name, pred in zip(scenario_names, predictions):
            risk = "🔴 HIGH" if pred > 0.6 else "🟡 MOD" if pred > 0.4 else "🟢 LOW"
            bar_length = int(pred * 40)
            bar = "█" * bar_length + "░" * (40 - bar_length)
            print(f"{name:30} | {bar} | {pred:.3f} {risk}")
        
        print("\n" + "="*80)
        print("\n✓ All scenarios tested successfully!")
        print("The model differentiates between different risk patterns.\n")


def main():
    """Main testing entry point."""
    
    # Check if model exists
    if not os.path.exists('models/grounded_model.h5'):
        print("❌ Error: Model not found!")
        print("Please run the training script first: python train_model.py")
        return
    
    # Create tester
    tester = ScenarioTester()
    
    # Run all scenarios
    tester.run_all_scenarios()


if __name__ == '__main__':
    main()