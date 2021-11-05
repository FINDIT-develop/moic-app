import 'package:FinDit/models/search_video_result.dart';
import 'package:FinDit/repository/youtube_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchController extends GetxController {
  String key = "searchKey";
  RxList<String> history = RxList<String>.empty(growable: true);
  late SharedPreferences _profs;
  ScrollController scrollController = ScrollController();
  late String _currentKeyword;
  Rx<YoutubeVideoResult> youtubeVideoResult = YoutubeVideoResult(items: []).obs;
  @override
  void onInit() async {
    _event();
    _profs = await SharedPreferences.getInstance();
    List<dynamic>? initData = _profs.get(key) as List?;

    history(initData!.map<String>((_) => _.toString()).toList());
    super.onInit();
  }

  void _event() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          youtubeVideoResult.value.nextPagetoken != "") {
        _searchYoutube(_currentKeyword);
      }
    });
  }

  void submitSearch(String searchKey) {
    history.addIf(!history.contains(searchKey), searchKey);
    _profs.setStringList(key, history);
    _currentKeyword = searchKey;
    _searchYoutube(searchKey);
  }

  void _searchYoutube(String searchKey) async {
    YoutubeVideoResult? youtubeVideoResultFromServer = await YoutubeService.to
        .search(searchKey, youtubeVideoResult.value.nextPagetoken ?? "");

    if (youtubeVideoResultFromServer != null &&
        youtubeVideoResultFromServer.items.length > 0) {
      youtubeVideoResult.update((youtube) {
        youtube!.nextPagetoken = youtubeVideoResultFromServer.nextPagetoken;
        youtube.items.addAll(youtubeVideoResultFromServer.items);
      });
    }
  }
}
