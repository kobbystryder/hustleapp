import 'package:flutter/material.dart';

class ArtisanDetailsPage extends StatelessWidget {
  final String artisanName;
  final String artisanService;
  final String artisanDescription;
  final double rating;
  final String profileImageUrl; // URL of the artisan's profile image

  const ArtisanDetailsPage({
    super.key,
    required this.artisanName,
    required this.artisanService,
    required this.artisanDescription,
    required this.rating,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(artisanName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture and Name
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artisanName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      artisanService,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow),
                        SizedBox(width: 5),
                        Text(
                          '$rating',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Description
            Text(
              'About $artisanName',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              artisanDescription,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Contact Button
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.phone),
                label: Text('Contact $artisanName'),
                onPressed: () {
                  // Implement contact functionality
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
