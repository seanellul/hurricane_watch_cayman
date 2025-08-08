import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HurricaneInfoScreen extends StatefulWidget {
  const HurricaneInfoScreen({super.key});

  @override
  State<HurricaneInfoScreen> createState() => _HurricaneInfoScreenState();
}

class _HurricaneInfoScreenState extends State<HurricaneInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hurricane Information'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Formation', icon: Icon(Icons.cyclone)),
            Tab(text: 'Sahara', icon: Icon(Icons.landscape)),
            Tab(text: 'Cayman', icon: Icon(Icons.place)),
            Tab(text: 'Safety', icon: Icon(Icons.security)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _HurricaneFormationTab(),
          _SaharaImpactTab(),
          _CaymanSpecificsTab(),
          _SafetyTipsTab(),
        ],
      ),
    );
  }
}

class _HurricaneFormationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'How Hurricanes Form',
            icon: Icons.cyclone,
            color: Colors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hurricanes are complex weather systems that develop through a specific process involving ocean temperatures, atmospheric pressure, and wind patterns.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _FormationStage(
                  number: '1',
                  title: 'Tropical Disturbance',
                  description:
                      'A cluster of thunderstorms with minimal circulation. Wind speeds less than 25 mph.',
                  icon: Icons.cloud,
                ),
                _FormationStage(
                  number: '2',
                  title: 'Tropical Depression',
                  description:
                      'Organized circulation develops. Wind speeds 25-38 mph. Given a number designation.',
                  icon: Icons.rotate_left,
                ),
                _FormationStage(
                  number: '3',
                  title: 'Tropical Storm',
                  description:
                      'Well-defined circulation with stronger winds. Wind speeds 39-73 mph. Given a name.',
                  icon: Icons.storm,
                ),
                _FormationStage(
                  number: '4',
                  title: 'Hurricane',
                  description:
                      'Powerful circular storm with an eye. Wind speeds 74+ mph. Categorized 1-5.',
                  icon: Icons.cyclone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Key Factors for Development',
            icon: Icons.thermostat,
            color: Colors.orange,
            child: Column(
              children: [
                _FactorItem(
                  icon: Icons.thermostat,
                  title: 'Sea Surface Temperature',
                  description:
                      'Must be at least 80°F (26.5°C) to a depth of 150 feet',
                  color: Colors.red,
                ),
                _FactorItem(
                  icon: Icons.compress,
                  title: 'Low Atmospheric Pressure',
                  description:
                      'Creates the suction effect that draws air upward',
                  color: Colors.purple,
                ),
                _FactorItem(
                  icon: Icons.air,
                  title: 'Low Wind Shear',
                  description:
                      'Minimal difference in wind speeds at different altitudes',
                  color: Colors.green,
                ),
                _FactorItem(
                  icon: Icons.rotate_right,
                  title: 'Coriolis Effect',
                  description: 'Earth\'s rotation provides the spinning motion',
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _AtmosphericPressureCard(),
        ],
      ),
    );
  }
}

class _SaharaImpactTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'The Saharan Air Layer (SAL)',
            icon: Icons.landscape,
            color: Colors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The Sahara Desert plays a crucial role in Caribbean and Atlantic hurricane activity through the Saharan Air Layer - a mass of very dry, dusty air that travels westward across the Atlantic.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.landscape,
                        size: 48,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Journey from Africa to the Caribbean',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Every 3-5 days during summer months, massive dust clouds containing billions of tons of sand travel 5,000 miles from the Sahara Desert to the Caribbean, including the Cayman Islands.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'SAL & Hurricanes',
            icon: Icons.block,
            color: Colors.red,
            child: Column(
              children: [
                _SALEffectItem(
                  icon: Icons.dry,
                  title: 'Dry Air Suppression',
                  description:
                      'Very dry air (10-30% humidity) inhibits thunderstorm development needed for hurricane formation',
                  impact: 'Negative',
                ),
                _SALEffectItem(
                  icon: Icons.air,
                  title: 'Wind Shear Increase',
                  description:
                      'Creates strong wind shear that can tear apart developing tropical systems',
                  impact: 'Negative',
                ),
                _SALEffectItem(
                  icon: Icons.grain,
                  title: 'Dust Particles',
                  description:
                      'Dust acts as condensation nuclei, but can also block sunlight and cool ocean surface',
                  impact: 'Mixed',
                ),
                _SALEffectItem(
                  icon: Icons.layers,
                  title: 'Temperature Inversion',
                  description:
                      'Warm, dry air above cooler, moist air prevents vertical cloud development',
                  impact: 'Negative',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DustForecastCard(),
        ],
      ),
    );
  }
}

