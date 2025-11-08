/// Comprehensive notification message dictionary for Grounded
/// Organized by type, context, and emotional tone
class NotificationMessages {
  // ============================================
  // 🎯 LAYER 1: DESCRIPTIVE (Mirror behavior)
  // ============================================

  static const Map<String, List<String>> descriptive = {
    'weekly_summary': [
      "You logged {count} entries this week — that's awareness in action.",
      "This week: {count} check-ins. You're building a clear picture.",
      "{count} logs this week. Every entry is data you can learn from.",
      "You tracked {count} times this week. That takes intention.",
    ],
    'pattern_noticed': [
      "You tend to use around {time} on {days}.",
      "Most of your use happens {context} — just noticing.",
      "Your entries show a pattern: {frequency} use, mostly {when}.",
      "{amount} on average per session — staying consistent.",
    ],
    'cost_tracking': [
      "You spent ₹{amount} this week on {substance}.",
      "This month's total: ₹{amount}. Just the facts.",
      "Cost per use averaged ₹{amount} this week.",
    ],
  };

  // ============================================
  // 🌍 LAYER 2: CONTEXTUAL (When/where patterns)
  // ============================================

  static const Map<String, List<String>> contextual = {
    'time_based': [
      "You often use after {time} — perhaps when {reason}.",
      "Evening sessions are your pattern, usually around {time}.",
      "{day} nights seem to be your rhythm.",
      "After work hours on weekdays — maybe when stress peaks?",
    ],
    'location_based': [
      "Home is where you use most — {percentage}% of the time.",
      "Weekend use is more social, weekday use more solitary.",
      "You tend to use at {location} when {context}.",
      "Alone at home after 9 PM — that's your usual setup.",
    ],
    'social_context': [
      "You use alone {percentage}% of the time, with others {percentage}%.",
      "Social weekends, solo weekdays — two different patterns.",
      "Friends are present in {count} of your last {total} logs.",
      "Your solo sessions happen mostly at night.",
    ],
    'trigger_context': [
      "{trigger} appears before {percentage}% of your sessions.",
      "Stress + evening = your most common combo.",
      "Boredom peaks on {days} based on your logs.",
      "You marked '{trigger}' {count} times this month.",
    ],
  };

  // ============================================
  // 💚 LAYER 3: EMOTIONAL (How you feel)
  // ============================================

  static const Map<String, List<String>> emotional = {
    'stress_anxiety': [
      "You often log stress before using — maybe it helps you decompress?",
      "Stress appears a lot lately. Using might be your release valve.",
      "You've marked 'stressed' before most sessions — that's real.",
      "Your mood drops to {score}/10 around now. That pattern is showing up.",
    ],
    'boredom': [
      "Boredom shows up before {percentage}% of your use. Seeking stimulation?",
      "You've marked 'bored' {count} times — maybe you're craving something new?",
      "'Nothing to do' seems to trigger use. Your brain wants engagement.",
      "Boredom + free time = your common pattern right now.",
    ],
    'loneliness': [
      "You often use when alone and feeling low. Connection might help?",
      "Loneliness appears in {count} recent entries. That's heavy.",
      "Solo evenings feel tough sometimes — your logs show that.",
      "Emotional pain + being alone = when you reach for it most.",
    ],
    'celebration': [
      "Happy moments trigger use too — rewards can look different ways.",
      "You use when celebrating {percentage}% of the time. That's your joy ritual.",
      "Good news leads to use sometimes. Enjoying success in your way.",
    ],
    'energy_mood': [
      "Your energy scores seem lower after late-night use. Sleep playing a role?",
      "Mood before: {before}/10. After: {after}/10. Tracking the shift.",
      "You feel {emotion} before most sessions lately.",
      "Low energy days coincide with {pattern} — just noticing.",
    ],
  };

  // ============================================
  // 🧠 LAYER 4: INTERPRETIVE (Why it happens)
  // ============================================

