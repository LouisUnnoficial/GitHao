import 'package:flutter/material.dart';
import 'package:githao/generated/i18n.dart';
import 'package:githao/resources/app_const.dart';
import 'package:githao/utils/string_util.dart';
import 'package:githao/widgets/common_search_delegate.dart';
import 'package:githao/widgets/search_repo_tab.dart';
import 'package:githao/widgets/search_user_tab.dart';

class CommonSearchPage extends StatefulWidget {
  static const ROUTE_NAME = '/common_search';
  @override
  _CommonSearchPageState createState() => _CommonSearchPageState();
}

class _CommonSearchPageState extends State<CommonSearchPage> with TickerProviderStateMixin {
  final List<String> _tabTitles = [S.current.repositories, S.current.users];
  TabController _tabController;
  String _query;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mounted) {
        Future.delayed(const Duration(milliseconds: 100)).then((_) {
          if(mounted) {
            _showSearchView();
          }
        });
      }
    });
  }

  Future _showSearchView() async {
    String q = await showSearch<String>(context: context, delegate: CommonSearchDelegate(_query));
    if(StringUtil.isNotBlank(q)) {
      if(this._query != q) {
        setState(() {
          this._query = q;
        });
      }
    }
  }

  Widget _buildDefaultEmpty() {
    return Container(
      child: Center(
        child: IconButton(icon: const Icon(Icons.search), onPressed: () {
          _showSearchView();
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxScrolled) => [
            SliverAppBar(
              title: Text(_query ?? S.current.search,),
              actions: <Widget>[
                IconButton(icon: const Icon(Icons.search), onPressed: () {
                  _showSearchView();
                }),
              ],
              floating: true, //是否随着滑动隐藏标题，为true时，当有下滑手势的时候就会显示SliverAppBar
              snap:true,   //与floating结合使用
              pinned: true, //为true时，SliverAppBar折叠后不消失
            ),
            SliverPersistentHeader(
              pinned: false,
              delegate: _SliverAppBarDelegate(
                Container(
                  color: Theme.of(context).primaryColor,
                  child: TabBar(
                    indicatorColor: Theme.of(context).primaryColorLight,
                    controller: _tabController,
                    tabs: _tabTitles.map((title) => Tab(child: Text(title),)).toList(growable: false),
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              StringUtil.isNotBlank(this._query) ? SearchRepoTab(this._query, key: Key('search_repo'+this._query),) : _buildDefaultEmpty(),
              StringUtil.isNotBlank(this._query) ? SearchUserTab(this._query, key: Key('search_user'+this._query),) : _buildDefaultEmpty(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

/// 定义tab栏高度
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Container _tabBar;
  _SliverAppBarDelegate(this._tabBar);
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(child: _tabBar,);
  }
  @override
  double get maxExtent => AppConst.TAB_HEIGHT;
  @override
  double get minExtent => AppConst.TAB_HEIGHT;
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}