import 'package:alaket_ios/home_fragment.dart';
import 'package:flutter/material.dart';
import 'package:onboarding/onboarding.dart';

class OnBoarding extends StatelessWidget {
  final onboardingPagesList = [
    PageModel(
      widget: Column(
        children: [
          Container(
              padding: EdgeInsets.only(bottom: 45.0),
              child: Image.asset('assets/icons/llogo.png')),
          Container(
            width: double.infinity,
            child: Text(
              'Размещайте свою спецтехнику для получения заявок по услугам от клиентов онлайн.',
              style: pageInfoStyle,
            ),
          ),
        ],
      ),
    ),
    PageModel(
      widget: Column(
        children: [
          Container(
              padding: EdgeInsets.only(bottom: 45.0),
              child: Image.asset('assets/icons/llogo.png')),
          Text(
            'Находите друг друга по местоположению, связывайтесь в чате или по телефону.',
            style: pageInfoStyle,
          )
        ],
      ),
    ),
    PageModel(
      widget: Column(
        children: [
          Container(
              padding: EdgeInsets.only(bottom: 45.0),
              child: Image.asset('assets/icons/llogo.png')),
          Text(
            'Нужны услуги спецтехники? Тогда размещайте заявку и специалисты свяжутся с вами.',
            style: pageInfoStyle,
          ),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Onboarding(
        proceedButtonStyle: ProceedButtonStyle(
          proceedButtonRoute: (context) {
            return Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => Home()));
          },
        ),
        isSkippable: true,
        pages: onboardingPagesList,
        indicator: Indicator(
          indicatorDesign: IndicatorDesign.line(
            lineDesign: LineDesign(
              lineType: DesignType.line_uniform,
            ),
          ),
        ),
      ),
    );
  }
}
