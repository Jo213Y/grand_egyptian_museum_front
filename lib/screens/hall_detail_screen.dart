import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/button.dart';
import '../widgets/img_error.dart';
import '../models/hall_model.dart';
import '../models/exhibition_model.dart';
import '../services/api_service.dart';
import 'booking_screen.dart';

class HallDetailScreen extends StatefulWidget {
  final HallModel hall;
  const HallDetailScreen({super.key, required this.hall});

  @override
  State<HallDetailScreen> createState() => _HallDetailScreenState();
}

class _HallDetailScreenState extends State<HallDetailScreen> {
  List<ExhibitionModel> exhibitions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadExhibitions();
  }

  Future<void> _loadExhibitions() async {
    try {
      final data = await ApiService.getHallExhibitions(widget.hall.id);
      setState(() {
        exhibitions = data.map((e) => ExhibitionModel.fromJson(e)).toList();
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFF0D0A05),
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.6),
          iconTheme: const IconThemeData(color: AppColors.gold),
          title: Text(widget.hall.name,
              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18),
              overflow: TextOverflow.ellipsis),
        ),
        body: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Hero Image ───────────────────────────────────
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(fit: StackFit.expand, children: [
                GemNetworkImage(widget.hall.imageUrl, fit: BoxFit.cover),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20, left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Hall ${widget.hall.id}  •  Capacity: ${widget.hall.capacity}',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Hall Info ────────────────────────────────
                Text(widget.hall.name,
                    style: const TextStyle(color: AppColors.gold,
                        fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(widget.hall.shortDescription,
                    style: const TextStyle(color: AppColors.primaryLight,
                        fontSize: 15, fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
                const Text('About this Hall',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(widget.hall.fullDescription,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.7)),
                const SizedBox(height: 32),

                // ── Exhibitions ──────────────────────────────
                const Text('Exhibitions',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(width: 50, height: 3,
                    decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),

                if (loading)
                  const Center(child: CircularProgressIndicator(color: AppColors.gold))
                else if (exhibitions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('No exhibitions available for this hall',
                          style: TextStyle(color: Colors.white38)),
                    ),
                  )
                else
                  ...exhibitions.map((ex) => _exhibitionSection(ex)),

                const SizedBox(height: 32),

                // ── Book Button ──────────────────────────────
                GemButton(
                  label: 'Book Your Visit',
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => BookingScreen(preselectedHallId: widget.hall.id))),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Exhibition Section ────────────────────────────────────
  Widget _exhibitionSection(ExhibitionModel ex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Exhibition name
        Row(children: [
          Container(width: 4, height: 22,
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(
            child: Text(ex.name,
                style: const TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 8),

        // Exhibition description
        if (ex.description.isNotEmpty)
          Text(ex.description,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6)),
        const SizedBox(height: 16),

        // Artifact cards
        if (ex.artifacts.isNotEmpty)
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ex.artifacts.length,
              itemBuilder: (_, i) => _artifactCard(ex.artifacts[i]),
            ),
          ),
      ]),
    );
  }

  // ── Artifact Card ─────────────────────────────────────────
  Widget _artifactCard(ArtifactModel art) {
    return GestureDetector(
      onTap: () => _showArtifactDetail(art),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Image
          SizedBox(
            height: 110,
            width: double.infinity,
            child: art.imageUrl.isNotEmpty
                ? Image.network(
              art.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imagePlaceholder(),
              loadingBuilder: (_, child, p) =>
              p == null ? child : _imagePlaceholder(loading: true),
            )
                : _imagePlaceholder(),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(art.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                if (art.historicalPeriod.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(art.historicalPeriod,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.gold, fontSize: 10)),
                  ),
                const SizedBox(height: 4),
                Text(art.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _imagePlaceholder({bool loading = false}) {
    return Container(
      color: Colors.white.withOpacity(0.05),
      child: Center(
        child: loading
            ? const CircularProgressIndicator(color: Colors.white24, strokeWidth: 2)
            : const Icon(Icons.image_outlined, color: Colors.white24, size: 32),
      ),
    );
  }

  // ── Artifact Detail Bottom Sheet ──────────────────────────
  void _showArtifactDetail(ArtifactModel art) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A0A00),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Handle
            Center(child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            )),

            // Image
            if (art.imageUrl.isNotEmpty)
              Image.network(art.imageUrl,
                  width: double.infinity, height: 220, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(art.name,
                    style: const TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (art.historicalPeriod.isNotEmpty) ...[
                  Row(children: [
                    const Icon(Icons.history, color: AppColors.gold, size: 16),
                    const SizedBox(width: 6),
                    Text(art.historicalPeriod,
                        style: const TextStyle(color: AppColors.primaryLight, fontSize: 13)),
                  ]),
                  const SizedBox(height: 12),
                ],
                const Text('Description',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(art.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.7)),
                const SizedBox(height: 20),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}