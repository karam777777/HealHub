import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationPickerWidget extends StatefulWidget {
  final String? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(String address, double latitude, double longitude)? onLocationSelected;
  final bool readOnly;

  const LocationPickerWidget({
    Key? key,
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
    this.onLocationSelected,
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final TextEditingController _addressController = TextEditingController();
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _addressController.text = widget.initialAddress!;
    }
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _latitude = widget.initialLatitude;
      _longitude = widget.initialLongitude;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('خطأ', 'تم رفض إذن الموقع');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('خطأ', 'إذن الموقع مرفوض نهائياً. يرجى تفعيله من الإعدادات');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = _formatAddress(place);
        
        setState(() {
          _addressController.text = address;
          _latitude = position.latitude;
          _longitude = position.longitude;
        });

        if (widget.onLocationSelected != null) {
          widget.onLocationSelected!(address, position.latitude, position.longitude);
        }
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في الحصول على الموقع الحالي: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      
      if (locations.isNotEmpty) {
        Location location = locations.first;
        
        // Get detailed address
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        String address = query;
        if (placemarks.isNotEmpty) {
          address = _formatAddress(placemarks.first);
        }

        setState(() {
          _addressController.text = address;
          _latitude = location.latitude;
          _longitude = location.longitude;
        });

        if (widget.onLocationSelected != null) {
          widget.onLocationSelected!(address, location.latitude, location.longitude);
        }
      } else {
        Get.snackbar('خطأ', 'لم يتم العثور على الموقع');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في البحث عن الموقع: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatAddress(Placemark place) {
    List<String> addressParts = [];
    
    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      addressParts.add(place.country!);
    }

    return addressParts.join(', ');
  }

  Future<void> _openInMaps() async {
    if (_latitude == null || _longitude == null) {
      Get.snackbar('خطأ', 'لا يوجد موقع محدد');
      return;
    }

    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude';
    
    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('خطأ', 'لا يمكن فتح خرائط Google');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في فتح خرائط Google: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF667eea),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'الموقع',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              if (_latitude != null && _longitude != null)
                IconButton(
                  onPressed: _openInMaps,
                  icon: const Icon(
                    Icons.map,
                    color: Color(0xFF667eea),
                  ),
                  tooltip: 'فتح في خرائط Google',
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Address input field
          TextFormField(
            controller: _addressController,
            readOnly: widget.readOnly,
            decoration: InputDecoration(
              labelText: 'العنوان',
              hintText: 'ادخل العنوان أو ابحث عن موقع',
              border: const OutlineInputBorder(),
              suffixIcon: widget.readOnly 
                  ? null 
                  : IconButton(
                      onPressed: () => _searchLocation(_addressController.text),
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                    ),
            ),
            onFieldSubmitted: widget.readOnly ? null : _searchLocation,
          ),
          
          if (!widget.readOnly) ...[
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _getCurrentLocation,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location, size: 18),
                    label: const Text('الموقع الحالي'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF667eea),
                      side: const BorderSide(color: Color(0xFF667eea)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (_latitude != null && _longitude != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openInMaps,
                      icon: const Icon(Icons.map, size: 18),
                      label: const Text('عرض في الخريطة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          
          // Coordinates display
          if (_latitude != null && _longitude != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.gps_fixed,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الإحداثيات: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Helper widget for displaying location in read-only mode
class LocationDisplayWidget extends StatelessWidget {
  final String address;
  final double? latitude;
  final double? longitude;
  final bool showMapButton;

  const LocationDisplayWidget({
    Key? key,
    required this.address,
    this.latitude,
    this.longitude,
    this.showMapButton = true,
  }) : super(key: key);

  Future<void> _openInMaps() async {
    if (latitude == null || longitude == null) {
      // Try to search by address
      final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
      
      try {
        if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
          await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar('خطأ', 'لا يمكن فتح خرائط Google');
        }
      } catch (e) {
        Get.snackbar('خطأ', 'فشل في فتح خرائط Google: ${e.toString()}');
      }
      return;
    }

    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    
    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('خطأ', 'لا يمكن فتح خرائط Google');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في فتح خرائط Google: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF667eea),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'الموقع',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              if (showMapButton)
                IconButton(
                  onPressed: _openInMaps,
                  icon: const Icon(
                    Icons.map,
                    color: Color(0xFF667eea),
                  ),
                  tooltip: 'فتح في خرائط Google',
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            address,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3748),
              height: 1.4,
            ),
          ),
          
          if (showMapButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openInMaps,
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('الحصول على الاتجاهات'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF667eea),
                  side: const BorderSide(color: Color(0xFF667eea)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