  static const Map<String, List<String>> interpretive = {
    'stress_relief': [
      "You might be using to transition from work mode to rest mode.",
      "It seems substances help you flip the 'off' switch after long days.",
      "Your pattern suggests using is how you process stress buildup.",
      "Could be your brain's way of saying 'I need a break from intensity.'",
    ],
    'routine_habit': [
      "This might be less about cravings, more about routine timing.",
      "Your body expects it at {time} — that's habit memory at work.",
      "The pattern is so consistent, it's become part of your daily rhythm.",
      "Automatic use happens when routines are strong — yours definitely is.",
    ],
    'social_bonding': [
      "Using socially might be how you connect and feel part of the group?",
      "It's how you participate in social moments — your belonging ritual.",
      "Friends + substance = your version of quality time together.",
      "Could be less about the substance, more about the shared experience.",
    ],
    'emotional_regulation': [
      "Substances might be your current tool for managing big emotions.",
      "When feelings build up, using is how you create distance from them.",
      "Could be your brain seeking relief when emotional load gets heavy.",
      "You might rely on this when other coping tools feel out of reach.",
    ],
    'reward_system': [
      "Your pattern suggests substances are a reward for productivity.",
      "'I worked hard, I earned this' — that's what the data shows.",
      "Using might be how you celebrate making it through tough days.",
      "Could be your brain's way of saying 'good job, here's your payoff.'",
    ],
    'sleep_aid': [
      "It seems using before bed helps you shut down racing thoughts?",
      "Your mind might rely on this to transition into sleep mode.",
      "Late-night use patterns suggest difficulty winding down naturally.",
      "Could be filling a gap where sleep routines used to be.",
    ],
  };

  // ============================================
  // 🔮 LAYER 5: PREDICTIVE (What's coming)
  // ============================================

  static const Map<String, List<String>> predictive = {
    'time_based_warning': [
      "Heads up: {time} is your usual craving window. Expect it?",
      "Based on patterns, tonight around {time} might feel triggering.",
      "Historically, {day} evenings show highest use. Awareness today?",
      "Your use tends to spike {when}. Just a gentle heads up.",
    ],
    'stress_prediction': [
      "Stress usually builds midweek for you. Feeling it already?",
      "Based on your pattern, today might feel heavier. Check in?",
      "Wednesdays are tough in your logs. Extra support today?",
      "You often mark stress on {days}. How's today looking?",
    ],
    'social_weekend': [
      "Weekends show more use in your data. Set intentions before Friday?",
      "Social plans coming up? Your use increases {percentage}% in groups.",
      "Friday nights are high-use times for you. Plan ahead?",
      "Weekend use is typically {amount} more than weekdays for you.",
    ],
    'financial_alert': [
      "Cost usually spikes after social weekends. Consider a budget?",
      "Based on patterns, you might spend ₹{amount} this weekend.",
      "Your monthly spend peaks around now. Track it?",
      "End-of-month means higher use in your data. Awareness helps.",
    ],
    'mood_forecast': [
      "After periods of better sleep, your use drops. Rest helps?",
      "Low-mood days often follow heavy-use nights. That cycle showing up?",
      "Energy crashes happen {days} after high use for you.",
      "When you skip {days}, mood improves. Pattern worth noting?",
    ],
  };

  // ============================================
  // 🛠️ LAYER 6: SUPPORTIVE (Coping tools)
  // ============================================

  static const Map<String, List<String>> supportive = {
    'breathing_prompts': [
      "Stress feels high? Try 5 minutes of breathing before deciding.",
      "Your body needs a reset. 3-minute breathing break?",
      "Before using, want to try box breathing? (4-4-4-4)",
      "Ground yourself first: 5 deep breaths, then decide.",
    ],
    'alternative_activities': [
      "Music, walking, or journaling could help too. Want options?",
      "Try something different for 10 minutes first?",
      "Movement helps mood. Quick walk before you decide?",
      "Distraction toolkit: music, call a friend, stretch, or journal?",
    ],
    'mindful_pause': [
      "Before using, ask: 'What do I actually need right now?'",
      "Take a minute to notice: How does your body feel?",
      "Pause and reflect: Is this habit or craving?",
      "Check in with yourself first: Physical need or emotional need?",
    ],
    'social_support': [
      "Want to text {contact_name} before using?",
      "Your support person is available. Reach out first?",
      "Calling someone might shift things. {contact_name}?",
      "You don't have to decide alone. Want to connect first?",
    ],
    'harm_reduction': [
      "If you're using tonight: hydrate, set limits, stay safe.",
      "Using with others? Make sure someone knows your plan.",
      "Set a timer for {amount} — stick to your intention.",
      "Test it first if you can. Safer use = better use.",
    ],
    'delay_technique': [
      "Wait 15 minutes, then decide. The urge might pass.",
      "Delay, don't deny: try {activity} for 10 minutes first.",
      "Give yourself 20 minutes before committing to use.",
      "Surf the craving: it peaks and falls. Can you ride it out?",
    ],
  };

