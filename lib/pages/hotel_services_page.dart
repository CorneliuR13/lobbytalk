import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lobbytalk/models/hotel_service.dart';
import 'package:lobbytalk/services/auth/auth_service.dart';

class HotelServicesPage extends StatefulWidget {
  const HotelServicesPage({super.key});

  @override
  State<HotelServicesPage> createState() => _HotelServicesPageState();
}

class _HotelServicesPageState extends State<HotelServicesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  List<HotelService> _services = [];
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.getCurrentUser()?.uid;
      final docSnapshot = await _firestore.collection('receptions').doc(userId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();

        if (data != null && data.containsKey('availableServices')) {
          // Get already configured services
          final List<String> serviceNames = List<String>.from(data['availableServices'] ?? []);

          // Get all potential services
          final allServices = HotelService.defaultServices();

          // Mark services as enabled/disabled based on what's in Firestore
          _services = allServices.map((service) {
            return HotelService(
              id: service.id,
              name: service.name,
              description: service.description,
              icon: service.icon,
              isEnabled: serviceNames.contains(service.name),
            );
          }).toList();
        } else {
          // No services configured yet, use defaults with some enabled
          _services = HotelService.defaultServices();

          // Enable some basic services by default
          for (int i = 0; i < _services.length; i++) {
            if (['Room Service', 'Housekeeping', 'Information'].contains(_services[i].name)) {
              _services[i] = HotelService(
                id: _services[i].id,
                name: _services[i].name,
                description: _services[i].description,
                icon: _services[i].icon,
                isEnabled: true,
              );
            } else {
              _services[i] = HotelService(
                id: _services[i].id,
                name: _services[i].name,
                description: _services[i].description,
                icon: _services[i].icon,
                isEnabled: false,
              );
            }
          }
        }
      } else {
        // Document doesn't exist yet, use defaults
        _services = HotelService.defaultServices();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading services: $e')),
      );
      setState(() {
        _isLoading = false;
        _services = HotelService.defaultServices();
      });
    }
  }

  Future<void> _saveServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.getCurrentUser()?.uid;

      // Get enabled service names
      final List<String> enabledServices = _services
          .where((service) => service.isEnabled)
          .map((service) => service.name)
          .toList();

      // Save to Firestore
      await _firestore.collection('receptions').doc(userId).update({
        'availableServices': enabledServices,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Services updated successfully')),
      );

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });
    } catch (e) {
      print('Error saving services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving services: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addCustomService() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Custom Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Service Name',
                hintText: 'Enter service name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter service description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  // Create a unique ID
                  final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';

                  // Add to list
                  _services.add(HotelService(
                    id: id,
                    name: nameController.text,
                    description: descriptionController.text,
                    icon: Icons.miscellaneous_services,
                    isEnabled: true,
                  ));
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a service name')),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotel Services', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
                _loadServices(); // Reload original services
              },
              tooltip: 'Cancel',
            ),
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveServices : () {
              setState(() {
                _isEditing = true;
              });
            },
            tooltip: _isEditing ? 'Save Changes' : 'Edit Services',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Configure the services your hotel offers',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                return _buildServiceItem(service, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
        onPressed: _addCustomService,
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add),
        tooltip: 'Add Custom Service',
      )
          : null,
    );
  }

  Widget _buildServiceItem(HotelService service, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.redAccent.withOpacity(0.1),
            child: Icon(
              service.icon,
              color: service.isEnabled ? Colors.redAccent : Colors.grey,
            ),
          ),
          title: Text(service.name),
          subtitle: Text(
            service.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: _isEditing
              ? Switch(
            value: service.isEnabled,
            activeColor: Colors.redAccent,
            onChanged: (bool value) {
              setState(() {
                _services[index] = HotelService(
                  id: service.id,
                  name: service.name,
                  description: service.description,
                  icon: service.icon,
                  isEnabled: value,
                );
              });
            },
          )
              : Icon(
            service.isEnabled ? Icons.check_circle : Icons.not_interested,
            color: service.isEnabled ? Colors.green : Colors.grey,
          ),
          onTap: _isEditing
              ? () {
            setState(() {
              _services[index] = HotelService(
                id: service.id,
                name: service.name,
                description: service.description,
                icon: service.icon,
                isEnabled: !service.isEnabled,
              );
            });
          }
              : null,
        ),
      ),
    );
  }
}