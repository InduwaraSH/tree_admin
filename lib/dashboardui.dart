import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardUI extends StatefulWidget {
  const DashboardUI({super.key});

  @override
  State<DashboardUI> createState() => _DashboardUIState();
}

class _DashboardUIState extends State<DashboardUI> {
  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Stats Cards with hover effect
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final cardData = [
                {
                  "title": "My Wallet",
                  "value": "\$865.2k",
                  "change": "+20.9k",
                  "icon": Icons.account_balance_wallet,
                  "gradient": const LinearGradient(
                    colors: [Color(0xFF6D5DF6), Color(0xFF8E7CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                },
                {
                  "title": "Number of Trades",
                  "value": "6258",
                  "change": "-29 Trades",
                  "icon": Icons.swap_vert,
                  "negative": true,
                  "gradient": const LinearGradient(
                    colors: [Color(0xFFEE5253), Color(0xFFFF7676)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                },
                {
                  "title": "Invested Amount",
                  "value": "\$4.32M",
                  "change": "+2.8k",
                  "icon": Icons.trending_up,
                  "gradient": const LinearGradient(
                    colors: [Color(0xFF00C9A7), Color(0xFF92FE9D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                },
                {
                  "title": "Profit Ratio",
                  "value": "12.57%",
                  "change": "+2.95%",
                  "icon": Icons.pie_chart,
                  "gradient": const LinearGradient(
                    colors: [Color(0xFFFFA751), Color(0xFFFFD452)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                },
              ];

              final data = cardData[index];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 16),
                  child: DashboardCard(
                    title: data["title"] as String,
                    value: data["value"] as String,
                    change: data["change"] as String,
                    negative: data["negative"] as bool? ?? false,
                    icon: data["icon"] as IconData,
                    gradient: data["gradient"] as Gradient,
                    isFocused: hoveredIndex == index,
                    isBlurred: hoveredIndex != null && hoveredIndex != index,
                    onHover: (isHovering) {
                      setState(() {
                        hoveredIndex = isHovering ? index : null;
                      });
                    },
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Bottom Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: SizedBox(
                    height: 220,
                    child: Center(
                      child: Text(
                        "Wallet Balance Chart Placeholder",
                        style: GoogleFonts.poppins(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Invested Overview",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Invested Amount: \$6134.39",
                          style: GoogleFonts.poppins(),
                        ),
                        Text("Income: \$2632.46", style: GoogleFonts.poppins()),
                        Text(
                          "Expenses: -\$924.38",
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  color: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bitcoin News",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Bitcoin prices fell sharply amid the global sell-off...",
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// DashboardCard widget (with animation)
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool negative;
  final IconData icon;
  final Gradient gradient;
  final bool isFocused;
  final bool isBlurred;
  final Function(bool) onHover;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    this.negative = false,
    required this.icon,
    required this.gradient,
    required this.isFocused,
    required this.isBlurred,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isFocused ? Colors.black.withOpacity(0.3) : Colors.black12,
            blurRadius: isFocused ? 30 : 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              change,
              style: GoogleFonts.poppins(
                color: negative ? Colors.red[200] : Colors.greenAccent[100],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    cardContent = AnimatedScale(
      scale: isFocused ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: cardContent,
    );

    if (isBlurred) {
      cardContent = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 3),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: value, sigmaY: value),
              child: child,
            ),
          );
        },
        child: cardContent,
      );
    }

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: cardContent,
    );
  }
}