  // ============================================
  // 🌟 LAYER 7: REFLECTIVE (Growth & meaning)
  // ============================================

  static const Map<String, List<String>> reflective = {
    'progress_monthly': [
      "Over the last month, your awareness has grown — you're logging consistently.",
      "You seem to use more intentionally now — fewer automatic patterns.",
      "A month in: You're noticing triggers sooner. That's growth.",
      "Your data shows less impulsive use. You're learning your rhythm.",
    ],
    'pattern_mastery': [
      "You're getting better at catching patterns before they happen.",
      "Self-awareness is the foundation. You're building it every day.",
      "You understand your triggers now. That knowledge is power.",
      "Knowing your 'why' changes everything. You're figuring it out.",
    ],
    'autonomy_reinforcement': [
      "You're learning your rhythm. That's harm reduction at its core.",
      "Every check-in is a choice. You're practicing agency.",
      "You decide what works for you. We just reflect it back.",
      "This isn't about stopping — it's about understanding. You're doing it.",
    ],
    'milestone_celebration': [
      "{days} days of consistent logging. Awareness is the first step.",
      "You've reduced use by {percentage}% without trying to quit. That's real change.",
      "First mindful week complete. You're building something sustainable.",
      "{achievement} unlocked — you're making progress your way.",
    ],
  };

  // ============================================
  // 🎉 POSITIVE REINFORCEMENT (After logging)
  // ============================================

  static const Map<String, List<String>> positiveReinforcement = {
    'mindful_day': [
      "🌿 Mindful day logged. You're building awareness, not perfection.",
      "✨ Noticed the urge, chose differently. That's strength.",
      "🧘 Today you practiced presence over autopilot. Beautiful.",
      "💚 A day of intentional choice. You're learning your power.",
      "🌱 Every mindful moment counts. This one definitely did.",
      "🎯 You showed up for yourself today. That matters.",
      "⭐ Awareness without action is still awareness. You're growing.",
      "🌟 Today's log shows you're paying attention. That's everything.",
    ],
    'reduced_usage': [
      "📉 Less than usual today — that's adaptation in real time.",
      "💪 You used less than your average. Intentional moderation is hard.",
      "🎨 Smaller amount, same awareness. You're learning control.",
      "🌙 Reduced use logged. You're finding your sustainable rhythm.",
      "✅ Below your baseline today. That's conscious choice.",
      "🔥 Cut back without cutting out. That's harm reduction working.",
      "🌸 Less is more sometimes. You proved it today.",
      "💎 Moderation is a skill. You're practicing it.",
    ],
    'used_day': [
      "📝 Logged honestly. That's what matters most.",
      "🙏 You showed up and tracked it. No judgment, just data.",
      "💚 Honest logging builds self-knowledge. You're doing the work.",
      "🌊 Every entry helps you see patterns. This one counts.",
      "✨ You used today AND you tracked it. That's awareness.",
      "🧭 The log itself is the win. You're staying present.",
      "🌿 Using doesn't erase progress. You're still learning.",
      "💪 You came back to log it. That's accountability.",
      "🎯 Honesty over perfection. You're building trust with yourself.",
      "📊 Another data point in understanding you. Keep going.",
    ],
    'streak_milestone': [
      "🔥 {days} day streak! Consistency builds momentum.",
      "⭐ {days} days of logging. Your commitment shows.",
      "🎉 {days} consecutive check-ins. That's dedication.",
      "💪 {days}-day tracking streak. You're creating real change.",
      "🌟 {days} days strong. Awareness is your superpower now.",
    ],
    'weekly_checkin': [
      "📅 Another week tracked. You're building a powerful data story.",
      "🌱 Week {number} complete. Every entry teaches you something.",
      "💚 Weekly check-in done. You're staying connected to yourself.",
      "✨ That's {total} total logs now. Your self-knowledge is growing.",
    ],
  };

