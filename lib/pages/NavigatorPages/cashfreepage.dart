import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cashfree_pg/cashfree_pg.dart';
import 'package:flutter_driver/pages/login/landingpage.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/login.dart';
import '../noInternet/nointernet.dart';
import 'walletpage.dart';

class CashFreePage extends StatefulWidget {
  const CashFreePage({Key? key}) : super(key: key);

  @override
  State<CashFreePage> createState() => _CashFreePageState();
}

class _CashFreePageState extends State<CashFreePage> {
  bool _isLoading = false;
  bool _success = false;
  bool _failed = false;

  @override
  void initState() {
    payMoney();
    super.initState();
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
    var getToken =
        await getCfToken(addMoney.toString(), walletBalance['currency_code']);
    if (getToken == 'success') {
      await CashfreePGSDK.doPayment({
        'appId': (walletBalance['cashfree_environment'] == 'test')
            ? walletBalance['cashfree_test_app_id']
            : walletBalance['cashfree_live_app_id'],
        'stage':
            (walletBalance['cashfree_environment'] == 'test') ? 'TEST' : 'PROD',
        'orderId': cftToken['orderId'],
        'orderAmount': addMoney.toString(),
        'orderCurrency': walletBalance['currency_code'],
        'customerPhone': userDetails['mobile'],
        'customerEmail': userDetails['email'],
        'tokenData': cftToken['cftoken'],
        'color1': '#FCB13D',
        'color2': '#ffffff',
        'customerName': userDetails['name']
      }).then((value) async {
        cfSuccessList = jsonDecode(jsonEncode(value));
        if (cfSuccessList['txStatus'] == 'SUCCESS') {
          var verify = await cashFreePaymentSuccess();
          if (verify == 'success') {
            setState(() {
              _success = true;
              _isLoading = false;
            });
          } else if (verify == 'logout') {
            navigateLogout();
          } else {
            setState(() {
              _failed = true;
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _failed = true;
          });
        }
      });
    } else if (getToken == 'logout') {
      navigateLogout();
    } else {
      setState(() {
        _failed = true;
      });
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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
                                          textAlign: TextAlign.center,
                                          size: media.width * sixteen,
                                          fontweight: FontWeight.w600,
                                        ),
                                        SizedBox(
                                          height: media.width * 0.05,
                                        ),
                                        Button(
                                            onTap: () async {
                                              setState(() {
                                                _failed = false;
                                              });
                                              Navigator.pop(context, true);
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
