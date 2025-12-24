import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class CustomizeIceCreamScreen extends StatefulWidget {
  const CustomizeIceCreamScreen({super.key});

  @override
  State<CustomizeIceCreamScreen> createState() =>
      _CustomizeIceCreamScreenState();
}

class _CustomizeIceCreamScreenState extends State<CustomizeIceCreamScreen> {
  final Color _primaryColor = const Color(0xFFF04888);
  final Color _backgroundColor = const Color(0xFFF8F9FA);

  // Flavors definition
  final List<Map<String, dynamic>> _flavors = [
    {'name': 'Vanilla', 'color': const Color(0xFFFFF8E1)},
    {'name': 'Chocolate', 'color': const Color(0xFF5D4037)},
    {'name': 'Strawberry', 'color': const Color(0xFFFF80AB)},
    {'name': 'Mint', 'color': const Color(0xFFB2DFDB)},
    {'name': 'Blueberry', 'color': const Color(0xFF90CAF9)},
  ];

  // Selected state
  late Map<String, dynamic> _selectedFlavor;
  final Set<String> _selectedToppings = {};

  // Toppings list (just names now)
  final List<String> _availableToppings = [
    'Chocolate Fudge',
    'Sprinkles',
    'Cherry',
    'Whipped Cream',
    'Caramel Drizzle',
    'Nuts',
    'Oreo Crumbs',
  ];

  // AI Generation State
  String? _generatedDescription;
  Uint8List? _generatedImageBytes;
  bool _isGenerating = false;
  // TODO: Replace with your actual Gemini API Key (ensure it has Imagen access)
  static const String _apiKey = 'AIzaSyBGoKnzw4dabkvKlp2d16qweFhIhLKsy6o';

  @override
  void initState() {
    super.initState();
    _selectedFlavor = _flavors[0];
  }

  Future<void> _generateIceCream() async {
    if (_apiKey == 'YOUR_API_KEY_HERE') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please update the hardcoded API Key in code'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedDescription = null;
      _generatedImageBytes = null;
    });

    try {
      // 1. Generate Description (Text)
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final promptText =
          '''
      Describe a delicious ice cream creation featuring a ${_selectedFlavor['name']} base with the following toppings: ${_selectedToppings.join(', ')}.
      Make it sound mouth-watering.
      ''';
      final content = [Content.text(promptText)];
      final response = await model.generateContent(content);

      final description = response.text;
      setState(() {
        _generatedDescription = description;
      });

      // 2. Generate Image (Imagen)
      // Note: This requires an API Key with access to Imagen (e.g., Trusted Tester)
      if (description != null) {
        await _generateIceCreamImage(description);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _generateIceCreamImage(String description) async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-001:predict?key=$_apiKey',
      );

      // Basic truncation to avoid hitting limits or excessive tokens if prompt is huge
      final cleanDescription = description.replaceAll('\n', ' ');
      final prompt =
          'High quality, photorealistic, appetizing photo of ice cream: $cleanDescription';

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'instances': [
            {'prompt': prompt},
          ],
          'parameters': {'sampleCount': 1},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check structure of Imagen response (predictions -> bytesBase64Encoded)
        if (data['predictions'] != null &&
            (data['predictions'] as List).isNotEmpty) {
          final firstPrediction = data['predictions'][0];
          // Adjust based on exact response format (bytesBase64Encoded is common for Vertex/Generative AI)
          String? base64Image = firstPrediction['bytesBase64Encoded'];

          if (base64Image != null) {
            setState(() {
              _generatedImageBytes = base64Decode(base64Image);
            });
          }
        }
      } else {
        debugPrint(
          'Image generation failed: ${response.statusCode} - ${response.body}',
        );
        // Don't throw, just log/notify, so text still shows
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image Gen failed: ${response.statusCode}. Check API Key permissions.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Image generation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'AI Customizer',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. Visualizer / Result Area
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _buildAIResultArea(),
            ),
          ),

          // 2. Controls Area
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLabel('Choose Flavor (Base)'),
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _flavors.length,
                      separatorBuilder: (c, i) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final flavor = _flavors[index];
                        final isSelected = _selectedFlavor == flavor;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFlavor = flavor;
                            });
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: flavor['color'],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? _primaryColor
                                    : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: (flavor['color'] as Color)
                                            .withAlpha(100),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('Add Toppings'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableToppings.map((name) {
                      final isSelected = _selectedToppings.contains(name);
                      return FilterChip(
                        label: Text(
                          name,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: _primaryColor,
                        checkmarkColor: Colors.white,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedToppings.add(name);
                            } else {
                              _selectedToppings.remove(name);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateIceCream,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      _isGenerating ? 'Dreaming...' : 'Visualize with AI',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAIResultArea() {
    if (_generatedDescription != null) {
      return Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_generatedImageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    _generatedImageBytes!,
                    height: 250,
                    width: 250,
                    fit: BoxFit.cover,
                  ),
                )
              else
                const Icon(
                  Icons.icecream,
                  size: 64,
                  color: Colors.orangeAccent,
                ),

              const SizedBox(height: 16),
              if (_generatedImageBytes == null &&
                  _generatedDescription != null) ...[
                Text(
                  _isGenerating ? 'Painting...' : 'Image Unavailable',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
              ],

              Text(
                'AI Description',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _generatedDescription!,
                style: GoogleFonts.poppins(fontSize: 14, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_isGenerating) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_awesome_outlined,
          size: 80,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        Text(
          'Select flavors & toppings\nthen click "Visualize with AI"',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 16),
        ),
      ],
    );
  }
}
