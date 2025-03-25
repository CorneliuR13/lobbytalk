import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
          ? EdgeInsets.all(4)
          : EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Colors.lightBlueAccent.shade100
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: messageType == 'image'
          ? _buildImageMessage()
          : Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildImageMessage() {
    return GestureDetector(
      onTap: () {
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
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                width: 200,
                color: Colors.grey[300],
                child: Icon(Icons.error, color: Colors.red),
              ),
              fit: BoxFit.cover,
              height: 200,
              width: 200,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Photo",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}