import 'package:flutter/material.dart';
import 'package:lcrealtime/Common/Global.dart';
import 'package:lcrealtime/Models/CurrentClient.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';
import 'ConversationDetailPage.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => new _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<String> _list = allClients();
  @override
  void initState() {
    super.initState();
    removeCurrentClient();
  }

  removeCurrentClient() {
    _list.remove(Global.clientID);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Expanded(
        child: ListView.separated(
            //添加分割线
            separatorBuilder: (BuildContext context, int index) {
              return new Divider(
                height: 0.8,
                color: Colors.grey,
              );
            },
            itemCount: _list.length,
//            itemExtent: 50.0, //强制高度为50.0
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  showConfirmDialog(_list[index]);
                },
                child: ListTile(title: Text(_list[index])),
              );
            }),
      ),
    ]);
  }

  void onTapEvent(String clientID) async {
    if (Global.clientID != null) {
      CurrentClient currentClient = CurrentClient();

      try {
        Conversation conversation = await currentClient.client.createConversation(
            isUnique: true,
            members: {clientID},
            name: Global.clientID + ' & ' + clientID);

        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) =>
                new ConversationDetailPage(conversation: conversation),
          ),
        );
      } catch (e) {
        showToastRed('创建会话失败:${e.message}');
      }
    } else {
      showToastRed('用户未登录');
      return;
    }
  }
  Future<bool> showConfirmDialog(String name) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text("确认开始与 $name 聊天？"),
          actions: <Widget>[
            FlatButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            FlatButton(
              child: Text("确认"),
              onPressed: () {
                onTapEvent(name);
                //关闭对话框并返回true
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
