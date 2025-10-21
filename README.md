# Grounded - Harm Reduction App

## 🌱 Vision
Grounded is a Flutter-based mobile application designed for **harm reduction, not quitting**. We provide personalized, non-judgmental support for users who want to develop a healthier relationship with substance use through awareness, pattern recognition, and mindful choices.

---

## 📱 Core Features

### 1. **Personal Tracking**
- Log substance use with detailed context:
  - Frequency and amount
  - Context (alone, friends, work, party, etc.)
  - Time of day and consumption method
  - Cost tracking
  - Emotional state (mood, cravings, sleep quality)

### 2. **AI-Powered Insights**
- **On-device ML model** predicts usage risk based on behavioral patterns
- Personalized, supportive notifications like:
  - "You might be out with friends — consider taking a little less."
  - "Late night patterns detected. Maybe try a different wind-down routine? 🌙"
- Privacy-first: All predictions run locally on your device
- [Technical Details: ML Model Documentation](grounded_ml_guide)

### 3. **Harm Reduction Tools**
- Set personal goals and timelines (not abstinence-focused)
- Track triggers and impacts
- Identify patterns in your behavior
- Support system integration
- Motivational messages and reminders

### 4. **Progress Visualization**
- Beautiful charts showing usage trends
- Context analysis (when/where/why patterns)
- Cost savings calculator
- Health impact insights
- Streak tracking for mindful days

### 5. **Privacy & Security**
- 100% on-device processing (no cloud required for basic features)
- Encrypted local storage
- Optional anonymized cloud insights for community patterns
- HIPAA & GDPR compliant
- No judgmental language or forced abstinence goals

---

## 💎 Subscription Tiers

### Free Tier
✅ Basic tracking (up to 1 substance)
✅ Manual logging
✅ Basic statistics
✅ 7-day pattern history
✅ Simple reminders
❌ AI predictions
❌ Unlimited substances
❌ Advanced analytics
❌ Cloud backup

### Premium - $4.99/month or $39.99/year (33% savings)
✅ **Everything in Free, plus:**
✅ AI-powered risk predictions
✅ Unlimited substances
✅ 90-day pattern history
✅ Advanced analytics & insights
✅ Custom notification messages
✅ Export data (CSV, PDF)
✅ Cloud backup & sync
✅ Priority support

### Lifetime - $79.99 one-time
✅ **All Premium features forever**
✅ Support app development
✅ No recurring charges
✅ Future feature updates included
✅ Early access to beta features

---

## 🛠️ Technical Architecture

### Frontend
- **Framework**: Flutter (cross-platform iOS & Android)
- **State Management**: Riverpod / Provider
- **Local Database**: Hive / SQLite (encrypted)
- **UI**: Material Design 3 with custom theming

### Machine Learning
- **Model**: Lightweight LSTM/GRU (32-64 units)
- **Framework**: TensorFlow Lite for Flutter
- **Size**: <500KB model, <50ms inference
- **Features**: 40+ behavioral & contextual inputs
- **Privacy**: Fully on-device processing
- 📚 [Comprehensive ML Documentation](grounded_ml_guide)

### Backend (Optional Cloud Features)
- **Platform**: Firebase / Supabase
- **Auth**: Email, Google, Apple Sign-In
- **Storage**: Encrypted cloud backup (opt-in)
- **Analytics**: Anonymized usage patterns only
- **Payments**: RevenueCat for subscription management

### Security
- AES-256 encryption for local data
- Secure storage for sensitive information
- No PII in cloud analytics
- User consent for all data sharing
- Right to delete all data

---

## 📊 Data Collection (For ML Model)

### User Inputs
- Frequency of use per substance
- Context of use (social, location, activity)
- Time of day patterns
- Consumption methods
- Amount and cost per session
- Motivation levels and personal goals
- Triggers and impacts

### Wellbeing Metrics
- Mood tracking (1-10 scale)
- Sleep quality
- Craving intensity
- Stress levels
- Support system availability

### App Interactions
- Reminder acknowledgments
- Motivational message engagement
- Journal entries (optional)
- Goal progress updates

All data stays **on-device by default**. Users can opt-in to share anonymized patterns to improve the community model.

---

## 🎯 User Journey

### Week 1: Onboarding & Learning
1. User creates account (or continues anonymously)
2. Adds substances they want to track
3. Sets personal goals (harm reduction focused)
4. Begins logging with simple reminders
5. App learns baseline patterns

### Week 2-3: Pattern Recognition
1. Rule-based suggestions (before ML has enough data)
2. Basic insights about usage context
3. Encouragement to log consistently
4. Introduction to harm reduction strategies

### Week 4+: AI-Powered Personalization
1. ML model activated with sufficient data
2. Personalized risk predictions
3. Contextual notifications ("You might be...")
4. Advanced pattern analysis
5. Customized intervention suggestions

---

## 🚀 Roadmap