  // ============================================
  // 🚨 CRISIS & SAFETY (Emergency support)
  // ============================================

  static const Map<String, List<String>> crisis = {
    'high_risk_detected': [
      "⚠️ This session looks different from your pattern. Everything okay?",
      "🆘 Want to reach out to {contact_name}? They're available.",
      "💚 You don't have to go through this alone. Need support?",
      "🔴 This feels heavy. Crisis resources are one tap away.",
    ],
    'overdose_prevention': [
      "⚠️ Using alone tonight? Make sure someone knows.",
      "🆘 Have Narcan nearby? Your safety matters most.",
      "💚 Test your stuff if you can. Harm reduction saves lives.",
      "🔴 Set a check-in timer. We're here if you need us.",
    ],
    'emotional_crisis': [
      "💚 You marked 'crisis mode.' I'm here. Want to talk to {contact_name}?",
      "🆘 Emotional pain is real pain. Crisis line: {number}",
      "🔴 You don't have to feel this alone. Reach out?",
      "💚 Dark thoughts showing up? Let's connect you with support.",
    ],
  };

  // ============================================
  // 🎯 GOAL-BASED NOTIFICATIONS
  // ============================================

  static const Map<String, List<String>> goalBased = {
    'financial_goals': [
      "💰 You've saved ₹{amount} vs. your baseline. That's {item} worth!",
      "📊 Spending down {percentage}% this month. Progress is visible.",
      "🎯 {days} days until your budget resets. You've got ₹{remaining} left.",
      "💎 On track to save ₹{amount} this month. Your goal is working.",
    ],
    'health_goals': [
      "💪 {days} days of better sleep logged. Recovery matters.",
      "🏃 You've reduced {substance} by {percentage}% this month.",
      "🌱 Physical symptoms decreasing based on your logs.",
      "❤️ Your health markers are improving. Keep noticing.",
    ],
    'relationship_goals': [
      "👥 More social logs this week. Connection increases.",
      "💚 {contact_name} checked in {count} times. Support is working.",
      "🤝 Less isolation in your pattern now. Relationships matter.",
      "✨ You're being more present with others. They notice.",
    ],
    'motivation_goals': [
      "🎯 {percentage}% toward your {timeline} goal.",
      "🔥 {days} days of consistent effort. Momentum builds.",
      "⭐ You're {percentage}% more mindful than when you started.",
      "💪 Progress isn't linear, but you're trending upward.",
    ],
  };

  // ============================================
  // 🕐 TIME-BASED CONTEXTUAL PROMPTS
  // ============================================

  static const Map<String, List<String>> timeContextual = {
    'morning': [
      "☀️ Morning check-in: How did last night go?",
      "🌅 New day, new data. How are you feeling?",
      "☕ Morning reflection: What's your intention today?",
      "🌞 Starting fresh. What does today need?",
    ],
    'afternoon': [
      "🌤️ Midday check-in: How's your energy?",
      "☀️ Afternoon pause: What's your body telling you?",
      "🍃 Halfway through the day. How are you managing?",
      "⏰ Quick pulse check: Stress level right now?",
    ],
    'evening': [
      "🌙 Evening approaches — your usual craving time. Ready?",
      "🌆 Winding down. What does tonight need?",
      "🌃 High-use window starting. Check in with yourself?",
      "🌛 Evening routine beginning. Stay aware.",
    ],
    'night': [
      "🌙 Late night check-in: How are you really doing?",
      "✨ Before bed: Worth logging today?",
      "🌃 Night session? Remember your intentions.",
      "🌛 Late use often impacts tomorrow. Aware of that?",
    ],
    'weekend': [
      "🎉 Weekend starts — your pattern shifts now.",
      "🥳 Social plans today? Remember your limits.",
      "🌴 Weekend use is different for you. Stay mindful?",
      "🍻 Social context coming — check your intentions?",
    ],
  };

