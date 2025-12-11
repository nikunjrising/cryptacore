
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'MiningController1.dart';


class MiningScreen extends StatelessWidget {
  MiningScreen({super.key});

  final MiningController1 controller = Get.put(MiningController1());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mining")),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // CURRENT MINED
              Text(
                "Current Mined: ${controller.currentMining.value.toStringAsFixed(6)}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // MINING RATE (public getter)
              Text(
                "Mining Rate: ${controller.currentRatePerSecond().toStringAsFixed(8)} / sec",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),

              // REMAINING TIME
              Text(
                "Remaining Time: ${controller.formattedRemaining()}",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 40),

              // BOOST (Ad) - only enabled while session active
              ElevatedButton(
                onPressed: controller.isMining.value ? controller.applyAdBoost : null,
                child: const Text("Boost with Ad"),
              ),
              const SizedBox(height: 20),

              // START / ACTIVE BUTTON
              controller.isMining.value
                  ? ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: const Text("Mining Active..."),
              )
                  : ElevatedButton(
                onPressed: () {
                  // For testing you said sessionHr = 0.1 hr -> 6 minutes = 360 seconds
                  controller.startMining(sessionSeconds: 360);
                },
                child: const Text("Start Mining"),
              ),
            ],
          ),
        );
      }),
    );
  }


}

