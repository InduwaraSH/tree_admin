import 'dart:ui';
import 'package:admin/person_reg_new.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardUI extends StatefulWidget {
  const DashboardUI({super.key});

  @override
  State<DashboardUI> createState() => _DashboardUIState();
}

class _DashboardUIState extends State<DashboardUI> {
  int? hoveredIndex;

  // Firebase reference
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(
    "Ongoing_Count",
  );

  Map<String, int> cityOngoing = {};
  int totalOngoing = 0;
  late Stream<DatabaseEvent> _ongoingStream;

  @override
  void initState() {
    super.initState();
    // Listen to realtime changes
    _ongoingStream = dbRef.onValue;
    _ongoingStream.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<String, dynamic> data = Map<String, dynamic>.from(
          snapshot.value as Map,
        );
        int total = 0;
        Map<String, int> temp = {};

        data.forEach((city, values) {
          int ongoing = 0;
          if (values is Map && values["ongoing"] != null) {
            ongoing = values["ongoing"];
          }
          temp[city] = ongoing;
          total += ongoing;
        });

        setState(() {
          cityOngoing = temp;
          totalOngoing = total;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20), // padding only for content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Stats Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final cardData = [
                    {
                      "title": "Ongoing Tasks",
                      "value": totalOngoing.toString(),
                      "icon": Icons.autorenew_rounded,
                      "gradient": const LinearGradient(
                        colors: [Color(0xFF6D5DF6), Color(0xFF8E7CFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    },
                    {
                      "title": "Completed Jobs",
                      "value": "6258",
                      "icon": Icons.emoji_events,
                      "negative": true,
                      "gradient": const LinearGradient(
                        colors: [Color(0xFFFFA751), Color(0xFFFFD452)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    },
                    {
                      "title": "This Year Revenue",
                      "value": "Rs 4.32M",
                      "icon": Icons.attach_money,
                      "gradient": const LinearGradient(
                        colors: [Color(0xFF00C9A7), Color(0xFF92FE9D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    },
                    {
                      "title": "Danger Zone",
                      "value": "5 ",
                      "icon": Icons.timelapse,
                      "gradient": const LinearGradient(
                        colors: [Color(0xFFEE5253), Color(0xFFFF7676)],
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
                        negative: data["negative"] as bool? ?? false,
                        icon: data["icon"] as IconData,
                        gradient: data["gradient"] as Gradient,
                        isFocused: hoveredIndex == index,
                        isBlurred:
                            hoveredIndex != null && hoveredIndex != index,
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
              SizedBox(height: 60),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: CityOngoingCard(cityOngoing: cityOngoing)),
                  const SizedBox(width: 16),

                  //personrequest_new(),
                  const SizedBox(width: 16),
                ],
              ),
              const SizedBox(height: 100),

              // Bottom Row
            ],
          ),
        ),
      ),
    );
  }
}

/// DashboardCard widget
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
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
      duration: const Duration(milliseconds: 900),
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
          ],
        ),
      ),
    );

    cardContent = AnimatedScale(
      scale: isFocused ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      child: cardContent,
    );

    if (isBlurred) {
      cardContent = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 3),
        duration: const Duration(milliseconds: 700),
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

/// City Ongoing Card
class CityOngoingCard extends StatefulWidget {
  final Map<String, int> cityOngoing;
  const CityOngoingCard({super.key, required this.cityOngoing});

  @override
  State<CityOngoingCard> createState() => _CityOngoingCardState();
}

class _CityOngoingCardState extends State<CityOngoingCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: isHovered ? 25 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.cityOngoing.length,
              itemBuilder: (context, index) {
                String city = widget.cityOngoing.keys.elementAt(index);
                int ongoing = widget.cityOngoing[city]!;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        city,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ongoing.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Hoverable Card
class HoverCard extends StatefulWidget {
  final Widget child;
  final Gradient? gradient;

  const HoverCard({super.key, required this.child, this.gradient});

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: widget.gradient == null ? Colors.white : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: isHovered ? 25 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
