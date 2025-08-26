import 'package:flutter/material.dart';
import 'package:xdoc/views/landingpage/actors_view.dart';

class InterconnectsView extends StatelessWidget {
  final List<Map<String, dynamic>> interconnectors = [
    {
      "title": "Job Application",
      "description": "Job application details",
      "icon": Icons.assignment
    },
    {
      "title": "Invoice",
      "description": "Invoice details",
      "icon": Icons.receipt_long
    },
    {
      "title": "Invoice with Inventory",
      "description": "Invoice and inventory details",
      "icon": Icons.inventory_2
    },
    {
      "title": "Payroll",
      "description": "Payroll details",
      "icon": Icons.payments
    },
    {
      "title": "Report",
      "description": "Reports and analytics",
      "icon": Icons.bar_chart
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 600;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Interconnects'),
        centerTitle: true,
        elevation: 0,
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
              child: _buildSquareGrid(context),
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
              Icons.link,
              size: 60,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Welcome to Xdoc',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Connect your applications seamlessly.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      childAspectRatio: 1,
      children: interconnectors
          .map((item) => _buildSquareBox(context, item))
          .toList(),
    );
  }

  Widget _buildSquareBox(BuildContext context, Map<String, dynamic> item) {
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
          List<Map<String, dynamic>> actors = [];

          if (item['title'] == "Job Application") {
            actors = [
              {"title": "Job Employer", "icon": Icons.business},
              {"title": "Job Application", "icon": Icons.assignment_ind},
            ];
          } else if (item['title'] == "Invoice") {
            actors = [
              {"title": "Customer", "icon": Icons.person},
              {"title": "Invoice Record", "icon": Icons.description},
            ];
          } else if (item['title'] == "Invoice with Inventory") {
            actors = [
              {"title": "Inventory", "icon": Icons.inventory},
              {"title": "Invoice + Inventory", "icon": Icons.list_alt},
            ];
          } else if (item['title'] == "Payroll") {
            actors = [
              {"title": "Employee", "icon": Icons.people},
              {"title": "Payroll Record", "icon": Icons.receipt},
            ];
          } else if (item['title'] == "Report") {
            actors = [
              {"title": "Analytics", "icon": Icons.analytics},
              {"title": "Summary Report", "icon": Icons.insert_chart},
            ];
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActorsView(
                title: item['title'],
                actors: actors,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item['icon'],
                size: 32,
                color: Colors.white,
              ),
              SizedBox(height: 6),
              Text(
                item['title'],
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
