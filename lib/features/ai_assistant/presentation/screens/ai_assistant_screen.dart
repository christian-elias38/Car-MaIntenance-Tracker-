import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../vehicles/data/models/vehicle_model.dart';
import '../../../vehicles/presentation/providers/vehicle_provider.dart';
import '../../../vehicles/presentation/widgets/app_vehicle_image.dart';
import '../../data/services/ai_recommendation_service.dart';

class AiAssistantScreen extends StatefulWidget {
  final VehicleModel? initialVehicle;

  const AiAssistantScreen({super.key, this.initialVehicle});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final AiRecommendationService _aiService = AiRecommendationService();
  late VehicleModel _selectedVehicle;
  late AiVehicleAnalysis _analysis;
  
  final List<AiChatMessage> _chatMessages = [];
  bool _isAiTyping = false;

  final List<String> _quickPrompts = [
    '🛢️ What engine oil spec should I use?',
    '🛞 What tire pressure is recommended?',
    '🛑 When should I replace brake pads?',
    '⛽ Recommended fuel grade?',
    '🔊 Troubleshoot engine squeaking noise',
    '📅 Show upcoming maintenance roadmap',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    final vehicleProvider = context.read<VehicleProvider>();
    _selectedVehicle = widget.initialVehicle ?? 
        vehicleProvider.activeVehicle ?? 
        (vehicleProvider.vehicles.isNotEmpty ? vehicleProvider.vehicles.first : _defaultFallbackVehicle());
    
    _analysis = _aiService.analyzeVehicle(_selectedVehicle);

    // Initial greeting from AI
    _chatMessages.add(
      AiChatMessage(
        sender: 'ai',
        text: 'Hello! I am your AI Vehicle Advisor for your ${_selectedVehicle.displayName}.\n\n'
            'How can I assist you with maintenance specs, fluid recommendations, or troubleshooting today?',
        timestamp: DateTime.now(),
      ),
    );
  }

  VehicleModel _defaultFallbackVehicle() {
    return VehicleModel(
      id: 'default',
      make: 'Toyota',
      model: 'Corolla',
      year: 2020,
      vin: '12345',
      mileage: '45,000 km',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onVehicleChanged(VehicleModel newVehicle) {
    setState(() {
      _selectedVehicle = newVehicle;
      _analysis = _aiService.analyzeVehicle(_selectedVehicle);
      _chatMessages.add(
        AiChatMessage(
          sender: 'ai',
          text: 'Switched focus to **${newVehicle.displayName}** (${newVehicle.year}, ${newVehicle.mileage}). Recommendations updated!',
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || _isAiTyping) return;

    _chatController.clear();
    setState(() {
      _chatMessages.add(
        AiChatMessage(sender: 'user', text: cleanText, timestamp: DateTime.now()),
      );
      _isAiTyping = true;
    });

    _scrollToBottom();

    final response = await _aiService.askAiAssistant(
      vehicle: _selectedVehicle,
      prompt: cleanText,
    );

    if (mounted) {
      setState(() {
        _isAiTyping = false;
        _chatMessages.add(
          AiChatMessage(sender: 'ai', text: response, timestamp: DateTime.now()),
        );
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _applyAiSpecsToVehicle() {
    final updated = _selectedVehicle.copyWith(
      oilType: _analysis.recommendedOil,
      tireSize: _selectedVehicle.tireSize.isEmpty ? '225/45 R17' : _selectedVehicle.tireSize,
      description: _selectedVehicle.description.isEmpty 
          ? _aiService.generateAutoDescription(_selectedVehicle)
          : _selectedVehicle.description,
    );

    context.read<VehicleProvider>().updateVehicle(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text('Applied AI Specs to ${_selectedVehicle.displayName}!'),
          ],
        ),
        backgroundColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vehicleProvider = context.watch<VehicleProvider>();
    final allVehicles = vehicleProvider.vehicles;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.info],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('AI Vehicle Advisor', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt_rounded, color: AppColors.primaryLight),
            tooltip: 'Apply AI Specs',
            onPressed: _applyAiSpecsToVehicle,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Vehicle Selection Card Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AppVehicleImage(
                    imagePath: _selectedVehicle.imagePath,
                    width: 50,
                    height: 38,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Analyzing Vehicle:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedVehicle.id,
                            isDense: true,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryLight),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            items: allVehicles.map((v) {
                              return DropdownMenuItem<String>(
                                value: v.id,
                                child: Text(v.displayName, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (id) {
                              if (id != null) {
                                final found = allVehicles.firstWhere((v) => v.id == id);
                                _onVehicleChanged(found);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryLight,
              labelColor: AppColors.primaryLight,
              unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.recommend_rounded, size: 18), text: 'AI Recommendations'),
                Tab(icon: Icon(Icons.chat_bubble_outline_rounded, size: 18), text: 'Ask AI Chatbot'),
              ],
            ),
            const Divider(height: 1),

            // Tab Bar Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: AI RECOMMENDATIONS
                  _buildRecommendationsTab(isDark),

                  // TAB 2: AI CHATBOT
                  _buildChatTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Diagnosis Summary Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [AppColors.mintBackground, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.psychology_rounded, color: AppColors.primaryLight, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Automotive Health Score: 98/100',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _analysis.summary,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Button: Apply to vehicle
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _applyAiSpecsToVehicle,
              icon: const Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Auto-Apply AI Suggestions to Vehicle Specs',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            '💡 Recommended Fluid & Spec Choices',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Recommendation Cards Grid
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _analysis.recommendations.length,
            itemBuilder: (ctx, idx) {
              final item = _analysis.recommendations[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getIcon(item.iconName), color: AppColors.primaryLight, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'AI Suggested',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.recommendation,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.detail,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Milestone Maintenance Roadmap
          Text(
            '📍 Maintenance Roadmap (${_selectedVehicle.mileage})',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: _analysis.upcomingMilestones.map((m) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.primaryLight, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          m,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildChatTab(bool isDark) {
    return Column(
      children: [
        // Quick Query Chips
        Container(
          height: 44,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _quickPrompts.length,
            itemBuilder: (ctx, i) {
              final prompt = _quickPrompts[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12)),
                  backgroundColor: isDark ? AppColors.darkSurface : AppColors.mintBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onPressed: () => _sendMessage(prompt),
                ),
              );
            },
          ),
        ),

        // Messages List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _chatMessages.length,
            itemBuilder: (ctx, index) {
              final msg = _chatMessages[index];
              final isUser = msg.sender == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? AppColors.primaryLight 
                        : (isDark ? AppColors.darkCard : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: isUser ? null : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: isUser 
                          ? Colors.white 
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        if (_isAiTyping)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLight),
                ),
                const SizedBox(width: 10),
                Text(
                  'AI Advisor is typing standard recommendations...',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

        // Input Field Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            border: Border(
              top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  onSubmitted: _sendMessage,
                  decoration: const InputDecoration(
                    hintText: 'Ask AI about oil, parts, sound diagnosis...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: AppColors.primaryLight),
                onPressed: () => _sendMessage(_chatController.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'opacity_rounded':
        return Icons.opacity_rounded;
      case 'tire_repair_rounded':
        return Icons.tire_repair_rounded;
      case 'tune_rounded':
        return Icons.tune_rounded;
      case 'health_and_safety_rounded':
        return Icons.health_and_safety_rounded;
      case 'ac_unit_rounded':
        return Icons.ac_unit_rounded;
      case 'local_gas_station_rounded':
        return Icons.local_gas_station_rounded;
      default:
        return Icons.build_rounded;
    }
  }
}
