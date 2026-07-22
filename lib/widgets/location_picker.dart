import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class LocationPicker extends StatefulWidget {
  final List<String> cities;
  final Function(String) onCitySelected;
  final Function() onUseGpsPressed;

  const LocationPicker({
    super.key,
    required this.cities,
    required this.onCitySelected,
    required this.onUseGpsPressed,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late TextEditingController _searchController;
  late List<String> _filteredCities;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCities = widget.cities;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredCities = widget.cities;
      } else {
        _filteredCities = widget.cities
            .where((city) =>
                city.toLowerCase().contains(query.toLowerCase().trim()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF161F18) : Colors.white;
    final cardBgColor = isDark ? const Color(0xFF222E25) : Colors.grey.shade100;
    final textColor = isDark ? Colors.white : Colors.grey.shade900;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.map_rounded,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      settingsProvider.tr('select_city'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // GPS Button Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade700,
                    Colors.teal.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade700.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: widget.onUseGpsPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.my_location, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          settingsProvider.tr('use_gps_location'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: settingsProvider.tr('search_city'),
                hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _filterCities('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: cardBgColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterCities,
            ),
          ),
          const SizedBox(height: 12),

          // City List Counter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Türkiye İlleri (${_filteredCities.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Cities ListView
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                final city = _filteredCities[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 0,
                  color: cardBgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.location_city,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      city,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      size: 20,
                    ),
                    onTap: () {
                      widget.onCitySelected(city);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
