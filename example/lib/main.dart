import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smile_snap/smile_snap.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ModernTestPage(),
  ));
}

class ModernTestPage extends StatefulWidget {
  const ModernTestPage({super.key});

  @override
  State<ModernTestPage> createState() => _ModernTestPageState();
}

class _ModernTestPageState extends State<ModernTestPage> {
  File? _capturedImage;
  SnapTrigger _selectedTrigger = SnapTrigger.smile;
  String _captureTime = "";

  // Modern Cyberpunk Palette
  final Color _primaryColor = const Color(0xFF6C63FF); // AI Purple
  final Color _accentColor = const Color(0xFF00E5FF);  // Neon Cyan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0C29), // Deep Night Blue
              Color(0xFF302B63), // Purple tint
              Color(0xFF24243E), // Dark foundation
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- APP BAR ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.face_retouching_natural, color: _accentColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "SMILE SNAP AI",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        shadows: [Shadow(color: _primaryColor, blurRadius: 15)],
                      ),
                    ),
                  ],
                ),
              ),

              // --- 1. TRIGGER SELECTOR ---
              Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildGlassChip("😁 Smile", SnapTrigger.smile),
                    _buildGlassChip("👀 Blink (2x)", SnapTrigger.doubleBlink),
                    _buildGlassChip("😉 Left", SnapTrigger.blinkLeft),
                    _buildGlassChip("😉 Right", SnapTrigger.blinkRight),
                  ],
                ),
              ),

              // --- 2. CAMERA HERO SECTION ---
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        SmileSnap(
                          trigger: _selectedTrigger,
                          onCapture: (File image) {
                            log("IMAGE SAVED AT: ${image.path}");
                            final now = DateTime.now();
                            setState(() {
                              _capturedImage = image;
                              _captureTime = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
                            });
                            _showSuccessMessage();
                          },
                        ),

                        // Gradient Overlay (Bottom)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                              ),
                            ),
                          ),
                        ),

                        // Top "Rec" Badge
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "REC ●",
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        // Instructions
                        Positioned(
                          bottom: 40,
                          left: 20,
                          right: 20,
                          child: Column(
                            children: [
                              Text(
                                _getInstructionText(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "AI Confidence: 99%",
                                style: TextStyle(
                                  color: _accentColor.withOpacity(0.7),
                                  fontSize: 10,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- 3. RESULT SECTION (Fixed: Large Image) ---
              Expanded(
                flex: 3, // Increased flex to give more space for the big image
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withOpacity(0.95),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -5))
                    ],
                    border: Border(
                      top: BorderSide(color: _accentColor.withOpacity(0.3), width: 1),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.analytics_outlined, color: _accentColor, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  "LATEST CAPTURE",
                                  style: TextStyle(
                                    color: _accentColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            if (_captureTime.isNotEmpty)
                              Text(
                                "Time: $_captureTime",
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                              )
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Center the big image
                        Center(
                          child: _capturedImage == null
                              ? _buildEmptyState()
                              : _buildBigPhotoCard(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildGlassChip(String label, SnapTrigger trigger) {
    final isSelected = _selectedTrigger == trigger;
    return GestureDetector(
      onTap: () => setState(() => _selectedTrigger = trigger),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.1), style: BorderStyle.none),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera_back, color: Colors.white.withOpacity(0.3), size: 30),
          const SizedBox(height: 10),
          Text(
            "Waiting for magic...",
            style: TextStyle(color: Colors.white.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  // UPDATED: Big Photo Card Logic
  Widget _buildBigPhotoCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentColor.withOpacity(0.5), width: 1), // Neon border
        boxShadow: [
          BoxShadow(
              color: _accentColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 5)
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.file(
          _capturedImage!,
          height: 200, // Fixed height for big image
          width: 200, // Take full width
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _getInstructionText() {
    switch (_selectedTrigger) {
      case SnapTrigger.smile: return "Show me a big smile! 😁";
      case SnapTrigger.doubleBlink: return "Blink both eyes quickly! 👀";
      case SnapTrigger.blinkLeft: return "Wink Left Eye 😉";
      case SnapTrigger.blinkRight: return "Wink Right Eye 😉";
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _accentColor,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.black),
            SizedBox(width: 10),
            Text("Target Captured!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}