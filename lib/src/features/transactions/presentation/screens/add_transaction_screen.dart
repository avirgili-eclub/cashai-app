import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/styles/app_styles.dart';
import '../widgets/scan_tab_content.dart';
import '../widgets/manual_tab_content.dart';
import '../widgets/extract_tab_content.dart';
import '../widgets/bank_statement_tab_content.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const AddTransactionScreen({
    Key? key,
    this.initialTabIndex = 0, // Default to first tab (Scan)
  }) : super(key: key);

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4, // Changed from 3 to 4 to include bank statement tab
      vsync: this,
      initialIndex:
          widget.initialTabIndex, // Set initial tab based on parameter
    );
    _tabController.addListener(() {
      // Force rebuild when tab changes to update UI state
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    developer.log(
        'Building AddTransactionScreen with tab index: ${widget.initialTabIndex}',
        name: 'add_transaction_screen');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Agregar Transacción'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1.0,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppStyles.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppStyles.primaryColor,
              indicatorWeight: 2.0,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Escanear'),
                Tab(text: 'Manual'),
                Tab(text: 'Extracto'),
                Tab(text: 'Bank Statement'), // Added new tab
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Scan Tab Content
                ScanTabContent(),

                // Manual Tab Content
                ManualTabContent(),

                // Extract Tab Content
                ExtractTabContent(),

                // Bank Statement Tab Content
                BankStatementTabContent(), // Added new tab content
              ],
            ),
          ),
        ],
      ),
    );
  }
}
