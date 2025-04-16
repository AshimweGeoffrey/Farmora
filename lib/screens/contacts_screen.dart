import 'dart:io';
import 'package:flutter/material.dart';
import 'package:farmora/models/contact_model.dart';
import 'package:farmora/services/contact_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];
  bool _isLoading = true;
  bool _isImporting = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final contacts = await ContactService.getContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading contacts: $e');
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Failed to load contacts');
    }
  }

  Future<void> _importPhoneContacts() async {
    setState(() {
      _isImporting = true;
    });
    
    try {
      final contacts = await ContactService.importPhoneContacts();
      setState(() {
        _contacts = contacts;
        _isImporting = false;
      });
      _showSnackBar('Contacts imported successfully');
    } catch (e) {
      print('Error importing contacts: $e');
      setState(() {
        _isImporting = false;
      });
      _showSnackBar('Failed to import contacts');
    }
  }

  Future<void> _callContact(String phoneNumber) async {
    try {
      final success = await ContactService.makeCall(phoneNumber);
      if (success) {
        _showSnackBar('Calling $phoneNumber...');
      } else {
        _showSnackBar('Failed to initiate call');
      }
    } catch (e) {
      _showSnackBar('Error making call: $e');
    }
  }

  Future<void> _deleteContact(String id) async {
    try {
      await ContactService.deleteContact(id);
      setState(() {
        _contacts.removeWhere((contact) => contact.id == id);
      });
      _showSnackBar('Contact deleted');
    } catch (e) {
      print('Error deleting contact: $e');
      _showSnackBar('Failed to delete contact');
    }
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<String?> _pickContactImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
      );
      
      if (image == null) return null;
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'contact_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(directory.path, fileName);
      
      final newFile = File(savedPath);
      await newFile.writeAsBytes(await image.readAsBytes());
      
      return savedPath;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  void _showAddEditContactDialog([Contact? contact]) {
    final isEditing = contact != null;
    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController = TextEditingController(text: contact?.phoneNumber ?? '');
    final emailController = TextEditingController(text: contact?.email ?? '');
    String? photoPath = contact?.photoPath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Contact' : 'Add New Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final imagePath = await _pickContactImage();
                    if (imagePath != null) {
                      setState(() {
                        photoPath = imagePath;
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColor,
                    backgroundImage: photoPath != null ? FileImage(File(photoPath!)) : null,
                    child: photoPath == null
                        ? Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email (Optional)',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                  _showSnackBar('Name and phone number are required');
                  return;
                }

                if (isEditing) {
                  final updatedContact = Contact(
                    id: contact!.id,
                    name: nameController.text,
                    phoneNumber: phoneController.text,
                    email: emailController.text.isEmpty ? null : emailController.text,
                    photoPath: photoPath,
                  );
                  
                  await ContactService.updateContact(updatedContact);
                  
                  setState(() {
                    final index = _contacts.indexWhere((c) => c.id == contact.id);
                    if (index != -1) {
                      _contacts[index] = updatedContact;
                    }
                  });
                } else {
                  final newContact = Contact(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    phoneNumber: phoneController.text,
                    email: emailController.text.isEmpty ? null : emailController.text,
                    photoPath: photoPath,
                  );
                  
                  await ContactService.addContact(newContact);
                  
                  setState(() {
                    _contacts.add(newContact);
                  });
                }
                
                Navigator.pop(context);
                _loadContacts();
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        actions: [
          _isImporting
              ? Container(
                  padding: EdgeInsets.all(10),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.sync),
                  tooltip: 'Import Phone Contacts',
                  onPressed: _importPhoneContacts,
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditContactDialog(),
        child: Icon(Icons.add),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Contacts',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadContacts();
                        },
                      ),
                    ),
                    onChanged: (value) async {
                      if (value.isNotEmpty) {
                        final results = await ContactService.searchContacts(value);
                        setState(() {
                          _contacts = results;
                        });
                      } else {
                        _loadContacts();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _contacts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.contacts,
                                size: 72,
                                color: Colors.grey.withOpacity(0.6),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No contacts found',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: Icon(Icons.sync),
                                label: Text('Import Contacts'),
                                onPressed: _importPhoneContacts,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _contacts.length,
                          itemBuilder: (context, index) {
                            final contact = _contacts[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  backgroundImage: contact.photoPath != null
                                      ? FileImage(File(contact.photoPath!))
                                      : null,
                                  child: contact.photoPath == null
                                      ? Text(
                                          contact.name[0].toUpperCase(),
                                          style: TextStyle(color: Colors.white),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  contact.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(contact.phoneNumber),
                                    if (contact.email != null)
                                      Text(
                                        contact.email!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green.withOpacity(0.1),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.call, color: Colors.green),
                                        onPressed: () => _callContact(contact.phoneNumber),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => _showAddEditContactDialog(contact),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _showDeleteConfirmationDialog(contact),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void _showDeleteConfirmationDialog(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteContact(contact.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
