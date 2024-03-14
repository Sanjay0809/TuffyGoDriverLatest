import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/landingpage.dart';
import '../login/login.dart';
import '../noInternet/nointernet.dart';
import 'walletpage.dart';

class FlutterWavePage extends StatefulWidget {
  const FlutterWavePage({Key? key}) : super(key: key);

  @override
  State<FlutterWavePage> createState() => _FlutterWavePageState();
}

class _FlutterWavePageState extends State<FlutterWavePage> {
  bool _isLoading = false;
  bool _success = false;
  bool _failed = false;
  dynamic flutterwave;
  @override
  void initState() {
    payMoney();
    super.initState();
  }

//navigate pop
  pop() {
    Navigator.pop(context, true);
  }

  navigateLogout() {
    if (ownermodule == '1') {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LandingPage()),
            (route) => false);
      });
    } else {
      ischeckownerordriver = 'driver';
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false);
      });
    }
  }

//payment gateway code
  payMoney() async {
    setState(() {
      _isLoading = true;
    });

    final style = FlutterwaveStyle(
      appBarText: "Flutterwave Checkout",
      buttonColor: buttonColor,
      appBarIcon: const Icon(Icons.message, color: Color(0xffd0ebff)),
      buttonTextStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      appBarColor: const Color(0xffd0ebff),
      dialogCancelTextStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 16,
      ),
      dialogContinueTextStyle: const TextStyle(
        color: Colors.blue,
        fontSize: 16,
      ),
    );

    final Customer customer = Customer(
        name: userDetails['name'],
        phoneNumber: userDetails['mobile'],
        email: userDetails['email']);

    flutterwave = Flutterwave(
        context: context,
        style: style,
        publicKey: (walletBalance['flutterwave_environment'] == 'test')
            ? walletBalance['flutter_wave_test_secret_key']
            : walletBalance['flutter_wave_live_secret_key'],
        currency: walletBalance['currency_code'],
        txRef: '${userDetails['id']}_${DateTime.now()}',
        amount: addMoney.toString(),
        customer: customer,
        paymentOptions: "ussd, card, barter, payattitude, account",
        customization: Customization(title: "Payment"),
        isTestMode: (walletBalance['flutterwave_environment'] == 'test')
            ? true
            : false);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      // onWillPop: () async {
      //   return false;
      // },
      child: Material(
        child: ValueListenableBuilder(
            valueListenable: valueNotifierHome.value,
            builder: (context, value, child) {
              return Directionality(
                textDirection: (languageDirection == 'rtl')
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(media.width * 0.05,
                          media.width * 0.05, media.width * 0.05, 0),
                      height: media.height * 1,
                      width: media.width * 1,
                      color: page,
                      child: Column(
                        children: [
                          SizedBox(height: MediaQuery.of(context).padding.top),
                          Stack(
                            children: [
                              Container(
                                padding:
                                    EdgeInsets.only(bottom: media.width * 0.05),
                                width: media.width * 0.9,
                                alignment: Alignment.center,
                                child: MyText(
                                  text: languages[choosenLanguage]
                                      ['text_addmoney'],
                                  size: media.width * sixteen,
                                  fontweight: FontWeight.bold,
                                ),
                              ),
                              Positioned(
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: Icon(
                                        Icons.arrow_back_ios,
                                        color: textColor,
                                      )))
                            ],
                          ),
                          SizedBox(
                            height: media.width * 0.05,
                          ),
                          MyText(
                            text: walletBalance['currency_symbol'] +
                                ' ' +
                                addMoney.toString(),
                            size: media.width * twenty,
                            fontweight: FontWeight.w600,
                          ),
                          SizedBox(
                            height: media.width * 0.05,
                          ),
                          Button(
                              onTap: () async {
                                final ChargeResponse response =
                                    await flutterwave.charge();
                                // ignore: unnecessary_null_comparison
                                if (response != null) {
                                  if (response.status == 'success') {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    var val = await addMoneyFlutterwave(
                                        addMoney, response.transactionId);
                                    if (val == 'success') {
                                      setState(() {
                                        _success = true;
                                        _isLoading = false;
                                      });
                                    } else if (val == 'logout') {
                                      navigateLogout();
                                    }
                                  } else {
                                    setState(() {
                                      _failed = true;
                                      _isLoading = false;
                                    });
                                    // Transaction not successful
                                  }
                                } else {
                                  pop();
                                }
                              },
                              text: 'Pay')
                        ],
                      ),
                    ),
                    //payment failed
                    (_failed == true)
                        ? Positioned(
                            top: 0,
                            child: Container(
                              height: media.height * 1,
                              width: media.width * 1,
                              color: Colors.transparent.withOpacity(0.6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(media.width * 0.05),
                                    width: media.width * 0.9,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: page),
                                    child: Column(
                                      children: [
                                        MyText(
                                          text: languages[choosenLanguage]
                                              ['text_somethingwentwrong'],
                                          size: media.width * sixteen,
                                          fontweight: FontWeight.w600,
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: media.width * 0.05,
                                        ),
                                        Button(
                                            onTap: () async {
                                              setState(() {
                                                _failed = false;
                                              });
                                            },
                                            text: languages[choosenLanguage]
                                                ['text_ok'])
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ))
                        : Container(),

                    //payment success
                    (_success == true)
                        ? Positioned(
                            top: 0,
                            child: Container(
                              alignment: Alignment.center,
                              height: media.height * 1,
                              width: media.width * 1,
                              color: Colors.transparent.withOpacity(0.6),
                              child: Container(
                                padding: EdgeInsets.all(media.width * 0.05),
                                width: media.width * 0.9,
                                height: media.width * 0.8,
                                decoration: BoxDecoration(
                                    color: page,
                                    borderRadius: BorderRadius.circular(
                                        media.width * 0.03)),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/paymentsuccess.png',
                                      fit: BoxFit.contain,
                                      width: media.width * 0.5,
                                    ),
                                    MyText(
                                      text: languages[choosenLanguage]
                                          ['text_paymentsuccess'],
                                      textAlign: TextAlign.center,
                                      size: media.width * sixteen,
                                      fontweight: FontWeight.w600,
                                    ),
                                    SizedBox(
                                      height: media.width * 0.07,
                                    ),
                                    Button(
                                        onTap: () {
                                          setState(() {
                                            _success = false;
                                            Navigator.pop(context, true);
                                          });
                                        },
                                        text: languages[choosenLanguage]
                                            ['text_ok'])
                                  ],
                                ),
                              ),
                            ))
                        : Container(),

                    //no internet
                    (internet == false)
                        ? Positioned(
                            top: 0,
                            child: NoInternet(
                              onTap: () {
                                setState(() {
                                  internetTrue();
                                  _isLoading = true;
                                });
                              },
                            ))
                        : Container(),

                    //loader
                    (_isLoading == true)
                        ? const Positioned(top: 0, child: Loading())
                        : Container()
                  ],
                ),
              );
            }),
      ),
    );
  }
}
