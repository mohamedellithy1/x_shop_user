import 'package:flutter/material.dart';

/// Observer عالمي للـ Navigation - أي ويدجت ممكن يشترك فيه
/// عشان يعرف لما صفحة جديدة بتتفتح فوقه أو بيرجع ليه
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();
