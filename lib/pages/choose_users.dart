import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/components/my_button.dart';
import 'package:flutter_application_1/pages/my_team_page.dart';
import 'package:flutter_application_1/pages/my_teams.dart';
import 'chat_page.dart';

class ChooseUsers extends StatefulWidget {
  final TextEditingController teamName;
  final bool isNew;
  final bool add;
  final bool remove;
  final String teamId;
  const ChooseUsers({
    Key? key,
    required this.teamName,
    required this.isNew,
    required this.add,
    required this.remove,
    required this.teamId,
  }) : super(key: key);

  @override
  State<ChooseUsers> createState() => _ChooseUsersState();
}

class _ChooseUsersState extends State<ChooseUsers> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  List<String> selectedUsers = [];

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hideKeyboard, // Hide keyboard when tapping anywhere on the screen
      child: Scaffold(
        appBar: AppBar(
          title: Text('Выберите пользователей'),
          actions: [
            // Only show the 'Next' button if not adding to an existing team
            IconButton(
              icon: Icon(Icons.arrow_forward_ios_outlined),
              onPressed: () {
                createTeam(context, widget.teamName, selectedUsers);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchField(),
            Expanded(child: _createUserList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск пользователей',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              setState(() {
                _searchText = value.toLowerCase();
              });
            },
          ),
          if (_searchController.text.isNotEmpty)
            Positioned(
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _searchController.clear();
                    _searchText = '';
                  });
                },
                child: Icon(Icons.clear),
              ),
            ),
        ],
      ),
    );
  }

  Widget _createUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Ошибка');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Загрузка...');
        }

        var filteredUsers = snapshot.data!.docs.where((doc) {
          Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
          return _auth.currentUser!.email != data['email'] &&
              (data['email'] as String).toLowerCase().contains(_searchText);
        }).toList();

        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            return _createUserListItem(filteredUsers[index]);
          },
        );
      },
    );
  }

  Widget _createUserListItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    String userEmail = data['email'];

    return ListTile(
      title: Text(userEmail),
      onTap: () {
        setState(() {
          if (selectedUsers.contains(userEmail)) {
            selectedUsers.remove(userEmail);
          } else {
            selectedUsers.add(userEmail);
          }
        });
      },
      leading: Checkbox(
        value: selectedUsers.contains(userEmail),
        onChanged: (bool? value) {
          setState(() {
            if (value != null && value) {
              selectedUsers.add(userEmail);
            } else {
              selectedUsers.remove(userEmail);
            }
          });
        },
      ),
    );
  }

  void createTeam(
    BuildContext context,
    TextEditingController teamNameController,
    List<String> selectedUsers,
  ) async {
    final String? teamName = teamNameController.text.trim();
    final String? captainId = FirebaseAuth.instance.currentUser?.uid;

    if (teamName != null && captainId != null && selectedUsers.isNotEmpty) {
      if (widget.add) {
        try {
          await FirebaseFirestore.instance
              .collection('teams')
              .doc(widget.teamId)
              .update({
            'members': FieldValue.arrayUnion(selectedUsers),
          });
          Navigator.pop(context); // Close the ChooseUsers screen
        } catch (e) {
          print('Ошибка при обновлении данных в Firestore: $e');
        }
      } else {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(captainId)
            .get();
        selectedUsers.add(userDoc['email']);

        DocumentReference teamRef =
            FirebaseFirestore.instance.collection('teams').doc();

        Map<String, dynamic> teamData = {
          'id': teamRef.id,
          'name': teamName,
          'members': selectedUsers,
          'createdBy': captainId,
        };

        try {
          await teamRef.set(teamData);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyTeamPage(
                teamId: teamData['id'],
              ),
            ),
          );
        } catch (e) {
          print('Ошибка при сохранении данных в Firestore: $e');
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Ошибка'),
            content: Text(
              'Название команды и идентификатор капитана не могут быть пустыми, и должны быть выбраны участники',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
