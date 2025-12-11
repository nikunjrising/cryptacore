import 'package:bounce/bounce.dart';
import 'package:country_pickers/countries.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:cryptacore/const/color.dart';
import 'package:cryptacore/ui/auth/login.dart';
import 'package:cryptacore/ui/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../const/app_images.dart';
import '../widget/AppSnackBar.dart';

class SelectCountryScreen extends StatefulWidget {
  const SelectCountryScreen({super.key});

  @override
  State<SelectCountryScreen> createState() => _SelectCountryScreenState();
}

class _SelectCountryScreenState extends State<SelectCountryScreen> {
  List<Country> countries = countryList;
  late List<Country> filteredCountries;

  Country? selectedCountry; // 🔥 selected country


  @override
  void initState() {
    super.initState();
    filteredCountries = countries;
  }


  void _filterCountries(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredCountries = countries.where((country) {
        return country.name.toLowerCase().contains(lowerQuery) ||
            country.isoCode.toLowerCase().contains(lowerQuery) ||
            country.phoneCode.contains(query);
      }).toList();
    });
  }
  Widget _buildCountryTile(Country country) {
    final isSelected = selectedCountry?.isoCode == country.isoCode;

    return Bounce(
      onTap: () {
        setState(() {
          selectedCountry = country; // 🔥 select country
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColor.skyColor : AppColor.grayColor,
            width: isSelected ? 2 : 1,

          ),

          borderRadius: BorderRadius.circular(15)
        ),
        margin: EdgeInsets.symmetric(horizontal: 12,vertical: 5),
        padding: EdgeInsets.only(left: 15),

        child: Row(
          children: [
            SvgPicture.asset( !isSelected ? AppSvg.radioUlSelected : AppSvg.radioSelected,),
            Expanded(
              child: ListTile(
                leading: CountryPickerUtils.getDefaultFlagImage(country),
                title: Text(country.name),
                subtitle: Text("+${country.phoneCode}"),
                trailing: Text(country.isoCode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(AppImages.bgApp),fit: BoxFit.fill)
        ),
        padding: EdgeInsets.all(15),
        child: Column(
          spacing: 10,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 15),

            Text('Select Your Country',style: TextStyle(color: AppColor.skyColor,fontSize: 28,),),
            Text('Choose your country to personalize rewards and offers.',textAlign: TextAlign.center,style: TextStyle(color: AppColor.grayColor,fontSize: 16,),),
            Expanded(child:   countryWidget(),),
            Bounce(
              onTap: () {
                if (selectedCountry != null) {
                  Get.off(LoginScreen());
                } else {

                  AppSnackBar.show(
                    title: "Please select a country",
                    subtitle: "",
                  );

                }
              },
              child: Container(
                height: 50,
                width: 80.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.skyColor,width: 1),
                  borderRadius: BorderRadius.circular(50)
                ),
                child: Text('Select Your Country',style: TextStyle(color: AppColor.skyColor,fontSize: 20),),
              ),
            ),
            if(MediaQuery.of(context).padding.bottom > 0)
              Container( height: MediaQuery.of(context).padding.bottom,)


          ],
        ),
      ),
    );
  }

  countryWidget() {
    return Container(
      decoration:  BoxDecoration(
        borderRadius:BorderRadius.circular(10),
        border: Border.all(color: AppColor.skyColor,width: 1)
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              // controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search country or code',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _filterCountries,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCountries.length,
              itemBuilder: (context, index) {
                return _buildCountryTile(filteredCountries[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
