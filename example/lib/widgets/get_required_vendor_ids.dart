import 'dart:async';

import 'package:didomi_sdk/didomi_sdk.dart';
import 'package:didomi_sdk_example/widgets/base_sample_widget_state.dart';
import 'package:flutter/material.dart';

/// Widget to call DidomiSdk.getRequiredVendorIds
class GetRequiredVendorIds extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GetRequiredVendorIds();
}

class _GetRequiredVendorIds
    extends BaseSampleWidgetState<GetRequiredVendorIds> {
  @override
  String getButtonName() => 'GetRequiredVendorIds';

  @override
  String getActionId() => 'getRequiredVendorIds';

  @override
  Future<String> callDidomiPlugin() async {
    final List<String> result = await DidomiSdk.requiredVendorIds;
    if (result.isEmpty) {
      return "Required Vendors list is empty";
    } else {
      return "Required Vendors: ${result.join(",")}";
    }
  }
}