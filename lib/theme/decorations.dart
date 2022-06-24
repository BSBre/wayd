import 'package:flutter/material.dart';
import 'package:waydchatapp/shared/placeholder_image.dart';

import 'colors.dart';

BoxDecoration kPrimaryGreenAccentB2R10 = BoxDecoration(
  color: kPrimaryGreenAccent,
  border: Border.all(width: 2.0),
  borderRadius: const BorderRadius.all(Radius.circular(10)),
);

BoxDecoration kPrimaryImageFitB0R30 = BoxDecoration(
  borderRadius: BorderRadius.circular(30),
  image: DecorationImage(
    image: AssetImage(PlaceholderImage.randomPlaceholderImagePath(14)),
    fit: BoxFit.cover,
  ),
);

BoxDecoration kPrimaryB1_5BlackR6 = BoxDecoration(
  borderRadius: BorderRadius.circular(6),
  border: Border.all(width: 1.5, color: Colors.black),
);

BoxDecoration kPrimaryR15 = BoxDecoration(borderRadius: BorderRadius.circular(15));

BoxDecoration kPrimaryRedAccentR10 = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.redAccent);

InputDecoration kPrimaryDashboardSearch = const InputDecoration(
  border: InputBorder.none,
  isDense: true,
  hintText: 'Search...',
  hintStyle: TextStyle(fontSize: 15),
  prefixIcon: Icon(
    Icons.search,
    size: 27,
    color: Colors.black,
  ),
);
