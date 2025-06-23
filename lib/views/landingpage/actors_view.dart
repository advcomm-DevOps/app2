import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';  // Make sure you're using go_router
import 'package:flutter_starter/core/routing/route_names.dart';

class ActorsView extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> actors;

  const ActorsView({
    Key? key,
    required this.title,
    required this.actors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 600;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
      ),
      body: Column(
        children: [
          _buildHeroSection(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 240.0 : 24.0,
                vertical: 16.0,
              ),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1,
                children: actors
                    .map((actor) => _buildSquareBox(actor, context))  // pass context
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Icon(
              Icons.group,
              size: 60,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Actors for $title',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Select an actor to proceed.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareBox(Map<String, dynamic> actor, BuildContext context) {  // add context param
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push(
            dashboardRoute,
            extra: actor, // pass the selected actor
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                actor['icon'],
                size: 32,
                color: Colors.white,
              ),
              SizedBox(height: 6),
              Text(
                actor['title'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
