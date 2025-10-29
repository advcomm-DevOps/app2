import 'package:flutter/material.dart';
import 'dashboard_controller.dart';
import 'package:xdoc/core/services/theme_service.dart';

class DashboardLogsView {
  // Show logs dialog
  static void showLogsDialog(BuildContext context, DashboardController dashboardController) {
    // Get logs from dashboard controller
    final logs = dashboardController.getAllLogs();
    bool showSuccessLogs = false; // Default to fail logs
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Initialize theme service
            final themeService = ThemeService();
            
            // Theme color getters - Use ThemeService
            final surfaceColor = themeService.surfaceColor;
            final cardColor = themeService.cardColor;
            final textColor = themeService.textColor;
            final subtitleColor = themeService.subtitleColor;
            final primaryAccent = themeService.primaryAccent;
            final borderColor = themeService.borderColor;
            
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 600,
                height: 500,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.list_alt,
                              color: primaryAccent,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Application Logs',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close, color: subtitleColor),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Tab selector
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          // Failed logs tab
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setDialogState(() => showSuccessLogs = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !showSuccessLogs ? Colors.red.withOpacity(0.2) : Colors.transparent,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                  border: !showSuccessLogs ? Border.all(color: Colors.red.withOpacity(0.5)) : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: !showSuccessLogs ? Colors.red : subtitleColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Failed (${logs["fail"]?.length ?? 0})',
                                      style: TextStyle(
                                        color: !showSuccessLogs ? Colors.red : subtitleColor,
                                        fontWeight: !showSuccessLogs ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Success logs tab
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setDialogState(() => showSuccessLogs = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: showSuccessLogs ? Colors.green.withOpacity(0.2) : Colors.transparent,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                  border: showSuccessLogs ? Border.all(color: Colors.green.withOpacity(0.5)) : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: showSuccessLogs ? Colors.green : subtitleColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Success (${logs["success"]?.length ?? 0})',
                                      style: TextStyle(
                                        color: showSuccessLogs ? Colors.green : subtitleColor,
                                        fontWeight: showSuccessLogs ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Logs list
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Builder(
                          builder: (context) {
                            final currentLogs = showSuccessLogs 
                              ? (logs["success"] ?? [])
                              : (logs["fail"] ?? []);
                            
                            if (currentLogs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      showSuccessLogs ? Icons.check_circle : Icons.error,
                                      color: showSuccessLogs ? Colors.green : Colors.red,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      showSuccessLogs 
                                        ? 'No successful operations logged yet'
                                        : 'No failed operations logged yet',
                                      style: TextStyle(
                                        color: subtitleColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            return ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: currentLogs.length,
                              itemBuilder: (context, index) {
                                final log = currentLogs[currentLogs.length - 1 - index]; // Reverse order (newest first)
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: showSuccessLogs 
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: showSuccessLogs 
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.red.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        showSuccessLogs ? Icons.check_circle : Icons.error,
                                        color: showSuccessLogs ? Colors.green : Colors.red,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              log["message"] ?? "Unknown operation",
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              log["time"] ?? "Unknown time",
                                              style: TextStyle(
                                                color: subtitleColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            dashboardController.clearLogs();
                            setDialogState(() {}); // Refresh the dialog
                          },
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear All Logs'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.orange,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            backgroundColor: primaryAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}