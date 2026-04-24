class ArtifactModel {
  final int? id;
  final String name;
  final String description;
  final String imageUrl;
  final String? material;

  const ArtifactModel({
    this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.material,
  });

  factory ArtifactModel.fromJson(Map<String, dynamic> j) => ArtifactModel(
    id: j['id'],
    name: j['name'] ?? '',
    description: j['description'] ?? '',
    imageUrl: (j['imageUrl'] != null && (j['imageUrl'] as String).isNotEmpty)
        ? j['imageUrl']
        : 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Tutankhamun_Egyptian_Museum.jpg/640px-Tutankhamun_Egyptian_Museum.jpg',
    material: j['material'],
  );

  /// لو الـ backend بيرجع اسم بس (String)، نحوّله لـ ArtifactModel
  factory ArtifactModel.fromString(String name) => ArtifactModel(
    name: name,
    description: 'A remarkable piece from the museum collection.',
    imageUrl:
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Tutankhamun_Egyptian_Museum.jpg/640px-Tutankhamun_Egyptian_Museum.jpg',
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    if (material != null) 'material': material,
  };

  ArtifactModel copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    String? material,
  }) =>
      ArtifactModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        material: material ?? this.material,
      );
}