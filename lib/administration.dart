import 'package:flutter/material.dart';

import 'drawer.dart';

class AdministrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administration'),
      ),
      body: Center(
        child: Text('Administration page work'),
      ),
      drawer: MyDrawer(
        selectedItem: DrawerSelectedItem.administration,
      ),
    );
  }
}
