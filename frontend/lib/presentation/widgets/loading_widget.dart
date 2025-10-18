import 'package:flutter/material.dart';
import '../../core/services/theme_service.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  
  const LoadingWidget({
    super.key,
    this.message,
  });
  
  static final TextStyle _loadingTextStyle = ThemeService.bodyStyle.copyWith(
    color: Colors.grey[600],
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: _loadingTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
