import '../../../vehicles/data/models/vehicle_model.dart';

class AiRecommendationItem {
  final String category;
  final String title;
  final String recommendation;
  final String detail;
  final String iconName;

  AiRecommendationItem({
    required this.category,
    required this.title,
    required this.recommendation,
    required this.detail,
    required this.iconName,
  });
}

class AiVehicleAnalysis {
  final String summary;
  final String recommendedOil;
  final String recommendedOilInterval;
  final String recommendedTransmissionFluid;
  final String recommendedBrakeFluid;
  final String recommendedCoolant;
  final String recommendedTirePsi;
  final String recommendedTireRotation;
  final String recommendedSparkPlugs;
  final String recommendedFuelGrade;
  final List<AiRecommendationItem> recommendations;
  final List<String> upcomingMilestones;

  AiVehicleAnalysis({
    required this.summary,
    required this.recommendedOil,
    required this.recommendedOilInterval,
    required this.recommendedTransmissionFluid,
    required this.recommendedBrakeFluid,
    required this.recommendedCoolant,
    required this.recommendedTirePsi,
    required this.recommendedTireRotation,
    required this.recommendedSparkPlugs,
    required this.recommendedFuelGrade,
    required this.recommendations,
    required this.upcomingMilestones,
  });
}

class AiChatMessage {
  final String sender; // 'user' or 'ai'
  final String text;
  final DateTime timestamp;

  AiChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });
}

class AiRecommendationService {
  static final AiRecommendationService _instance = AiRecommendationService._internal();
  factory AiRecommendationService() => _instance;
  AiRecommendationService._internal();

