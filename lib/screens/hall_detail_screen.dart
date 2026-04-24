import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/button.dart';
import '../widgets/common_widgets.dart';
import '../models/hall_model.dart';
import '../widgets/img_error.dart';
import 'booking_screen.dart';

class HallDetailScreen extends StatelessWidget {
  final HallModel hall;
  const HallDetailScreen({super.key, required this.hall});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.6),
          iconTheme: const IconThemeData(color: AppColors.gold),
          title: Text(hall.name,
              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18),
              overflow: TextOverflow.ellipsis),
        ),
        body: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Hero image
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(fit: StackFit.expand, children: [
                GemNetworkImage(hall.imageUrl, fit: BoxFit.cover),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
                Positioned(bottom: 20, left: 20, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Hall ${hall.id}  •  Capacity: ${hall.capacity}',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                )),
              ]),
            ),
      
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Hall name
                Text(hall.name,
                    style: const TextStyle(color: AppColors.gold,
                        fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                const SizedBox(height: 4),
                Text(hall.shortDescription,
                    style: const TextStyle(color: AppColors.primaryLight,
                        fontSize: 15, fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
      
                // Full description
                const Text('About this Hall',
                    style: TextStyle(color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(hall.fullDescription,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.7)),
                const SizedBox(height: 24),
      
                // Artifacts list
                if (hall.artifacts.isNotEmpty) ...[
                  const Text('Key Exhibits',
                      style: TextStyle(color: Colors.white,
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...hall.artifacts.map((a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                                color: AppColors.gold, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(a,
                              style: const TextStyle(color: Colors.white70, fontSize: 14))),
                        ]),
                      )),
                  const SizedBox(height: 32),
                ],
      
                // Book button
                GemButton(
                  label: 'Book Your Visit',
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => BookingScreen(preselectedHallId: hall.id))),
                ),
              ]),
            ),
          ]),
        ),
        backgroundColor: const Color(0xFF0D0A05),
      ),
    );
  }
}
