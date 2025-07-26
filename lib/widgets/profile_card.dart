import 'package:flutter/material.dart';
import '../utils/color_parser.dart'; // Import the color parser utility
import '../utils/alignment_parser.dart'; // Import alignment parsing utilities

class ProfileCard extends StatelessWidget {
  final Color backgroundColor;
  final double borderRadius;
  final bool isVisible;
  final Alignment alignment;
  final double padding;

  final double profileImageBorderRadius;
  final double profileImageSize;

  final String nameTextContent;
  final double nameFontSize;
  final FontWeight nameFontWeight;
  final Color nameTextColor;
  final TextAlign nameTextAlign;
  final bool isNameTextVisible;
  final Alignment nameTextAlignment;
  final double nameTextPadding;

  final String titleTextContent;
  final double titleFontSize;
  final Color titleTextColor;
  final bool isTitleVisible;
  final TextAlign titleTextAlign;
  final Alignment titleTextAlignment;
  final double titleTextPadding;

  final String bioTextContent;
  final double bioFontSize;
  final Color bioTextColor;
  final TextAlign bioTextAlign;
  final bool isBioTextVisible;
  final Alignment bioTextAlignment;
  final double bioTextPadding;

  final Animation<double> scaleAnimation;

  const ProfileCard({
    super.key,
    required this.backgroundColor,
    required this.borderRadius,
    required this.isVisible,
    required this.alignment,
    required this.padding,
    required this.profileImageBorderRadius,
    required this.profileImageSize,
    required this.nameTextContent,
    required this.nameFontSize,
    required this.nameFontWeight,
    required this.nameTextColor,
    required this.nameTextAlign,
    required this.isNameTextVisible,
    required this.nameTextAlignment,
    required this.nameTextPadding,
    required this.titleTextContent,
    required this.titleFontSize,
    required this.titleTextColor,
    required this.isTitleVisible,
    required this.titleTextAlign,
    required this.titleTextAlignment,
    required this.titleTextPadding,
    required this.bioTextContent,
    required this.bioFontSize,
    required this.bioTextColor,
    required this.bioTextAlign,
    required this.isBioTextVisible,
    required this.bioTextAlignment,
    required this.bioTextPadding,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Align(
          alignment: alignment,
          child: AnimatedBuilder(
            animation: scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: scaleAnimation.value,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: 'profile_image',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(profileImageBorderRadius),
                          child: Image.network(
                            'https://picsum.photos/150?random=4',
                            width: profileImageSize,
                            height: profileImageSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: profileImageSize,
                                height: profileImageSize,
                                color: Colors.grey[300],
                                child: const Icon(Icons.person, size: 50),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Visibility(
                        visible: isNameTextVisible,
                        child: Padding(
                          padding: EdgeInsets.all(nameTextPadding),
                          child: Align(
                            alignment: nameTextAlignment,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: nameFontSize,
                                fontWeight: nameFontWeight,
                                color: nameTextColor,
                              ),
                              child: Text(
                                nameTextContent,
                                textAlign: nameTextAlign,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (isTitleVisible)
                        Padding(
                          padding: EdgeInsets.all(titleTextPadding),
                          child: Align(
                            alignment: titleTextAlignment,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: titleFontSize,
                                color: titleTextColor,
                              ),
                              child: Text(
                                titleTextContent,
                                textAlign: titleTextAlign,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 15),
                      Visibility(
                        visible: isBioTextVisible,
                        child: Padding(
                          padding: EdgeInsets.all(bioTextPadding),
                          child: Align(
                            alignment: bioTextAlignment,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: bioFontSize,
                                color: bioTextColor,
                              ),
                              child: Text(
                                bioTextContent,
                                textAlign: bioTextAlign,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
