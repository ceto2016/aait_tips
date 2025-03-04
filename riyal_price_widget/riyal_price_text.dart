import 'package:flutter/widgets.dart';

/// Dont forget to add the font to pubspec
///
/// - family: Riyal
///   fonts:
///     - asset: assets/fonts/riyal.ttf
///
class RiyalPriceText extends StatelessWidget {
  final String price;
  final TextStyle? priceTextStyle;
  final TextStyle? currencyTextStyle;

  const RiyalPriceText(
      {super.key,
      required this.price,
      this.priceTextStyle,
      this.currencyTextStyle});

  bool checkIfPriceOnly() {
    final regx = RegExp(r'(\d+\.\d+)');
    return regx.hasMatch(price);
  }

  String getPrice() {
    if (checkIfPriceOnly()) {
      return price;
    } else {
      return price.split(' ').firstOrNull ?? "";
    }
  }

  static const IconData saudiRiyalSymbol2 =
      IconData(0xe800, fontFamily: 'Riyal');
  @override
  Widget build(BuildContext context) {
    // Example: Using a custom icon from a font family

    return RichText(
        text: TextSpan(
      style: priceTextStyle,
      children: [
        TextSpan(text: "${getPrice()} "),
        WidgetSpan(
          child: Text(
            String.fromCharCode(saudiRiyalSymbol2.codePoint),
            style: currencyTextStyle?.copyWith(
                  fontFamily: saudiRiyalSymbol2.fontFamily,
                ) ??
                priceTextStyle?.copyWith(
                  fontFamily: saudiRiyalSymbol2.fontFamily,
                ) ??
                TextStyle(
                  fontFamily: saudiRiyalSymbol2.fontFamily,
                ),
          ),
        ),
      ],
    ));
  }
}


extension RiyalPrice on Text {
  static const IconData saudiRiyalSymbol2 =
      IconData(0xe800, fontFamily: 'Riyal');

  Widget withRiyalPrice() {
    return RiyalPriceText(
        price: data.toString(),
        priceTextStyle: style,
        currencyTextStyle: style);
  }
}
