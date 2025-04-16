import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmora/models/contact_model.dart';

class ContactService {
  static const String _contactsKey = 'contacts_list';
  static List<Contact>? _cachedContacts;
  
  static Future<List<Contact>> getContacts() async {
    if (_cachedContacts != null) {
      return List.from(_cachedContacts!);
    }
    
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getStringList(_contactsKey);
    
    if (contactsJson == null || contactsJson.isEmpty) {
      _cachedContacts = [];
      return [];
    }
    
    try {
      _cachedContacts = contactsJson
          .map((json) => Contact.fromJson(jsonDecode(json)))
          .toList();
      return List.from(_cachedContacts!);
    } catch (e) {
      print('Error loading contacts: $e');
      _cachedContacts = [];
      return [];
    }
  }
  
  static Future<bool> saveContacts(List<Contact> contacts) async {
    _cachedContacts = List.from(contacts);
    
    final prefs = await SharedPreferences.getInstance();
    final contactsJsonList = contacts
        .map((contact) => jsonEncode(contact.toJson()))
        .toList();
    
    return await prefs.setStringList(_contactsKey, contactsJsonList);
  }
  
  static Future<void> addContact(Contact contact) async {
    final contacts = await getContacts();
    contacts.add(contact);
    await saveContacts(contacts);
  }
  
  static Future<void> updateContact(Contact updatedContact) async {
    final contacts = await getContacts();
    final index = contacts.indexWhere((c) => c.id == updatedContact.id);
    
    if (index != -1) {
      contacts[index] = updatedContact;
      await saveContacts(contacts);
    }
  }
  
  static Future<void> deleteContact(String id) async {
    final contacts = await getContacts();
    contacts.removeWhere((contact) => contact.id == id);
    await saveContacts(contacts);
  }
  
  static Future<List<Contact>> searchContacts(String query) async {
    final contacts = await getContacts();
    if (query.isEmpty) {
      return contacts;
    }
    
    final lowercaseQuery = query.toLowerCase();
    return contacts.where((contact) {
      return contact.name.toLowerCase().contains(lowercaseQuery) ||
             contact.phoneNumber.contains(query);
    }).toList();
  }
  
  // Method to import contacts from phone
  static Future<List<Contact>> importPhoneContacts() async {
    // Simulate importing contacts from phone
    // In a real app, we'd use a contacts plugin
    final mockPhoneContacts = [
      Contact(
        id: "phone_1",
        name: "John Smith",
        phoneNumber: "+1 234 567 8901",
        email: "john@example.com",
      ),
      Contact(
        id: "phone_2",
        name: "Jane Doe",
        phoneNumber: "+1 987 654 3210",
        email: "jane@example.com",
      ),
      Contact(
        id: "phone_3",
        name: "Robert Johnson",
        phoneNumber: "+250 788 123 456",
      ),
    ];
    
    // Add to existing contacts
    final currentContacts = await getContacts();
    final newContacts = [...currentContacts];
    
    for (final phoneContact in mockPhoneContacts) {
      if (!currentContacts.any((c) => c.phoneNumber == phoneContact.phoneNumber)) {
        newContacts.add(phoneContact);
      }
    }
    
    // Save combined list
    await saveContacts(newContacts);
    return newContacts;
  }

  // Method to make a call
  static Future<bool> makeCall(String phoneNumber) async {
    try {
      // In a real app, we would use url_launcher
      print('Making call to: $phoneNumber');
      return true;
    } catch (e) {
      print('Error making call: $e');
      return false;
    }
  }
}
