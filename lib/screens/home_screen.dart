// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//   String _fcmToken = '';
//   int _currentIndex = 0;
//   List<Map<String, dynamic>> _recentActivities = [];
//   Map<String, dynamic> _userStats = {};

//   late AnimationController _navBarAnimationController;
//   late AnimationController _fabAnimationController;
//   late Animation<double> _fabScaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//     _getFCMToken();

//     _navBarAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _fabAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );

//     _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
//       CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
//     );

//     _navBarAnimationController.forward();
//   }

//   @override
//   void dispose() {
//     _navBarAnimationController.dispose();
//     _fabAnimationController.dispose();
//     super.dispose();
//   }

//   void _initializeData() {
//     _recentActivities = [
//       {
//         'title': 'Welcome to Grounded',
//         'description': 'You successfully signed in',
//         'time': 'Just now',
//         'icon': Icons.login,
//         'color': Colors.green,
//       },
//       {
//         'title': 'Notification Enabled',
//         'description': 'Push notifications are active',
//         'time': '2 min ago',
//         'icon': Icons.notifications_active,
//         'color': Colors.blue,
//       },
//       {
//         'title': 'Profile Updated',
//         'description': 'Your profile is complete',
//         'time': '5 min ago',
//         'icon': Icons.person,
//         'color': Colors.orange,
//       },
//     ];

//     _userStats = {
//       'streak': 7,
//       'goals_completed': 12,
//       'points': 450,
//       'level': 3,
//     };
//   }

//   Future<void> _getFCMToken() async {
//     try {
//       String? token = await FirebaseMessaging.instance.getToken();
//       setState(() {
//         _fcmToken = token ?? 'No token available';
//       });
//     } catch (e) {
//       setState(() {
//         _fcmToken = 'Error getting token: $e';
//       });
//     }
//   }

