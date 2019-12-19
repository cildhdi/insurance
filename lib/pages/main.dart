import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurance/components/value_select.dart';
import 'package:insurance/components/form_item.dart';
import 'package:insurance/pages/util.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

//sex -> timeLimit -> feeLimit
Map<int, Map<int, Map<int, String>>> loc = {
  0: {
    0: {0: "O", 1: "T", 2: "Y"},
    1: {0: "AE", 1: "AJ", 2: "AO", 3: "AT"},
    2: {0: "AZ", 1: "BE", 2: "BJ", 3: "BO"},
    3: {0: "BT", 1: "BY", 2: "CD", 3: "CI"},
    4: {0: "CN", 1: "CS", 2: "CX", 3: "DC"}
  },
  1: {
    0: {0: "O", 1: "T", 2: "Y"},
    1: {0: "AF", 1: "AK", 2: "AP", 3: "AU"},
    2: {0: "BB", 1: "BG", 2: "BL", 3: "BP"},
    3: {0: "BV", 1: "CA", 2: "CF", 3: "CK"},
    4: {0: "CQ", 1: "CV", 2: "DA", 3: "DF"}
  }
};

int timeLimitToRange(int tl) {
  if (tl <= 2) {
    return (tl + 1) * 10;
  } else {
    return tl == 3 ? 35 : 45;
  }
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  static final int minAge = 0, maxAge = 30;
  int age = minAge;

  static final int minSex = 0, maxSex = 1;
  int sex = minSex;

  static final int minTimeLimit = 0, maxTimeLimit = 4;
  int timeLimit = minTimeLimit;

  static final int minFeeLimit = 0, maxFeeLimit = 3;
  int feeLimit = minFeeLimit;

  static final int minAmount = 0, maxAmount = 9;
  int amount = minAmount;

  double result;
  var values = new List<double>();
  SpreadsheetDecoder spreadsheetDecoder, respXlsx;

  Future<void> loadXlsx(BuildContext context) async {
    try {
      var bytes = await rootBundle.load("assets/insurance.xlsx");
      spreadsheetDecoder =
          SpreadsheetDecoder.decodeBytes(bytes.buffer.asUint8List());
      bytes = await rootBundle.load("assets/in2.xlsx");
      respXlsx = SpreadsheetDecoder.decodeBytes(bytes.buffer.asUint8List());
      debugPrint("加载表格成功");
    } catch (e) {
      debugPrint("加载表格失败");
    }
  }

  void onQuery() {
    try {
      var table = spreadsheetDecoder.tables[timeLimit.toString()];
      var value = table.rows[age][feeLimit * 2 + sex];

      table = respXlsx.tables[sex.toString()];
      //($O$29*($I$29-I29)/H29-($L$29-L29)/H29)*100000
      //($O$29*($I$29-I30)/H30-($L$29-L30)/H30)*100000

      //($O$29*($I$29-I29)/H29-($L$29-L29)/H29)*100000
      //($T$29*($I$29-I29)/H29-($L$29-L29)/H29)*100000

      double pureFee = table.rows[ageToIndex(age)]
          [columnToIndex(loc[sex][timeLimit][feeLimit])];

      var Iage = table.rows[ageToIndex(age)][columnToIndex("I")];
      var Lage = table.rows[ageToIndex(age)][columnToIndex("L")];

      debugPrint(Iage.toString());
      debugPrint(Lage.toString());

      values.clear();
      int range = timeLimitToRange(timeLimit);
      for (var i = ageToIndex(age); i <= ageToIndex(age) + range; i++) {
        var v = (pureFee *
                    (Iage - table.rows[i][columnToIndex("I")]) /
                    table.rows[i][columnToIndex("H")] -
                (Lage - table.rows[i][columnToIndex("L")]) /
                    table.rows[i][columnToIndex("H")]) *
            (amount + 1) *
            100000;
        values.add(v);
      }
      this.setState(() {
        result = value;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void setValue(void Function() fn) {
    this.setState(() {
      result = null;
      values.clear();
      fn();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (spreadsheetDecoder == null) {
      loadXlsx(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("保了么"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FormItem(
                  title: "投保年龄",
                  content: Row(
                    children: <Widget>[
                      Text("${age + 25} 岁   "),
                      RaisedButton(
                        child: const Text("选择出生日期"),
                        onPressed: () async {
                          final now = DateTime.now();
                          var date = await showDatePicker(
                              context: context,
                              initialDate: DateTime(now.year - maxAge - 25),
                              firstDate: DateTime(now.year - maxAge - 25),
                              lastDate: DateTime(now.year - minAge - 25));
                          if (date != null) {
                            this.setValue(() {
                              age = now.year - date.year - 25;
                            });
                          }
                        },
                      )
                    ],
                  )),
              FormItem(
                title: "性        别",
                content: ValueSelect(
                  value: sex,
                  min: minSex,
                  max: maxSex,
                  buildText: (v) {
                    return v == 0 ? "男性" : "女性";
                  },
                  onChange: (v) {
                    this.setValue(() {
                      sex = v;
                    });
                  },
                ),
              ),
              FormItem(
                title: "保障期限",
                content: ValueSelect(
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
                    this.setValue(() {
                      timeLimit = v;
                    });
                  },
                ),
              ),
              FormItem(
                title: "缴费期限",
                content: ValueSelect(
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
                    this.setValue(() {
                      feeLimit = v;
                    });
                  },
                ),
              ),
              FormItem(
                title: "保障额度",
                content: ValueSelect(
                  value: amount,
                  min: minAmount,
                  max: maxAmount,
                  buildText: (v) {
                    return "${(v + 1) * 10} 万元";
                  },
                  onChange: (v) {
                    this.setValue(() {
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
              ),
              Text(
                "责任准备金：",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.display1,
              ),
              Column(
                children: values.map((v) {
                  return ListTile(
                      title: Text(
                    v.toInt().toString(),
                    textAlign: TextAlign.center,
                  ));
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
