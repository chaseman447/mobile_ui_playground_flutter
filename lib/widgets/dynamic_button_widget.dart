import 'package:flutter/material.dart';
import '../utils/color_parser.dart'; // Import the color parser utility
import '../utils/alignment_parser.dart'; // Import alignment parsing utilities
import '../services/navigation_service.dart'; // Import navigation service

class DynamicButtonWidget extends StatelessWidget {
  final String buttonTextContent;
  final Color buttonBackgroundColor;
  final Color buttonTextColor;
  final double buttonBorderRadius;
  final bool isVisible;
  final Alignment alignment;
  final double padding;
  final VoidCallback? onPressed;
  final String? navigationAction;
  final String? navigationTarget;
  final NavigationService _navigationService = NavigationService();

  DynamicButtonWidget({
    super.key,
    required this.buttonTextContent,
    required this.buttonBackgroundColor,
    required this.buttonTextColor,
    required this.buttonBorderRadius,
    required this.isVisible,
    required this.alignment,
    required this.padding,
    this.onPressed,
    this.navigationAction,
    this.navigationTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Align(
          alignment: alignment,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton(
              onPressed: _getButtonAction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
                foregroundColor: buttonTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonBorderRadius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 3,
              ),
              child: Text(buttonTextContent),
            ),
          ),
        ),
      ),
    );
  }

  VoidCallback? _getButtonAction() {
    if (onPressed != null) {
      return onPressed;
    }
    
    if (navigationAction != null && navigationTarget != null) {
      return () {
        switch (navigationAction) {
          case 'navigateToScreen':
            _navigationService.navigateToScreen(navigationTarget!);
            break;
          case 'navigateToLayout':
            _navigationService.navigateToLayout(navigationTarget!);
            break;
          case 'openLayoutManager':
            _navigationService.navigateToLayoutManager();
            break;
          default:
            debugPrint('Unknown navigation action: $navigationAction');
        }
      };
    }
    
    return null;
  }
}
