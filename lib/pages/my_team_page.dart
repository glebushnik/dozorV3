import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/components/team_bubble.dart';
import 'package:flutter_application_1/pages/choose_users.dart';
import 'package:flutter_application_1/pages/my_teams.dart';
import 'package:flutter_application_1/pages/team_chat_page.dart';

class MyTeamPage extends StatelessWidget {
  final String teamId;

  const MyTeamPage({Key? key, required this.teamId}) : super(key: key);

  Future<List<String>> _getIdsFromEmails(List<String> emailAddresses) async {
    List<String> userIds = [];

    for (String email in emailAddresses) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic>? userData =
            snapshot.docs[0].data() as Map<String, dynamic>;
        String? userId = userData['uid'];
        if (userId != null) {
          userIds.add(userId);
        }
      }
    }

    return userIds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Информация о команде'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('teams')
            .doc(teamId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          var teamData = snapshot.data?.data() as Map<String, dynamic>?;

          if (teamData == null) {
            return Center(child: Text('Данные о команде не найдены'));
          }

          var teamName = teamData['name'] ?? 'Название не указано';
          var captainId = teamData['createdBy'] ?? 'Капитан не указан';
          var members = List<String>.from(teamData['members']);
          TextEditingController teamNameController =
              TextEditingController(text: teamName);
          return Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 300,
                    ),
                    child: TeamBubble(
                      teamName: teamName,
                      teamId: teamId,
                      captainId: captainId,
                      members: members,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 300, // Растягиваем кнопку на всю доступную ширину
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChooseUsers(
                            teamName: teamNameController,
                            isNew: false,
                            add: true,
                            remove: false,
                            teamId: teamId),
                      ),
                    );
                  },
                  child: Text('Добавить участника'),
                ),
              ),
              FutureBuilder(
                future: _getIdsFromEmails(members),
                builder: (context, AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Ошибка: ${snapshot.error}'));
                  }

                  return SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamChatPage(
                              receiverUserIds: snapshot.data ?? [],
                              receiverUserEmails: members,
                              teamName: teamName,
                            ),
                          ),
                        );
                      },
                      child: Text('Чат команды'),
                    ),
                  );
                },
              ),
              SizedBox(
                width: 300, // Растягиваем кнопку на всю доступную ширину
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // Получаем текущего пользователя
                      User? currentUser = FirebaseAuth.instance.currentUser;

                      // Получаем данные о команде из Firestore
                      DocumentSnapshot<Map<String, dynamic>> teamSnapshot =
                          await FirebaseFirestore.instance
                              .collection('teams')
                              .doc(teamId)
                              .get();

                      // Получаем электронную почту капитана команды из данных о команде
                      String? createdBy = teamSnapshot['createdBy'];

                      // Проверяем, совпадает ли электронная почта текущего пользователя с электронной почтой капитана команды
                      if (currentUser?.uid == createdBy) {
                        print(currentUser?.uid);
                        print(createdBy);
                        // Если совпадает, удаляем команду
                        await FirebaseFirestore.instance
                            .collection('teams')
                            .doc(teamId)
                            .delete();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyTeam(
                              shouldReload: true,
                            ),
                          ),
                        );
                      } else {
                        // Если не совпадает, показываем всплывающее предупреждение
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Ошибка'),
                              content: Text(
                                  'Вы должны быть капитаном, чтобы удалить команду'),
                              actions: <Widget>[
                                ButtonBar(
                                  alignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                const Color.fromARGB(
                                                    255, 155, 132, 197)),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            side: BorderSide(
                                                color: const Color.fromARGB(
                                                    255, 155, 132, 197)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } catch (error) {
                      print('Ошибка при удалении команды: $error');
                    }
                  },
                  child: Text('Удалить команду'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
