import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grand_egyptian_museum/models/hall_model.dart';
import 'package:grand_egyptian_museum/services/api_service.dart';
import 'package:grand_egyptian_museum/theme/app_theme.dart';
import 'package:grand_egyptian_museum/utils/app_events.dart';
import 'package:image_picker/image_picker.dart';


class HallEditTab extends StatefulWidget {
  const HallEditTab({super.key});

  @override
  State<HallEditTab> createState() => _HallEditTabState();
}

class _HallEditTabState extends State<HallEditTab> {
  List<HallModel> halls = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final h = await ApiService.getHalls();
    setState(() {
      halls = h;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }

    return RefreshIndicator(
      onRefresh: load,
      color: AppColors.gold,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: halls.length,
        itemBuilder: (_, i) => HallEditCard(
          hall: halls[i],
          onUpdated: load,
        ),
      ),
    );
  }
}

// ─────────────────────────────
// CARD
// ─────────────────────────────

class HallEditCard extends StatefulWidget {
  final HallModel hall;
  final VoidCallback onUpdated;

  const HallEditCard({
    super.key,
    required this.hall,
    required this.onUpdated,
  });

  @override
  State<HallEditCard> createState() => _HallEditCardState();
}

class _HallEditCardState extends State<HallEditCard> {
  bool editing = false;
  bool saving = false;

  File? selectedImage;
  final picker = ImagePicker();

  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController densityCtrl;
  late TextEditingController urlCtrl;

  @override
  void initState() {
    super.initState();

    nameCtrl = TextEditingController(text: widget.hall.name);
    descCtrl = TextEditingController(text: widget.hall.fullDescription);

    // 👇 عدّل اسم الحقل حسب الموديل عندك
    densityCtrl = TextEditingController(
      text: widget.hall.capacity?.toString() ?? "0",
    );

    urlCtrl = TextEditingController(text: widget.hall.imageUrl);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    densityCtrl.dispose();
    urlCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        urlCtrl.clear();
      });
    }
  }

  Future<void> save() async {
    setState(() => saving = true);

    try {
      final data = {
        "name": nameCtrl.text.trim(),
        "description": descCtrl.text.trim(),

        // 👇 density / capacity
        "capacity": int.tryParse(densityCtrl.text.trim()) ?? 0,

        if (urlCtrl.text.isNotEmpty)
          "imageUrl": urlCtrl.text.trim(),
      };

      await ApiService.updateHall(widget.hall.id, data);

      AppEvents.emit(AppEventTypes.hallsUpdated);
      AppEvents.emit(AppEventTypes.logsUpdated);

      widget.onUpdated();

      setState(() => editing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Updated Successfully ✅"),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    setState(() => saving = false);
  }

  Widget buildImage() {
    if (selectedImage != null) {
      return Image.file(
        selectedImage!,
        width: double.infinity,
        height: 170,
        fit: BoxFit.cover,
      );
    }

    final url = urlCtrl.text.isNotEmpty ? urlCtrl.text : widget.hall.imageUrl;
    return Image.network(
      url,
      width: double.infinity,
      height: 170,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: double.infinity,
        height: 170,
        color: Colors.black26,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, color: Colors.white30, size: 48),
            SizedBox(height: 8),
            Text('Image not available', style: TextStyle(color: Colors.white30, fontSize: 12)),
          ],
        ),
      ),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          width: double.infinity,
          height: 170,
          color: Colors.black26,
          child: const Center(child: CircularProgressIndicator(color: Colors.white30, strokeWidth: 2)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppDecorations.card,
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── IMAGE ──
          Stack(
            children: [
              buildImage(),

              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => setState(() => editing = !editing),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: editing ? Colors.redAccent : AppColors.gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      editing ? "Cancel" : "Edit",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── CONTENT ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: editing
                ? Column(
              children: [

                // NAME
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    hintText: "Hall Name",
                  ),
                ),

                const SizedBox(height: 10),

                // DESCRIPTION
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Description",
                  ),
                ),

                const SizedBox(height: 10),

                // DENSITY / CAPACITY
                TextField(
                  controller: densityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Capacity / Density",
                  ),
                ),

                const SizedBox(height: 10),

                // IMAGE URL
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    hintText: "Image URL",
                  ),
                  onChanged: (_) {
                    setState(() => selectedImage = null);
                  },
                ),

                const SizedBox(height: 10),


                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving ? null : save,
                    child: saving
                        ? const CircularProgressIndicator(
                        color: Colors.white)
                        : const Text("Save"),
                  ),
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hall.name,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.hall.fullDescription,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Capacity: ${widget.hall.capacity}",
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
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