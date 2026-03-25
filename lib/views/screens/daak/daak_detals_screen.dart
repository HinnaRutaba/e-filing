import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DaakDetailsScreen extends ConsumerStatefulWidget {
  final int? daakId;
  const DaakDetailsScreen({super.key, required this.daakId});

  @override
  ConsumerState<DaakDetailsScreen> createState() => _DaakDetailsScreenState();
}

class _DaakDetailsScreenState extends ConsumerState<DaakDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daak Details'),
      ),
      body: Center(
        child: Text('Details for Daak ID: ${widget.daakId}'),
      ),
    );
  }
}
