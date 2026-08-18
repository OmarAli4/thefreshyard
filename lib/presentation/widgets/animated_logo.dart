import 'package:flutter/material.dart';

const Color _brandGold = Color(0xFFC4AB63);

class AnimatedLogo extends StatefulWidget {
  final double height;
  final bool showName;
  
  const AnimatedLogo({super.key, this.height = 50, this.showName = true});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with TickerProviderStateMixin {
  late AnimationController _walkController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _walkController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 8),
    )..repeat();
    
    _bounceController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 350),
    )..repeat(reverse: true);
    
    _bounceAnimation = Tween<double>(begin: 0, end: -2.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _walkController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manSize = widget.height * 0.9;
    
    final logoImage = Image.asset(
      'assets/images/logo.png',
      height: manSize,
      filterQuality: FilterQuality.low,
    );

    if (widget.showName) {
      return RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            
            return ClipRect(
              child: SizedBox(
                height: widget.height,
                width: availableWidth,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: Listenable.merge([_walkController, _bounceController]),
                      child: logoImage,
                      builder: (context, child) {
                        final totalDistance = availableWidth + manSize;
                        final xPos = -manSize + (_walkController.value * totalDistance);
                        
                        return Positioned(
                          left: xPos,
                          child: Transform.translate(
                            offset: Offset(0, _bounceAnimation.value),
                            child: child,
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _walkController,
                      builder: (context, _) {
                        final totalDistance = availableWidth + manSize;
                        final xPos = -manSize + (_walkController.value * totalDistance);
                        final manCenter = xPos + manSize / 2;
                        final textCenter = availableWidth / 2;
                        
                        const double textWidth = 140.0;
                        final riseStart = textCenter - textWidth / 2 - manSize * 0.8;
                        final holdStart = textCenter - textWidth / 2 + 10.0;
                        final holdEnd = textCenter + textWidth / 2 + manSize * 0.6;
                        final landEnd = holdEnd + 60.0;
                        
                        final maxJump = -widget.height * 0.65;
                        double yOffset = 0.0;
                        
                        if (manCenter >= riseStart && manCenter <= landEnd) {
                          if (manCenter < holdStart) {
                            final progress = (manCenter - riseStart) / (holdStart - riseStart);
                            yOffset = maxJump * Curves.easeOut.transform(progress.clamp(0.0, 1.0));
                          } else if (manCenter <= holdEnd) {
                            yOffset = maxJump;
                          } else {
                            final progress = 1.0 - ((manCenter - holdEnd) / (landEnd - holdEnd));
                            yOffset = maxJump * Curves.easeInOut.transform(progress.clamp(0.0, 1.0));
                          }
                        }
                        
                        return Transform.translate(
                          offset: Offset(0, yOffset),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'The Fresh',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  color: _brandGold,
                                  fontSize: widget.height * 0.28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'YARD',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  color: _brandGold,
                                  fontSize: widget.height * 0.22,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 4.0,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      return RepaintBoundary(
        child: AnimatedBuilder(
          animation: _bounceController,
          child: logoImage,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _bounceAnimation.value),
              child: child,
            );
          },
        ),
      );
    }
  }
}
