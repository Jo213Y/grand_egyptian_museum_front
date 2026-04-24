class HallModel {
  final int id;
  final String name;
  final String shortDescription;
  final String fullDescription;
  final String imageUrl;
  final List<String> artifacts;
  final int capacity;

  const HallModel({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.fullDescription,
    required this.imageUrl,
    required this.artifacts,
    required this.capacity,
  });

  factory HallModel.fromJson(Map<String, dynamic> j) => HallModel(
        id: j['id'] ?? 0,
        name: j['name'] ?? '',
        // الـ museum_project مش فيها shortDescription — هنستخدم أول 80 حرف من الـ description
        shortDescription: j['shortDescription'] ??
            (j['description'] != null && (j['description'] as String).length > 80
                ? '${(j['description'] as String).substring(0, 80)}...'
                : j['description'] ?? ''),
        fullDescription: j['description'] ?? '',
        // لو مفيش imageUrl، نستخدم صورة default
        imageUrl: (j['imageUrl'] != null && (j['imageUrl'] as String).isNotEmpty)
            ? j['imageUrl']
            : 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/All_Gizah_Pyramids.jpg/640px-All_Gizah_Pyramids.jpg',
        artifacts: List<String>.from(j['artifacts'] ?? []),
        // museum_project بيستخدم Area بدل maxCapacity
        capacity: j['maxCapacity'] ?? j['area'] ?? 200,
      );
}

/// Static hall data — fallback لو الـ backend مش شغال
/// المعرّفات (IDs) متطابقة مع جدول halls في museum_project
class HallsData {
  static const List<Map<String, dynamic>> halls = [
    {
      'id': 1,
      'name': 'Grand Atrium',
      'shortDescription': 'Main entrance hall with rotating displays',
      'description':
          'Grand entrance hall with curated rotating exhibits from across Egypt\'s history. The perfect starting point for your museum journey.',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Mummy_of_Ramesses_II.jpg/640px-Mummy_of_Ramesses_II.jpg',
      'artifacts': ['Rotating Exhibits', 'Welcome Display', 'Museum Map', 'Conservation Lab Tour', 'Metals & Jewelry'],
      'maxCapacity': 400,
    },
    {
      'id': 2,
      'name': 'Ancient Egypt',
      'shortDescription': 'Artifacts from Pharaonic periods',
      'description':
          'Home to the most complete collection of pharaonic artifacts including royal mummies, golden masks, sarcophagi, and monumental sculptures spanning 3,000 years of ancient Egyptian civilization.',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Tutankhamun_Egyptian_Museum.jpg/640px-Tutankhamun_Egyptian_Museum.jpg',
      'artifacts': ['Egyptian Sarcophagus', 'Canopic Jar', 'Funerary Mask', 'Papyrus Fragment', 'Hieroglyphic Inscriptions'],
      'maxCapacity': 300,
    },
    {
      'id': 3,
      'name': 'Classical Antiquity',
      'shortDescription': 'Greek and Roman collections',
      'description':
          'Discover Greek and Roman civilizations through sculptures, pottery, coins and everyday objects from the ancient Mediterranean world.',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Egypt_Hieroglyphe4.jpg/640px-Egypt_Hieroglyphe4.jpg',
      'artifacts': ['Greek Vase', 'Roman Coin', 'Marble Bust', 'Roman Lamp', 'Greek Helmet'],
      'maxCapacity': 320,
    },
    {
      'id': 4,
      'name': 'Middle Ages',
      'shortDescription': 'Medieval artifacts and displays',
      'description':
          'A journey through medieval history featuring armor, weapons, religious art and everyday objects from the 5th to 15th centuries.',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Great_Sphinx_of_Giza_-_20080716a.jpg/640px-Great_Sphinx_of_Giza_-_20080716a.jpg',
      'artifacts': ['Medieval Helmet', 'Chain Mail', 'Horse Armor', 'Knight Shield', 'Crossbow'],
      'maxCapacity': 280,
    },
    {
      'id': 5,
      'name': 'Renaissance',
      'shortDescription': 'European renaissance artworks',
      'description':
          'Renaissance masterpieces including paintings, sculptures, and decorative arts from 14th-17th century Europe.',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/GD-EG-Alex-Mus%C3%A9e081.JPG/640px-GD-EG-Alex-Mus%C3%A9e081.JPG',
      'artifacts': ['Oil Painting', 'Altar Piece', 'Fresco Fragment', 'Madonna Study', 'Sketchbook'],
      'maxCapacity': 260,
    },
    {
      'id': 6,
      'name': 'Modern Art',
      'shortDescription': 'Modern and contemporary collection',
      'description':
          'Contemporary art and photography from the 19th century to present day, including impressionist masterworks and modern sculpture.',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/All_Gizah_Pyramids.jpg/640px-All_Gizah_Pyramids.jpg',
      'artifacts': ['Impressionist Canvas', 'Modern Metal Sculpture', 'Vintage Photo', 'Designer Lamp', 'Modern Chair'],
      'maxCapacity': 240,
    },
    {
      'id': 7,
      'name': 'Natural History',
      'shortDescription': 'Fossils and natural specimens',
      'description':
          'Explore Earth\'s natural history through fossils, specimens, and dioramas spanning millions of years of evolution.',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Abu_Simbel_temple%2C_1838.jpg/640px-Abu_Simbel_temple%2C_1838.jpg',
      'artifacts': ['Dinosaur Tooth', 'Fossil Egg', 'Trilobite', 'Mounted Fossil', 'Skull Replica'],
      'maxCapacity': 350,
    },
    {
      'id': 8,
      'name': 'Cultural Heritage',
      'shortDescription': 'Local cultural exhibits',
      'description':
          'Celebrating local traditions, folk costumes, handicrafts and cultural heritage from communities across the region.',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/CairoEgMuseumTaaMaskMostlyPhotographed.jpg/640px-CairoEgMuseumTaaMaskMostlyPhotographed.jpg',
      'artifacts': ['Traditional Dress', 'Weaving Loom', 'Ceremonial Robe', 'Cultural Mask', 'Embroidery Panel'],
      'maxCapacity': 220,
    },
    {
      'id': 9,
      'name': 'Temporary Exhibitions',
      'shortDescription': 'Short-term exhibitions space',
      'description':
          'Our dynamic temporary exhibition space hosting world-class rotating exhibitions on diverse cultural and historical themes.',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/All_Gizah_Pyramids.jpg/640px-All_Gizah_Pyramids.jpg',
      'artifacts': ['Silk Road Relic', 'Silk Banner', 'Saddle', 'Map Fragment', 'Coin Hoard'],
      'maxCapacity': 200,
    },
    {
      'id': 10,
      'name': 'Children Gallery',
      'shortDescription': 'Interactive gallery for kids',
      'description':
          'A hands-on, educational space designed for young visitors with interactive exhibits, puzzles, and science demonstrations.',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Great_Sphinx_of_Giza_-_20080716a.jpg/640px-Great_Sphinx_of_Giza_-_20080716a.jpg',
      'artifacts': ['Children\'s Puzzle', 'STEM Kit', 'Science Display', 'Interactive Exhibit', 'Science Poster'],
      'maxCapacity': 150,
    },
  ];
}
