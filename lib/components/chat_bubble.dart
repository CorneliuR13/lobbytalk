import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'image_download_web.dart' if (dart.library.io) 'image_download_mobile.dart';

// Conditionally import html for web platform only
import 'dart:ui' as ui;

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageType;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.messageType = 'text',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      padding: messageType == 'image'
          ? const EdgeInsets.all(4)
          : const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Colors.lightBlueAccent.shade100
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: messageType == 'image'
          ? _buildImageMessage(context)
          : Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // When image is tapped, show it in a full-screen dialog with zoom options
        showDialog(
          context: context,
          builder: (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Fullscreen image with interactive viewer for zooming
                InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: message,
                    placeholder: (context, url) => Container(
                      color: Colors.black,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.black,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 48),
                            SizedBox(height: 8),
                            Text(
                              "Error loading image",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
                // Close button
                Positioned(
                  top: 20,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                ),
                // Download button
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.download, color: Colors.white),
                      onPressed: () {
                        downloadImage(message);
                      },
                      tooltip: 'Download image',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: message,
              placeholder: (context, url) => Container(
                height: 200,
                width: 200,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                width: 200,
                color: Colors.grey[300],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(height: 4),
                    const Text(
                      "Image failed to load",
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              fit: BoxFit.cover,
              height: 200,
              width: 200,
              // Add specific web settings to improve loading
              cacheKey: message,
              memCacheWidth: 800, // Higher resolution cache for web
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Photo",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.touch_app,
                size: 12,
                color: Colors.grey[700],
              ),
              Text(
                " Tap to view",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void downloadImage(String url) {

  }
}