import 'dart:async';
import 'package:async/async.dart';
import 'package:fluminus/widgets/dialog.dart';

import 'package:flutter/material.dart';
import 'package:luminus_api/luminus_api.dart';
import 'package:fluminus/announcement_list_page.dart';
import 'package:fluminus/data.dart' as data;
import 'package:fluminus/widgets/common.dart' as common;
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart' as main;

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({Key key}) : super(key: key);
  @override
  _AnnouncementPageState createState() => new _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<AnnouncementPage> {
  // To prevent this page being loaded multiple times:
  // https://medium.com/saugo360/flutter-my-futurebuilder-keeps-firing-6e774830bc2
  // I don't know why it doesn't work though...
  // HEHE
  final AsyncMemoizer<List<Module>> _memoizer = AsyncMemoizer();
  FutureOr<List<Module>> _fetchData() async {
    return this._memoizer.runOnce(() async {
      SharedPreferences sp = await SharedPreferences.getInstance();
      List<Module> modules = await API.getModules(data.authentication());
      sp.setStringList('moduleStrs', modules.map((x) => x.name).toList());
      return modules;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    /*return DefaultTabController(
              length: main.modules.length,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text("Announcements"),
                  bottom: TabBar(
                    isScrollable: true,
                    tabs: main.modules.map((Module module) {
                      return Tab(
                        text: module.name,
                      );
                    }).toList(),
                  ),
                ),
                body: TabBarView(
                  children: main.modules.map((Module module) {
                    return AnnouncementListPage(module: module);
                  }).toList(),
                ),
              ),
            );*/
    return FutureBuilder<List<Module>>(
        future: this._fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Module> _modules;
            _modules = snapshot.data;
            return DefaultTabController(
              length: _modules.length,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text("Announcements"),
                  bottom: TabBar(
                    isScrollable: true,
                    tabs: _modules.map((Module module) {
                      return Tab(
                        text: module.name,
                      );
                    }).toList(),
                  ),
                ),
                body: TabBarView(
                  children: _modules.map((Module module) {
                    return AnnouncementListPage(module: module);
                  }).toList(),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            // TODO: Error handling
            return Text(snapshot.error.toString());
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text("Announcements"),
            ),
            body: common.progressIndicator,
          );
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
