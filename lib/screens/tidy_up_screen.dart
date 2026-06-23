import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/shared_background.dart';
import '../services/tts_service.dart';
import '../widgets/tts_audio_buttons.dart';

class ToyItem {
  final int id;
  final IconData icon;
  final Color color;

  ToyItem(this.id, this.icon, this.color);
}

class TidyUpScreen extends StatefulWidget {
  final int levelType;

  const TidyUpScreen({super.key, this.levelType = 1});

  @override
  State<TidyUpScreen> createState() => _TidyUpScreenState();
}

class _TidyUpScreenState extends State<TidyUpScreen> {
  List<ToyItem> toys = [];
  List<ToyItem> targets = [];
  List<int> matchedToyIds = [];

  @override
  void initState() {
    super.initState();
    toys = [
      ToyItem(1, Icons.smart_toy, Colors.blue),
      ToyItem(2, Icons.directions_car, Colors.red),
      ToyItem(3, Icons.pedal_bike, Colors.green),
      ToyItem(4, Icons.flight, Colors.orange),
    ];
    targets = List.from(toys);
  }

  @override
  Widget build(BuildContext context) {
    return SharedBackground(
      child: Center(
        child: SingleChildScrollView(
          child: WhiteCardContainer(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        ),
                      ),
                      const Text(
                        'BERES-BERES',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,

                        ),
                      ),
                      TTSAudioButtons(
                        textToSpeak: widget.levelType == 1 
                            ? "Masukkan semua mainan ke dalam kotak kardus!" 
                            : "Tarik mainan ke bayangan yang sesuai!",
                        iconSize: 40.0,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Toys
                  if (toys.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Pintar Sekali!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: toys.map((toy) => Draggable<int>(
                        data: toy.id,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Icon(toy.icon, size: 80, color: toy.color.withOpacity(0.8)),
                        ),
                        childWhenDragging: Icon(toy.icon, size: 80, color: Colors.grey[300]),
                        child: Icon(toy.icon, size: 80, color: toy.color),
                      )).toList(),
                    ),
                    
                  const SizedBox(height: 60),
                  
                  // Drop Area based on Level Type
                  if (widget.levelType == 1)
                    DragTarget<int>(
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: candidateData.isNotEmpty ? Colors.amber[200] : Colors.amber[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.amber[800]!,
                              width: candidateData.isNotEmpty ? 8 : 4,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.inventory_2,
                              size: 120,
                              color: Colors.brown,
                            ),
                          ),
                        );
                      },
                      onAcceptWithDetails: (details) {
                        setState(() {
                          toys.removeWhere((toy) => toy.id == details.data);
                        });
                        if (toys.isEmpty) {
                          Get.snackbar(
                            'Selesai!',
                            'Semua mainan sudah rapi di dalam kotak!',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        }
                      },
                    )
                  else
                    Wrap(
                      spacing: 30,
                      runSpacing: 30,
                      alignment: WrapAlignment.center,
                      children: targets.map((target) => DragTarget<int>(
                        onWillAcceptWithDetails: (details) => details.data == target.id,
                        onAcceptWithDetails: (details) {
                          setState(() {
                            toys.removeWhere((toy) => toy.id == details.data);
                            matchedToyIds.add(details.data);
                          });
                          if (toys.isEmpty) {
                            Get.snackbar(
                              'Hebat!',
                              'Kamu berhasil mencocokkan semua bentuk!',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          bool isMatched = matchedToyIds.contains(target.id);
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: isMatched ? Colors.white : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: candidateData.isNotEmpty ? Colors.green : Colors.grey[400]!,
                                width: candidateData.isNotEmpty ? 4 : 2,
                                style: isMatched ? BorderStyle.none : BorderStyle.solid,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                target.icon,
                                size: 80,
                                color: isMatched ? target.color : Colors.grey[400],
                              ),
                            ),
                          );
                        },
                      )).toList(),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
