import 'package:flutter/material.dart';
import 'package:gallery_asset_picker/features/camera/controllers/camera_controller.dart';

class CameraShutterButton extends StatefulWidget {
  const CameraShutterButton({Key? key, required this.xCameraController, this.size = 70.0}) : super(key: key);

  final double size;
  final XCameraController xCameraController;

  @override
  _CameraShutterButtonState createState() => _CameraShutterButtonState();
}

class _CameraShutterButtonState extends State<CameraShutterButton> with TickerProviderStateMixin {
  late XCameraController _camController;
  late final AnimationController _pulseController;

  final _margin = 0.0;
  final _strokeWidth = 6.0;

  @override
  void initState() {
    super.initState();
    _camController = widget.xCameraController;

    // Splash animation controller
    _pulseController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this)
      ..addStatusListener((status) {
        if (_pulseController.status == AnimationStatus.completed) {
          _pulseController.reverse();
        }
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _cameraButtonPressed() {
    _camController.takePicture(context);
    _pulseController.forward(from: 0.2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size,
      width: widget.size,
      padding: EdgeInsets.all(_margin),
      child: GestureDetector(
        onTap: _cameraButtonPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background
            Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
            ),

            // Pulse animation
            _Pulse(
              controller: _pulseController,
              size: widget.size - _strokeWidth - _margin - 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _Pulse extends StatefulWidget {
  const _Pulse({Key? key, required this.controller, this.size = 50.0}) : super(key: key);

  final double size;
  final AnimationController controller;

  @override
  _PulseState createState() => _PulseState();
}

class _PulseState extends State<_Pulse> {
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.easeIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Center(
          child: Opacity(
            opacity: _animation.value,
            child: Transform.scale(
              scale: widget.controller.status == AnimationStatus.reverse ? 1.0 : _animation.value,
              child: SizedBox.fromSize(
                size: Size.square(widget.size),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
