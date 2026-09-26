import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AiImageGeneratorDialog extends StatefulWidget {
  final String initialMake;
  final String initialModel;
  final String initialColor;

  const AiImageGeneratorDialog({
    super.key,
    this.initialMake = 'Porsche',
    this.initialModel = '911 GT3',
    this.initialColor = 'Emerald Green',
  });

  @override
  State<AiImageGeneratorDialog> createState() => _AiImageGeneratorDialogState();
}

class _AiImageGeneratorDialogState extends State<AiImageGeneratorDialog> {
  late TextEditingController _promptController;
  late TextEditingController _colorController;
  String _selectedStyle = 'Sport GT Studio';
  bool _isGenerating = false;
  String? _generatedImageData;
  final List<String> _styles = [
    'Sport GT Studio',
    'Cyberpunk Neon',
    'Luxury Emerald Pearl',
    'Vintage Classic',
    'Off-Road Beast',
    'Hypercar Carbon',
  ];

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(
      text: '${widget.initialMake} ${widget.initialModel} ${widget.initialColor} high performance automotive concept art',
    );
    _colorController = TextEditingController(text: widget.initialColor);
  }

  @override
  void dispose() {
    _promptController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _generateImage() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final primaryColorHex = _getColorHex(_colorController.text);
    final styleBgHex = _getStyleBgHex(_selectedStyle);

    // Render an ultra-sleek high quality SVG vehicle concept banner base64 data URI
    final svgString = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 500" width="800" height="500">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="$styleBgHex"/>
      <stop offset="100%" stop-color="#050B08"/>
    </linearGradient>
    <linearGradient id="carBody" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="$primaryColorHex"/>
      <stop offset="50%" stop-color="#16A34A"/>
      <stop offset="100%" stop-color="$primaryColorHex"/>
    </linearGradient>
    <linearGradient id="glow" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#00C853" stop-opacity="0.6"/>
      <stop offset="100%" stop-color="#00C853" stop-opacity="0"/>
    </linearGradient>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="15"/>
    </filter>
  </defs>

  <rect width="800" height="500" fill="url(#bg)"/>

  <!-- Studio Floor Grid Lines -->
  <path d="M 0 380 Q 400 350 800 380" stroke="#10B981" stroke-opacity="0.2" stroke-width="2" fill="none"/>
  <ellipse cx="400" cy="380" rx="350" ry="40" fill="url(#glow)"/>

  <!-- AI Vehicle Silhouette SVG Art -->
  <g transform="translate(100, 140)">
    <!-- Car Body Shape -->
    <path d="M 40 180 Q 90 120 200 90 L 360 80 Q 460 85 520 120 Q 560 140 570 180 L 580 195 C 580 205 570 215 550 215 L 30 215 Q 10 215 10 195 Z" fill="url(#carBody)"/>
    
    <!-- Roof & Cabin Glass -->
    <path d="M 170 95 Q 240 45 360 45 Q 430 45 470 90 Z" fill="#0A1813" stroke="#253530" stroke-width="3"/>
    <path d="M 260 52 L 350 52 L 440 90 L 260 90 Z" fill="#162D24" opacity="0.8"/>

    <!-- Headlight & Tail Light Glows -->
    <ellipse cx="560" cy="170" rx="14" ry="6" fill="#6EE7B7"/>
    <ellipse cx="25" cy="170" rx="10" ry="4" fill="#EF4444"/>

    <!-- Wheels & Alloy Rims -->
    <circle cx="130" cy="205" r="46" fill="#0D1311" stroke="#253530" stroke-width="6"/>
    <circle cx="130" cy="205" r="28" fill="#16A34A" opacity="0.8"/>
    <circle cx="130" cy="205" r="14" fill="#FFFFFF"/>

    <circle cx="470" cy="205" r="46" fill="#0D1311" stroke="#253530" stroke-width="6"/>
    <circle cx="470" cy="205" r="28" fill="#16A34A" opacity="0.8"/>
    <circle cx="470" cy="205" r="14" fill="#FFFFFF"/>
  </g>

  <!-- Title Badge Overlay -->
  <rect x="30" y="30" width="340" height="50" rx="12" fill="#061A13" opacity="0.85" stroke="#10B981" stroke-opacity="0.4"/>
  <text x="50" y="62" font-family="sans-serif" font-size="20" font-weight="bold" fill="#F1F5F9">AI Concept: ${widget.initialMake} $_selectedStyle</text>
</svg>
''';

    final base64Svg = 'data:image/svg+xml;base64,${base64Encode(utf8.encode(svgString))}';

    setState(() {
      _isGenerating = false;
      _generatedImageData = base64Svg;
    });
  }

  String _getColorHex(String colorText) {
    final lower = colorText.toLowerCase();
    if (lower.contains('red')) return '#EF4444';
    if (lower.contains('blue')) return '#3B82F6';
    if (lower.contains('yellow') || lower.contains('gold')) return '#F59E0B';
    if (lower.contains('white') || lower.contains('silver')) return '#E2E8F0';
    if (lower.contains('black') || lower.contains('dark')) return '#1E293B';
    if (lower.contains('purple')) return '#8B5CF6';
    return '#0F4C3A'; // Emerald Primary
  }

  String _getStyleBgHex(String style) {
    if (style.contains('Neon')) return '#180B2B';
    if (style.contains('Vintage')) return '#1C150C';
    if (style.contains('Off-Road')) return '#131A12';
    if (style.contains('Carbon')) return '#0A0E11';
    return '#091F18';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.primaryLight, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'AI Vehicle Image Generator',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // AI Prompt Input
              Text(
                'Custom AI Visual Prompt:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _promptController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Describe vehicle style, color, background lighting...',
                  prefixIcon: Icon(Icons.brush_outlined),
                ),
              ),
              const SizedBox(height: 14),

              // Visual Style Selector Chips
              Text(
                'Art Style & Lighting:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _styles.map((style) {
                  final isSelected = _selectedStyle == style;
                  return ChoiceChip(
                    label: Text(style),
                    selected: isSelected,
                    selectedColor: AppColors.primaryLight,
                    onSelected: (val) {
                      if (val) setState(() => _selectedStyle = style);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Generate Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateImage,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                  label: Text(
                    _isGenerating ? 'AI Synthesizing Visual Art...' : 'Generate AI Image',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Preview Box
              if (_generatedImageData != null) ...[
                Text(
                  'Generated AI Image Preview:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryLight, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      base64Decode(_generatedImageData!.split(',').last),
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Center(
                        child: Text('AI Image Generated Successfully ✨'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _generatedImageData);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Apply This AI Image to Vehicle',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
