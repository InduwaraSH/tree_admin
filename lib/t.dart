import 'dart:ui';
import 'package:admin/branchRequestApprove_ARM.dart';
import 'package:admin/branchRequestApprove_RM.dart';
import 'package:admin/dashboardui.dart';
import 'package:admin/personRequestApprove.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  final List<String> menuItems = [
    "Dashboard",
    "Apps",
    "Pages",
  ];

  /// 🔥 Content switcher
  Widget getSelectedContent() {
     switch (selectedIndex) {
      case 0:
        return const DashboardUI();
      case 1:
        return const Branchrequestapprove_ARM();
      case 2:
        return const Branchrequestapprove_RM();

      case 3:
        return const personrequest();
      default:
        return const Center(child: Text("Page Not Found"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FD),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 230,
            margin: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Title
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "Minia",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Menu
                      Expanded(
                        child: ListView.builder(
                          itemCount: menuItems.length,
                          itemBuilder: (context, index) {
                            bool isActive = index == selectedIndex;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.deepPurple.withOpacity(0.85)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      height: 6,
                                      width: 6,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isActive
                                            ? Colors.white
                                            : Colors.transparent,
                                      ),
                                    ),
                                    Text(
                                      menuItems[index],
                                      style: GoogleFonts.poppins(
                                        color: isActive
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.85),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Area
          Expanded(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.2, 0),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Text(
                          menuItems[selectedIndex],
                          key: ValueKey<int>(selectedIndex),
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // 🔥 Main Content (smooth switch)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: getSelectedContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}