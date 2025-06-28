import 'package:flutter/material.dart';
import 'sql_helper.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _entries = [];
  final TextEditingController _feelingController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  int? _editingId;

  void _refreshEntries() async {
    final data = await SQLHelper.getEntries();
    setState(() => _entries = data);
  }

  void _showEntryModal({Map<String, dynamic>? entry}) {
    if (entry != null) {
      _editingId = entry['id'];
      _feelingController.text = entry['feeling'];
      _descController.text = entry['description'];
    } else {
      _editingId = null;
      _feelingController.clear();
      _descController.clear();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      //icon: Icon(Icons.person, color: Colors.black),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(50))),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_circle, color: Colors.black, size: 50),
            Text(_editingId == null ? "New Diary" : "Edit Diary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            TextField(
              controller: _feelingController,
              decoration: InputDecoration(
                labelText: 'How are you feeling today?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'What happened today?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              label: Text(_editingId == null ? "Add" : "Update", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () async {
                if (_feelingController.text.trim().isEmpty || _descController.text.trim().isEmpty) return;

                if (_editingId == null) {
                  await SQLHelper.insertEntry(_feelingController.text.trim(), _descController.text.trim());
                } else {
                  await SQLHelper.updateEntry(
                      _editingId!, _feelingController.text.trim(), _descController.text.trim());
                }
                Navigator.pop(context);
                _refreshEntries();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _deleteEntry(int id) async {
    await SQLHelper.deleteEntry(id);
    _refreshEntries();
  }

  @override
  void initState() {
    super.initState();
    _refreshEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF5FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/account'),
              
              child: Row(
                children: [
                  Icon(Icons.account_circle, color: Colors.black, size: 30),
                  SizedBox(width: 8),
                  Text('My Account', style: TextStyle(color: Colors.black, fontSize: 18)),
                ],
              ),
              //child: CircleAvatar(
              //  radius: 18,
                //backgroundImage: AssetImage('assets/profile.png'),
                //backgroundColor: Colors.grey.shade300,
              //),
            ),
            SizedBox(width: 48),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _entries.isEmpty
            ? Center(child: Text('No diary yet. Try add your story.', style: TextStyle(fontSize: 16)))
            : ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(entry['feeling'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry['description'], style: TextStyle(fontSize: 14)),
                            SizedBox(height: 6),
                            Text(entry['createdAt'], style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.deepPurple),
                            onPressed: () => _showEntryModal(entry: entry),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _deleteEntry(entry['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent.withOpacity(0.9),
        onPressed: () => _showEntryModal(),
        child: Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}