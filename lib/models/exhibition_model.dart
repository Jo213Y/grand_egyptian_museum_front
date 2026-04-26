class ArtifactModel {
  final int    id;
  final String name;
  final String historicalPeriod;
  final String description;
  final String imageUrl;

  const ArtifactModel({
    required this.id,
    required this.name,
    required this.historicalPeriod,
    required this.description,
    required this.imageUrl,
  });

  factory ArtifactModel.fromJson(Map<String, dynamic> j) => ArtifactModel(
    id:               j['Artifact_id'] ?? j['artifactId'] ?? 0,
    name:             j['Art_name']    ?? j['artName']    ?? '',
    historicalPeriod: j['Historical_period'] ?? j['historicalPeriod'] ?? '',
    description:      j['Art_description']   ?? j['artDescription']  ?? '',
    imageUrl:         j['image_url']         ?? j['imageUrl']        ?? '',
  );
}

class ExhibitionModel {
  final int              id;
  final String           name;
  final String           description;
  final String           imageUrl;
  final List<ArtifactModel> artifacts;

  const ExhibitionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.artifacts,
  });

  factory ExhibitionModel.fromJson(Map<String, dynamic> j) => ExhibitionModel(
    id:          j['Exhibition_id']          ?? j['exhibitionId']   ?? 0,
    name:        j['Exhibition_name']         ?? j['exhibitionName'] ?? '',
    description: j['Exhibition_description']  ?? j['description']   ?? '',
    imageUrl:    j['image_url']               ?? j['imageUrl']      ?? '',
    artifacts:   (j['artifacts'] as List? ?? [])
        .map((a) => ArtifactModel.fromJson(a))
        .toList(),
  );
}