  /// Generates a comprehensive AI analysis & recommendation report for a given vehicle
  AiVehicleAnalysis analyzeVehicle(VehicleModel vehicle) {
    final make = vehicle.make.toLowerCase();
    final fuel = vehicle.fuelType.toLowerCase();
    final int mileageNum = int.tryParse(vehicle.mileage.replaceAll(RegExp(r'[^0-9]'), '')) ?? 40000;

    // Determine Oil Spec
    String oilViscosity = vehicle.oilType.isNotEmpty ? vehicle.oilType : '0W-20 Full Synthetic';
    String oilInterval = '8,000 - 10,000 km (or 6 months)';
    if (make.contains('bmw') || make.contains('mercedes') || make.contains('audi') || make.contains('porsche')) {
      oilViscosity = '5W-30 / 0W-40 Euro Spec Synthetic (LL-01 / MB 229.5)';
      oilInterval = '10,000 - 12,000 km';
    } else if (fuel.contains('diesel')) {
      oilViscosity = '5W-40 Heavy Duty Diesel Synthetic';
      oilInterval = '10,000 km';
    } else if (fuel.contains('electric')) {
      oilViscosity = 'N/A (Electric Drive Unit)';
      oilInterval = 'Inspect gearbox fluid every 40,000 km';
    }

    // Transmission Fluid
    String transFluid = 'Manufacturer Spec Synthetic ATF (flush every 60,000 km)';
    if (vehicle.transmission.toLowerCase().contains('cvt')) {
      transFluid = 'CVT Fluid Genuine Spec (flush every 45,000 km)';
    } else if (vehicle.transmission.toLowerCase().contains('manual')) {
      transFluid = '75W-90 Synthetic Gear Lube (change every 80,000 km)';
    } else if (vehicle.transmission.toLowerCase().contains('dual-clutch')) {
      transFluid = 'DSG / DCT Fluid (change filter & fluid every 60,000 km)';
    }

    // Tire Pressure & Rotation
    String tirePsi = '32 - 35 PSI (Cold)';
    if (vehicle.bodyType.toLowerCase().contains('truck') || vehicle.bodyType.toLowerCase().contains('suv')) {
      tirePsi = '35 - 38 PSI (Cold)';
    }
    String tireRotation = 'Rotate tires every 8,000 - 10,000 km for even tread wear';

    // Brake Fluid
    String brakeFluid = 'DOT 4 Synthetic Brake Fluid (flush every 2 years / 40,000 km)';

    // Coolant
    String coolant = 'Organic Acid Tech (OAT) Long-life Coolant (50/50 Mix)';

    // Spark Plugs
    String sparkPlugs = 'Iridium Spark Plugs (replace every 100,000 km)';

    // Fuel Grade
    String fuelGrade = fuel.contains('electric') 
        ? 'Level 2 EV Charging (240V)'
        : (vehicle.horsepower.contains('300') || make.contains('porsche') || make.contains('bmw')
            ? '91 / 93 Premium Octane Unlead'
            : '87 Regular Octane Unlead');

    // Recommendations Items List
    final List<AiRecommendationItem> items = [
      AiRecommendationItem(
        category: 'Engine & Lubrication',
        title: 'Optimal Engine Oil',
        recommendation: oilViscosity,
        detail: 'Recommended change interval: $oilInterval. Synthetic oil reduces friction and protects turbochargers.',
        iconName: 'opacity_rounded',
      ),
      AiRecommendationItem(
        category: 'Tires & Alignment',
        title: 'Tire Pressure & Care',
        recommendation: '$tirePsi | ${vehicle.tireSize}',
        detail: '$tireRotation. Maintain correct PSI to improve fuel efficiency by up to 3%.',
        iconName: 'tire_repair_rounded',
      ),
      AiRecommendationItem(
        category: 'Drivetrain & Transmission',
        title: 'Transmission Fluid',
        recommendation: transFluid,
        detail: 'Proper transmission maintenance prevents shift slippage and extends gearbox lifespan.',
        iconName: 'tune_rounded',
      ),
      AiRecommendationItem(
        category: 'Braking System',
        title: 'Brake Maintenance',
        recommendation: brakeFluid,
        detail: 'Inspect brake pad thickness (minimum 3mm) and test brake fluid moisture content every 15,000 km.',
        iconName: 'health_and_safety_rounded',
      ),
      AiRecommendationItem(
        category: 'Cooling & Engine Protection',
        title: 'Radiator Coolant / Antifreeze',
        recommendation: coolant,
        detail: 'Flush system every 5 years or 100,000 km to prevent internal corrosion and overheating.',
        iconName: 'ac_unit_rounded',
      ),
      AiRecommendationItem(
        category: 'Fuel & Combustion',
        title: 'Fuel Octane & Ignition',
        recommendation: fuelGrade,
        detail: '$sparkPlugs. Clean fuel injectors every 30,000 km for optimal power output.',
        iconName: 'local_gas_station_rounded',
      ),
    ];

    // Mileage Milestones
    final List<String> milestones = [];
    if (mileageNum > 100000) {
      milestones.add('⚠️ High Mileage Check: Replace spark plugs & inspect serpentine drive belt');
      milestones.add('🔄 Perform complete transmission & differential fluid flush');
      milestones.add('🛠️ Check shocks/struts, control arm bushings, and wheel bearings');
    } else if (mileageNum > 60000) {
      milestones.add('🔧 60k Service: Change engine air filter & cabin air filter');
      milestones.add('🛑 Inspect front & rear brake pads and brake rotors');
      milestones.add('🔋 Test 12V starter battery health and alternator voltage output');
    } else if (mileageNum > 30000) {
      milestones.add('🔄 Rotate all four tires and rebalance wheels');
      milestones.add('🛢️ Standard oil & filter change with full synthetic blend');
      milestones.add('🔍 Inspect wiper blades, washer fluid, and chassis fittings');
    } else {
      milestones.add('✨ Initial Inspection: Maintain regular 8,000 km oil service');
      milestones.add('🔄 Rotate tires every 8,000 km to preserve tread depth');
      milestones.add('🍃 Replace cabin air filter annually for clean HVAC airflow');
    }

    final summary = 'AI Diagnosis for ${vehicle.year} ${vehicle.make} ${vehicle.model}: '
        'Your vehicle is in optimal operating condition. At ${vehicle.mileage}, focus on scheduled synthetic oil changes ($oilViscosity) '
        'and tire rotation ($tirePsi).';

    return AiVehicleAnalysis(
      summary: summary,
      recommendedOil: oilViscosity,
      recommendedOilInterval: oilInterval,
      recommendedTransmissionFluid: transFluid,
      recommendedBrakeFluid: brakeFluid,
      recommendedCoolant: coolant,
      recommendedTirePsi: tirePsi,
      recommendedTireRotation: tireRotation,
      recommendedSparkPlugs: sparkPlugs,
      recommendedFuelGrade: fuelGrade,
      recommendations: items,
      upcomingMilestones: milestones,
    );
  }

