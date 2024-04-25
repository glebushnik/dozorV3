import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/input_text_field.dart';
import 'package:flutter_application_1/components/my_text_field.dart';
import 'package:flutter_application_1/pages/choose_users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/my_teams.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({Key? key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final teamNameController = TextEditingController();
  final List<String> teamMemberEmails = [];

  bool _isCaptain =
      false; // Переменная для хранения информации о том, является ли пользователь капитаном

  @override
  void initState() {
    super.initState();
    // Проверяем, является ли пользователь капитаном при загрузке страницы
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  height: 70,
                ),
                Icon(
                  Icons.group_outlined,
                  size: 80,
                ),
                Text(
                  "Создай свою команду!",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 30,
                ),
                CustomInputTextField(
                  controller: teamNameController,
                  hintText: 'Название команды',
                  obscureText: false,
                  textCapitalization: TextCapitalization.words,
                ),
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () {
                    // Если пользователь капитан какой-либо команды, показываем все команды

                    // Если поле название команды не пустое, переходим на страницу выбора пользователей
                    if (teamNameController.text.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChooseUsers(
                            teamName: teamNameController,
                            isNew: true,
                          ),
                        ),
                      );
                      teamNameController.clear();
                    } else {
                      // Если поле пустое, можно показать пользователю сообщение или ничего не делать
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Пустое название команды!'),
                            content: Text(
                              'Чтобы создать команду, введите ее название.',
                            ),
                            actions: <Widget>[
                              ButtonBar(
                                alignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Закрываем диалоговое окно
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
                                            255, 155, 132, 197),
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side: BorderSide(
                                            color: const Color.fromARGB(
                                                255, 155, 132, 197),
                                          ),
                                        ),
                                      ),
                                      minimumSize: MaterialStateProperty.all(Size(
                                          200,
                                          48)), // Задаем фиксированный размер кнопки
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text("Далее"),
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                        Size(200, 48)), // Задаем фиксированный размер кнопки
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyTeam(
                          shouldReload: true,
                        ),
                      ),
                    );
                  },
                  child: Text("Посмотреть мои команды"),
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                        Size(200, 48)), // Задаем фиксированный размер кнопки
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