class _CaymanSpecificsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'Caymanian Climatology',
            icon: Icons.place,
            color: Colors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The Cayman Islands\' location in the western Caribbean makes it vulnerable to hurricanes from multiple directions during the Atlantic hurricane season.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _StatisticCard(
                  icon: Icons.calendar_today,
                  title: 'Hurricane Season',
                  value: 'June 1 - November 30',
                  subtitle: 'Peak: August - October',
                ),
                const SizedBox(height: 12),
                _StatisticCard(
                  icon: Icons.track_changes,
                  title: 'Most Common Tracks',
                  value: 'East to West',
                  subtitle: 'From main development region',
                ),
                const SizedBox(height: 12),
                _StatisticCard(
                  icon: Icons.schedule,
                  title: 'Peak Threat Period',
                  value: 'September',
                  subtitle: 'Historically most active month',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Historical Impact on Cayman',
            icon: Icons.history,
            color: Colors.purple,
            child: Column(
              children: [
                _HistoricalEvent(
                  year: '2004',
                  name: 'Hurricane Ivan',
                  category: 'Category 5',
                  impact:
                      'Passed 220 miles south, caused significant damage with 150+ mph winds',
                ),
                _HistoricalEvent(
                  year: '2008',
                  name: 'Hurricane Paloma',
                  category: 'Category 4',
                  impact:
                      'Direct hit on Cayman Brac and Little Cayman, minimal damage to Grand Cayman',
                ),
                _HistoricalEvent(
                  year: '1932',
                  name: 'Cuba Hurricane',
                  category: 'Category 4',
                  impact:
                      'Devastating direct hit, considered the worst in Cayman history',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Local Weather Patterns',
            icon: Icons.wb_sunny,
            color: Colors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Understanding local weather patterns helps predict hurricane behavior in Cayman waters.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _WeatherPattern(
                  title: 'Trade Winds',
                  description:
                      'Easterly trade winds typically steer storms westward',
                  months: 'Year-round',
                ),
                _WeatherPattern(
                  title: 'Sea Breeze Effect',
                  description:
                      'Land-sea temperature differences affect local wind patterns',
                  months: 'Daily cycle',
                ),
                _WeatherPattern(
                  title: 'Bermuda High',
                  description: 'High pressure system influences storm tracks',
                  months: 'Summer peak',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyTipsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'Hurricane Prep Timeline',
            icon: Icons.schedule,
            color: Colors.green,
            child: Column(
              children: [
                _TimelineItem(
                  timeframe: '72 Hours Before',
                  color: Colors.green,
                  actions: [
                    'Monitor weather forecasts closely',
                    'Review evacuation routes',
                    'Charge all electronic devices',
                    'Fill vehicles with fuel',
                  ],
                ),
                _TimelineItem(
                  timeframe: '48 Hours Before',
                  color: Colors.orange,
                  actions: [
                    'Complete final preparations',
                    'Secure outdoor furniture',
                    'Install storm shutters',
                    'Withdraw cash from ATMs',
                  ],
                ),
                _TimelineItem(
                  timeframe: '24 Hours Before',
                  color: Colors.red,
                  actions: [
                    'Finalize shelter plans',
                    'Test emergency equipment',
                    'Prepare for power outages',
                    'Stay indoors when winds reach 39 mph',
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Hurricane Categories',
            icon: Icons.speed,
            color: Colors.blue,
            child: Column(
              children: [
                _CategoryItem(
                  category: 1,
                  windSpeed: '74-95 mph',
                  damage: 'Minimal',
                  description: 'Some damage to vegetation and mobile homes',
                  color: Colors.yellow.shade700,
                ),
                _CategoryItem(
                  category: 2,
                  windSpeed: '96-110 mph',
                  damage: 'Moderate',
                  description:
                      'Considerable damage to vegetation, some roofing damage',
                  color: Colors.orange.shade600,
                ),
                _CategoryItem(
                  category: 3,
                  windSpeed: '111-129 mph',
                  damage: 'Extensive',
                  description:
                      'Large trees blown down, structural damage to buildings',
                  color: Colors.red.shade600,
                ),
                _CategoryItem(
                  category: 4,
                  windSpeed: '130-156 mph',
                  damage: 'Extreme',
                  description: 'Well-built structures severely damaged',
                  color: Colors.purple.shade600,
                ),
                _CategoryItem(
                  category: 5,
                  windSpeed: '157+ mph',
                  damage: 'Catastrophic',
                  description: 'Complete roof failure and wall collapse',
                  color: Colors.red.shade800,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _EmergencyKitCard(),
        ],
      ),
    );
  }
}

// Supporting Widget Classes

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _FormationStage extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _FormationStage({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(icon, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FactorItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FactorItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AtmosphericPressureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compress, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Text(
                'Atmospheric Pressure',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Lower atmospheric pressure at the center of a hurricane creates a powerful vacuum effect that draws air upward, fueling the storm\'s intensity.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Normal',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '29.92 inHg',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '1013 mb',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Cat 5 Hurricane',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '< 27.17 inHg',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '< 920 mb',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SALEffectItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String impact;

  const _SALEffectItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.impact,
  });

  @override
  Widget build(BuildContext context) {
    final Color impactColor = impact == 'Negative'
        ? Colors.red
        : impact == 'Positive'
            ? Colors.green
            : Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: impactColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: impactColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        impact,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: impactColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DustForecastCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monitoring Saharan Dust',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Satellite imagery and specialized weather models track Saharan dust movement, helping meteorologists predict its impact on hurricane development.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _launchDustForecast(),
              icon: const Icon(Icons.satellite),
              label: const Text('View Current Dust Forecast'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchDustForecast() async {
    final uri = Uri.parse(
        'https://www.cira.colostate.edu/ramm/visit/saharan-dust-rgb-air-mass-product/');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _StatisticCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatisticCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
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

class _HistoricalEvent extends StatelessWidget {
  final String year;
  final String name;
  final String category;
  final String impact;

  const _HistoricalEvent({
    required this.year,
    required this.name,
    required this.category,
    required this.impact,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.purple.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    year,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  category,
                  style: TextStyle(
                    color: Colors.purple.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              impact,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherPattern extends StatelessWidget {
  final String title;
  final String description;
  final String months;

  const _WeatherPattern({
    required this.title,
    required this.description,
    required this.months,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Text(
                      months,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String timeframe;
  final Color color;
  final List<String> actions;

  const _TimelineItem({
    required this.timeframe,
    required this.color,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeframe,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                const SizedBox(height: 8),
                ...actions.map((action) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: color)),
                          Expanded(
                            child: Text(
                              action,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final int category;
  final String windSpeed;
  final String damage;
  final String description;
  final Color color;

  const _CategoryItem({
    required this.category,
    required this.windSpeed,
    required this.damage,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        windSpeed,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        damage,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyKitCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Essential Emergency Kit',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your emergency kit should sustain your household for at least 72 hours without power or external assistance.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to preparedness checklist
                Navigator.of(context).pop(); // Go back to dashboard
                // The user can then tap the Preparedness Checklist button
              },
              icon: const Icon(Icons.checklist),
              label: const Text('View Full Preparedness Checklist'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