//   Widget _buildHeader(bool isDark) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: isDark
//               ? [Colors.grey.shade800, Colors.grey.shade700]
//               : [Colors.blue.shade700, Colors.blue.shade400],
//         ),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const CircleAvatar(
//                 radius: 30,
//                 backgroundImage: NetworkImage(
//                   'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
//                 ),
//               ),
//               IconButton(
//                 onPressed: _showNotificationSettings,
//                 icon: const Icon(
//                   Icons.notifications,
//                   color: Colors.white,
//                   size: 30,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 15),
//           const Text(
//             'Welcome back,',
//             style: TextStyle(color: Colors.white70, fontSize: 16),
//           ),
//           const Text(
//             'Alex Johnson!',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Stay grounded, stay focused',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.8),
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsCard(bool isDark) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: isDark ? Colors.grey.shade800 : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Text(
//             'Your Progress',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: isDark ? Colors.white : Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildStatItem(
//                 Icons.local_fire_department,
//                 'Streak',
//                 '${_userStats['streak']} days',
//                 Colors.orange,
//                 isDark,
//               ),
//               _buildStatItem(
//                 Icons.flag,
//                 'Goals',
//                 '${_userStats['goals_completed']}',
//                 Colors.green,
//                 isDark,
//               ),
//               _buildStatItem(
//                 Icons.emoji_events,
//                 'Points',
//                 '${_userStats['points']}',
//                 Colors.blue,
//                 isDark,
//               ),
//               _buildStatItem(
//                 Icons.star,
//                 'Level',
//                 '${_userStats['level']}',
//                 Colors.purple,
//                 isDark,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(
//     IconData icon,
//     String title,
//     String value,
//     Color color,
//     bool isDark,
//   ) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: color, size: 24),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: isDark ? Colors.white : Colors.black87,
//           ),
//         ),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 12,
//             color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRecentActivity(bool isDark) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Recent Activity',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: isDark ? Colors.white : Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ..._recentActivities.map(
//             (activity) => _buildActivityItem(activity, isDark),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActivityItem(Map<String, dynamic> activity, bool isDark) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       color: isDark ? Colors.grey.shade800 : Colors.white,
//       child: ListTile(
//         leading: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: activity['color'].withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(activity['icon'], color: activity['color']),
//         ),
//         title: Text(
//           activity['title'],
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color: isDark ? Colors.white : Colors.black87,
//           ),
//         ),
//         subtitle: Text(
//           activity['description'],
//           style: TextStyle(
//             color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//           ),
//         ),
//         trailing: Text(
//           activity['time'],
//           style: TextStyle(
//             fontSize: 12,
//             color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFCMTokenSection(bool isDark) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'FCM Token (For Testing)',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//               color: isDark ? Colors.white : Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _fcmToken,
//             style: TextStyle(
//               fontSize: 12,
//               fontFamily: 'Monospace',
//               color: isDark ? Colors.grey.shade300 : Colors.black87,
//             ),
//             maxLines: 3,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: _getFCMToken,
//                   icon: const Icon(Icons.refresh, size: 16),
//                   label: const Text('Refresh Token'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue.shade50,
//                     foregroundColor: Colors.blue,
//                     elevation: 0,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () => _copyToClipboard(_fcmToken),
//                   icon: const Icon(Icons.copy, size: 16),
//                   label: const Text('Copy'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green.shade50,
//                     foregroundColor: Colors.green,
//                     elevation: 0,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _copyToClipboard(String text) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Token copied to clipboard!'),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showNotificationSettings() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Notification Settings'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildNotificationSettingItem('Push Notifications', true),
//             _buildNotificationSettingItem('Email Notifications', false),
//             _buildNotificationSettingItem('SMS Alerts', false),
//             _buildNotificationSettingItem('Daily Reminders', true),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNotificationSettingItem(String title, bool value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title),
//         Switch(value: value, onChanged: (newValue) {}),
//       ],
//     );
//   }

//   void _showAddDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Add New Item'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.flag, color: Colors.green),
//               title: const Text('New Goal'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.task, color: Colors.blue),
//               title: const Text('New Task'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.notification_add, color: Colors.orange),
//               title: const Text('New Reminder'),
//               onTap: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody(bool isDark) {
//     switch (_currentIndex) {
//       case 0:
//         return SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildHeader(isDark),
//               _buildStatsCard(isDark),
//               _buildRecentActivity(isDark),
//               _buildFCMTokenSection(isDark),
//               const SizedBox(height: 20),
//             ],
//           ),
//         );
//       case 1:
//         return Center(
//           child: Text(
//             'Analytics',
//             style: TextStyle(
//               fontSize: 24,
//               color: isDark ? Colors.white : Colors.black87,
//             ),
//           ),
//         );
//       case 2:
//         return Center(
//           child: Text(
//             'Profile',
//             style: TextStyle(
//               fontSize: 24,
//               color: isDark ? Colors.white : Colors.black87,
//             ),
//           ),
//         );
//       case 3:
//         return _buildSettingsTab(isDark);
//       default:
//         return Container();
//     }
//   }

//   Widget _buildSettingsTab(bool isDark) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Settings',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 24),
//             _buildSettingsSection('Appearance', [
//               _buildThemeSelector(isDark),
//             ], isDark),
//             const SizedBox(height: 16),
//             _buildSettingsSection('Notifications', [
//               _buildSettingsTile(
//                 'Push Notifications',
//                 'Receive app notifications',
//                 Icons.notifications_outlined,
//                 true,
//                 isDark,
//               ),
//               _buildSettingsTile(
//                 'Daily Reminders',
//                 'Get reminded to check in',
//                 Icons.alarm,
//                 true,
//                 isDark,
//               ),
//             ], isDark),
//             const SizedBox(height: 16),
//             _buildSettingsSection('Privacy', [
//               _buildSettingsTile(
//                 'Analytics',
//                 'Help improve the app',
//                 Icons.analytics_outlined,
//                 true,
//                 isDark,
//               ),
//               _buildSettingsTile(
//                 'Motivational Messages',
//                 'Receive encouraging messages',
//                 Icons.emoji_objects_outlined,
//                 true,
//                 isDark,
//               ),
//             ], isDark),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSettingsSection(
//     String title,
//     List<Widget> children,
//     bool isDark,
//   ) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? Colors.grey.shade800 : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//             ),
//           ),
//           ...children,
//         ],
//       ),
//     );
//   }

//   Widget _buildThemeSelector(bool isDark) {
//     return FutureBuilder<String>(
//       future: _getThemePreference(),
//       builder: (context, snapshot) {
//         String currentTheme = snapshot.data ?? 'System';
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.palette_outlined,
//                     color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
//                   ),
//                   const SizedBox(width: 12),
//                   Text(
//                     'Theme',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Wrap(
//                 spacing: 12,
//                 children: ['System', 'Light', 'Dark'].map((theme) {
//                   final isSelected = currentTheme == theme;
//                   return GestureDetector(
//                     onTap: () => _setThemePreference(theme),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 12,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? const Color(0xFF2196F3)
//                             : (isDark
//                                   ? Colors.grey.shade700
//                                   : Colors.grey.shade100),
//                         borderRadius: BorderRadius.circular(25),
//                         border: Border.all(
//                           color: isSelected
//                               ? const Color(0xFF2196F3)
//                               : (isDark
//                                     ? Colors.grey.shade600
//                                     : Colors.grey.shade300),
//                           width: 2,
//                         ),
//                       ),
//                       child: Text(
//                         theme,
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: isSelected
//                               ? Colors.white
//                               : (isDark ? Colors.white : Colors.grey.shade800),
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 12),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSettingsTile(
//     String title,
//     String subtitle,
//     IconData icon,
//     bool value,
//     bool isDark,
//   ) {
//     return ListTile(
//       leading: Icon(
//         icon,
//         color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//           fontWeight: FontWeight.w600,
//           color: isDark ? Colors.white : Colors.black87,
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: TextStyle(
//           fontSize: 12,
//           color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//         ),
//       ),
//       trailing: Switch(
//         value: value,
//         onChanged: (newValue) {},
//         activeColor: const Color(0xFF4CAF50),
//       ),
//     );
//   }

//   Future<String> _getThemePreference() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('app_theme') ?? 'System';
//   }

//   Future<void> _setThemePreference(String theme) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('app_theme', theme);
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<String>(
//       future: _getThemePreference(),
//       builder: (context, snapshot) {
//         String themeMode = snapshot.data ?? 'System';
//         bool isDark =
//             themeMode == 'Dark' ||
//             (themeMode == 'System' &&
//                 MediaQuery.of(context).platformBrightness == Brightness.dark);

//         return Scaffold(
//           backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
//           appBar: AppBar(
//             title: const Text('Grounded'),
//             backgroundColor: isDark
//                 ? Colors.grey.shade800
//                 : Colors.blue.shade700,
//             foregroundColor: Colors.white,
//             elevation: 0,
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.settings),
//                 onPressed: () {
//                   setState(() => _currentIndex = 3);
//                 },
//               ),
//             ],
//           ),
//           body: _buildBody(isDark),
//           floatingActionButton: ScaleTransition(
//             scale: _fabScaleAnimation,
//             child: FloatingActionButton(
//               onPressed: () {
//                 _fabAnimationController.forward().then((_) {
//                   _fabAnimationController.reverse();
//                 });
//                 _showAddDialog();
//               },
//               backgroundColor: isDark
//                   ? Colors.blue.shade600
//                   : Colors.blue.shade700,
//               foregroundColor: Colors.white,
//               child: const Icon(Icons.add),
//             ),
//           ),
//           floatingActionButtonLocation:
//               FloatingActionButtonLocation.centerDocked,
//           bottomNavigationBar: _AnimatedBottomNavBar(
//             currentIndex: _currentIndex,
//             onTap: (index) {
//               setState(() => _currentIndex = index);
//             },
//             isDark: isDark,
//           ),
//         );
//       },
//     );
//   }
// }

// class _AnimatedBottomNavBar extends StatefulWidget {
//   final int currentIndex;
//   final Function(int) onTap;
//   final bool isDark;

//   const _AnimatedBottomNavBar({
//     required this.currentIndex,
//     required this.onTap,
//     required this.isDark,
//   });

//   @override
//   State<_AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
// }

// class _AnimatedBottomNavBarState extends State<_AnimatedBottomNavBar>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
//     _controller.forward();
//   }

//   @override
//   void didUpdateWidget(_AnimatedBottomNavBar oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.currentIndex != widget.currentIndex) {
//       _controller.reset();
//       _controller.forward();
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       {'icon': Icons.home_rounded, 'label': 'Home'},
//       {'icon': Icons.analytics_rounded, 'label': 'Analytics'},
//       {'icon': Icons.person_rounded, 'label': 'Profile'},
//       {'icon': Icons.more_horiz_rounded, 'label': 'More'},
//     ];

//     return Container(
//       decoration: BoxDecoration(
//         color: widget.isDark ? Colors.grey.shade800 : Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Container(
//           height: 70,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: List.generate(items.length, (index) {
//               if (index == 2) {
//                 return const SizedBox(width: 56);
//               }
//               final adjustedIndex = index > 2 ? index - 1 : index;
//               return _NavBarItem(
//                 icon: items[adjustedIndex]['icon'] as IconData,
//                 label: items[adjustedIndex]['label'] as String,
//                 isSelected: widget.currentIndex == adjustedIndex,
//                 onTap: () => widget.onTap(adjustedIndex),
//                 animation: _animation,
//                 isDark: widget.isDark,
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _NavBarItem extends StatefulWidget {
//   final IconData icon;
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;
//   final Animation<double> animation;
//   final bool isDark;

//   const _NavBarItem({
//     required this.icon,
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//     required this.animation,
//     required this.isDark,
//   });

//   @override
//   State<_NavBarItem> createState() => _NavBarItemState();
// }

// class _NavBarItemState extends State<_NavBarItem>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
//       CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => _scaleController.forward(),
//       onTapUp: (_) {
//         _scaleController.reverse();
//         widget.onTap();
//       },
//       onTapCancel: () => _scaleController.reverse(),
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: widget.isSelected
//                 ? (widget.isDark
//                       ? Colors.blue.shade700.withOpacity(0.2)
//                       : Colors.blue.shade50)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//                 child: Icon(
//                   widget.icon,
//                   color: widget.isSelected
//                       ? (widget.isDark
//                             ? Colors.blue.shade300
//                             : Colors.blue.shade700)
//                       : (widget.isDark
//                             ? Colors.grey.shade400
//                             : Colors.grey.shade600),
//                   size: widget.isSelected ? 28 : 24,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               AnimatedDefaultTextStyle(
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//                 style: TextStyle(
//                   fontSize: widget.isSelected ? 12 : 11,
//                   fontWeight: widget.isSelected
//                       ? FontWeight.w600
//                       : FontWeight.w500,
//                   color: widget.isSelected
//                       ? (widget.isDark
//                             ? Colors.blue.shade300
//                             : Colors.blue.shade700)
//                       : (widget.isDark
//                             ? Colors.grey.shade400
//                             : Colors.grey.shade600),
//                 ),
//                 child: Text(widget.label),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
