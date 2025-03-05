import 'package:flutter/widgets.dart';

/// Dont forget to add the font to pubspec
///
/// - family: Riyal
///   fonts:
///     - asset: assets/fonts/riyal.ttf
///


   const IconData saudiRiyalSymbolIconData =
      IconData(0xe800, fontFamily: 'Riyal');
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
            String.fromCharCode(saudiRiyalSymbolIconData.codePoint),
            style: currencyTextStyle?.copyWith(
                  fontFamily: saudiRiyalSymbolIconData.fontFamily,
                ) ??
                priceTextStyle?.copyWith(
                  fontFamily: saudiRiyalSymbolIconData.fontFamily,
                ) ??
                TextStyle(
                  fontFamily: saudiRiyalSymbolIconData.fontFamily,
                ),
          ),
        ),
      ],
    ));
  }
}


extension RiyalPrice on Text {

  Widget withRiyalPrice() {
    return RiyalPriceText(
        price: data.toString(),
        priceTextStyle: style,
        currencyTextStyle: style);
  }
}
