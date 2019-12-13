import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurance/components/value_slider.dart';
import 'package:insurance/components/form_item.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  static final int minAge = 0, maxAge = 30;
  int age = minAge;

  bool sex = false;

  static final int minTimeLimit = 0, maxTimeLimit = 4;
  int timeLimit = minTimeLimit;

  static final int minFeeLimit = 0, maxFeeLimit = 3;
  int feeLimit = minFeeLimit;

  static final int minAmount = 0, maxAmount = 9;
  int amount = minAmount;

  double result;
  SpreadsheetDecoder spreadsheetDecoder;

  Future<void> loadXlsx(BuildContext context) async {
    try {
      var bytes = await rootBundle.load("assets/insurance.xlsx");
      spreadsheetDecoder =
          SpreadsheetDecoder.decodeBytes(bytes.buffer.asUint8List());
      debugPrint("加载表格成功");
    } catch (e) {
      debugPrint("加载表格失败");
    }
  }

  void onQuery() {
    try {
      var table = spreadsheetDecoder.tables[timeLimit.toString()];
      var value = table.rows[age][feeLimit * 2 + (sex ? 0 : 1)];
      this.setState(() {
        debugPrint(value.toString());
        result = value;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (spreadsheetDecoder == null) {
      loadXlsx(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("保费查询"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FormItem(
                title: "投保年龄",
                content: ValueSlider(
                  value: age,
                  min: minAge,
                  max: maxAge,
                  buildText: (v) {
                    return "${v + 25} 岁";
                  },
                  onChange: (v) {
                    this.setState(() {
                      age = v;
                    });
                  },
                ),
              ),
              FormItem(
                title: "性        别",
                content: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      width: 55,
                      child: Text(sex ? "男性" : "女性"),
                    ),
                    Expanded(
                      child: Switch(
                        value: sex,
                        onChanged: (v) {
                          this.setState(() {
                            sex = v;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              FormItem(
                title: "保障期限",
                content: ValueSlider(
                  value: timeLimit,
                  min: minTimeLimit,
                  max: maxTimeLimit,
                  buildText: (v) {
                    if (v <= 2) {
                      return "${(v + 1) * 10} 年";
                    } else {
                      return v == 3 ? "至60周岁" : "至70周岁";
                    }
                  },
                  onChange: (v) {
                    this.setState(() {
                      timeLimit = v;
                    });
                  },
                ),
              ),
              FormItem(
                title: "缴费期限",
                content: ValueSlider(
                  value: feeLimit,
                  min: minFeeLimit,
                  max: maxFeeLimit,
                  buildText: (v) {
                    switch (v) {
                      case 0:
                        return "趸交";
                        break;
                      case 1:
                        return "5 年";
                        break;
                      case 2:
                        return "10 年";
                        break;
                      case 3:
                        return "20 年";
                        break;
                      default:
                        return "趸交";
                    }
                  },
                  onChange: (v) {
                    this.setState(() {
                      feeLimit = v;
                    });
                  },
                ),
              ),
              FormItem(
                title: "保障额度",
                content: ValueSlider(
                  value: amount,
                  min: minAmount,
                  max: maxAmount,
                  buildText: (v) {
                    return "${(v + 1) * 10} 万元";
                  },
                  onChange: (v) {
                    this.setState(() {
                      amount = v;
                    });
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: RaisedButton(
                  child: const Text("查询"),
                  onPressed: () {
                    onQuery();
                  },
                ),
              ),
              Text(
                result == null
                    ? "---- 元"
                    : "${(result * (amount + 1) * 100).round()} 元",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.display1,
              )
            ],
          ),
        ),
      ),
    );
  }
}
