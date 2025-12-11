import 'dart:math';

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:random_name_generator/random_name_generator.dart';
import 'package:sizer/sizer.dart';

import '../../const/AnimatedFlipperText.dart';
import '../../const/app_images.dart';
import '../../const/color.dart';
import '../../controller/MiningController.dart';
import '../widget/DiagonalBorderPainter.dart';

class WalletItem {
  final String name;
  final String accountNumber;
  final String amount;

  WalletItem({
    required this.name,
    required this.accountNumber,
    required this.amount,
  });
}


class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final MiningController miningController = Get.find();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController networkController = TextEditingController();
  late List<WalletItem> userList = generateUserList(100);

  final _formKey = GlobalKey<FormState>();

  double currentAmount = 0.00055;

  String selectedNetwork = "";
  final List<String> networks = ["TRC20", "ERC20", "BEP20", "Bank"];

  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController ibanController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Your Wallet',style: TextStyle(fontSize: 24,fontWeight: FontWeight.w400,color: AppColor.skyColor),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 25,
          children: [
            balanceSection(),
            withdrawal(),
            usersList()
          ],
        ),
      ),
    );
  }


  Widget balanceSection(){
    return Obx(() {
      return CustomPaint(
        painter: DiagonalBorderPainter(AppColor.skyGradient),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 15,
            children: [
              Text('Available Balance',style: TextStyle(color: AppColor.skyColor,fontWeight: FontWeight.w400,fontSize: 25),),
              CustomPaint(
                painter: DiagonalBorderPainter(AppColor.skyGradient),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          Text('Total Mining',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 12),),
                          AnimatedFlipperText(
                            value: miningController.currentMining.value.toStringAsFixed(6),
                            fractionDigits: 8,
                            fontSize: 13,
                            color: AppColor.skyColor,
                          ),

                        ],
                      ),
                      SvgPicture.asset(AppSvg.dividerSky),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 5,
                        children: [
                          Text('Wallet Balance',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 12),),
                          AnimatedFlipperText(
                            value: (miningController.currentMining.value + miningController.earnedByReward.toDouble() + miningController.earnedBySpinWheel.toDouble()).toString(),
                            fractionDigits: 8,
                            fontSize: 13,
                            color: AppColor.skyColor,
                          ),
                        ],
                      ),
                      // Column(
                      //   mainAxisSize: MainAxisSize.min,
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   spacing: 5,
                      //   children: [
                      //     Text('Earned Today',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 12),),
                      //     Text( (miningController.currentMining.value + miningController.earnedByReward.toDouble() + miningController.earnedBySpinWheel.toDouble()).toString() ,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 12),),
                      //     AnimatedFlipperText(
                      //       value: miningController.earnedToday.toStringAsFixed(6),
                      //       fractionDigits: 8,
                      //       fontSize: 13,
                      //       color: AppColor.skyColor,
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      );
    },);

  }


  Widget withdrawal() {
    return CustomPaint(
      painter: DiagonalBorderPainter(AppColor.skyGradient),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Form(
          key: _formKey, // ⬅ FORM KEY
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 15,
              children: [
                Text(
                  'Withdraw USDT',
                  style: TextStyle(
                      color: AppColor.skyColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 25),
                ),
            
                // ---------------- Amount Field with VALIDATOR ----------------
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Amount',
                    hintStyle: TextStyle(color: AppColor.grayColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter amount";
                    }
            
                    final amount = double.tryParse(value);
                    if (amount == null) return "Enter valid amount";

                    if (amount < 100) {
                      return "Minimum withdrawal is 100 USDT";
                    }
            
                    if (amount > miningController.currentMining.toDouble()) {
                      return "Insufficient balance (current balance is ${miningController.currentMining})";
                    }
            
                    return null;
                  },
                ),
            
                // ---------------- Recipient Field ----------------
                TextFormField(
                  controller: recipientController,
                  decoration: InputDecoration(
                    hintText: 'Enter recipient address',
                    hintStyle: TextStyle(color: AppColor.grayColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Recipient address required";
                    }
                    return null;
                  },
                ),
            
                // ---------------- Network Dropdown ----------------
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Select Network',
                    hintStyle: TextStyle(color: AppColor.grayColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: networks
                      .map((n) => DropdownMenuItem(
                    value: n,
                    child: Text(n, style: TextStyle(color: Colors.white)),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedNetwork = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Select a network";
                    }
                    return null;
                  },
                ),
            
                // ---------------- BANK ONLY FIELDS ----------------
                if (selectedNetwork == "Bank") ...[
                  TextFormField(
                    controller: bankNameController,
                    decoration: InputDecoration(
                      hintText: 'Bank Name',
                      hintStyle: TextStyle(color: AppColor.grayColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) {
                      if (selectedNetwork == "Bank" &&
                          (value == null || value.isEmpty)) {
                        return "Bank name required";
                      }
                      return null;
                    },
                  ),
            
                  TextFormField(
                    controller: ibanController,
                    decoration: InputDecoration(
                      hintText: 'IBAN / Account Number',
                      hintStyle: TextStyle(color: AppColor.grayColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) {
                      if (selectedNetwork == "Bank" &&
                          (value == null || value.isEmpty)) {
                        return "IBAN/Account number required";
                      }
                      if (value!.length < 10) {
                        return "Invalid IBAN/Account number";
                      }
                      return null;
                    },
                  ),
                ],
            
                // ---------------- Fee ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fee', style: TextStyle(color: AppColor.grayColor)),
                    Text('0.5897 USD', style: TextStyle(color: AppColor.grayColor)),
                  ],
                ),
            
                // ---------------- SUBMIT ----------------
                Bounce(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      _showSuccess("Withdrawal request submitted successfully!");
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 75.w,
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColor.skyColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "Withdraw",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }


  Widget usersList(){
    return  ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: userList.length,
      itemBuilder: (context, index) {
        final item = userList[index];
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.skyColor,width: 0.2)
          ),
          child: ListTile(
            title: Text(item.name),
            subtitle: Text(item.accountNumber),
            trailing: Text(item.amount),
          ),
        );
      },
    );
  }

  List<WalletItem> generateUserList(int count) {
    final random = Random();
    final randomNames = RandomNames(Zone.us);

    return List.generate(count, (index) {
      // Generate random full name (male + female mixed)
      String name = randomNames.fullName();

      // Random 4-digit ending
      String last4 = (random.nextInt(9000) + 1000).toString();

      // Masked account number
      String account = "XXXX XXxx XXxx X$last4";

      // Random amount 1–50 Solana
      String amount = "${random.nextInt(50) + 1} Solana";

      return WalletItem(
        name: name,
        accountNumber: account,
        amount: amount,
      );
    });
  }



}