  // ============================================
  // 📊 DATA-DRIVEN INSIGHTS (From actual logs)
  // ============================================

  static const Map<String, List<String>> dataDriven = {
    'frequency_change': [
      "📈 Use increased {percentage}% this week vs. last. Notice anything?",
      "📉 Down {count} sessions from last week. What changed?",
      "📊 Same frequency, but amounts are {direction}. Pattern shift?",
      "🔄 Your rhythm changed: {old_pattern} → {new_pattern}",
    ],
    'amount_change': [
      "📏 Average amount: {old} → {new}. That's {percentage}% {direction}.",
      "🎯 You used {amount} less per session this month.",
      "📊 Amounts are creeping up lately. Worth noticing?",
      "💎 Smaller doses, same frequency. Harm reduction in action.",
    ],
    'mood_correlation': [
      "😊 Your mood improved on days you {action}.",
      "📉 Mood drops after {pattern}. See the link?",
      "🔗 {trigger} + {action} = mood change of {value} points.",
      "💭 Best mood days: when you {positive_pattern}.",
    ],
    'trigger_analysis': [
      "🎯 {trigger} appeared {count} times. That's {percentage}% of entries.",
      "🔍 New trigger emerging: '{trigger}' x {count} this week.",
      "📊 Your #1 trigger: {trigger}. #2: {trigger2}.",
      "🎭 Triggers are clustering: {trigger1} + {trigger2} = use.",
    ],
  };

  // ============================================
  // 🎓 EDUCATIONAL MICRO-LESSONS
  // ============================================

  static const Map<String, List<String>> educational = {
    'harm_reduction_tips': [
      "💡 Tip: Hydration reduces next-day impact. Water nearby?",
      "🧠 Did you know: Testing takes 5 minutes but saves lives.",
      "⏰ Harm reduction: Setting time limits helps maintain control.",
      "🔍 Lower doses, longer breaks = sustainable use pattern.",
    ],
    'tolerance_awareness': [
      "📚 Tolerance builds: What worked before needs more now. Notice it?",
      "🧪 Your baseline keeps shifting. That's tolerance in action.",
      "⚠️ Needing more to feel the same? Classic tolerance pattern.",
      "🔬 Breaks reset tolerance. Your data shows it working.",
    ],
    'withdrawal_info': [
      "💭 Irritability + poor sleep = common withdrawal signs.",
      "🌊 Cravings peak days 2-4, then decrease. Ride the wave.",
      "💪 Physical symptoms are temporary. Your logs show it passing.",
      "🧠 Brain chemistry rebalancing takes time. Be patient.",
    ],
    'mindful_use': [
      "🎯 Intention before action = mindful use in practice.",
      "🧘 Notice the difference: habitual vs. intentional use.",
      "💭 'Do I want this or do I expect this?' — powerful question.",
      "✨ Awareness transforms use from automatic to conscious.",
    ],
  };

  // ============================================
  // 🎊 CELEBRATION & MILESTONES
  // ============================================

  static const Map<String, List<String>> celebrations = {
    'first_week': [
      "🎉 One week of logging! Self-awareness is growing.",
      "⭐ 7 days tracked. You're building something real.",
      "🌟 First week complete. This is how change starts.",
      "💪 Week 1 done. Data is power — you're collecting it.",
    ],
    'first_month': [
      "🎊 One month in! Your patterns are clear now.",
      "🏆 30 days of awareness. This is sustainable change.",
      "🌟 Month 1 complete. You've learned so much about yourself.",
      "💎 4 weeks tracked. Your self-knowledge is deep now.",
    ],
    'cost_savings': [
      "💰 You've saved ₹{amount} this month. That's {comparison}!",
      "🎯 ₹{amount} not spent = {item} you could buy instead.",
      "💎 Financial impact: -{percentage}% spending. Real money saved.",
      "🏆 ₹{total} saved since starting. That's {milestone}!",
    ],
    'reduction_success': [
      "🎉 {percentage}% reduction in {timeframe}. You're doing it!",
      "⭐ From {old_amount} to {new_amount}. That's real progress.",
      "💪 Moderation goal achieved: {achievement}!",
      "🌟 {metric} improved by {percentage}%. Growth is visible.",
    ],
  };
}