  /// AI Assistant Chat logic to answer user queries with vehicle-aware intelligence
  Future<String> askAiAssistant({
    required VehicleModel vehicle,
    required String prompt,
  }) async {
    final lower = prompt.toLowerCase();
    final vInfo = '${vehicle.year} ${vehicle.make} ${vehicle.model} (${vehicle.engineSize}, ${vehicle.mileage})';

    // Simulated network response delay for realistic AI feel
    await Future.delayed(const Duration(milliseconds: 650));

    if (lower.contains('oil') || lower.contains('lubricant') || lower.contains('viscosity')) {
      final spec = vehicle.oilType.isNotEmpty ? vehicle.oilType : '0W-20 Full Synthetic';
      return 'For your $vInfo, I recommend using **$spec**.\n\n'
          '• **Recommended Interval:** Every 8,000 - 10,000 km or 6 months.\n'
          '• **Capacity:** ~4.2 - 4.5 Liters with filter replacement.\n'
          '• **Pro Tip:** Always replace the oil filter washer and O-ring to prevent slow leaks!';
    } else if (lower.contains('tire') || lower.contains('wheel') || lower.contains('psi') || lower.contains('pressure')) {
      final size = vehicle.tireSize.isNotEmpty ? vehicle.tireSize : '225/45 R17';
      return 'Tire recommendations for your $vInfo:\n\n'
          '• **Tire Size:** $size\n'
          '• **Recommended Pressure:** 32 - 35 PSI front / rear (cold).\n'
          '• **Rotation Schedule:** Every 8,000 km for balanced wear.\n'
          '• **Tip:** Check pressure monthly; cold weather drops pressure by ~1 PSI per 5°C drop.';
    } else if (lower.contains('brake') || lower.contains('pad') || lower.contains('rotor') || lower.contains('stopping')) {
      return 'Brake System suggestions for your $vInfo:\n\n'
          '• **Brake Fluid:** DOT 4 Synthetic (flush every 2 years / 40,000 km).\n'
          '• **Pad Replacement:** Typically required every 40,000 - 60,000 km depending on driving habits.\n'
          '• **Warning Sign:** Squealing or grinding noise indicates friction pads are worn below 3mm.';
    } else if (lower.contains('fuel') || lower.contains('gas') || lower.contains('octane') || lower.contains('mileage')) {
      return 'Fuel & Efficiency advice for your $vInfo:\n\n'
          '• **Recommended Octane:** Regular 87 Octane (unless performance tuned).\n'
          '• **Fuel Tank Capacity:** ${vehicle.fuelCapacity.isNotEmpty ? vehicle.fuelCapacity : '50 Liters'}.\n'
          '• **Efficiency Tips:** Keep tires properly inflated, avoid rapid acceleration, and use clean engine air filters.';
    } else if (lower.contains('service') || lower.contains('schedule') || lower.contains('maintenance') || lower.contains('milestone')) {
      final analysis = analyzeVehicle(vehicle);
      return 'Here is the recommended maintenance schedule for your $vInfo at ${vehicle.mileage}:\n\n'
          '${analysis.upcomingMilestones.map((m) => '• $m').join('\n')}\n\n'
          'Keeping up with these tasks protects vehicle resale value and performance!';
    } else if (lower.contains('squeak') || lower.contains('noise') || lower.contains('sound') || lower.contains('vibrat')) {
      return 'Diagnostic help for sound/vibration in your $vInfo:\n\n'
          '1. **High-pitched squeal when starting:** Likely a worn or loose serpentine drive belt.\n'
          '2. **Squeaking when braking:** Front or rear brake wear indicators touching rotors.\n'
          '3. **Vibration at high speeds:** Unbalanced tires or misaligned front wheels.\n'
          '4. **Knocking noise over bumps:** Worn sway bar links or strut mounts.';
    } else {
      final analysis = analyzeVehicle(vehicle);
      return 'Based on your $vInfo, here are the key specs and recommendations:\n\n'
          '• **Engine Oil:** ${analysis.recommendedOil}\n'
          '• **Tire Size & PSI:** ${vehicle.tireSize} @ ${analysis.recommendedTirePsi}\n'
          '• **Transmission:** ${analysis.recommendedTransmissionFluid}\n'
          '• **Brake Fluid:** ${analysis.recommendedBrakeFluid}\n\n'
          'Feel free to ask me about specific parts, troubleshooting issues, or upcoming service steps!';
    }
  }

  /// Auto-generates a full car description based on vehicle details
  String generateAutoDescription(VehicleModel vehicle) {
    final make = vehicle.make;
    final model = vehicle.model;
    final year = vehicle.year;
    final trim = vehicle.trim.isNotEmpty ? vehicle.trim : '';
    final engine = vehicle.engineSize.isNotEmpty ? vehicle.engineSize : 'Engine';
    final hp = vehicle.horsepower.isNotEmpty ? vehicle.horsepower : '';
    final body = vehicle.bodyType.isNotEmpty ? vehicle.bodyType : 'vehicle';

    final buffer = StringBuffer();
    buffer.write('$year $make $model');
    if (trim.isNotEmpty) buffer.write(' $trim');
    buffer.write(' - High-performance $body equipped with a $engine');
    if (hp.isNotEmpty) buffer.write(' producing $hp');
    buffer.write('. Features ${vehicle.transmission.toLowerCase()} transmission, ${vehicle.drivetrain} layout, and premium interior trim. ');
    buffer.write('Maintained regularly with ${vehicle.oilType} for optimal reliability and performance.');

    return buffer.toString();
  }
}
