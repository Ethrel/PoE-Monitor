import 'package:flutter/material.dart';
import "package:poe_monitor/main.dart";

class ItemPriceCard extends StatelessWidget {
  const ItemPriceCard({
    super.key,
    required this.icon,
    required this.name,
    required this.amount,
    required this.price,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
  });

  final Image? icon;
  final String name;
  final int amount;
  final double price;

  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;

  final int iconPercentWidth = 25;

  static const Icon unknownIcon = Icon(Icons.question_mark);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        color: backgroundColor ?? theme.colorScheme.primary,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: iconPercentWidth,
              child: icon ?? unknownIcon,
            ),
            Expanded(
              flex: 100 - iconPercentWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        name,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: textColor ?? theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: ItemPriceLine(
                      itemIcon: icon ?? unknownIcon,
                      amount: amount,
                      priceIcon: apiData.currencyImage.value ?? unknownIcon,
                      price: price,
                      useDecimal: false,
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: ItemPriceLine(
                      itemIcon: icon ?? unknownIcon,
                      amount: 1,
                      priceIcon: apiData.currencyImage.value ?? unknownIcon,
                      price: price,
                      useDecimal: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemPriceLine extends StatelessWidget {
  const ItemPriceLine({
    super.key,
    required this.itemIcon,
    required this.amount,
    required this.priceIcon,
    required this.price,
    required this.useDecimal,
  });

  final Widget itemIcon;
  final int amount;
  final Widget priceIcon;
  final double price;
  final bool useDecimal;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              amount.toString(),
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
            SizedBox(height: 20, child: itemIcon),
          ],
        ),
        const Padding(padding: EdgeInsetsDirectional.symmetric(horizontal: 2.0), child: Center(child: Text("="))),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              useDecimal ? price.toStringAsFixed(2) : (price * amount).floor().toString(),
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
            SizedBox(height: 20, child: priceIcon),
          ],
        ),
      ],
    );
  }
}
