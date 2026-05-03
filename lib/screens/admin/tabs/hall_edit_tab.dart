import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grand_egyptian_museum/models/hall_model.dart';
import 'package:grand_egyptian_museum/models/exhibition_model.dart';
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
  bool showExhibitions = false;
  List<ExhibitionModel> exhibitions = [];
  bool loadingExhibitions = false;

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


    densityCtrl = TextEditingController(
      text: widget.hall.capacity?.toString() ?? "0",
    );

    urlCtrl = TextEditingController(text: widget.hall.imageUrl);
  }

  Future<void> loadExhibitions() async {
    setState(() => loadingExhibitions = true);
    try {
      final data = await ApiService.getHallExhibitions(widget.hall.id, showHidden: true);
      setState(() {
        exhibitions = data.map((e) => ExhibitionModel.fromJson(e)).toList();
        loadingExhibitions = false;
      });
    } catch (_) {
      setState(() => loadingExhibitions = false);
    }
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
        "capacity": int.tryParse(densityCtrl.text.trim()) ?? 0,
        if (urlCtrl.text.isNotEmpty)
          "imageUrl": urlCtrl.text.trim(),
      };

      if (selectedImage != null) {
        await ApiService.uploadHallImage(widget.hall.id, selectedImage!);
      }

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
          // ── EXHIBITIONS SECTION ──────────────────────────
          if (!editing) ...[
            const Divider(color: Colors.white10),
            InkWell(
              onTap: () {
                setState(() => showExhibitions = !showExhibitions);
                if (showExhibitions && exhibitions.isEmpty) loadExhibitions();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.museum, color: AppColors.gold, size: 18),
                    const SizedBox(width: 8),
                    const Text('Exhibitions & Artifacts',
                        style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Icon(showExhibitions ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white38),
                  ],
                ),
              ),
            ),
            if (showExhibitions) ...[
              if (loadingExhibitions)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
                )
              else if (exhibitions.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Row(
                    children: [
                      const Text('No exhibitions yet',
                          style: TextStyle(color: Colors.white38, fontSize: 13)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _addExhibitionDialog(),
                        icon: const Icon(Icons.add, size: 16, color: AppColors.gold),
                        label: const Text('Add', style: TextStyle(color: AppColors.gold)),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    children: [
                      ...exhibitions.map((ex) => _exhibitionAdminCard(ex)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _addExhibitionDialog(),
                          icon: const Icon(Icons.add, color: AppColors.gold, size: 16),
                          label: const Text('Add Exhibition',
                              style: TextStyle(color: AppColors.gold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.gold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }

  // ── Exhibition admin card ─────────────────────────────────
  Widget _exhibitionAdminCard(ExhibitionModel ex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.collections, color: AppColors.gold, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(ex.name,
                    style: const TextStyle(color: AppColors.gold,
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              TextButton.icon(
                onPressed: () => _addArtifactDialog(ex),
                icon: const Icon(Icons.add, size: 14, color: Colors.white54),
                label: const Text('Add Artifact',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
              ),
            ],
          ),
          if (ex.description.isNotEmpty)
            Text(ex.description,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          if (ex.artifacts.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...ex.artifacts.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white10,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: a.imageUrl.isNotEmpty
                        ? Image.network(a.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported, color: Colors.white24, size: 18))
                        : const Icon(Icons.image_not_supported, color: Colors.white24, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.name,
                            style: TextStyle(
                                color: a.isHidden ? Colors.white38 : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                decoration: a.isHidden ? TextDecoration.lineThrough : null)),
                        Text(a.historicalPeriod,
                            style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                  // Edit button
                  IconButton(
                    onPressed: () => _editArtifactDialog(a),
                    icon: const Icon(Icons.edit, size: 16, color: Colors.white38),
                    tooltip: 'Edit',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  // Hide/Show button
                  IconButton(
                    onPressed: () async {
                      try {
                        await ApiService.toggleArtifactVisibility(a.id);
                        await loadExhibitions();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed: \$e'), backgroundColor: Colors.red),
                        );
                        }
                      }
                    },
                    icon: Icon(
                      a.isHidden ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: a.isHidden ? Colors.white24 : Colors.white54,
                    ),
                    tooltip: a.isHidden ? 'Show' : 'Hide',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  // ── Add Exhibition Dialog ─────────────────────────────────
  Future<void> _addExhibitionDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imgCtrl  = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A00),
        title: const Text('Add Exhibition', style: TextStyle(color: AppColors.gold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(nameCtrl, 'Exhibition Name', Icons.collections),
            const SizedBox(height: 10),
            _field(descCtrl, 'Description', Icons.description, lines: 2),
            const SizedBox(height: 10),
            _field(imgCtrl, 'Image URL (optional)', Icons.image),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(context, true);
            },
            child: const Text('Add', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await ApiService.addExhibition(
        hallId:      widget.hall.id,
        name:        nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        imageUrl:    imgCtrl.text.trim(),
      );
      await loadExhibitions();
      AppEvents.emit(AppEventTypes.logsUpdated);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: \$e'), backgroundColor: Colors.red),
      );
    }
  }

  // ── Add Artifact Dialog ───────────────────────────────────
  Future<void> _addArtifactDialog(ExhibitionModel ex) async {
    final nameCtrl   = TextEditingController();
    final periodCtrl = TextEditingController();
    final descCtrl   = TextEditingController();
    final imgCtrl    = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A00),
        title: Text('Add Artifact to "${ex.name}"',
            style: const TextStyle(color: AppColors.gold, fontSize: 14)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameCtrl,   'Artifact Name',     Icons.auto_awesome),
              const SizedBox(height: 10),
              _field(periodCtrl, 'Historical Period',  Icons.history),
              const SizedBox(height: 10),
              _field(descCtrl,   'Description',        Icons.description, lines: 2),
              const SizedBox(height: 10),
              _field(imgCtrl,    'Image URL',          Icons.image),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(context, true);
            },
            child: const Text('Add', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await ApiService.addArtifact(
        exhibitionId:    ex.id,
        name:            nameCtrl.text.trim(),
        historicalPeriod: periodCtrl.text.trim(),
        description:     descCtrl.text.trim(),
        imageUrl:        imgCtrl.text.trim(),
      );
      await loadExhibitions();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: \$e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _editArtifactDialog(ArtifactModel a) async {
    final nameCtrl   = TextEditingController(text: a.name);
    final periodCtrl = TextEditingController(text: a.historicalPeriod);
    final descCtrl   = TextEditingController(text: a.description);
    final imgCtrl    = TextEditingController(text: a.imageUrl);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A00),
        title: const Text('Edit Artifact', style: TextStyle(color: AppColors.gold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameCtrl,   'Artifact Name',    Icons.auto_awesome),
              const SizedBox(height: 10),
              _field(periodCtrl, 'Historical Period', Icons.history),
              const SizedBox(height: 10),
              _field(descCtrl,   'Description',       Icons.description, lines: 3),
              const SizedBox(height: 10),
              _field(imgCtrl,    'Image URL',         Icons.image),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(context, true);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await ApiService.updateArtifact(
        artifactId:      a.id,
        name:            nameCtrl.text.trim(),
        historicalPeriod: periodCtrl.text.trim(),
        description:     descCtrl.text.trim(),
        imageUrl:        imgCtrl.text.trim(),
      );
      await loadExhibitions();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artifact updated ✅'), backgroundColor: AppColors.primary),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: \$e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {int lines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: lines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: AppColors.gold, size: 18),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white24)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.gold)),
      ),
    );
  }
}