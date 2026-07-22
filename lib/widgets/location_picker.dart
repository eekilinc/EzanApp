import 'package:flutter/material.dart';

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
      if (query.isEmpty) {
        _filteredCities = widget.cities;
      } else {
        _filteredCities = widget.cities
            .where((city) =>
                city.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: widget.onUseGpsPressed,
                icon: const Icon(Icons.location_on),
                label: const Text('GPS ile Konumumu Al'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Şehir Seç',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Şehir ara...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: _filterCities,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredCities.length,
            itemBuilder: (context, index) {
              final city = _filteredCities[index];
              return ListTile(
                leading: const Icon(Icons.location_city),
                title: Text(city),
                onTap: () {
                  widget.onCitySelected(city);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
