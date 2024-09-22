import 'package:flutter/material.dart';

import 'artisan_detail_page.dart';

class DetailsPage extends StatelessWidget {
  final String category;
  const DetailsPage({required this.category, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ArtisanDetailsPage(
                            artisanName: 'Kenton',
                            artisanService: "Coding",
                            artisanDescription:
                                'In a land of myth and a time of magic, the destiny of a great kingdom rests on the shoulder of a young warlock and his name is Merlin',
                            profileImageUrl: 'https://picsum.photos/200/300',
                            rating: 5.5,
                          ))),
              title: Text('$category $index'),
            );
          },
          separatorBuilder: (context, int) {
            return const SizedBox();
          },
          itemCount: 10),
    );
  }
}
