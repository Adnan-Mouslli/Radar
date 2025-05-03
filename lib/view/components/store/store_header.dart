import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StoreHeader extends StatelessWidget {
  final String storeName;
  final String storeCity;
  final String storeAddress;
  final String? storeImage;
  final dynamic phone;
  final Function(String) launchWhatsApp;

  const StoreHeader({
    Key? key,
    required this.storeName,
    required this.storeCity,
    required this.storeAddress,
    this.storeImage,
    this.phone,
    required this.launchWhatsApp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // صورة المتجر
          _buildStoreImage(),
          SizedBox(width: 16),

          // معلومات المتجر
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (storeCity.isNotEmpty)
                  Text(
                    storeCity,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                if (storeAddress.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white60, size: 14),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          storeAddress,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // زر اتصال واتساب
          IconButton(
            onPressed: () {
              if (phone != null) {
                // تنسيق رقم الهاتف لواتساب
                final formattedPhone = phone.toString().replaceAll('+', '');
                launchWhatsApp('https://wa.me/$formattedPhone');
              }
            },
            icon: Icon(
              FontAwesomeIcons.whatsapp,
              color: Color(0xFF25D366),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreImage() {
    if (storeImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: CachedNetworkImage(
          imageUrl: storeImage!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 60,
            height: 60,
            color: Colors.grey[800],
            child: Icon(Icons.store, color: Colors.grey),
          ),
          errorWidget: (context, url, error) => Container(
            width: 60,
            height: 60,
            color: Colors.grey[800],
            child: Icon(Icons.store, color: Colors.grey),
          ),
        ),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(40),
        ),
        child: Icon(Icons.store, color: Colors.white, size: 30),
      );
    }
  }
}