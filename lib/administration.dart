import 'package:flutter/material.dart';

import 'drawer.dart';

class AdministrationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AdministrationPageState();
  }
}

class _AdministrationPageState extends State<AdministrationPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administration'),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(text: 'Users'),
            Tab(text: 'More...'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Center(child: Text('Users Page')),
          Center(child: Text('More Page')),
        ],
      ),
      drawer: MyDrawer(
        selectedItem: DrawerSelectedItem.administration,
      ),
    );
  }
}