### Phase 1: MVP (Months 1-3)
- [ ] Core tracking functionality
- [ ] Basic statistics and charts
- [ ] Simple reminders
- [ ] Encrypted local storage
- [ ] Free tier complete

### Phase 2: ML Integration (Months 3-4)
- [ ] Train and deploy TFLite model
- [ ] Implement on-device predictions
- [ ] Smart notifications
- [ ] Premium tier launch
- [ ] Subscription infrastructure

### Phase 3: Enhancement (Months 4-6)
- [ ] Advanced analytics dashboard
- [ ] Cloud backup (opt-in)
- [ ] Community insights (anonymized)
- [ ] Export features
- [ ] iOS & Android optimization

### Phase 4: Scale (Months 6-12)
- [ ] Federated learning for model improvement
- [ ] Wearable device integration
- [ ] Multi-language support
- [ ] Therapist/counselor portal (optional)
- [ ] Research partnerships

---

## 💰 Monetization Strategy

### Primary Revenue
- **Premium Subscriptions**: $4.99/month (target 10-15% conversion)
- **Annual Plans**: $39.99/year (target 30% of subscribers)
- **Lifetime**: $79.99 (one-time, for power users)

### Secondary Revenue (Future)
- B2B partnerships with harm reduction organizations
- Anonymized research data licensing (with user consent)
- White-label solutions for clinics

### Free Tier Strategy
- Limited but functional (build trust)
- Clear value proposition for premium
- No ads, ever
- Ethical monetization only

---

## 🎨 Design Principles

### 1. Non-Judgmental
- Positive, supportive language
- No shame or stigma
- Celebrate progress, not perfection
- Acknowledge harm reduction is valid

### 2. Privacy-First
- On-device by default
- Transparent about data use
- User control over all data
- No selling of personal information

### 3. Science-Backed
- Evidence-based harm reduction strategies
- Transparent about ML predictions
- Educational resources
- Partnership with health professionals

### 4. Accessible
- Clean, intuitive UI
- Support for diverse users
- Multiple language support (future)
- Accessibility features (screen readers, etc.)

---

## 📱 Target Platforms

### Launch
- iOS 14.0+
- Android 8.0+

### Future
- Web app (limited features)
- Apple Watch / Wear OS
- Desktop companion app

---

## 🤝 Community & Support

### In-App Support
- Comprehensive FAQ
- Interactive tutorials
- Crisis resources
- Direct support chat (Premium)

### External Resources
- Blog with harm reduction tips
- Scientific research references
- Community guidelines
- Partnership with harm reduction orgs

---

## 📈 Success Metrics

### User Engagement
- Daily active users (DAU)
- Weekly retention rate
- Average session length
- Feature adoption rates

### Health Outcomes
- Reduction in harmful usage patterns
- Improved wellbeing scores (mood, sleep)
- User-reported positive changes
- Goal achievement rates

### Business Metrics
- Free to Premium conversion (target: 10-15%)
- Monthly Recurring Revenue (MRR)
- Customer Lifetime Value (LTV)
- Churn rate (target: <5%/month)

### ML Performance
- Prediction accuracy (target: >75%)
- False positive rate (target: <20%)
- User satisfaction with predictions
- Model inference time (<50ms)

---

## 🔒 Legal & Compliance

### Disclaimers
- Not a medical device or treatment
- Not a replacement for professional help
- For informational purposes only
- Users should consult healthcare providers

### Compliance
- HIPAA (if handling health data in US)
- GDPR (European users)
- CCPA (California users)
- App Store & Play Store guidelines
- Substance use policy compliance

### Terms of Service
- Clear data usage policies
- User rights and responsibilities
- Subscription terms
- Content moderation policies

---

## 🌟 Differentiators

**vs Traditional Recovery Apps:**
- ✅ Harm reduction vs abstinence only
- ✅ No shame or judgment
- ✅ AI-powered personalization
- ✅ Privacy-first architecture

**vs Generic Habit Trackers:**
- ✅ Substance-specific insights
- ✅ Predictive risk modeling
- ✅ Evidence-based harm reduction
- ✅ Community support

**vs Therapy Apps:**
- ✅ Self-directed and affordable
- ✅ On-device ML for immediate insights
- ✅ Complements professional care
- ✅ No waitlists or appointments

---

## 📞 Contact & Resources

- **Website**: [coming soon]
- **Email**: support@grounded.app
- **Documentation**: [Technical ML Guide](grounded_ml_guide)
- **Privacy Policy**: [link]
- **Terms of Service**: [link]

---

## 🙏 Mission Statement

Grounded believes that **harm reduction is a valid, evidence-based approach** to substance use. We empower users to make informed, mindful choices without judgment. Our technology respects your privacy while providing personalized support on your journey toward a healthier relationship with substances.

**Your data. Your choices. Your journey.** 🌱

---

*Last Updated: October 2025*

## Licensed Icons by:
<!-- Fluent Emoji by Microsoft
Licensed under MIT License
https://github.com/microsoft/fluentui-emoji -->