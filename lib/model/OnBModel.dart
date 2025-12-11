import 'dart:ui';

import 'package:cryptacore/const/color.dart';

class OnBModel {
  final String bg;
  final String logo;
  final String subLogo;
  final String title;
  final String title2;
  final String subtitle;
  final Color color;

  OnBModel({
    required this.bg,
    required this.logo,
    required this.subLogo,
    required this.title,
    required this.title2,
    required this.subtitle,
    required this.color,
  });
}


final List<OnBModel> onboardingData = [
  OnBModel(
    bg: 'assets/images/onb_bg_1.png',
    logo: 'assets/svg/onb_logo_1.svg',
    subLogo: 'assets/svg/onb_sub_logo_1.svg',
    title: 'Experience Mining, Simplified',
    title2: 'Mine Solana, Anywhere',
    subtitle: 'Start mining Solana tokens right from your phone, no expensive rigs or complex setups needed.',
    color: AppColor.pinkColor,
  ),
  OnBModel(
    bg: 'assets/images/onb_bg_2.png',
    logo: 'assets/svg/onb_logo_2.svg',
    subLogo: 'assets/svg/onb_sub_logo_2.svg',
    title: 'Boost and Earn More Rewards',
    title2: 'Power Up Your Mining',
    subtitle: 'Use boosters, daily spins, and ad rewards to accelerate your mining rate. Watch your balance grow in real time.',
    color: AppColor.skyColor,

  ),
  OnBModel(
    bg: 'assets/images/onb_bg_3.png',
    logo: 'assets/svg/onb_logo_3.svg',
    subLogo: 'assets/svg/onb_sub_logo_3.svg',
    title: 'Secure. Smart.\nRewarding',
    title2: 'Your Wallet, Your Control',
    subtitle: 'Use boosters, daily spins, and ad rewards to accelerate your mining rate. Watch your balance grow in real time.',
    color: AppColor.greenColor,

  ),
  OnBModel(
    bg: 'assets/images/onb_bg_4.png',
    logo: 'assets/svg/onb_logo_4.svg',
    subLogo: 'assets/svg/onb_sub_logo_4.svg',
    title: 'Invite Friends and\NEarn More',
    title2: 'Grow Together, Earn Together.',
    subtitle: 'Share CryptaCore with your friends and unlock bonus mining speed, extra rewards, and exclusive boosters every time they join using your link. The more you invite, the faster you earn.',
    color: AppColor.purpleColor,

  ),

];
