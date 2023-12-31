import 'package:flutter/material.dart';
import 'package:school_management_app/models/student.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_management_app/widgets/add_student_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Student> _studentList = [];

  void _loadData() async {
    final url = Uri.https(
      'shopping-list2-bcc4b-default-rtdb.asia-southeast1.firebasedatabase.app',
      'student-data.json',
    );
    final response = await http.get(url);
    print('#debug student-list.dart');
    print(response.body);
    final Map<String, dynamic> listData = json.decode(response.body);
    print('#debug student-list.dart');
    print(listData);
    final List<Student> _loadedData = [];
    for (final data in listData.entries) {
      _loadedData.add(
        Student(
          id: data.key,
          matricNo: data.value['Matric No'],
          fullName: data.value['Full Name'],
          course: data.value['Course'],
        ),
      );
    }

    setState(() {
      _studentList = _loadedData;
    });
  }

  void _addData() async {
    await Navigator.of(context).push<Student>(
      MaterialPageRoute(
        builder: (ctx) => const StudentDataEntry(),
      ),
    );

    _loadData();
  }

  void _removeData(Student data) async {
    final url = Uri.https(
      'shopping-list2-bcc4b-default-rtdb.asia-southeast1.firebasedatabase.app',
      'student-data/${data.id}.json',
    );

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        // If the delete request is successful, remove the data from the local list
        setState(() {
          _studentList.remove(data);
        });

        // show snackbar to indicate delete success
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student data deleted successfully.'),
          ),
        );
      } else {
        // Handle error - print or display an error message
        print('Failed to delete data: ${response.statusCode}');
      }
    } catch (error) {
      // Handle other errors
      print('Error: $error');
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete this student?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        'No student data yet...!',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (_studentList.isNotEmpty) {
      content = ListView.builder(
        itemCount: _studentList.length,
        itemBuilder: (context, index) => Dismissible(
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (direction) async {
            return await _showDeleteConfirmation(context);
          },
          onDismissed: (direction) {
            _removeData(_studentList[index]);
          },
          key: ValueKey(_studentList[index].id),
          child: ListTile(
            title: Text(_studentList[index].fullName),
            subtitle: Text(_studentList[index].course),
            trailing: Text(
              _studentList[index].matricNo,
            ),
            onTap: () {},
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _addData,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
