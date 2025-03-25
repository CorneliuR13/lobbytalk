import 'package:flutter/material.dart';

class HotelService {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool isEnabled;

  HotelService({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isEnabled = true,
  });

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isEnabled': isEnabled,
    };
  }

  // Create a service from a Firestore map
  factory HotelService.fromMap(Map<String, dynamic> map) {
    return HotelService(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: _getIconForService(map['name'] ?? ''),
      isEnabled: map['isEnabled'] ?? true,
    );
  }

  // Get icon based on service name
  static IconData _getIconForService(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'room service':
        return Icons.room_service;
      case 'housekeeping':
        return Icons.cleaning_services;
      case 'spa & wellness':
      case 'spa and wellness':
        return Icons.spa;
      case 'restaurant':
        return Icons.local_dining;
      case 'transport':
        return Icons.directions_car;
      case 'concierge':
        return Icons.assistant;
      case 'laundry':
        return Icons.local_laundry_service;
      case 'gym':
      case 'fitness center':
        return Icons.fitness_center;
      case 'swimming pool':
      case 'pool':
        return Icons.pool;
      case 'business center':
        return Icons.business_center;
      case 'conference rooms':
      case 'meeting rooms':
        return Icons.meeting_room;
      case 'airport shuttle':
        return Icons.airport_shuttle;
      case 'information':
        return Icons.info;
      default:
        return Icons.miscellaneous_services;
    }
  }

  // Predefined hotel services
  static List<HotelService> defaultServices() {
    return [
      HotelService(
        id: 'room_service',
        name: 'Room Service',
        description: 'Food and beverage delivery to guest rooms',
        icon: Icons.room_service,
      ),
      HotelService(
        id: 'housekeeping',
        name: 'Housekeeping',
        description: 'Room cleaning and maintenance services',
        icon: Icons.cleaning_services,
      ),
      HotelService(
        id: 'spa',
        name: 'Spa & Wellness',
        description: 'Massage, treatments, and wellness facilities',
        icon: Icons.spa,
      ),
      HotelService(
        id: 'restaurant',
        name: 'Restaurant',
        description: 'Hotel dining facilities and reservations',
        icon: Icons.local_dining,
      ),
      HotelService(
        id: 'transport',
        name: 'Transport',
        description: 'Transportation services and bookings',
        icon: Icons.directions_car,
      ),
      HotelService(
        id: 'concierge',
        name: 'Concierge',
        description: 'Personalized guest services and local recommendations',
        icon: Icons.assistant,
      ),
      HotelService(
        id: 'laundry',
        name: 'Laundry',
        description: 'Laundry and dry cleaning services',
        icon: Icons.local_laundry_service,
      ),
      HotelService(
        id: 'gym',
        name: 'Gym',
        description: 'Fitness facilities and equipment',
        icon: Icons.fitness_center,
      ),
      HotelService(
        id: 'pool',
        name: 'Swimming Pool',
        description: 'Pool access and related services',
        icon: Icons.pool,
      ),
      HotelService(
        id: 'business',
        name: 'Business Center',
        description: 'Business services and facilities',
        icon: Icons.business_center,
      ),
      HotelService(
        id: 'conference',
        name: 'Conference Rooms',
        description: 'Meeting and event spaces',
        icon: Icons.meeting_room,
      ),
      HotelService(
        id: 'shuttle',
        name: 'Airport Shuttle',
        description: 'Transportation to and from the airport',
        icon: Icons.airport_shuttle,
      ),
      HotelService(
        id: 'info',
        name: 'Information',
        description: 'General information about the hotel and local area',
        icon: Icons.info,
      ),
    ];
  }
}